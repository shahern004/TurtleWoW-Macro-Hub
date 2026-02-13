# DoiteAuras API Reference

> Source: DoiteAuras addon (local copy in `DoiteAuras/`)
> Version: 1.5.0
> Last updated: 2026-02-13

DoiteAuras is a WeakAuras-inspired addon for TurtleWoW 1.12 that tracks abilities,
buffs, debuffs, and items with conditional display logic. It exposes several global
APIs useful for other addons — most importantly **DoitePlayerAuras** for tracking
buffs beyond the 32-slot visual cap, and **DoiteTrack** for querying aura durations
and ownership.

---

## Table of Contents

1. [Dependencies & Load Order](#dependencies--load-order)
2. [DoitePlayerAuras — Buff Cap Tracking](#doiteplayerauras--buff-cap-tracking)
3. [DoiteTrack — Aura Duration & Ownership](#doitetrack--aura-duration--ownership)
4. [DoiteBuffData — Stack Consumer Registry](#doitebuffdata--stack-consumer-registry)
5. [DoiteConditions — Condition Evaluation](#doiteconditions--condition-evaluation)
6. [Global State & Icon Frame Access](#global-state--icon-frame-access)
7. [Slash Commands](#slash-commands)
8. [CVar Requirements](#cvar-requirements)
9. [Integration Examples for IWinEnhanced](#integration-examples-for-iwinenhanced)

---

## Dependencies & Load Order

**No hard addon dependencies** — DoiteAuras is standalone. However, it leverages
DLL-level APIs when available:

| Dependency | Usage |
|-----------|-------|
| **SuperWoW** | `UnitBuff`/`UnitDebuff` return spellId (3rd/4th arg); `UnitExists` returns GUID |
| **Nampower** | `GetSpellRecField()` for spell names/stack amounts; `AURA_CAST_ON_SELF`, `BUFF_ADDED_SELF`, etc. events |
| **pfUI** (optional) | Border styling on icon frames when detected |

**Load order** (from `.toc`):

```
DoiteAuras.lua              -- Main file: icon management, UI, slash commands
Modules/DoiteBuffData.lua   -- Stack consumer registry (loaded before PlayerAuras)
Modules/DoitePlayerAuras.lua -- Buff cap tracking system
Modules/DoiteEdit.lua       -- Edit UI (not relevant for integration)
Modules/DoiteGlow.lua       -- Glow effects
Modules/DoiteConditions.lua -- Condition evaluation engine (~50 condition types)
Modules/DoiteGroup.lua      -- Icon grouping system
Modules/DoiteLogic.lua      -- AND/OR logic builder
Modules/DoiteExport.lua     -- Import/export
Modules/DoiteTrack.lua      -- Aura duration & ownership API
Modules/DoiteSettings.lua   -- Settings UI
```

---

## DoitePlayerAuras — Buff Cap Tracking

**Global:** `DoitePlayerAuras` (table, set via `_G["DoitePlayerAuras"]`)

This is the key module for IWinEnhanced integration. In vanilla WoW 1.12, the client
only displays 32 buff slots. When a player has 32+ buffs, new buffs are applied but
invisible to standard `UnitBuff()` queries. DoitePlayerAuras solves this by:

1. Tracking all 32 buff slots via `BUFF_ADDED_SELF` / `BUFF_REMOVED_SELF` events
2. When slot 32 fills, registering `AURA_CAST_ON_SELF` to detect hidden buffs
3. Maintaining a parallel `cappedBuffs` table with expiration times and stacks

### Internal State

```lua
DoitePlayerAuras.buffs           -- [1..32] = { spellId, stacks } — current buff slots
DoitePlayerAuras.debuffs         -- [1..16] = { spellId, stacks } — current debuff slots
DoitePlayerAuras.activeBuffs     -- [spellName] = slot (or false if inactive)
DoitePlayerAuras.activeDebuffs   -- [spellName] = slot (or false if inactive)

-- Buff cap overflow tracking (only populated when at 32/32 buffs)
DoitePlayerAuras.cappedBuffsExpirationTime  -- [spellName] = GetTime() expiration
DoitePlayerAuras.cappedBuffsStacks          -- [spellName] = current stack count

-- Caches
DoitePlayerAuras.spellIdToNameCache    -- [spellId] = spellName
DoitePlayerAuras.spellNameToIdCache    -- [spellName] = spellId
DoitePlayerAuras.spellNameToMaxStacks  -- [spellName] = max stacks (from DBC)
DoitePlayerAuras.playerBuffIndexCache  -- [spellName] = index for GetPlayerBuffX()
```

### Public Functions

#### `DoitePlayerAuras.IsActive(spellName) -> boolean`

Returns `true` if the spell is active as either a buff or debuff, **including**
buffs hidden by the buff cap.

```lua
if DoitePlayerAuras.IsActive("Battle Shout") then
  -- Battle Shout is up (even if hidden beyond slot 32)
end
```

#### `DoitePlayerAuras.HasBuff(spellName) -> boolean`

Returns `true` if the spell is active as a **buff**, including buff-cap-hidden buffs.

```lua
if DoitePlayerAuras.HasBuff("Rallying Cry of the Dragonslayer") then
  -- World buff is present (even if pushed past slot 32)
end
```

#### `DoitePlayerAuras.HasDebuff(spellName) -> boolean`

Returns `true` if the spell is active as a **debuff**. Does not track debuff cap
overflow (comment in source: "not possible to hit debuff cap as a player currently").

#### `DoitePlayerAuras.GetBuffStacks(spellName) -> number|nil`

Returns the current stack count for a buff, or `nil` if not active.
Checks buff-cap-hidden buffs as a fallback.

```lua
local stacks = DoitePlayerAuras.GetBuffStacks("Lightning Shield")
if stacks and stacks >= 3 then
  -- 3+ Lightning Shield charges
end
```

#### `DoitePlayerAuras.GetDebuffStacks(spellName) -> number|nil`

Returns the current stack count for a debuff, or `nil` if not active.

#### `DoitePlayerAuras.GetBuffBarSlot(spellName) -> number|nil`

Returns the player buff index (0-47, mixed buffs+debuffs) for use with
`GetPlayerBuffTexture()`, `GetPlayerBuffTimeLeft()`, etc. Uses a cached index
with fallback linear scan.

#### `DoitePlayerAuras.IsHiddenByBuffCap(spellName) -> boolean`

Returns `true` if the spell is tracked as a buff-cap-hidden buff and has not yet
expired. Automatically cleans up expired entries.

#### `DoitePlayerAuras.GetHiddenBuffRemaining(spellName) -> number|nil`

Returns seconds remaining for a buff-cap-hidden buff, or `nil` if not tracked
or expired.

```lua
local remaining = DoitePlayerAuras.GetHiddenBuffRemaining("Songflower Serenade")
if remaining and remaining > 60 then
  -- More than 1 minute left on hidden Songflower
end
```

### Buff Cap Event Flow

```
Normal (< 32 buffs):
  BUFF_ADDED_SELF    → updates buffs[slot], marks activeBuffs[name] = slot
  BUFF_REMOVED_SELF  → full UpdateBuffs() rescan, marks inactive

At buff cap (slot 32 filled):
  RegisterBuffCapEvents() called → registers:
    AURA_CAST_ON_SELF     → captures hidden buff (spellId, durationMs, stacks)
    SPELL_GO_SELF          → processes stack consumers (Pyroblast→Hot Streak, etc.)
    SPELL_CHANNEL_START    → processes stack consumers for channeled spells

When slot 32 empties:
  UnregisterBuffCapEvents() called (currently left registered for safety)
```

### Debug Mode

```lua
DoitePlayerAuras.ToggleDebugBuffCap()
```

Toggles debug mode that simulates buff cap behavior regardless of actual buff count.
Unregisters normal buff events and forces buff cap events. Useful for testing.

---

## DoiteTrack — Aura Duration & Ownership

**Global:** `DoiteTrack` (table, set via `_G["DoiteTrack"]`)

Provides remaining-duration timers and ownership detection for auras the player has
applied. Uses Nampower's `AURA_CAST_ON_SELF/OTHER` events for duration data and
`BUFF/DEBUFF_ADDED_SELF/OTHER` for apply confirmation.

**Key design:** DoiteTrack only tracks auras configured in DoiteAurasDB with
`onlyMine = true` or `onlyOthers = true`. It does NOT track arbitrary auras — the
user must configure them in the DoiteAuras UI first.

### Public Functions

#### `DoiteTrack:GetAuraRemainingSecondsByName(spellName, unit) -> remaining, spellId`

Returns the remaining duration in seconds for a tracked aura on the given unit,
plus the matching spellId. Returns `nil` if the aura is not present, not tracked,
or not owned by the player.

```lua
local remaining, sid = DoiteTrack:GetAuraRemainingSecondsByName("Rend", "target")
if remaining and remaining > 3 then
  -- Rend has 3+ seconds left, no need to reapply
end
```

**Parameters:**
- `spellName` (string) — Spell name, case-insensitive, rank-stripped (e.g. `"Rip"` matches all ranks)
- `unit` (string) — Unit token (`"target"`, `"player"`, `"party1"`, etc.)

**Returns:**
- `remaining` (number|nil) — Seconds remaining, or nil
- `spellId` (number|nil) — The matching spellId with the longest remaining time

#### `DoiteTrack:RemainingPassesByName(spellName, unit, comp, threshold) -> boolean|nil`

Convenience wrapper: checks if the remaining duration passes a comparison test.

```lua
if DoiteTrack:RemainingPassesByName("Sunder Armor", "target", "<=", 5) then
  -- Sunder has 5 or fewer seconds left, time to refresh
end
```

**Parameters:**
- `spellName` (string) — Spell name
- `unit` (string) — Unit token
- `comp` (string) — Comparison operator: `">="`, `"<="`, or `"=="`
- `threshold` (number) — Seconds to compare against

**Returns:** `true`/`false` if aura is present, `nil` if not tracked or absent.

#### `DoiteTrack:GetAuraOwnershipByName(spellName, unit) -> remaining, _, spellId, hasMine, hasOther, ownerKnown`

Extended query that distinguishes between the player's own aura and others'.

```lua
local rem, _, sid, mine, other, known = DoiteTrack:GetAuraOwnershipByName("Rend", "target")
if known then
  if mine then
    -- Player's Rend is on target, rem seconds left
  elseif other then
    -- Someone else's Rend is on target
  end
end
```

**Returns (6 values):**

| Position | Name | Type | Description |
|----------|------|------|-------------|
| 1 | `remaining` | number\|nil | Seconds remaining on player's copy |
| 2 | *(unused)* | false | Always `false` (reserved) |
| 3 | `spellId` | number\|nil | SpellId of the best match |
| 4 | `hasMine` | boolean | Player has a confirmed timer for this aura |
| 5 | `hasOther` | boolean | Aura is present but no player timer (implies another caster) |
| 6 | `ownerKnown` | boolean | Whether ownership could be determined |

### Internal: Duration Resolution

DoiteTrack resolves durations in this priority order:

1. **CP-table manual override** — For combo-point-based spells (Rip, Rupture, Kidney Shot,
   Slice and Dice, etc.), a hardcoded `ManualDurationBySpellId` table maps
   `[spellId][comboPoints] = seconds`. These override Nampower durations because NP
   is often wrong for CP-based spells.
2. **Nampower `durationMs`** — From `AURA_CAST_ON_SELF/OTHER` arg8. Used when > 0.
3. **Flat manual fallback** — From `ManualDurationBySpellId[spellId] = seconds`.
   Only used when Nampower returns `durationMs == 0`.

### Internal: Tracked Aura State

```lua
-- Per-GUID aura timers (only for onlyMine tracked auras)
AuraStateByGuid[guid][spellId] = {
  appliedAt = GetTime(),  -- when timer started
  fullDur   = seconds,    -- full duration
  cp        = number,     -- combo points at cast time
  isDebuff  = boolean,    -- buff or debuff
}
```

### Special-Case Class Logic

DoiteTrack has built-in special-case handling for:

- **Shaman:** Molten Blast refreshes Flame Shock duration on hit
- **Druid:** Carnage talent — Ferocious Bite procs refresh Rip/Rake
- **Rogue:** Taste for Blood (+2s/point to Rupture), Improved Blade Tactics (+15%/point to Slice and Dice)
- **Paladin:** Judgement tracking (Seal → Judgement correlation, refresh on Crusader Strike / Holy Strike / auto-attack)

### Debug

```lua
DoiteTrack_SetNPDebug(true)   -- enable debug prints
DoiteTrack_SetNPDebug(false)  -- disable
```

Prints all `AURA_CAST` events with spellId, name, target GUID, duration, CP, and
tracked/untracked status.

---

## DoiteBuffData — Stack Consumer Registry

**Global:** `DoiteBuffData` (table, set via `_G["DoiteBuffData"]`)

Maps spellIds that consume stacks from other buffs during buff cap conditions.
Used by DoitePlayerAuras to track stack changes when the buff bar is full and
normal `UnitBuff()` stacks can't be read.

### Structure

```lua
DoiteBuffData.stackConsumers = {
  [spellId] = {
    modifiedBuffName = "BuffName",  -- which buff's stacks change
    stackChange = -N,               -- how many stacks to remove
  },
}
```

### Current Entries (v1.5.0)

| SpellId(s) | Spell | Modified Buff | Stack Change |
|------------|-------|--------------|-------------|
| 11366, 12505, 12522, 12523, 12524, 12525 | Pyroblast (Ranks 1-6) | Hot Streak | -5 |
| 51387, 52420, 52422 | Lightning Strike (Ranks 1-3) | Lightning Shield | -1 |

Additionally, **Clearcasting** is handled as a special case directly in DoitePlayerAuras
(not via stackConsumers): any spell cast with `manaCost > 0` targeting a non-self unit
removes the Clearcasting buff-cap entry.

---

## DoiteConditions — Condition Evaluation

**Global:** `DoiteConditions` (table, set via `_G["DoiteConditions"]`)

The condition evaluation engine handles ~50 condition types that determine when icons
show, hide, glow, or grey out. Four tracked icon types exist:

| Type | Description |
|------|-------------|
| `"Ability"` | Spells/abilities with cooldown, usability, range checks |
| `"Buff"` | Player or target buffs with presence/stack/duration checks |
| `"Debuff"` | Player or target debuffs with presence/stack/duration checks |
| `"Item"` | Inventory items with cooldown, count, equipped checks |

### Condition Categories (not exhaustive)

- **Aura conditions:** `targetSelf`, `targetHelp`, `targetHarm`, `onlyMine`, `onlyOthers`, stack count, duration
- **Ability conditions:** usability, cooldown, range, proc windows
- **Unit conditions:** health %, mana %, exists, dead, friendly/hostile
- **Class-specific:** warrior stances, druid forms, rogue stealth, paladin auras
- **Combat state:** in combat, combo points, soul shards

DoiteConditions is primarily an internal engine — external addons rarely call it
directly. The relevant external interaction is through the **DoiteAurasDB** config
that feeds into DoiteTrack's watch list.

---

## Global State & Icon Frame Access

### Icon Frames

Each configured icon creates a frame named `DoiteIcon_<key>` where `<key>` is the
spell's config key in `DoiteAurasDB.spells`:

```lua
local frame = _G["DoiteIcon_" .. key]
if frame then
  -- frame.icon = texture child
  -- frame:IsShown() = currently visible
end
```

### Key Globals

| Global | Type | Description |
|--------|------|-------------|
| `DoiteAurasDB` | table | SavedVariablesPerCharacter — all config, spells, cache |
| `DoiteAurasDB.spells` | table | `[key] = { type, name, displayName, spellid, conditions, ... }` |
| `DoiteAurasDB.cache` | table | Spell name → texture path cache |
| `DoitePlayerAuras` | table | Buff cap tracking system (see above) |
| `DoiteTrack` | table | Aura duration & ownership API (see above) |
| `DoiteBuffData` | table | Stack consumer registry (see above) |
| `DoiteConditions` | table | Condition evaluation engine |
| `DoiteGroup_Computed` | table | Group layout positions |
| `DoiteGroup_NeedReflow` | boolean | Flag to trigger group reflow |
| `DoiteAuras_RefreshIcons` | function | Rebuilds all icon frames from config |
| `DoiteAuras_HardDisabled` | boolean | Set `true` when required mods are missing |

---

## Slash Commands

### `/da` (aliases: `/doiteaura`, `/doiteaurs`, `/doite`)

Toggles the main DoiteAuras configuration UI. If hard-disabled (missing required
mods), prints an error message instead.

**Subcommands:**

| Command | Description |
|---------|-------------|
| `/da` | Toggle config UI |
| `/da debug` | Toggle DoiteTrack NP debug prints (shows all AURA_CAST events) |

### `/daversionwho`

Broadcasts a version check request to raid/party/guild. Other DoiteAuras users
respond with their version number. Useful for checking addon versions in a group.

---

## CVar Requirements

DoiteAuras sets the following CVars automatically on login (via DoiteTrack):

| CVar | Value | Purpose |
|------|-------|---------|
| `NP_EnableAuraCastEvents` | `"1"` | Enables `AURA_CAST_ON_SELF`, `AURA_CAST_ON_OTHER`, `BUFF_ADDED_*`, `DEBUFF_ADDED_*` events from Nampower |
| `NP_EnableAutoAttackEvents` | `"1"` | Enables `AUTO_ATTACK_SELF` event (only set when Paladin Judgement refresh is needed) |

These are Nampower CVars set in `Config\config.wtf` or via `/run SetCVar(...)`.
If not set, DoiteTrack's duration tracking will not function.

---

## Integration Examples for IWinEnhanced

### Checking a Buff Beyond the Buff Cap

The primary use case: checking if a buff is active even when the player has 32+ buffs
and `UnitBuff()` can't see all of them.

```lua
-- In warrior/action.lua or warrior/condition.lua:
local function HasBuffIncludingCap(spellName)
  -- Prefer DoitePlayerAuras if available (handles buff cap)
  if DoitePlayerAuras and DoitePlayerAuras.HasBuff then
    return DoitePlayerAuras.HasBuff(spellName) and true or false
  end
  -- Fallback to libdebuff or raw API
  -- ...
end

-- Usage:
if HasBuffIncludingCap("Flurry") then
  -- Flurry is active, even if pushed past slot 32 in a world-buffed raid
end
```

### Querying Remaining Duration on Target Debuff

Useful for refreshing debuffs at the right time (e.g., reapply Rend with < 3s left).

```lua
-- Requires the debuff to be configured in DoiteAuras with onlyMine = true
local function GetMyDebuffRemaining(spellName, unit)
  if DoiteTrack and DoiteTrack.GetAuraRemainingSecondsByName then
    local rem = DoiteTrack:GetAuraRemainingSecondsByName(spellName, unit or "target")
    return rem  -- seconds remaining, or nil
  end
  return nil
end

-- Usage in a rotation decision:
local rendRemaining = GetMyDebuffRemaining("Rend", "target")
if not rendRemaining or rendRemaining < 3 then
  -- Time to reapply Rend
end
```

### Checking if Debuff is Mine vs. Another Player's

```lua
local function IsMyDebuffOnTarget(spellName)
  if DoiteTrack and DoiteTrack.GetAuraOwnershipByName then
    local _, _, _, hasMine = DoiteTrack:GetAuraOwnershipByName(spellName, "target")
    return hasMine == true
  end
  return false  -- can't determine
end
```

### Getting Buff Stacks (Buff-Cap-Safe)

```lua
local function GetBuffStacksSafe(spellName)
  if DoitePlayerAuras and DoitePlayerAuras.GetBuffStacks then
    return DoitePlayerAuras.GetBuffStacks(spellName)  -- number or nil
  end
  return nil
end

local stacks = GetBuffStacksSafe("Lightning Shield")
```

### Important Integration Notes

1. **DoitePlayerAuras uses spell names, not IDs** — All public functions take
   `spellName` as a string (e.g., `"Battle Shout"`, case-sensitive to how
   `GetSpellRecField(spellId, "name")` returns it).

2. **DoiteTrack requires config** — Auras must be configured in DoiteAurasDB with
   `onlyMine = true` for duration/ownership tracking to work. It won't track
   arbitrary auras automatically.

3. **Nil-safe access** — Always check `DoitePlayerAuras` and `DoiteTrack` exist
   before calling methods (the addon may not be installed/loaded).

4. **No addon dependency needed** — IWinEnhanced doesn't need to declare DoiteAuras
   as a dependency. Just nil-check the globals at runtime.
