# IWinEnhanced Code Review Rules

> 17 rule categories for auditing warrior rotation code in IWinEnhanced.
> Read this before reviewing `warrior/rotation.lua` or `warrior/action.lua`.
> Cross-reference with `warrior-rotations.md` for expected ability priorities.

---

## How to Use This Document

1. **For each rotation** (`/idps`, `/icleave`, `/itank`, `/ihodor`): walk through rules 1–17
2. **For each ability function** in `action.lua`: check rules 1, 7, 8, 12, 13, 17
3. **Severity levels:** CRITICAL (breaks rotation), HIGH (significant DPS/TPS loss), MEDIUM (suboptimal), LOW (style/maintainability)

---

## Rule 1: Stance-Gating

**Description:** Abilities that require a specific stance should not appear in rotation chains where that stance is unavailable, unless a stance-dance is coded.

**Detection Pattern:**
- `Revenge()` or `SetReservedRageRevenge()` in a rotation that doesn't ensure Defensive Stance
- `Overpower()` in a rotation that doesn't ensure Battle Stance
- `Whirlwind()` in a rotation that doesn't ensure Berserker Stance
- `Execute()` without a stance-swap to Battle/Berserker (it can't fire from Defensive)
- Check: does the ability function itself handle the stance swap? (e.g., `ExecuteDefensiveTactics()` swaps internally — OK)

**Severity:** CRITICAL — ability silently fails, wastes position in chain

**Example (fixed):** `Revenge()` + `SetReservedRageRevenge()` were in `/itank` without checking stance. `SetReservedRageRevenge()` now gates on `IsTanking() and IsStanceActive("Defensive Stance")` (action.lua:851-854).

---

## Rule 2: Rage Reservation Leaks

**Description:** `SetReservedRage()` calls inflate `reservedRage`, starving later abilities. A reservation for an ability that can never fire in the current context wastes rage budget.

**Detection Pattern:**
- `SetReservedRage("X", ...)` appears in a rotation, but `X()` can never fire due to:
  - Wrong stance (see Rule 1)
  - Config disabled (e.g., `dtbattle` is "off" but Battle Stance abilities still reserve)
  - Spec mismatch (e.g., BT reservation when player has no BT talent)
  - Equipment mismatch (e.g., Shield Slam reservation without shield)
- Look for `SetReservedRage` without matching conditions from the ability function

**Severity:** HIGH — phantom reservations starve real abilities of rage

**Example (fixed):** `/ihodor` reserved rage for BT and Revenge even when DT Prot config disabled those abilities. Removing the reservations freed ~35 rage for Sunder/Cleave.

---

## Rule 3: GCD Ordering — On-GCD Below Off-GCD

**Description:** Off-GCD abilities (HS, Cleave, ShieldBlock, Bloodrage, StartAttack) don't consume the GCD. If an on-GCD ability (BattleShout, Sunder) appears BELOW an off-GCD ability in the chain, it effectively gets demoted because the off-GCD ability's position doesn't "cost" a slot.

However, the real issue is the reverse: an on-GCD ability placed too LOW in the chain gets starved because off-GCD abilities above it always fire first. The fix is ensuring important on-GCD abilities appear HIGH in the chain, above filler.

**Detection Pattern:**
- `BattleShout()` or `BattleShoutRefresh()` appearing below `HeroicStrike()`/`HeroicStrikeTank()`/`CleaveAOE()` in a tank rotation (BShout is on-GCD, HS is off-GCD — but BShout should still be above filler Sunder)
- Critical on-GCD abilities (ShieldSlam, Revenge, Sunder) appearing below non-essential off-GCD abilities

**Severity:** HIGH — misplacement can delay threat-critical abilities by full GCD cycles

**Example (fixed):** In `/itank`, `BattleShoutRefresh()` (line 133) was below `HeroicStrikeTank()` (line 135). Since HS is off-GCD, BShout only fires when GCD is free — but BShout was also below Revenge/BT which is correct for tank priority.

---

## Rule 4: Dead Code / Wrong Spec

**Description:** Abilities that the current spec cannot use should not appear in the rotation chain. They waste evaluation time and (worse) can reserve rage.

**Detection Pattern:**
- `Bloodthirst()` in a rotation targeting Arms or DT Prot spec (no BT talent)
- `Revenge()` in a DPS rotation (no Defensive Stance use)
- `SlamThreat()` in a DT Prot rotation (Slam Rank 5 unlikely with Prot talents)
- `Whirlwind()` in a DT Prot rotation (1H WW does negligible damage)
- Any ability gated by `IsSpellLearnt()` that the target spec will never have

**Note:** Multi-spec rotations (like `/itank` supporting both Furyprot and DT Prot) intentionally include abilities from multiple specs, gated by `IsSpellLearnt()`. This is a design choice, NOT dead code. Only flag abilities that NO tank spec would use.

**Severity:** MEDIUM (wasted eval) to HIGH (if reserving rage)

**Example (fixed):** `/ihodor` included `Bloodthirst()`, `Revenge()`, and `SlamThreat()` with their reservations. For DT Prot with dtbattle/dtdefensive/dtberserker on, these never fired but inflated reservedRage by ~40.

---

## Rule 5: Priority Ordering

**Description:** The position of an ability in `rotation.lua` determines its priority. Compare against `warrior-rotations.md` for the expected priority.

**Detection Pattern:**
- Cross-reference each rotation's ability order against the guide:
  - `/idps`: Fury DW ST (lines 20-29 of warrior-rotations.md) or Arms ST (lines 79-97)
  - `/icleave`: Fury DW MT (lines 31-40) or Arms MT (lines 99-111)
  - `/itank`: Furyprot ST (lines 115-125) or DT Prot Def Stance (lines 144-153)
  - `/ihodor`: Furyprot MT (lines 126-137) or DT Prot AOE (line 176)
- Flag abilities that are >5 positions away from their guide priority
- Special attention: primary damage dealers (MS, BT, ShieldSlam) should never be below filler

**Severity:** HIGH — wrong priority directly reduces DPS/TPS

**Example (open):** `MortalStrike()` is at position 30 in `/idps` (rotation.lua:30). For Arms spec, MS should be priority ~2-3 (after Sunder). This means MS fires AFTER BT, Execute, Slam, Shield Slam — all of which an Arms warrior may not even have.

---

## Rule 6: Config Awareness

**Description:** IWinEnhanced settings (`/iwin dtbattle`, `/iwin dtdefensive`, `/iwin dtberserker`, `/iwin sunder`, `/iwin demo`) change which abilities are available. Rotations should respect these.

**Detection Pattern:**
- DT stance config (`dtbattle`/`dtdefensive`/`dtberserker`) set to "on" enables stance dancing. Abilities in non-Defensive stances only work when the corresponding DT config is active.
- `ExecuteDefensiveTactics()` gates on `IsDefensiveTacticsActive()` — correct
- `OverpowerDefensiveTactics()` gates on `IsDefensiveTacticsStanceAvailable("Battle Stance")` — correct
- Check: does every DT-variant ability check the DT config?
- Check: does `sunder` setting gate sunder variants correctly? (`SunderArmorDPS` checks `sunder ~= "off"`, `SunderArmorElite` checks `sunder == "high"`)

**Severity:** MEDIUM — wrong config awareness means abilities fire (or don't fire) unexpectedly

**Example:** `DemoralizingShout()` correctly checks `IWin_Settings["demo"] == "on"` (action.lua:241). Good pattern to follow.

---

## Rule 7: Swing Tax

**Description:** `IsRageAvailable()` adds +20 rage to HS/Cleave costs (the "swing replacement tax" — when HS/Cleave replaces a white hit, you lose ~20 rage from the missed swing). Tank variants should bypass this tax because incoming damage provides rage that replaces the lost swing rage.

**Detection Pattern:**
- In tank rotations (`/itank`, `/ihodor`): HS should use `HeroicStrikeTank()` (bypasses tax), NOT `HeroicStrike()` (adds tax)
- In tank rotations: Cleave should use `CleaveAOE()` (bypasses tax), NOT `Cleave()` (adds tax)
- Check: `HeroicStrikeTank()` uses `IWin_RageCost["Heroic Strike"] + reservedRage` (action.lua:465) — no +20
- Check: `HeroicStrike()` uses `IsRageAvailable("Heroic Strike")` (action.lua:444) — includes +20

**Severity:** HIGH — +20 tax means HS needs 35+ rage instead of 15+reservedRage, dramatically reducing tank HS uptime

**Example (fixed):** `/itank` used `HeroicStrike()` (with tax). Changed to `HeroicStrikeTank()` (rotation.lua:135).

---

## Rule 8: Ability Constraints

**Description:** Each ability has constraints beyond rage: cooldowns, procs, equipment, stance, combat state. The ability function must check ALL relevant constraints.

**Detection Pattern:**
- `Revenge()`: requires proc (IsRevengeAvailable), Defensive Stance, shield equipped (implicit)
- `Overpower()`: requires proc (IsOverpowerAvailable), Battle Stance (or stance dance)
- `ShieldSlam()`: requires shield equipped (IsShieldEquipped), cooldown
- `ShieldBlock()`: requires shield, Defensive Stance, not already active
- `Execute()`: requires target <20% HP (IsExecutePhase)
- `Slam()`: requires 2H weapon (Is2HanderEquipped), swing timer check
- `Whirlwind()`: requires Berserker Stance (or stance dance)
- Check: is any constraint missing from the ability function?

**Severity:** MEDIUM to CRITICAL depending on the missing constraint

**Example:** `ConcussionBlow()` (action.lua:226-233) has no rage check — it only checks `IsSpellLearnt` and `queueGCD` and cooldown. Since `CastSpellByName` fails gracefully when rage is insufficient, this is LOW severity but technically incomplete.

---

## Rule 9: Rage Safety — HS/Cleave Starving Emergency Abilities

**Description:** Heroic Strike and Cleave are "next swing" abilities that commit rage on the NEXT auto-attack. If rage drops between queue and swing, critical abilities (Shield Slam, Revenge, Sunder) can be starved.

**Detection Pattern:**
- Tank HS/Cleave variants should respect `reservedRage`: check that `rageNeeded = rageCost + reservedRage` pattern is used
- DPS HS should have a fallback: `or UnitMana("player") > 75` (action.lua:446) allows HS at high rage even when reservedRage is inflated
- Check: no ability with `SetReservedRage` after HS/Cleave in the chain — reservations set after the swing attack can't protect against it

**Severity:** HIGH — rage starvation delays Shield Slam/Revenge which are top threat

**Example:** `HeroicStrikeTank()` (action.lua:461-472) correctly uses `IWin_RageCost["Heroic Strike"] + reservedRage` — if 15 rage is reserved for Sunder, HS needs 30 rage (15 HS + 15 reserved).

---

## Rule 10: Rotation Completeness

**Description:** Compare the rotation chain against the guide's ability list. Flag missing abilities that should be present, and extra abilities that shouldn't.

**Detection Pattern:**
- `/itank` for DT Prot Defensive Stance should have: Shield Slam, Concussion Blow, Revenge, Sunder, HS
- `/ihodor` for DT Prot AoE should have: WW (only in Berserker via dtberserker), Cleave, Sunder, TClap
- `/idps` for Arms should have: Slam, MS, WW, Overpower, Sunder, HS (filler)
- `/idps` for Fury DW should have: BT, WW, HS, Sunder, Execute
- Flag: ability in rotation but NOT in guide AND not a utility (BShout, Demo, Bloodrage)
- Flag: ability in guide but NOT in rotation

**Note on intentional deviations:**
- Rend in `/idps` is gated to `not UnitInRaid("player")` — valid for solo/dungeon, not a bug
- No WW in DT Prot `/itank`/`/ihodor` — 1H WW does negligible damage, intentionally excluded
- Shield Bash not in `/itank` — delegated to `/ikick` utility rotation, design choice

**Severity:** MEDIUM — missing ability = lost DPS/TPS opportunity

---

## Rule 11: Pre-Queue Timing

**Description:** Abilities with cooldowns can be pre-queued by passing `IWin_Settings["GCD"]` (~1500ms) as `queueTime`. This means "start trying to cast when CD has <1500ms remaining." Passing `0` means "only cast when CD is fully ready" — no pre-queuing.

**Detection Pattern:**
- `Whirlwind(0)` in `/idps` (rotation.lua:34 calls `Whirlwind(GCD)` — check actual value)
- `Bloodthirst(GCD)` — correct, pre-queues
- `MortalStrike(GCD)` — correct, pre-queues
- `ShieldSlam(GCD)` — correct, pre-queues
- Any ability with a cooldown that passes `0` instead of `GCD` loses ~0.5s per cycle

**Severity:** MEDIUM — ~0.5s delay per cooldown cycle reduces DPS by 3-5%

**Example (open):** If `Whirlwind()` is called with `queueTime=0` via `Whirlwind(0)`, it won't pre-queue. The wrapper `Whirlwind(queueTime)` calls `WhirlwindAOE(queueTime)` — check what value the rotation passes.

---

## Rule 12: Slam Integration

**Description:** Slam has complex interactions with the GCD mutex (`slamQueued`) and swing timer. When `slamQueued = true`, all GCD abilities are blocked to protect the Slam window.

**Detection Pattern:**
- Every on-GCD ability function must check `not IWin_CombatVar["slamQueued"]` before firing
- `SetSlamQueued()` must appear AFTER `Slam()` in the chain (Slam sets up, then SetSlamQueued gates)
- `Slam()` itself should check `slamGCDAllowed` grace period to prevent double-Slam
- `SetReservedRageSlam()` should only reserve when Slam can actually fire (grace period check)
- Off-GCD abilities (HS, Cleave, ShieldBlock, Bloodrage) should NOT check slamQueued — they don't consume GCD

**Severity:** HIGH — broken slam integration either clips autos (DPS loss) or blocks rotation (GCD starvation)

**Example:** `HeroicStrike()` (action.lua:442-458) correctly does NOT check `slamQueued` — it's off-GCD. `BattleShout()` (action.lua:17-26) correctly checks `not slamQueued` — it's on-GCD.

---

## Rule 13: Copy-Paste Bugs

**Description:** Functions copied from templates but not fully updated. The function name suggests one spell but `CastSpellByName` fires another.

**Detection Pattern:**
- For every function, verify that `CastSpellByName("X")` matches the function name
- `MasterStrikeWindfury()` → should cast "Master Strike" but casts "Hamstring" (action.lua:639)
- Check Windfury variants especially — they're typically copy-pasted from the base function
- Check DT variants (ExecuteDefensiveTactics, OverpowerDefensiveTactics) for correct spell names
- Check SetReservedRage variants — the spell name in `SetReservedRage("X", ...)` should match the ability

**Severity:** CRITICAL — wrong spell fires, completely breaking the intended behavior

**Example (open):** `MasterStrikeWindfury()` (action.lua:632-641) checks `IsSpellLearnt("Master Strike")`, checks cooldown for "Master Strike", checks rage for "Master Strike", then calls `CastSpellByName("Hamstring")`. This is a copy-paste bug from `HamstringWindfury()`.

---

## Rule 14: AoE vs ST Selection

**Description:** Single-target rotations should use ST abilities; AoE rotations should use AoE abilities. Using the wrong type wastes damage/threat.

**Detection Pattern:**
- `/itank` (ST): should use `HeroicStrikeTank()`, NOT `CleaveAOE()`
- `/ihodor` (AoE): should use `CleaveAOE()`, NOT `HeroicStrikeTank()`
- `/idps` (ST): should use `HeroicStrike()`, NOT `Cleave()`
- `/icleave` (AoE): should use `Cleave()` AND `WhirlwindAOE()` over ST variants
- `ThunderClap()` (AoE threat) should be in `/ihodor`, not `/itank` (unless for debuff)
- `ThunderClapDPS()` should be in `/icleave`, not `/idps`

**Severity:** MEDIUM — wrong type reduces efficiency but still does some damage/threat

**Example:** `/ihodor` correctly uses `CleaveAOE()` (rotation.lua:177) and `ThunderClap()` (rotation.lua:168). `/itank` correctly uses `HeroicStrikeTank()` (rotation.lua:135) without TClap.

---

## Rule 15: DT Stance Dance — Missing Variants

**Description:** Defensive Tactics Prot can stance-dance to Battle/Berserker Stance for specific abilities. Each ability needs a DT-aware variant that handles the stance swap.

**Detection Pattern:**
- `Execute()` in tank rotation → should be `ExecuteDefensiveTactics()` (handles stance swap via DT config)
- `Overpower()` in tank rotation → should be `OverpowerDefensiveTactics()` (checks `IsDefensiveTacticsStanceAvailable`)
- Regular `Execute()` would try `CastSpellByName("Battle Stance")` without checking DT availability
- Check: every stance-restricted ability in `/itank`/`/ihodor` has a DT variant or is gated by DT checks

**Severity:** HIGH — non-DT variant may swap to a stance that DT config hasn't enabled, wasting a GCD

**Example:** `/itank` correctly uses `ExecuteDefensiveTactics()` (rotation.lua:121) and `OverpowerDefensiveTactics()` (rotation.lua:123) instead of base `Execute()`/`Overpower()`.

---

## Rule 16: TTD Gating

**Description:** Debuffs and DoTs should not be applied to targets that will die before the effect is useful. `GetTimeToDie()` provides estimated seconds remaining.

**Detection Pattern:**
- `Rend()`: gates on `GetTimeToDie() > 9` (action.lua:806) — correct (Rend ticks over ~15s)
- `DemoralizingShout()`: gates on `GetTimeToDie() > 10` (action.lua:244) — correct
- `SunderArmorDPS()`: gates on `GetTimeToDie() > 5` (action.lua:1058) — correct
- `SunderArmorFirstStack()`: NO TTD gate (action.lua:1041-1051) — intentional for tank (first GCD sunder)
- `SunderArmor()` (tank filler): NO TTD gate — intentional (always sunder as tank)
- Flag: any debuff ability WITHOUT a TTD check in DPS rotations

**Severity:** LOW to MEDIUM — wasting a GCD on a dying mob

---

## Rule 17: Rage Cost vs Reservation — IsRageCostAvailable vs IsRageAvailable

**Description:** IWinEnhanced has two rage-check functions:
- `IsRageCostAvailable("spell")`: checks `UnitMana("player") >= rageCost` — raw cost only
- `IsRageAvailable("spell")`: checks `UnitMana("player") >= rageCost + reservedRage + swingTax` — includes reservation system and +20 swing tax for HS/Cleave

**Detection Pattern:**
- **On-GCD abilities** should generally use `IsRageAvailable()` — respects the reservation system
- **Off-GCD tank abilities** (HeroicStrikeTank, CleaveAOE) should use direct math: `rageCost + reservedRage` — avoids +20 swing tax
- **Emergency abilities** (Pummel, ShieldBash, Hamstring) may use `IsRageCostAvailable()` — they should fire even at low rage
- **Proc abilities** with very low cost (Overpower at 5 rage, Revenge at 5 rage) may use `IsRageCostAvailable()` to ensure they fire on proc
- Flag: tank HS/Cleave using `IsRageAvailable()` (adds unnecessary swing tax)
- Flag: filler abilities using `IsRageCostAvailable()` (bypasses reservations, may starve priority abilities)

**Severity:** HIGH (for tank HS/Cleave) to LOW (for emergency abilities)

**Example:** `Revenge()` (action.lua:825) uses `IsRageCostAvailable("Revenge")` — correct, since Revenge is a 5-rage proc that should always fire. `SunderArmor()` (action.lua:1034) uses `IsRageAvailable("Sunder Armor")` — correct, respects reservations as a filler.

---

## Quick Reference: Rotation-to-Spec Mapping

| Rotation | Primary Spec | Secondary Spec | Key Abilities |
|----------|-------------|----------------|---------------|
| `/idps` | Arms (2H Slam) | Fury DW | Slam, MS, BT, WW, HS, Execute |
| `/icleave` | Arms AoE | Fury AoE | SS, WW, Cleave, MS/BT, TClap |
| `/itank` | DT Prot ST | Furyprot ST | ShieldSlam, BT, Revenge, HS, Sunder |
| `/ihodor` | DT Prot AoE | Furyprot AoE | ShieldSlam, TClap, Cleave, Sunder |

## Quick Reference: Off-GCD vs On-GCD

**Off-GCD (don't consume queueGCD):**
- HeroicStrike / HeroicStrikeTank (next-swing)
- Cleave / CleaveAOE (next-swing)
- ShieldBlock / ShieldBlockFRD
- Bloodrage
- StartAttack
- BerserkerRage (off-GCD in WoW, but IWin sets queueGCD=false — review this)

**On-GCD (consume queueGCD):**
- Everything else: BattleShout, Sunder, ShieldSlam, MortalStrike, Bloodthirst, Revenge, Execute, Overpower, Slam, ThunderClap, DemoralizingShout, ConcussionBlow, Rend, Hamstring, etc.
