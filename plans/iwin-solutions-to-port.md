# IWinEnhanced: Code Patterns & Optimization Reference

> **Generated:** 2026-02-07 | **Updated:** 2026-02-07 | **Source:** Deep dive into IWinEnhanced v2.1 source code
> **Purpose:** Reference document for understanding IWinEnhanced's internal patterns. Originally written to port solutions into TurtleRotation, now serves as a **code reference for optimizing IWinEnhanced directly** — understanding how each system works so we can tune `warrior/rotation.lua` for maximum Arms DPS and identify performance improvement opportunities.
>
> **Strategy pivot:** We are now using IWinEnhanced as our rotation addon, not building TurtleRotation. The "Adaptation Plan" sections below now describe optimization opportunities within IWinEnhanced itself.

---

## Problem 1: Debuff/Buff Stack Detection

### How IWinEnhanced Solves It

**Key function:** `IWin:GetBuffStack(unit, spell, owner)` — `core/condition.lua:79-109`

Uses **`IWin.libdebuff:UnitDebuff()`** (CleveRoids' debuff library wrapper), NOT vanilla `UnitDebuff()`. The wrapper returns 8 values: `(effect, _, texture, stacks, dtype, duration, timeleft, caster)` — position 4 is **stacks**.

```lua
-- Three-stage cascade:
-- Stage 1: Debuff scan (16 slots) via libdebuff
for index = 1, 16 do
    local effect, _, texture, stacks, dtype, duration, timeleft, caster = IWin.libdebuff:UnitDebuff(unit, index)
    if not effect then break end
    if effect == spell and ((not owner) or (caster == owner)) then
        return stacks
    end
end
-- Stage 2: Player buff scan (DoitePlayerAuras or GetPlayerBuffID)
-- Stage 3: Debuff overflow scan (64 buff slots for overflow debuffs)
```

**Sunder gate:** `not IWin:IsBuffStack("target", "Sunder Armor", 5)` — stops at 5 stacks.

**Duration checks:** `IWin:GetBuffRemaining(unit, spell)` uses same libdebuff cascade, returns `timeleft` in seconds. Battle Shout refresh: `GetBuffRemaining("player", "Battle Shout") < 9`.

### Adaptation Plan for TurtleRotation

1. **Replace manual sunder counter** with `CleveRoids.libdebuff:UnitDebuff()` call
2. **Add helper functions** to `abilities.lua` or a new `conditions.lua`:
   - `TR:GetDebuffStacks(unit, spell)` — iterate debuffs via libdebuff, return stacks
   - `TR:GetBuffRemaining(unit, spell)` — iterate via libdebuff, return timeleft
   - `TR:IsDebuffAtStacks(unit, spell, count)` — boolean wrapper
3. **Gate Sunder:** `if TR:GetDebuffStacks("target", "Sunder Armor") < 5 then`
4. **Gate Battle Shout:** `if TR:GetBuffRemaining("player", "Battle Shout") < 9 then`

### Complexity: Simple port
CleveRoids is already a dependency. Just need to access `CleveRoids.libdebuff` (verify the global name — may be `CleveRoidAddon.libdebuff` or similar).

---

## Problem 2: Auto-Attack Toggle Prevention

### How IWinEnhanced Solves It

**Key function:** `IWin:StartAttack()` — `core/action.lua:32-48`

```lua
function IWin:StartAttack()
    if IWin_CombatVar["swingAttackQueued"]
        or IWin_CombatVar["startAttackThrottle"] and IWin_CombatVar["startAttackThrottle"] > GetTime()
    then return end

    local attackActionFound = false
    for action = 1, 172 do
        if IsAttackAction(action) then
            attackActionFound = true
            if not IsCurrentAction(action) then  -- ← KEY: only activate if not already active
                UseAction(action)
            end
        end
    end
    if not attackActionFound and not PlayerFrame.inCombat then
        AttackTarget()  -- fallback only when OOC and no bar slot
    end
end
```

**Pattern:** Scan all 172 action bar slots → find Attack action → check `IsCurrentAction()` → only call `UseAction()` if not already active. Never calls `AttackTarget()` in combat.

**Throttle:** After HS/Cleave cast, sets `startAttackThrottle = GetTime() + 0.2` to prevent StartAttack from firing for 200ms.

### Adaptation Plan for TurtleRotation

1. **Replace `AttackTarget()` calls** with action bar scanning pattern:
   ```lua
   function TR:StartAttack()
       for action = 1, 172 do
           if IsAttackAction(action) then
               if not IsCurrentAction(action) then
                   UseAction(action)
               end
               return
           end
       end
       -- Fallback: only OOC
       if not PlayerFrame.inCombat then AttackTarget() end
   end
   ```
2. **Add startAttackThrottle** — 0.2s cooldown after HS/Cleave
3. **Remove `autoAttacking` flag** — no longer needed

### Complexity: Simple port
Direct copy of the pattern. `IsAttackAction()` and `IsCurrentAction()` are vanilla API.

---

## Problem 3: Heroic Strike / On-Next-Swing Toggle Prevention

### How IWinEnhanced Solves It

**Key insight: They DON'T track whether HS is queued.** Instead they rely on **rotation cycle discipline**.

**Pattern** (`warrior/action.lua:425-442`):
```lua
function IWin:HeroicStrike()
    if IWin:IsSpellLearnt("Heroic Strike") then
        if IWin:IsRageAvailable("Heroic Strike")
            or (UnitMana("player") > 75
                and (not IWin:IsSpellLearnt("Whirlwind")
                     or IWin:GetCooldownRemaining("Whirlwind") > 0))
        then
            IWin_CombatVar["swingAttackQueued"] = true
            IWin_CombatVar["startAttackThrottle"] = GetTime() + 0.2
            CastSpellByName("Heroic Strike")
        end
    end
end
```

**How they avoid the toggle-off:**
1. `swingAttackQueued` is **reset to false at the start of every rotation cycle** (`InitializeRotation()`)
2. HS is called **exactly once per cycle** — it's in the rotation sequence, not in a loop
3. HS does NOT check `queueGCD` — it's a swing replacement, not a GCD ability
4. The flag is **ephemeral** (lives within one keypress cycle), not persistent across swings

**Why this works:** Because `InitializeRotation()` resets `swingAttackQueued = false` every keypress, and HS is called once per cycle, it can never be called twice in the same cycle. The toggle-off only happens when you call `CastSpellByName("Heroic Strike")` when it's already queued — but since the flag resets each cycle, it fires fresh each time.

### Adaptation Plan for TurtleRotation

1. **Adopt per-cycle reset pattern:**
   - At start of each rotation tick: `swingAttackQueued = false`
   - HS function sets it to `true` when it fires
   - StartAttack checks it to avoid toggling
2. **Remove persistent HS tracking** — don't try to track across swing completions
3. **HS rage gating:** Only fire if `currentRage >= rageCost + reservedRage` OR `currentRage > 75 and WW on CD`
4. **Set startAttackThrottle** when HS fires (prevents StartAttack toggle for 0.2s)

### Complexity: Medium — requires restructuring rotation to be per-cycle with resets

---

## Problem 4: Spell ID Resolution

### How IWinEnhanced Solves It

**Key finding: They NEVER use spell IDs. Everything is spell-name-based.**

**Cooldown check** (`core/condition.lua:141-150`):
```lua
function IWin:GetCooldownRemaining(spell)
    local spellID = IWin:GetSpellSpellbookID(spell)  -- name → spellbook INDEX
    if not spellID then return false end
    local start, duration = GetSpellCooldown(spellID, "BOOKTYPE_SPELL")
    if start ~= 0 and duration ~= IWin_Settings["GCD"] then
        return duration - (GetTime() - start)
    else
        return 0
    end
end
```

**Spellbook scan** (`core/condition.lua:128-139`):
```lua
function IWin:GetSpellSpellbookID(spell, rank)
    local spellID = 1
    while true do
        local spellName, spellRank = GetSpellName(spellID, "BOOKTYPE_SPELL")
        if not spellName then break end
        if spellName == spell and ((not rank) or spellRank == rank)
            and (rank ~= nil or spellName ~= GetSpellName(spellID + 1, "BOOKTYPE_SPELL")) then
            return spellID  -- returns SPELLBOOK INDEX, not DBC spell ID
        end
        spellID = spellID + 1
    end
    return nil
end
```

**Rage costs** keyed by spell name (`warrior/data.lua:37-68`):
```lua
IWin_RageCost = {
    ["Mortal Strike"] = 30,
    ["Slam"] = 15,
    ["Execute"] = 15 - IWin:GetExecuteCostReduction(),  -- talent-aware
    ...
}
```

### Adaptation Plan for TurtleRotation

1. **Remove hardcoded spell IDs from config.lua** — they're not needed
2. **Implement `TR:GetSpellbookIndex(spellName)`** — runtime scan via `GetSpellName()`
3. **Implement `TR:GetCooldownRemaining(spellName)`** — uses spellbook index + `GetSpellCooldown()`
4. **Key rage cost table by spell name**, not spell ID
5. **All casting via `CastSpellByName("Spell Name")`** — which is what we already do
6. **Filter out GCD** in cooldown check: `duration ~= 1.5` means it's GCD, not a real cooldown

### Complexity: Medium — need to rework config.lua and all cooldown checks

---

## Problem 5: Slam Swing Timer Integration

### How IWinEnhanced Solves It

**Slam gate** (`warrior/action.lua:912-934`):
```lua
function IWin:Slam()
    if IWin:IsSpellLearnt("Slam")
        and IWin_CombatVar["queueGCD"]
        and IWin:IsRageAvailable("Slam")
        and IWin:Is2HanderEquipped()
        and (
            not st_timer
            or st_timer > UnitAttackSpeed("player") * 0.5  -- ← KEY: first half of swing
        )
        and (not IWin:IsStanceActive("Battle Stance")
             or not IWin:IsSpellLearnt("Berserker Stance"))
    then
        IWin_CombatVar["queueGCD"] = false
        CastSpellByName("Slam")
    end
end
```

**Slam window rule:** `st_timer > attackSpeed * 0.5` = only cast Slam in the **first half** of the swing timer. This prevents clipping the auto-attack.

**Post-cast tracking** (`warrior/event.lua:41-47`):
```lua
elseif event == "SPELLCAST_START" and arg1 == "Slam" then
    IWin_CombatVar["slamCasting"] = GetTime() + (arg2 / 1000)  -- cast end time
    if st_timer and st_timer > UnitAttackSpeed("player") * 0.9 then
        IWin_CombatVar["slamGCDAllowed"] = IWin_CombatVar["slamCasting"] + 0.2
        IWin_CombatVar["slamClipAllowedMax"] = IWin_CombatVar["slamGCDAllowed"] + GCD
        IWin_CombatVar["slamClipAllowedMin"] = st_timer + GetTime()
    end
end
```

**SetSlamQueued** (`warrior/action.lua:942-953`) — blocks other abilities during slam:
```lua
function IWin:SetSlamQueued()
    if not st_timer then return end
    if IWin:IsSpellLearnt("Slam") and IWin:Is2HanderEquipped() then
        local nextSwing = st_timer + UnitAttackSpeed("player")
        local nextSlam = IWin_Settings["GCD"] + IWin:GetCastTime("Slam")
        if nextSlam > nextSwing
            and IWin_CombatVar["slamGCDAllowed"] < GetTime() then
            IWin_CombatVar["slamQueued"] = true
        end
    end
end
```

**All GCD abilities check:** `and not IWin_CombatVar["slamQueued"]` — prevents casting during slam window.

### Adaptation Plan for TurtleRotation

1. **Slam pre-gate:** Check `st_timer > UnitAttackSpeed("player") * 0.5` before casting
2. **Graceful degradation:** If `st_timer` is nil (no SP_SwingTimer), allow all Slams (same as IWinEnhanced)
3. **Hook SPELLCAST_START** for "Slam" → track `slamCasting` end time
4. **Add slamGCDAllowed** buffer (0.2s after cast end) to prevent immediate re-queue
5. **Gate all GCD abilities** on `not slamQueued` during slam window
6. **Require 2H weapon** check before allowing Slam

### Complexity: Medium — needs event handler for SPELLCAST_START and state management

---

## Problem 6: Rage Reservation Strategy

### How IWinEnhanced Solves It

**Time-aware prediction** (`core/condition.lua:324-347`):
```lua
function IWin:GetRageToReserve(spell, trigger, unit)
    local rageCost = IWin_RageCost[spell]
    -- Swing replacement tax: HS/Cleave cost +20 (lost auto-attack rage)
    if spell == "Heroic Strike" or spell == "Cleave" or spell == "Maul" then
        rageCost = rageCost + 20
    end
    if trigger == "nocooldown" then return rageCost end

    local spellTriggerTime = 0
    if trigger == "cooldown" then
        spellTriggerTime = IWin:GetCooldownRemaining(spell) or 0
    elseif trigger == "buff" then
        spellTriggerTime = IWin:GetBuffRemaining(unit, spell) or 0
    end

    local reservedRageTime = 0
    if IWin_Settings["ragePerSecondPrediction"] > 0 then
        reservedRageTime = IWin_CombatVar["reservedRage"] / IWin_Settings["ragePerSecondPrediction"]
    end
    local timeToReserveRage = math.max(0, spellTriggerTime - IWin_Settings["rageTimeToReserveBuffer"] - reservedRageTime)
    return math.max(0, rageCost - IWin_Settings["ragePerSecondPrediction"] * timeToReserveRage)
end
```

**Rage check** (`core/condition.lua:311-318`):
```lua
function IWin:IsRageAvailable(spell)
    local rageRequired = IWin_RageCost[spell] + IWin_CombatVar["reservedRage"]
    if spell == "Heroic Strike" or spell == "Cleave" or spell == "Maul" then
        rageRequired = rageRequired + 20  -- swing replacement tax
    end
    return UnitMana("player") >= rageRequired or IWin:IsBuffActive("player", "Clearcasting")
end
```

**Per-cycle pattern:**
1. `InitializeRotation()` resets `reservedRage = 0`
2. Each ability call is followed by `SetReservedRage("Spell", "trigger")`
3. Lower-priority abilities see accumulated reservation and require more rage
4. HS (last in chain) only fires if `currentRage >= own cost + ALL reserved`

**Settings:**
- `ragePerSecondPrediction` = 10 (default) — estimated rage gain rate
- `rageTimeToReserveBuffer` = 1.5 (default) — how early to start reserving
- Configurable via `/iwin ragegain N` and `/iwin ragebuffer N`

**Example:** MS has 4s cooldown, rage gain = 10/sec, buffer = 1.5s:
- `timeToReserveRage = max(0, 4 - 1.5 - 0) = 2.5`
- `reservation = max(0, 30 - 10 * 2.5) = 5` (only reserve 5, will earn the rest)

### Adaptation Plan for TurtleRotation

1. **Add settings:** `ragePerSecondPrediction` (default 10), `rageTimeToReserveBuffer` (default 1.5)
2. **Implement `TR:GetRageToReserve(spell, trigger)`** — port the time-aware formula
3. **Implement `TR:IsRageAvailable(spell)`** — checks `rage >= cost + reservedRage`
4. **Add +20 swing tax** for HS/Cleave
5. **Reset `reservedRage = 0` at start of each rotation cycle**
6. **Interleave `SetReservedRage()` calls** after each ability in the rotation definition
7. **Rage cost table** keyed by spell name with talent adjustments

### Complexity: Medium-High — most complex system to port, but well-documented pattern

---

## Summary: Optimization Opportunities Within IWinEnhanced

Now that we're working within IWinEnhanced directly, these patterns become **areas to understand and tune** rather than features to port:

| # | System | Where in IWinEnhanced | Optimization Opportunity |
|---|--------|----------------------|--------------------------|
| 1 | Debuff Stack Detection | `core/condition.lua:79-109` | Already works. Tune Sunder priority thresholds in rotation.lua |
| 2 | Auto-Attack Toggle | `core/action.lua:32-48` | Already solved. No changes needed |
| 3 | HS Toggle Prevention | Per-cycle reset in `warrior/action.lua` | Tune HS rage threshold and WW-on-CD gating for Arms |
| 4 | Spell ID Resolution | `core/condition.lua:128-150` | Already spell-name-based. No changes needed |
| 5 | Slam Swing Timer | `warrior/action.lua:912-953` | **Key tuning area**: slam window ratio (0.5) and `SetSlamQueued` (currently commented out in rotations!) |
| 6 | Rage Reservation | `core/condition.lua:311-347` | **Key tuning area**: `/iwin ragegain` and `/iwin ragebuffer` settings for Arms DPS |

### DPS Optimization Focus Areas

1. **`warrior/rotation.lua`** — Reorder the `/idps` priority chain for Arms (MS > Slam > WW > HS instead of default)
2. **Rage reservation tuning** — Adjust `ragePerSecondPrediction` and `rageTimeToReserveBuffer` via `/iwin` for your gear level
3. **Slam swing ratio** — The 0.5 ratio is conservative; test if 0.4 or 0.6 yields better DPS
4. **Re-enable `SetSlamQueued()`** — Currently commented out in rotations; may improve slam interleaving
5. **HS threshold tuning** — IWinEnhanced uses 75 rage OR WW-on-CD; Arms may want different thresholds
6. **Sunder priority placement** — Move Sunder higher or lower in chain depending on target type (elite vs trash)
7. **Fix `MasterStrikeWindfury` bug** — Casts Hamstring instead of Master Strike (copy-paste bug noted in study)
