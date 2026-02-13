# Skull/X Priority + Lowest-HP Targeting for /idps and /icleave

**Date:** 2026-02-13
**Status:** Approved
**Scope:** `/idps` and `/icleave` only (not /ihodor, /itank, or other slash commands)

## Problem

When running `/idps` or `/icleave` in dungeons, the warrior has no automatic way to:
1. Focus the raid-marked kill target (skull or X)
2. Efficiently pick up a new target when the current one dies (defaults to nearest, not lowest HP)

## Design

### Behavior Flow (per keypress)

```
TargetEnemy()       — acquire any hostile target if none (existing, unchanged)
TargetSkullX()      — swap to skull/X if marked target exists (NEW)
TargetLowestHP()    — if target dead/missing, find lowest HP mob (NEW)
```

### Step 1: TargetSkullX() — Mark Priority (every press)

**Guards:**
- `skulltarget` config must be `"on"` (default: on)
- Player must be in combat
- Skip if already targeting the chosen mark

**Logic:**
1. Check `UnitExists("mark8")` (skull) — alive, hostile
2. Check `UnitExists("mark7")` (X) — alive, hostile
3. If both valid → compare `UnitXP("distanceBetween", "player", markUnit, "meleeAutoAttack")`, pick closer
4. If only one valid → pick that one
5. If neither valid → return (no-op, fall through)
6. `TargetUnit(markUnit)` to switch

**Why `"mark8"`/`"mark7"` unit tokens?** SuperWoW exposes raid marks as pseudo-unit tokens. No cycling needed — direct access to the marked unit.

### Step 2: TargetLowestHP() — Lowest HP Fallback (only when needing target)

**Guards:**
- Only runs if target is dead, doesn't exist, or is friendly
- Uses same need-target check as TargetEnemy()

**Logic:**
1. Save current state (may have no target)
2. Cycle up to 8 enemies via `UnitXP("target", "nextEnemyConsideringDistance")`
3. For each: skip dead/friendly, skip if out of melee range (8 yards)
4. Track lowest `UnitHealth("target") / UnitHealthMax("target")` and its GUID
5. If best found → `TargetUnit(bestGuid)`
6. If nothing found → `TargetNearestEnemy()` (vanilla fallback)

**GUID pattern:** Uses `local _, guid = UnitExists("target")` to capture GUIDs, `TargetUnit(guid)` to switch — same proven pattern as TargetLooseMob().

### Config

| Command | Default | Effect |
|---------|---------|--------|
| `/iwin skulltarget on` | on | Enable skull/X priority in /idps and /icleave |
| `/iwin skulltarget off` | — | Disable, use normal targeting |

### Files to Edit

| File | Change |
|------|--------|
| `warrior/action.lua` | Add `TargetSkullX()` and `TargetLowestHP()` functions |
| `warrior/rotation.lua` | Insert both calls after `TargetEnemy()` in `/idps` and `/icleave` chains |
| `warrior/setup.lua` | Add `skulltarget` config option with `/iwin` slash command handler |

### What Does NOT Change

- `core/action.lua` — `TargetEnemy()` untouched, all other classes/macros unaffected
- `/ihodor` — has its own `TargetLooseMob()` for tab-sunder
- `/itank`, `/ikick`, `/ichase`, etc. — no mark targeting

## Key APIs Used

```lua
-- SuperWoW mark unit tokens
UnitExists("mark8")                              --> 1, guid (skull)
UnitExists("mark7")                              --> 1, guid (X)

-- UnitXP distance
UnitXP("distanceBetween", "player", unit, "meleeAutoAttack")

-- UnitXP cycling
UnitXP("target", "nextEnemyConsideringDistance")

-- GUID save/restore
local _, guid = UnitExists("target")
TargetUnit(guid)
```
