# Nampower Lua API Reference

> Source: https://gitea.com/avitasia/nampower (SCRIPTS.md)
> Version: master HEAD
> Last fetched: 2026-02-06

Nampower is a DLL mod that adds spell queuing, DBC data access, and extensive
Lua scripting functions to the 1.12.1 WoW client. It is a hard dependency for
SuperCleveRoidMacros (v2.24+).

---

## IMPORTANT: Reusable Table References

> **This is the #1 source of bugs with Nampower.** Many functions return the
> **same Lua table object** recycled across calls. Contents are overwritten on
> each call. Functions marked with **(reusable table)** below are affected.

- You **must extract values immediately** after calling the function.
- **Do not store the table reference** for later use -- it will be overwritten.
- Pass `copy=1` (or `1` as the copy parameter) to get an independent table
  that is safe to store.

Affected functions:
`GetCastInfo`, `GetEquippedItems`, `GetBagItems`, `GetBagItem`,
`GetEquippedItem`, `GetSpellIdCooldown`, `GetItemIdCooldown`, `GetItemStats`,
`GetUnitData`, `GetSpellRec`, `GetItemStatsField`, `GetUnitField`,
`GetSpellRecField`, `GetTrinkets`

```lua
-- WRONG: table will be overwritten on next call
local saved = GetCastInfo()

-- RIGHT: extract values immediately
local info = GetCastInfo()
if info then
    local id = info.spellId
    local remaining = info.castRemainingMs
end

-- RIGHT: request an independent copy
local safeCopy = GetItemStats(12345, 1)  -- copy=1
```

---

## Spell / Item / Unit Information

### GetItemStats(itemId [, copy]) -- (reusable table)

Returns a table with all ItemStats DBC record fields, plus localized
`displayName` and `description`.

- **itemId** (number) -- item ID
- **copy** (number, optional) -- pass `1` for independent copy
- **Returns:** table or nil

### GetItemStatsField(itemId, fieldName [, copy]) -- (reusable table)

Fast single-field lookup from the ItemStats DBC record.

- **itemId** (number) -- item ID
- **fieldName** (string) -- DBC field name (see DBC_FIELDS.md)
- **copy** (number, optional) -- pass `1` for array field copies
- **Returns:** field value or nil; error on invalid field name

### GetSpellRec(spellId [, copy]) -- (reusable table)

Returns a table with all SpellRec DBC record fields, plus localized `name`
and `rank`.

- **spellId** (number) -- spell ID
- **copy** (number, optional) -- pass `1` for independent copy
- **Returns:** table or nil

### GetSpellRecField(spellId, fieldName [, copy]) -- (reusable table)

Fast single-field lookup from the SpellRec DBC record.

- **spellId** (number) -- spell ID
- **fieldName** (string) -- DBC field name
- **copy** (number, optional) -- pass `1` for array copies
- **Returns:** field value or nil

### GetSpellModifiers(spellId, modifierType)

Returns current spell modifiers applied by buffs, talents, and effects.

- **spellId** (number) -- spell ID
- **modifierType** (number) -- modifier type code (0-28)
- **Returns:**
  - flat modification value (number)
  - percent modification value (number)
  - function return value indicating modifier presence

### GetUnitData(unitToken [, copy]) -- (reusable table)

Returns a table with all unit data fields (health, mana, stats, auras,
resistances, etc.).

- **unitToken** (string) -- standard unit token or GUID string
- **copy** (number, optional) -- pass `1` for independent copy
- **Returns:** table or nil

### GetUnitField(unitToken, fieldName [, copy]) -- (reusable table)

Fast single-field lookup from unit data.

- **unitToken** (string) -- unit token or GUID
- **fieldName** (string) -- field name (see UNIT_FIELDS.md)
- **copy** (number, optional) -- pass `1` for array copies
- **Returns:** field value or nil

### GetSpellIdForName(spellName)

Returns the max-rank spell ID for a spell in the player's spellbook.

- **spellName** (string) -- exact spell name, or name with rank e.g.
  `"Flash Heal(Rank 3)"`
- **Returns:** spell ID (number) or `0` if not in spellbook

### GetSpellNameAndRankForId(spellId)

Returns the localized spell name and rank string.

- **spellId** (number) -- spell ID
- **Returns:**
  - name (string)
  - rank (string) -- e.g. `"Rank 1"`

### GetSpellSlotTypeIdForName(spellName)

Returns spellbook slot information for a spell.

- **spellName** (string) -- spell name in spellbook
- **Returns:**
  - slot (number) -- 1-indexed slot, or `0` if not found
  - bookType (string) -- `"spell"`, `"pet"`, or `"unknown"`
  - spellId (number) -- or `0`

### FindPlayerItemSlot(itemIdOrName)

Searches the player's full inventory for an item by ID or name.

- **itemIdOrName** (number or string) -- item ID or item name
- **Returns:**
  - bagIndex (number or nil) -- nil=equipped, 0=backpack, 1-4=bags,
    -1=bank, 5-10=bank bags, -2=keyring
  - slotIndex (number) -- slot within container or equipment slot (0-18)
  - nil, nil if not found

### UseItemIdOrName(itemIdOrName [, target])

Uses the first matching item found in inventory.

- **itemIdOrName** (number or string) -- item ID or name
- **target** (string or number, optional) -- unit token or GUID; defaults
  to LockedTargetGuid
- **Returns:** `1` if successful, `0` if not found or failed

### GetEquippedItems(unitToken) -- (reusable table)

Returns a table of all equipped items for a unit.

- **unitToken** (string) -- unit token or GUID
- **Returns:** table with slot indices (0-18) as keys, item info tables as
  values, or nil

**Item info table fields:**
`itemId`, `stackCount`, `duration`, `spellCharges` (table), `flags`,
`permanentEnchantId`, `tempEnchantId`, `tempEnchantmentTimeLeftMs`,
`tempEnchantmentCharges`, `durability`, `maxDurability`

### GetEquippedItem(unitToken, slot) -- (reusable table)

Returns item info for one equipment slot.

- **unitToken** (string) -- unit token or GUID
- **slot** (number) -- equipment slot 0-18
- **Returns:** item info table or nil

### GetBagItems([bagIndex]) -- (reusable table)

Returns all bag contents, or a single bag's contents.

- **bagIndex** (number, optional) -- 0=backpack, 1-4=bags, -1=bank,
  5-10=bank bags, -2=keyring
- **Returns:** nested table `{ [bagIdx] = { [slot] = itemInfo } }` or nil

### GetBagItem(bagIndex, slot) -- (reusable table)

Returns item info for one specific bag slot.

- **bagIndex** (number) -- bag identifier
- **slot** (number) -- 1-indexed slot within bag
- **Returns:** item info table or nil

---

## Spell Casting and Queuing

> **IWinEnhanced uses `CastSpellByName()`** — queuing is handled by the addon framework.
> `QueueSpellByName` is available for forcing queue timing in Lua scripts.
> `CastSpellByNameNoQueue` bypasses the queue entirely (rare).

### QueueSpellByName(spellName)

Forces a spell into the queue regardless of queue window settings. Queues a
maximum of 1 GCD spell or 5 non-GCD spells per queue cycle.

- **spellName** (string) -- spell name

```lua
QueueSpellByName("Flash Heal")
```

**See also:** `nampower-cvars.md#spell-queuing-controls` (queue behavior CVars), `superwow-api.md#CastSpellByName` (direct cast with unit arg)

### CastSpellByNameNoQueue(spellName)

Forces an immediate cast attempt with no queuing behavior.

- **spellName** (string) -- spell name

### QueueScript(script [, priority])

Queues an arbitrary Lua script string using the spell queue timing logic.

- **script** (string) -- Lua code to execute
- **priority** (number, optional):
  - `1` = execute before queued spells
  - `2` = execute after non-GCD spells
  - `3` = execute after all queued spells

```lua
QueueScript("DEFAULT_CHAT_FRAME:AddMessage('Cast complete!')", 3)
```

### IsSpellInRange(spellNameOrId [, target])

Checks whether a spell is in range of a target.

- **spellNameOrId** (string or number) -- spell name or spell ID
- **target** (string or number, optional) -- unit token or GUID
- **Returns:**
  - `1` = in range
  - `0` = out of range
  - `-1` = not valid for range check

### IsSpellUsable(spellNameOrId)

Checks whether a spell can be cast right now (learned, not on CD, etc.).

- **spellNameOrId** (string or number) -- spell name or spell ID
- **Returns:**
  - isUsable: `1` or `0`
  - notEnoughMana: `1` or `0`

### ChannelStopCastingNextTick()

When queue-channeling is enabled, stops the current channel early on the
next tick.

---

## Cast Information

### GetCurrentCastingInfo()

Returns the player's current casting state.

- **Returns (7 values):**
  1. castingSpellId (number) -- or `0`
  2. visualSpellId (number) -- or `0`
  3. autoRepeatSpellId (number) -- or `0`
  4. isCasting (number) -- `1` if casting with cast time, else `0`
  5. isChanneling (number) -- `1` if channeling, else `0`
  6. isOnSwingPending (number) -- `1` if on-swing spell pending, else `0`
  7. isAutoAttacking (number) -- `1` if auto-attacking, else `0`

```lua
local spellId, _, _, casting, channeling = GetCurrentCastingInfo()
```

### GetCastInfo() -- (reusable table)

Returns detailed information about the active cast or channel.

**See also:** `nampower-events.md` (`SPELL_CAST_EVENT` for cast success/failure events)

- **Returns:** table or nil (if no active cast)

**Table fields:**
| Field | Type | Description |
|-------|------|-------------|
| castId | number | Unique cast identifier |
| spellId | number | Spell being cast/channeled |
| guid | number | Target GUID (`0` if none) |
| castType | number | 0=NORMAL, 3=CHANNEL, 4=TARGETING |
| castStartS | number | Cast start time (GetTime seconds) |
| castEndS | number | Cast end time (GetTime seconds) |
| castRemainingMs | number | Remaining cast time in ms |
| castDurationMs | number | Total cast duration in ms |
| gcdEndS | number | GCD end time (GetTime seconds) |
| gcdRemainingMs | number | GCD remaining in ms |

---

## Cooldown Information

### GetSpellIdCooldown(spellId) -- (reusable table)

Returns comprehensive cooldown data for a spell.

**See also:** `cleveroid-conditionals.md` (`[cooldown]` and `[cdgcd]` conditionals use this data)

- **spellId** (number) -- spell ID
- **Returns:** table

**Table fields:**
| Field | Type | Description |
|-------|------|-------------|
| isOnCooldown | number | `1` if any cooldown is active |
| cooldownRemainingMs | number | Max remaining CD across all types (ms) |
| itemId | number | Associated item ID (`0` if none) |
| itemHasActiveSpell | number | `1` if item has on-use spell |
| itemActiveSpellId | number | Item spell ID (`0` if none) |
| individualStartS | number | Individual CD start (GetTime seconds) |
| individualDurationMs | number | Individual CD total duration (ms) |
| individualRemainingMs | number | Individual CD remaining (ms) |
| isOnIndividualCooldown | number | `1` if on individual CD |
| categoryId | number | Shared category ID |
| categoryStartS | number | Category CD start |
| categoryDurationMs | number | Category CD duration (ms) |
| categoryRemainingMs | number | Category CD remaining (ms) |
| isOnCategoryCooldown | number | `1` if on category CD |
| gcdCategoryId | number | GCD category ID |
| gcdCategoryStartS | number | GCD start |
| gcdCategoryDurationMs | number | GCD duration (ms) |
| gcdCategoryRemainingMs | number | GCD remaining (ms) |
| isOnGcdCategoryCooldown | number | `1` if on GCD |

### GetItemIdCooldown(itemId) -- (reusable table)

Returns cooldown data for an item. Same table structure as
`GetSpellIdCooldown`.

- **itemId** (number) -- item ID
- **Returns:** table

### GetTrinkets([copy]) -- (reusable table)

Returns a table of all trinkets from equipped slots and bags.

- **copy** (number or boolean, optional) -- truthy for independent copy
- **Returns:** table of trinket entries

**Trinket entry fields:**
| Field | Type | Description |
|-------|------|-------------|
| itemId | number | Item ID |
| trinketName | string | Localized name |
| texture | string | Icon texture path |
| bagIndex | number or nil | nil=equipped, 0=backpack, 1-4=bags |
| slotIndex | number | 1-based slot |

### GetTrinketCooldown(slotOrId)

Returns cooldown data for an equipped trinket.

- **slotOrId** (number or string) -- `1` or `13` (first trinket), `2` or
  `14` (second trinket), item ID, or item name
- **Returns:** cooldown table (same as `GetSpellIdCooldown`) or `-1` if
  not found

### UseTrinket(slotOrId [, target])

Uses an equipped trinket.

- **slotOrId** (number or string) -- `1`/`13` (first), `2`/`14` (second),
  item ID, or name
- **target** (string or number, optional) -- unit token or GUID
- **Returns:** `1` (success), `0` (found but failed), `-1` (not found)

**See also:** `patterns.md#5` (trinket swap macro example)

---

## Utility

### GetNampowerVersion()

Returns the current Nampower version.

- **Returns:** major (number), minor (number), patch (number)

```lua
local major, minor, patch = GetNampowerVersion()
```

### GetItemLevel(itemId)

Returns the item level of an item.

- **itemId** (number) -- item ID
- **Returns:** itemLevel (number)

### GetItemIconTexture(displayInfoId)

Returns the texture path for an item icon.

- **displayInfoId** (number) -- item display info ID (from DBC)
- **Returns:** texture path (string) or nil

### GetSpellIconTexture(spellIconId)

Returns the texture path for a spell icon.

- **spellIconId** (number) -- spell icon ID (from DBC)
- **Returns:** texture path (string) or nil

### DisenchantAll(itemIdOrName [, includeSoulbound])

Automatically disenchants matching items in the player's bags.

**Mode 1 -- by item:**
- **itemIdOrName** (number or string) -- specific item ID or name
- **includeSoulbound** (number, optional) -- non-zero to include soulbound

**Mode 2 -- by quality:**
- **quality** (string) -- `"greens"`, `"blues"`, `"purples"`, or
  pipe-separated e.g. `"greens|blues"`
- **includeSoulbound** (number, optional) -- non-zero to include soulbound

- **Returns:** `1` if first disenchant succeeded, `0` if nothing found

**WARNING:** Disenchants without confirmation. No undo. Equipped items,
bank, keyring, and quest items are protected. Searches backpack and bags
1-4 only. Repeats every 5 seconds until complete.

```lua
DisenchantAll("greens|blues")       -- DE all green and blue weapons/armor
DisenchantAll(12345, 1)             -- DE specific item including soulbound
```
