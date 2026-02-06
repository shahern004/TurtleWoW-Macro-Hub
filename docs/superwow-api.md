# SuperWoW API Reference

> Source: https://github.com/balakethelock/SuperWoW/wiki
> Version: v2.0
> Last fetched: 2026-02-06

SuperWoW is a DLL injection mod for the 1.12.1 WoW client that fixes bugs and
expands the Lua API. It is a hard dependency for SuperCleveRoidMacros.

---

## Table of Contents

1. [Modified Functions](#modified-functions)
2. [New Functions](#new-functions)
3. [Events](#events)
4. [Enhanced Unit Suffixes](#enhanced-unit-suffixes)
5. [CVars](#cvars)
6. [Global Variables](#global-variables)
7. [Other Behavior Changes](#other-behavior-changes)

---

## Modified Functions

These vanilla functions have been changed by SuperWoW.

### CastSpellByName(spell, [unit/onSelf])

*(vanilla: only accepts boolean onSelf flag)*

Now accepts a unit token string as the second argument. Backward-compatible with `1`, `0`, `true`, `false`.
In v2.0, also accepts `"CLICK"` flag for reticle spell placement at cursor.

```lua
CastSpellByName("Flash Heal", "party2")   -- cast on party2
CastSpellByName("Flash Heal", 1)          -- cast on self (vanilla behavior)
CastSpellByName("Blizzard", "CLICK")      -- place reticle at cursor (v2.0)
```

**See also:** `nampower-api.md` (`QueueSpellByName` for spell queuing), `vanilla-api-essentials.md#CastSpellByName`

### UnitExists(unit)

*(vanilla: returns 1 or nil)*

Additionally returns the unit's GUID string.

```lua
local exists = UnitExists("target")        -- vanilla: 1 or nil
local guid   = UnitExists("target")        -- SuperWoW: GUID string or nil
```

**See also:** `vanilla-api-essentials.md#UnitExists`

### UnitBuff(unit, index [, castable])

*(vanilla: returns texture, stacks only)*

Additionally returns the aura (spell) ID as an extra return value.

```lua
local texture, stacks, auraId = UnitBuff("player", 1)
```

**See also:** `vanilla-api-essentials.md#UnitBuff`

### UnitDebuff(unit, index [, showDispellable])

*(vanilla: returns texture, stacks, debuffType only)*

Additionally returns the aura (spell) ID as an extra return value.

```lua
local texture, stacks, debuffType, auraId = UnitDebuff("target", 1)
```

**See also:** `vanilla-api-essentials.md#UnitDebuff`

### UnitMana("player")

*(vanilla: returns only current-form power)*

For druids in shapeshift form, returns both current-form power and caster mana.

```lua
local power, casterMana = UnitMana("player")
```

### frame:GetName(1)

When called with argument `1` on a nameplate frame, returns the attached unit's
GUID string instead of the frame name.

```lua
local guid = nameplateFrame:GetName(1)
```

### SetRaidTarget(unit, raidTargetIndex [, local])

*(vanilla: requires party/raid to set marks)*

Optional third argument enables solo raid-target marking without requiring a
party or raid.

```lua
SetRaidTarget("target", 8, 1)  -- mark skull even when solo
```

### LootSlot(slotId [, forceLoot])

Second argument, when set to `1`, forces the actual looting action.

```lua
LootSlot(1, 1)  -- force loot slot 1
```

### GetContainerItemInfo(bagId, slotId)

*(vanilla: no charge info for non-stackable items)*

For non-stackable charged items (e.g., engineering devices), returns item
charges as a negative number instead of stack count.

### GetWeaponEnchantInfo([unit])

*(vanilla: player-only, no enchant names)*

Accepts an optional friendly player unit token. Returns temporary enchant names
on their mainhand and offhand.

### GetActionText(actionSlot)

Now also returns the action type and action ID for macros using `/tooltip`.

### GetActionCount / GetActionCooldown / ActionIsConsumable

These now work correctly for macros that use the `/tooltip spell:id` or
`/tooltip item:id` prefix.

---

## New Functions

### GetPlayerBuffID(buffIndex)

Returns the aura (spell) ID for the player buff at the given index.

```lua
local auraId = GetPlayerBuffID(1)
```

### CombatLogAdd(text [, addToRawLog])

Writes a line directly to the combat log files. If `addToRawLog` is truthy,
also writes to the raw combat log file.

### SpellInfo(spellId)

Returns spell metadata from the client DBC data.

```lua
local name, rank, texture, minRange, maxRange = SpellInfo(spellId)
```

### TrackUnit(unitId) / UntrackUnit(unitId)

Adds or removes a friendly unit from the minimap tracking. (v2.0 split
`TrackUnit` into two functions.)

### UnitPosition(unitId)

Returns the X, Y coordinates of a friendly unit.

```lua
local x, y = UnitPosition("player")
```

### SetMouseoverUnit(unitId)

Programmatically sets the current mouseover unit, enabling mouseover-based
macros to work on arbitrary units.

### Clickthrough(flag)

Toggles or queries the clickthrough mode for the game window.

```lua
Clickthrough(1)         -- enable clickthrough
Clickthrough(0)         -- disable clickthrough
local state = Clickthrough()  -- query current state
```

### SetAutoloot(flag)

Toggles or queries the autoloot setting (also works for enchanting and
pickpocketing).

```lua
SetAutoloot(1)          -- enable autoloot
local state = SetAutoloot()  -- query
```

### ImportFile(filename)

Reads text from a file in the game directory's `imports` folder.

```lua
local contents = ImportFile("mydata.txt")
```

### ExportFile(filename, text)

Writes text to a file in the game directory's `imports` folder.

```lua
ExportFile("output.txt", "Hello World")
```

### UnitNameplate(unitId) (v2.0)

Returns the nameplate frame for a unit.

### CanLootUnit(unitId) (v2.0)

Returns whether a unit can be looted.

### CursorPosition() (v2.0)

Returns the current cursor screen position.

### IsSwimming() (v2.0)

Returns whether the player is currently swimming.

### IsMounted() (v2.0)

Returns whether the player is currently mounted.

### IsIndoors() (v2.0)

Returns whether the player is currently indoors.

### GetSpeed() (v2.0)

Returns the player's current movement speed.

### GetWorldLocMapPosition() / GetMapPositionWorldLoc() / GetMapBoundaries() (v2.0)

Map coordinate conversion functions for translating between world coordinates
and map positions.

---

## Events

### UNIT_CASTEVENT

Fires when any visible unit begins, finishes, fails, or channels a spell, or
performs a melee swing.

| arg | Type | Description |
|-----|------|-------------|
| arg1 | string | Caster GUID |
| arg2 | string | Target GUID |
| arg3 | string | Event type: `"START"`, `"CAST"`, `"FAIL"`, `"CHANNEL"`, `"MAINHAND"`, `"OFFHAND"` |
| arg4 | number | Spell ID (0 for melee) |
| arg5 | number | Cast duration in milliseconds |

**See also:** `nampower-events.md` (`SPELL_START_SELF/OTHER`, `SPELL_CAST_EVENT` for Nampower equivalents)

### RAW_COMBATLOG

Fires alongside every standard combat log event, providing the raw,
unprocessed version. Raw logs are also written to a separate text file.

### CREATE_CHATBUBBLE (v2.0)

Fires when a chat bubble is created.

### SPELLCAST_START (modification)

The vanilla `SPELLCAST_START` event is enhanced by SuperWoW. The spell ID is
made available in addition to the standard `arg1` (spell name) and `arg2`
(cast time in ms).

---

## Enhanced Unit Suffixes

SuperWoW extends the unit token system with additional suffixes and accepts
GUID strings directly.

### "owner" suffix

Retrieves the owner of a pet, totem, or other controlled unit.

```lua
local ownerName = UnitName("targetowner")  -- name of target's owner
local ownerHP   = UnitHealth("petowner")   -- health of pet's owner
```

### "mark1" through "mark8" suffixes

Target the unit bearing the corresponding raid marker. **See also:** `unitxp-api.md#targeting-functions` (marked enemy targeting via UnitXP).

| Suffix | Raid Mark |
|--------|-----------|
| `mark1` | Yellow Star |
| `mark2` | Orange Circle |
| `mark3` | Purple Diamond |
| `mark4` | Green Triangle |
| `mark5` | White Moon |
| `mark6` | Blue Square |
| `mark7` | Red Cross (X) |
| `mark8` | White Skull |

```lua
local skullHP = UnitHealth("mark8")        -- HP of skull-marked unit
CastSpellByName("Heal", "mark8")           -- heal the skull target
```

### GUID strings as unit tokens

Any function that accepts a unit token also accepts a raw GUID hex string
(obtained from `UnitExists()` or nameplate `GetName(1)`).

```lua
local guid = UnitExists("target")
local hp   = UnitHealth(guid)
```

---

## CVars

| CVar | Default | Description |
|------|---------|-------------|
| `BackgroundSound` | 0 | Enable/disable audio when game is in background |
| `UncapSounds` | 0 | Remove hardcoded sound channel limits |
| `FoV` | 1.57 | Camera field of view in radians (0.1 to 3.14) |
| `LootSparkle` | 1 | Toggle sparkling effect on lootable corpses |
| `SelectionCircleStyle` | 0 | Selection circle appearance (0=classic, 1=full, 2=pointed, 3=facing) |
| `ChatBubbleRange` | 60 | Chat bubble visibility range in yards (vanilla: 20) |
| `ChatBubblesRaid` | 1 | Show chat bubbles in raid chat (v2.0) |
| `ChatBubblesBattleground` | 1 | Show chat bubbles in battleground chat (v2.0) |
| `ChatBubblesWhisper` | 0 | Show chat bubbles for whispers (v2.0) |
| `ChatBubblesCreatures` | 1 | Show chat bubbles for creature speech (v2.0) |
| `NameplateRange` | -- | Nameplate visibility range in yards (v2.0) |
| `NameplateMotion` | -- | Nameplate motion behavior (v2.0) |
| `HealingText` | 1 | Show healing values in floating combat text (v2.0) |

---

## Global Variables

| Variable | Type | Description |
|----------|------|-------------|
| `SUPERWOW_VERSION` | number/string | Current SuperWoW version; use to detect presence |
| `SUPERWOW_STRING` | string | Mod information string |

Detection pattern:
```lua
local hasSuperWoW = SUPERWOW_VERSION ~= nil
```

---

## Other Behavior Changes

| Change | Details |
|--------|---------|
| Macro character limit | Raised from 255 to 510. Reduces need for SuperMacro addon |
| Healing combat text | Healing amounts on nameplates (CVar `HealingText`) |
| Chat bubble range | Increased from 20 to 60 yards (CVar `ChatBubbleRange`) |
| Chat bubble channels | Raid, BG, whisper, creature speech (configurable via CVars) |
| Spell/recipe chat links | Spell and crafting recipe links work in chat |
| Absorb in combat log | Fully absorbed damage correctly shown |
| Buff bar | Shows all buffs including those without icons |
| Combat log owners | Pet/totem owner names appended to entries |
| Inspect range | No distance restriction on inspecting friendly players |
| Circle targeting spells | No erroneous "moving" casting errors |
| Autoloot expanded | Works for enchanting and pickpocketing via `SetAutoloot` |
| Macros as spells/items | `/tooltip spell:id` or `/tooltip item:id` shows spell/item tooltip, cooldown, and count |
