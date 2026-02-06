# Vanilla 1.12 WoW Lua API -- Essentials for Macros

> Source: Turtle-WoW-UI-Source FrameXML (refaim/Turtle-WoW-UI-Source)
> and standard vanilla 1.12 client API | Updated: 2026-02-06

Curated API functions most commonly used in `/run` macros. Functions marked
**SuperWoW** have enhanced behavior -- see `superwow-api.md` for details.
Nampower adds 30+ custom events and functions -- see `nampower-events.md` and `nampower-api.md`.

---

## Unit Functions

```lua
UnitName(unitId)                    --> name, realm
UnitLevel(unitId)                   --> level (-1 for "??")
UnitHealth(unitId)                  --> currentHP
UnitHealthMax(unitId)               --> maxHP
UnitMana(unitId)                    --> currentPower [, casterMana]
    -- **SuperWoW:** druids return (formPower, casterMana) while shifted -> See superwow-api.md#UnitMana
UnitManaMax(unitId)                 --> maxPower [, casterMaxMana]
UnitPowerType(unitId)               --> type (0=mana,1=rage,2=focus,3=energy,4=happiness)

UnitClass(unitId)                   --> localizedName, "WARRIOR"|"DRUID"|...
UnitRace(unitId)                    --> localizedRace
UnitSex(unitId)                     --> 1=unknown, 2=male, 3=female
UnitCreatureType(unitId)            --> "Beast"|"Humanoid"|"Undead"|...
UnitClassification(unitId)          --> "normal"|"elite"|"rareelite"|"rare"|"worldboss"

UnitExists(unitId)                  --> 1 or nil
    -- **SuperWoW:** returns GUID string instead of 1 -> See superwow-api.md#UnitExists
UnitIsDeadOrGhost(unitId)           --> 1 or nil
UnitIsDead(unitId)                  --> 1 or nil
UnitIsPlayer(unitId)                --> 1 or nil
UnitIsUnit(unit1, unit2)            --> 1 or nil  (same unit?)
UnitIsEnemy(unit1, unit2)           --> 1 or nil
UnitIsFriend(unit1, unit2)          --> 1 or nil
UnitCanAttack(unit1, unit2)         --> 1 or nil  (can unit1 attack unit2?)
UnitAffectingCombat(unitId)         --> 1 or nil
UnitIsConnected(unitId)             --> 1 or nil

UnitBuff(unitId, index [, filter])  --> texture [, stacks [, auraId]]
    -- **SuperWoW:** additionally returns aura spell ID -> See superwow-api.md#UnitBuff
UnitDebuff(unitId, index [, filter])--> texture, stacks, debuffType [, auraId]
    -- **SuperWoW:** additionally returns aura spell ID -> See superwow-api.md#UnitDebuff
    -- debuffType: "Magic"|"Curse"|"Disease"|"Poison"|nil

UnitReaction(unit1, unit2)          --> 1-7 (1-2=hostile, 4=neutral, 5-7=friendly)
UnitFactionGroup(unitId)            --> "Alliance"|"Horde"|nil
UnitIsPVP(unitId)                   --> 1 or nil
UnitIsTapped(unitId)                --> 1 or nil
UnitIsTappedByPlayer(unitId)        --> 1 or nil
UnitPlayerControlled(unitId)        --> 1 or nil
```

**Standard unit tokens:** `"player"`, `"target"`, `"pet"`, `"mouseover"`,
`"party1"`-`"party4"`, `"raid1"`-`"raid40"`, `"targettarget"`,
`"partypet1"`-`"partypet4"`, `"raidpet1"`-`"raidpet40"`

**SuperWoW extended tokens:** `"targetowner"`, `"petowner"`, `"mark1"`-`"mark8"`,
raw GUID hex strings.

---

## Spell Functions

```lua
CastSpellByName(name [, onSelf])    -- primary macro cast function
    -- **SuperWoW:** second arg can be unit token string -> See superwow-api.md#CastSpellByName
CastSpell(spellIndex, bookType)     -- cast by spellbook index ("spell"|"pet")
SpellStopCasting()                  -- interrupt your own cast

GetSpellCooldown(index, bookType)   --> startTime, duration, enable
    -- Compare: (GetTime() - startTime) >= duration means ready
GetSpellTexture(index, bookType)    --> texturePath
GetSpellName(index, bookType)       --> name, subName

SpellIsTargeting()                  --> 1 or nil (awaiting target click?)
SpellTargetUnit(unitId)             -- apply pending spell to unit
SpellCanTargetUnit(unitId)          --> 1 or nil
SpellStopTargeting()                -- cancel pending targeting

GetNumSpellTabs()                   --> numTabs
GetSpellTabInfo(tabIndex)           --> name, texture, offset, numSpells
IsCurrentCast(index, bookType)      --> 1 or nil
```

---

## Target Functions

```lua
TargetUnit(unitId)                  -- target a specific unit
TargetNearestEnemy([reverse])       -- TAB targeting; pass 1 to reverse
TargetNearestFriend()
TargetLastTarget()                  -- swap back to previous target
TargetLastEnemy()                   -- re-target last enemy
AssistUnit(unitId)                  -- target what unit is targeting
ClearTarget()                       -- clear current target

SetRaidTarget(unitId, iconIndex)    -- 0=none, 1-8=star..skull
    -- **SuperWoW:** optional 3rd arg for solo marking -> See superwow-api.md#SetRaidTarget
GetRaidTargetIndex(unitId)          --> 1-8 or nil
```

---

## Action Bar

```lua
UseAction(slot, checkCursor [, onSelf])  -- fire action button (1-120)
HasAction(slot)                     --> 1 or nil
IsCurrentAction(slot)               --> 1 or nil  (is button pressed/active?)
IsUsableAction(slot)                --> isUsable, notEnoughMana
IsAttackAction(slot)                --> 1 or nil
IsAutoRepeatAction(slot)            --> 1 or nil
IsActionInRange(slot)               --> 1 or 0 (nil if no range check)
GetActionCooldown(slot)             --> startTime, duration, enable
GetActionTexture(slot)              --> texturePath
GetActionCount(slot)                --> count
```

---

## Inventory and Items

```lua
GetContainerNumSlots(bagId)         --> numSlots  (bagId 0-4, 0=backpack)
GetContainerItemInfo(bag, slot)     --> texture, count, locked, quality, readable
    -- **SuperWoW:** returns negative count for charged items -> See superwow-api.md#GetContainerItemInfo
GetContainerItemLink(bag, slot)     --> itemLink string
UseContainerItem(bag, slot [, onSelf])  -- use/equip item from bag
PickupContainerItem(bag, slot)      -- pick up for moving

GetInventorySlotInfo(slotName)      --> slotId, texture, checkRelic
    -- slotNames: "HeadSlot","MainHandSlot","Trinket0Slot", etc.
GetInventoryItemLink(unit, invSlot) --> itemLink or nil
PickupInventoryItem(invSlot)        -- pick up equipped item
UseInventoryItem(invSlot)           -- use equipped item

GetItemInfo(itemId)                 --> name, link, quality, iLevel, reqLevel,
                                    --  class, subclass, maxStack, equipSlot, texture

GetWeaponEnchantInfo()              --> hasMH, mhExpire, mhCharges,
                                    --  hasOH, ohExpire, ohCharges
    -- **SuperWoW:** accepts optional unit arg, returns enchant names -> See superwow-api.md#GetWeaponEnchantInfo
```

---

## Shapeshift / Forms

```lua
GetNumShapeshiftForms()             --> count
GetShapeshiftFormInfo(index)        --> icon, name, isActive, isCastable
CastShapeshiftForm(index)           -- shift to form by index
```

Warrior stances: 1=Battle, 2=Defensive, 3=Berserker
Druid forms: 1=Bear, 2=Aquatic, 3=Cat, 4=Travel, 5=Moonkin/Tree (varies)

---

## Chat

```lua
SendChatMessage(msg, chatType [, lang, target])
    -- chatType: "SAY","PARTY","RAID","GUILD","WHISPER","CHANNEL","EMOTE","YELL"
    -- target: player name for WHISPER, channel number for CHANNEL

DEFAULT_CHAT_FRAME:AddMessage(text [, r, g, b])
    -- Print colored text to chat window (local only)
```

---

## Modifier Keys

```lua
IsShiftKeyDown()                    --> 1 or nil
IsControlKeyDown()                  --> 1 or nil
IsAltKeyDown()                      --> 1 or nil
```

---

## Timing

```lua
GetTime()                           --> seconds (float, ms precision)
    -- Primary timer for cooldown math, throttling, debouncing
```

---

## Frame API Basics

```lua
CreateFrame(type, name, parent [, template])
    -- type: "Frame","Button","StatusBar","GameTooltip", etc.
    -- Returns: frame object

getglobal(name)                     --> object  (access global by string name)

-- Common frame methods:
frame:SetScript("OnUpdate", function() ... end)
frame:SetScript("OnEvent", function() ... end)
frame:RegisterEvent("EVENT_NAME")
frame:Show() / frame:Hide()
frame:IsShown()                     --> 1 or nil
```

---

## Addon Detection

```lua
IsAddOnLoaded(addonName)            --> isLoaded, onDemand
    -- Returns 1 if loaded, nil otherwise
```

Detection patterns for the Turtle WoW macro stack:
```lua
local hasSuperWoW  = SUPERWOW_VERSION ~= nil
local hasNampower  = QueueSpellByName ~= nil
local hasUnitXP    = UnitXP and UnitXP("nop", "nop")
local hasCleveroid = IsAddOnLoaded("SuperCleveRoidMacros")
```

---

## Player Buff Functions

```lua
GetPlayerBuff(index, filter)        --> buffIndex (-1 if none), untilCancelled
    -- filter: "HELPFUL","HARMFUL","CANCELABLE","NOT_CANCELABLE"
GetPlayerBuffTexture(buffIndex)     --> texture
GetPlayerBuffTimeLeft(buffIndex)    --> seconds remaining
GetPlayerBuffApplications(buffIndex)--> stackCount
CancelPlayerBuff(buffIndex)         -- cancel a buff
```

---

## Common Vanilla Events (for frame:RegisterEvent)

| Event | Args | Description |
|-------|------|-------------|
| `PLAYER_TARGET_CHANGED` | -- | Target changed |
| `UNIT_HEALTH` | arg1=unitId | Health changed |
| `UNIT_MANA` / `UNIT_RAGE` / `UNIT_ENERGY` | arg1=unitId | Power changed |
| `UNIT_AURA` | arg1=unitId | Buffs/debuffs changed |
| `PLAYER_REGEN_DISABLED` | -- | Entered combat |
| `PLAYER_REGEN_ENABLED` | -- | Left combat |
| `SPELLCAST_START` | arg1=name, arg2=castTimeMs | Cast started. **SuperWoW:** also provides spellId |
| `SPELLCAST_STOP` | -- | Finished casting |
| `SPELLCAST_FAILED` | -- | Cast failed |
| `SPELLCAST_INTERRUPTED` | -- | Cast interrupted |
| `SPELLCAST_CHANNEL_START` | arg1=durationMs, arg2=name | Channel started |
| `SPELLCAST_CHANNEL_STOP` | -- | Channel ended |
| `BAG_UPDATE` | arg1=bagId | Bag contents changed |
| `UPDATE_MOUSEOVER_UNIT` | -- | Mouseover changed |
| `PLAYER_ENTERING_WORLD` | -- | Login / reload / zone |
| `ACTIONBAR_UPDATE_COOLDOWN` | -- | Cooldown changed |

**Nampower adds 30+ custom events** (spell queue, cast, damage, aura, auto-attack, heal, energize, unit death). See `nampower-events.md` for full reference.
