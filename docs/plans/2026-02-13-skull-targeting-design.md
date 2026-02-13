# Skull/X Priority + Lowest-HP Targeting + Sweeping Execute for /idps and /icleave

**Date:** 2026-02-13
**Status:** Implemented & Tested

## Problem

When running `/idps` or `/icleave` in dungeons, the warrior had no automatic way to:
1. Focus the raid-marked kill target (skull or X)
2. Efficiently pick up a new target when the current one dies (defaults to nearest, not lowest HP)
3. Exploit Sweeping Strikes + Execute synergy by swapping to low-HP mobs in /icleave

## Design

### Behavior Flow (per keypress)

**`/idps` chain:**
```
TargetEnemy()       — acquire any hostile target if none (existing, unchanged)
TargetSkullX()      — swap to skull/X if marked target exists
TargetLowestHP()    — if target dead/missing, find lowest HP mob
```

**`/icleave` chain:**
```
TargetEnemy()              — acquire any hostile target if none (existing, unchanged)
TargetSkullX()             — swap to skull/X if marked target exists
TargetSweepingExecute()    — swap to <20% HP mob when SS active/ready (/icleave only)
TargetLowestHP()           — if target dead/missing, find lowest HP mob
```

### TargetSkullX() — Mark Priority (every press)

**Guards:**
- `skullTarget` config must be `"on"` (default: on)
- Player must be in combat
- Skip if already targeting the chosen mark

**Logic:**
1. Check `UnitExists("mark8")` (skull) — alive, hostile
2. Check `UnitExists("mark7")` (X) — alive, hostile
3. If both valid → compare `UnitXP("distanceBetween", "player", markUnit, "meleeAutoAttack")`, pick closer
4. If only one valid → pick that one
5. If neither valid → return (no-op, fall through)
6. `TargetUnit(markGuid)` to switch

### TargetSweepingExecute() — Execute Cleave (/icleave only, every press)

**Guards:**
- Player must be in combat
- Sweeping Strikes must be learnt AND Execute must be learnt
- Sweeping Strikes must be active (buff) OR off cooldown
- Skip if current target is already <20% HP (already an execute target)

**Logic:**
1. Save original target GUID
2. Cycle up to 8 enemies via UnitXP, find one <20% HP in melee range (8 yards)
3. If found → `TargetUnit(bestGuid)` (swaps off skull if needed)
4. If nothing found → restore original target

**Key interaction:** Runs AFTER TargetSkullX, so it CAN swap off skull to execute an unmarked mob when SS criteria are met. This is intentional — Execute + Sweeping Strikes mirrors massive damage to a second target.

### TargetLowestHP() — Lowest HP Fallback (only when needing target)

**Guards:**
- Only runs if target is dead, doesn't exist, or is friendly
- Must be in combat

**Logic:**
1. Cycle up to 8 enemies via UnitXP, track lowest HP% in melee range
2. If best found → `TargetUnit(bestGuid)`
3. If nothing found → `TargetNearestEnemy()` (vanilla fallback)

### Config

| Command | Default | Effect |
|---------|---------|--------|
| `/iwin skulltarget on` | on | Enable skull/X priority + sweeping execute in /idps and /icleave |
| `/iwin skulltarget off` | — | Disable mark targeting (TargetSweepingExecute still works independently) |

### Files Changed

| File | Change |
|------|--------|
| `warrior/action.lua` | Added `TargetSkullX()`, `TargetSweepingExecute()`, `TargetLowestHP()` |
| `warrior/rotation.lua` | Wired into `/idps` (SkullX + LowestHP) and `/icleave` (SkullX + SweepingExecute + LowestHP) |
| `warrior/setup.lua` | Added `skulltarget` config option with validation, setter, and help |
| `warrior/event.lua` | Added `skullTarget` default (`"on"`) |

### What Does NOT Change

- `core/action.lua` — `TargetEnemy()` untouched, all other classes/macros unaffected
- `/ihodor` — has its own `TargetLooseMob()` for tab-sunder
- `/itank`, `/ikick`, `/ichase`, etc. — no mark targeting

## Key APIs Used

```lua
-- SuperWoW mark unit tokens
UnitExists("mark8")                              --> 1, guid (skull)
UnitExists("mark7")                              --> 1, guid (X)

-- UnitXP distance + cycling
UnitXP("distanceBetween", "player", unit, "meleeAutoAttack")
UnitXP("target", "nextEnemyConsideringDistance")

-- IWinEnhanced condition checks
IWin:IsBuffActive("player", "Sweeping Strikes")  --> true if SS buff active
IWin:GetCooldownRemaining("Sweeping Strikes")    --> 0 if off CD (ignores GCD)
IWin:IsSpellLearnt("Sweeping Strikes")           --> true if talent learned

-- GUID save/restore
local _, guid = UnitExists("target")
TargetUnit(guid)
```
