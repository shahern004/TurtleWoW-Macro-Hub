# IWinEnhanced Repository Study: Implementation Patterns

> **OUTCOME:** This study, combined with the deep dive (`plans/iwin-solutions-to-port.md`), led us to adopt IWinEnhanced directly as our rotation addon. We now customize `warrior/rotation.lua` for Arms DPS optimization rather than building a separate addon.

**Repo:** [Profiler781/IWinEnhanced](https://github.com/Profiler781/IWinEnhanced) v2.1
**Date:** 2026-02-07

---

## 1. Architecture & Execution Model

**It's a full addon, not macro-based.** IWinEnhanced is a WoW addon (`.toc` file, `CreateFrame`, event registration) that exposes slash commands (`/idps`, `/icleave`, `/itank`, etc.) which the user binds to keys. Each keypress runs a complete priority evaluation from top to bottom.

### Entry Point & Init Flow
```
IWinEnhanced.lua          -- Creates IWin frame + tooltip, nothing else
core/data.lua             -- Shared lookup tables (taunts, roots, fears, blacklists, drinks)
warrior/data.lua          -- Rage cost table (IWin_RageCost), talent cost reductions
warrior/init.lua          -- IWin_CombatVar state table, IWin_Target cache table
warrior/condition.lua     -- Condition helpers (IsOverpowerAvailable, IsHighAP, stance math)
warrior/action.lua        -- One function per ability (IWin:Slam(), IWin:Execute(), etc.)
warrior/event.lua         -- Event handlers (dodge→overpower, block→revenge, slam cast tracking)
warrior/setup.lua         -- /iwin config command parser
core/condition.lua        -- Shared conditions (buff/debuff, cooldown, range, health, mana/rage)
core/action.lua           -- Shared actions (StartAttack, TargetEnemy, CancelBuff, UseItem)
core/rotation.lua         -- InitializeRotationCore() + /ihydrate
warrior/rotation.lua      -- The actual rotation definitions (/idps, /icleave, /itank, etc.)
```

### Execution Model: **Imperative function chain, not conditional evaluation**
Each slash command is a flat sequence of function calls. There is NO loop, NO priority queue, NO conditional chain evaluation. Instead:

```lua
function SlashCmdList.IDPSWARRIOR()
    IWin:InitializeRotation()    -- reset per-press state
    IWin:TargetEnemy()           -- ensure valid target
    IWin:BattleShoutRefreshOOC() -- top priority
    IWin:ChargePartySize()       -- gap closer
    ...
    IWin:Slam()                  -- mid priority
    ...
    IWin:HeroicStrike()          -- rage dump (low priority)
    IWin:StartAttack()           -- ensure auto-attack
end
```

**Each function self-gates:** Every ability function contains its own conditions (learned? off CD? enough rage? not during slam?) and either casts or returns silently. The first function to successfully cast sets `IWin_CombatVar["queueGCD"] = false`, which prevents all subsequent GCD abilities from casting on the same keypress.

### User Interaction
- **Keybind a macro** containing `/idps` (or `/icleave`, `/itank`, etc.)
- **Spam the key** — each press runs the full priority chain
- **Configure via `/iwin`** slash command (charge behavior, sunder priority, demo shout, rage prediction, etc.)
- **No UI** — all config is slash-command based, settings saved in `IWin_Settings` (SavedVariablesPerCharacter)

---

## 2. Core Logic & Priority System

### Priority Expression: Hardcoded call order
Priorities are expressed purely by **function call ordering** in `warrior/rotation.lua`. Higher priority = called earlier in the sequence. The `queueGCD` flag acts as a mutex — once one GCD ability fires, the rest are skipped.

### The queueGCD Pattern (Critical Design Pattern)
```lua
-- Every GCD ability follows this exact pattern:
function IWin:MortalStrike(queueTime)
    if IWin:IsSpellLearnt("Mortal Strike")
        and IWin_CombatVar["queueGCD"]              -- hasn't fired yet this press
        and IWin:GetCooldownRemaining("Mortal Strike") < queueTime  -- CD check
        and IWin:IsRageAvailable("Mortal Strike")    -- rage (with reservation)
        and not IWin_CombatVar["slamQueued"] then    -- not in slam window
            IWin_CombatVar["queueGCD"] = false       -- claim the GCD
            CastSpellByName("Mortal Strike")         -- cast via direct API
    end
end
```

### Cooldown Queuing
CD-gated abilities accept a `queueTime` parameter (typically `IWin_Settings["GCD"]` = 1.5s):
```lua
IWin:GetCooldownRemaining("Mortal Strike") < queueTime
```
This means "cast if the CD will be ready within 1.5s" — **pre-queuing** the ability. This is how they handle timing without Nampower's `QueueSpellByName`. They just call `CastSpellByName` slightly early and let the game engine handle the actual queue timing.

### How Slam Interleaving Works

**Slam is gated by `st_timer` (from SP_SwingTimer addon):**
```lua
function IWin:Slam()
    if IWin:IsSpellLearnt("Slam")
        and IWin_CombatVar["queueGCD"]
        and IWin:IsRageAvailable("Slam")
        and IWin:Is2HanderEquipped()
        and (
                not st_timer
                or st_timer > UnitAttackSpeed("player") * 0.5
            )
        and (
                not IWin:IsStanceActive("Battle Stance")
                or not IWin:IsSpellLearnt("Berserker Stance")
            ) then
                IWin_CombatVar["queueGCD"] = false
                CastSpellByName("Slam")
    end
end
```

**Key insight:** `st_timer > UnitAttackSpeed("player") * 0.5` means "only Slam if the swing timer is in the first half." This prevents clipping the next auto-attack. If `st_timer` doesn't exist (SP_SwingTimer not loaded), Slam fires freely.

**The `slamQueued` flag prevents other abilities during slam windows:**
Every GCD ability checks `not IWin_CombatVar["slamQueued"]`. The `SetSlamQueued()` function (currently commented out in rotations!) would set this when a slam cast + GCD would overlap the next swing.

**Slam casting tracking via events:**
```lua
-- warrior/event.lua
elseif event == "SPELLCAST_START" and arg1 == "Slam" then
    IWin_CombatVar["slamCasting"] = GetTime() + (arg2 / 1000)
    if st_timer and st_timer > UnitAttackSpeed("player") * 0.9 then
        IWin_CombatVar["slamGCDAllowed"] = IWin_CombatVar["slamCasting"] + 0.2
        IWin_CombatVar["slamClipAllowedMax"] = IWin_CombatVar["slamGCDAllowed"] + GCD
        IWin_CombatVar["slamClipAllowedMin"] = st_timer + GetTime()
    end
```

### Non-GCD Abilities (Heroic Strike, Cleave)
These DON'T check `queueGCD` because they replace the next auto-attack rather than consuming a GCD:
```lua
function IWin:HeroicStrike()
    if IWin:IsSpellLearnt("Heroic Strike") then
        if IWin:IsRageAvailable("Heroic Strike")
            or (UnitMana("player") > 75 and (not IsSpellLearnt("WW") or WW on CD)) then
                IWin_CombatVar["swingAttackQueued"] = true
                IWin_CombatVar["startAttackThrottle"] = GetTime() + 0.2
                CastSpellByName("Heroic Strike")
        end
    end
end
```

---

## 3. State Management & Decision-Making

### State Tracked (IWin_CombatVar)
| Variable | Purpose |
|----------|---------|
| `queueGCD` | Boolean mutex — prevents multiple GCD casts per keypress |
| `reservedRage` | Running sum of rage "reserved" for upcoming abilities |
| `reservedRageStance` | Which stance is reserved for (prevents double stance swaps) |
| `reservedRageStanceLast` | Timestamp of last stance swap (GCD-based cooldown) |
| `slamQueued` | Whether slam timing prevents other GCD abilities |
| `slamCasting` | Timestamp when current slam cast ends |
| `slamGCDAllowed` | When next GCD is safe after slam |
| `slamClipAllowedMax/Min` | Window where slam clipping is acceptable |
| `swingAttackQueued` | Whether HS/Cleave is queued (suppresses StartAttack) |
| `startAttackThrottle` | Prevents rapid StartAttack toggling |
| `overpowerAvailable` | Timestamp when overpower window expires |
| `revengeAvailable` | Timestamp when revenge window expires |
| `charge` | Timestamp of last charge (prevents intercept during charge animation) |

### State Reading: Hybrid (API + events + external addon)
- **Cooldowns:** `GetSpellCooldown()` via spellbook ID lookup (vanilla API)
- **Buffs/Debuffs:** `CleveRoids.libdebuff:UnitDebuff()` — borrows CleveroidMacros' debuff library for duration tracking
- **Overpower/Revenge windows:** Combat log text parsing via `CHAT_MSG_COMBAT_*` events (looking for "dodge", "parry", "blocked" strings)
- **Swing timer:** External `st_timer` global from SP_SwingTimer addon
- **GCD remaining:** `GetCastInfo().gcdRemainingMs` from Nampower
- **Range:** `IsSpellInRange()` from Nampower, with `CheckInteractDistance()` fallback

### Target Switching
On `PLAYER_TARGET_CHANGED`, the addon recaches target properties:
```lua
IWin:SetTrainingDummy()
IWin:SetElite()
IWin:SetBlacklistFear()
IWin:SetBlacklistAOEDebuff()
IWin:SetBlacklistAOEDamage()
IWin:SetBlacklistKick()
IWin:SetWhitelistCharge()
```
These are stored in `IWin_Target` and read via `IWin:IsElite()`, `IWin:IsBlacklistKick()`, etc. This avoids recalculating every keypress.

### The Rage Reservation System (Major Innovation)
The most sophisticated part of IWinEnhanced. After each ability function, a `SetReservedRage` call adds that ability's rage cost to `IWin_CombatVar["reservedRage"]`. This reserved rage is then subtracted from available rage for lower-priority abilities:

```lua
-- In /idps rotation:
IWin:Slam()
IWin:SetReservedRageSlam()              -- reserves 15 rage for slam
IWin:MortalStrike(IWin_Settings["GCD"])
IWin:SetReservedRage("Mortal Strike", "cooldown")  -- reserves 30 rage for MS
IWin:Whirlwind(0)
IWin:SetReservedRage("Whirlwind", "cooldown")      -- reserves 25 rage for WW
-- By this point, HeroicStrike needs 15+30+25+20 = 90 rage minimum to fire
```

The reservation is **time-aware**: `GetRageToReserve()` predicts future rage gain and reduces reservation proportionally:
```lua
local timeToReserveRage = max(0, spellTriggerTime - rageTimeToReserveBuffer - reservedRageTime)
return max(0, rageCost - ragePerSecondPrediction * timeToReserveRage)
```
If MS is 4 seconds from coming off CD and rage gain is 10/sec, only reserve `max(0, 30 - 10*2.5) = 5` rage instead of 30.

---

## 4. Dependency Usage

### Actually Used
| Dependency | What's Used | How Tightly Coupled |
|-----------|------------|-------------------|
| **SuperCleveRoidMacros** | `CleveRoids.libdebuff` for buff/debuff duration tracking | **Moderate** — only uses the debuff library, not macro syntax at all |
| **SuperWoW** | `SpellInfo()`, `SetAutoloot` (detection only), `UnitXP("behind")` | **Light** — only a few utility functions |
| **Nampower** | `GetCastInfo()` for GCD remaining, `IsSpellInRange()` | **Light** — no `QueueSpellByName`, no custom events |
| **UnitXP_SP3** | `UnitXP("behind", u1, u2)` for behind check | **Minimal** — single function |
| **SP_SwingTimer** | `st_timer` global for slam timing | **Optional** — gracefully degrades if not present |

### NOT Used (Surprising)
- **No `QueueSpellByName`** — uses direct `CastSpellByName` with pre-queue timing
- **No Nampower custom events** — uses vanilla combat log text parsing for dodge/parry/block detection
- **No CleveroidMacros `/cast` syntax** — entirely Lua-based, no conditional macros at all
- **No `UnitXP("distanceBetween")`** — uses `IsSpellInRange` and `CheckInteractDistance` instead
- **No file I/O** — no ImportFile/ExportFile

### Unlisted Dependencies
- **SP_SwingTimer** — provides `st_timer` global for slam timing
- **DoiteAura** — optional, provides `DoitePlayerAuras.GetHiddenBuffRemaining()`
- **TimeToKill** — optional, provides `TimeToKill.GetTTK()` for time-to-die estimation
- **MonkeySpeed** — optional, provides movement detection via `MonkeySpeed.m_fSpeed`

---

## 5. Anti-Patterns & Defensive Code

### Workarounds
1. **StartAttack toggle prevention:** `startAttackThrottle` adds 0.2s cooldown after queuing HS/Cleave, because `UseAction` on the Attack action toggles it off if already on.

2. **Stance swap rage tracking:** `reservedRageStanceLast` timestamps prevent double-stance-swapping within a GCD window — if you just swapped stances, don't immediately swap again.

3. **Slam clip window calculation:** The commented-out `slamClipAllowed` system suggests the author experimented with allowing slam casts that would clip auto-attacks in specific timing windows, but disabled it.

4. **Buff ID wraparound:** `buffIndex = (buffIndex < -1) and (buffIndex + 65536) or buffIndex` — handles negative spell IDs from `GetPlayerBuffID()`.

5. **HS/Cleave rage buffer:** `IWin:IsRageAvailable` adds +20 extra rage cost for HS/Cleave/Maul because "replacing auto attack will prevent getting rage from next swing."

### Code Smells
1. **Commented-out `SetSlamQueued()` calls** in all rotations suggest slam timing is not fully working or was regressed.

2. **`MasterStrikeWindfury` casts Hamstring instead of Master Strike** — likely a copy-paste bug:
   ```lua
   function IWin:MasterStrikeWindfury()
       ...  -- checks for Master Strike
       CastSpellByName("Hamstring")  -- bug?
   end
   ```

3. **Significant code duplication** — `ChargePartySize`, `InterceptPartySize`, `IntervenePartySize` are nearly identical. No abstraction for party-size gating.

4. **Combat log text parsing is fragile** — `string.find(arg1,"dodge")` will break if the game locale changes or if the combat log format changes.

5. **No error handling** — if `GetCooldownRemaining` returns `false` (spell not found), calling functions will error.

---

## 6. Transferable Ideas

### Strongest Design Decisions
1. **Rage Reservation System** — The time-aware rage reservation that predicts future rage income is elegant. It prevents rage-starving high-priority abilities by budgeting rage across the full rotation.

2. **queueGCD mutex** — Simple, effective. One boolean prevents all double-casting without complex state machines.

3. **Target property caching** — Computing elite/blacklist/boss status once on target change instead of every keypress is smart for performance.

4. **Self-gating functions** — Each ability is a self-contained unit with all its conditions. Makes reordering priorities trivial (just move the function call).

### Paradigm-Independent Patterns (Useful Either Way)
| Pattern | How to Apply to Macros | How to Apply to Addon |
|---------|----------------------|---------------------|
| Rage reservation | Use `[mypower:>N]` where N = sum of higher-priority costs | Port directly |
| Target caching | Already done by CleveroidMacros multiscan | Port directly |
| queueGCD mutex | `/firstaction` provides this natively | Port directly |
| Slam swing timer gating | `[noslamclip]` conditional does this | Port via `st_timer` check |
| Pre-queue via CD remaining < GCD | `[cooldown:Spell<1.5]` does this natively | Port directly |

### If Adopting Addon-Based Approach: Migration Path
1. Install IWinEnhanced as-is for immediate functionality
2. Fork and modify `warrior/rotation.lua` to match your priorities
3. Customize `warrior/action.lua` for Arms-specific behaviors
4. Main effort: understanding and tuning the rage reservation parameters via `/iwin ragegain` and `/iwin ragebuffer`

**Pros of going addon:** Full Lua control, rage reservation system, slam timing with swing timer integration, no 255-char limit, easier debugging.
**Cons of going addon:** Heavier dependency (must install addon), less portable, harder to share single macros.

### If Staying Macro-Based: Techniques to Borrow
1. **The CD pre-queue pattern** — your current `[cooldown:X<1]` approach IS what IWinEnhanced does, confirming it's correct.

2. **Slam window = first half of swing timer** — `st_timer > attackSpeed * 0.5` translates to using `[noslamclip]` (which does the same check internally).

3. **HS only when WW is on cooldown** — IWinEnhanced explicitly checks `GetCooldownRemaining("Whirlwind") > 0` before allowing HS. In macro form:
   ```
   /cast [cooldown:Whirlwind>0,mypower:>75] Heroic Strike
   ```

4. **The commented-out `SetSlamQueued` suggests even IWinEnhanced hasn't fully solved slam interleaving** — your problems with it in macro form may be fundamental to the mechanic, not a macro-specific issue.

5. **Rage reservation** is harder in macros but approximatable:
   ```
   -- Instead of exact reservation, use higher rage thresholds for low-priority abilities:
   /cast [mypower:>30,cooldown:Mortal Strike<1.5] Mortal Strike
   /cast [mypower:>55,cooldown:Whirlwind<1.5] Whirlwind   -- 30(MS) + 25(WW)
   /cast [mypower:>70] Heroic Strike                       -- 30+25+15(Slam)
   ```
