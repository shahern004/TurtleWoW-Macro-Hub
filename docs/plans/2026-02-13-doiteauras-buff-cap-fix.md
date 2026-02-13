# Plan: Fix & Upgrade DoiteAuras Integration for Buff-Cap Tracking

**Date:** 2026-02-13
**Status:** DEPLOYED, pending test

## Context

In 40-person TurtleWoW raids, warriors routinely exceed the 32 visible buff limit due to class buffs + consumables + procs + TurtleWoW's debuff overflow (target debuffs >16 stored as player buffs). When this happens, IWinEnhanced's vanilla `GetPlayerBuffID()` scan can't see the hidden buffs.

IWinEnhanced already has DoiteAuras integration in `core/condition.lua` — but **it was completely broken** due to a variable name typo on line 59 (`return timeleft` instead of `return timeLeft`). This meant every buff hidden by the cap was invisible to `IsBuffActive()` and `GetBuffRemaining()`, causing rotation failures (missed Battle Shout refreshes, wrong Windfury gating, etc.).

## Changes Made

### File: `addons/IWinEnhanced/core/condition.lua`

### 1. Fixed timeleft typo + added HasBuff catch-all in `GetBuffRemaining()`

**Before (broken):**
```lua
if DoitePlayerAuras then
    local timeLeft = DoitePlayerAuras.GetHiddenBuffRemaining(spell)
    if timeLeft then
        return timeleft  -- BUG: wrong variable name, always nil
    end
end
```

**After:**
```lua
if DoitePlayerAuras then
    local timeLeft = DoitePlayerAuras.GetHiddenBuffRemaining(spell)
    if timeLeft then
        return timeLeft
    end
    if DoitePlayerAuras.HasBuff(spell) then
        return 9999
    end
end
```

**Why the `HasBuff` catch-all?** `GetHiddenBuffRemaining` only returns a value for buffs with duration data. Permanent/aura-type buffs hidden by the cap (e.g., Windfury Totem aura) would return `nil`. `HasBuff()` checks both visible AND hidden buffs, so `return 9999` (the "permanent buff" sentinel, same as line 52 for visible permanent buffs) covers this gap.

### 2. Fixed `GetBuffStack()` early-return gap

**Before:**
```lua
if DoitePlayerAuras then
    return DoitePlayerAuras.GetBuffStacks(spell) or 0
end
```

**After:**
```lua
if DoitePlayerAuras then
    local stacks = DoitePlayerAuras.GetBuffStacks(spell)
    if stacks then return stacks end
end
```

**Problem:** `or 0` coerced `nil` → `0`, returning "buff not found" and skipping the vanilla `GetPlayerBuffIndex` + `UnitBuff` fallback entirely. Now falls through when DoitePlayerAuras returns nil.

### 3. Added DoiteTrack helper functions (new)

```lua
function IWin:GetDebuffRemainingDoite(unit, spell)
    if DoiteTrack and DoiteTrack.GetAuraRemainingSecondsByName then
        local remaining = DoiteTrack:GetAuraRemainingSecondsByName(spell, unit)
        if remaining then return remaining end
    end
    return nil
end

function IWin:IsMyDebuffActive(unit, spell)
    if DoiteTrack and DoiteTrack.GetAuraOwnershipByName then
        local _, _, _, hasMine, _, ownerKnown = DoiteTrack:GetAuraOwnershipByName(spell, unit)
        if ownerKnown then return hasMine end
    end
    return nil
end
```

These enable future checks like "is MY Rend on the target?" without re-applying unnecessarily. Returns `nil` when DoiteTrack isn't loaded or doesn't have data, so callers fall back gracefully.

**Note:** DoiteTrack only tracks auras configured in DoiteAuras UI. These helpers are not yet wired into action.lua (future work).

## Affected Buff Checks (no action.lua changes needed)

All 15 player buff checks in `warrior/action.lua` flow through `IsBuffActive` → `GetBuffRemaining`, so fixing `core/condition.lua` automatically fixes them all:

| Buff | Risk if Hidden by Cap |
|------|-----------------------|
| Battle Shout | Fails to refresh — drops off |
| Enrage | Bloodrage cast when Enrage active — wastes rage |
| Juju Flurry | Consumes Juju when already buffed — wastes item |
| Windfury Totem | Uses wrong ability variant — DPS loss |
| Shield Block | Shield Slam gating broken |
| Improved Shield Slam | Shield Slam gating broken |
| Sweeping Strikes | Target swap logic fails — cleave DPS loss |

## What Was NOT Changed

- **DoiteAuras code** — read-only external dependency, no modifications
- **Target debuff checks** — Sunder/Rend/DemoShout use `libdebuff:UnitDebuff()` which isn't affected by the player buff cap
- **action.lua** — all fixes flow through the core condition functions; no wiring changes needed
- **DoiteTrack wiring into rotation** — helpers added but not wired into action.lua yet (future work, requires DoiteAuras UI config per aura)

## Verification Checklist

1. [x] Deploy to live folder: `cp -r addons/IWinEnhanced/* C:/Games/TurtleWoW/Interface/AddOns/IWinEnhanced/`
2. [ ] `/reload` in-game
3. [ ] Test with enough buffs to exceed 32 (class buffs + consumes + procs in a dungeon/raid)
4. [ ] Verify: Battle Shout refresh works when hidden by cap
5. [ ] Verify: Windfury Totem detection works when hidden by cap
6. [ ] Verify: Sweeping Strikes detection works when hidden by cap
7. [ ] Verify: Without DoiteAuras installed, behavior is identical (nil-check path)

## Root Cause Analysis

The bug was a single-character Lua scoping error: `timeLeft` (camelCase, declared on the line above) vs `timeleft` (all lowercase, which only existed as a loop variable inside the debuff scan `for` block on line 36). Lua treats these as completely different variables. Since `timeleft` was not in scope at line 59, it evaluated to `nil`, making the entire DoitePlayerAuras integration a silent no-op since it was first written.
