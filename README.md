# TurtleWoW Macro Hub

Personal collection of macros, Lua snippets, and API reference docs for Turtle WoW 1.12 with modded client extensions.

## Dependencies

These four mods/DLLs must be installed for macros to work. Most macros require all four.

| Mod | Type | Purpose |
|-----|------|---------|
| **SuperWoW** | DLL | Enhanced Lua API: GUIDs via `UnitExists`, aura IDs via `UnitBuff`/`UnitDebuff`, `CastSpellByName` with unit arg, file I/O, `UNIT_CASTEVENT` |
| **Nampower** | DLL | Spell queuing (`QueueSpellByName`), DBC data access (`GetSpellRec`, `GetItemStats`, `GetUnitData`), cast/cooldown info, 30+ custom events |
| **UnitXP_SP3** | DLL | Distance checks (5 meter types), line-of-sight, behind check, advanced targeting, timers |
| **SuperCleveRoidMacros** | Addon | Conditional macro system: `/cast [cond] Spell` syntax, 100+ conditionals, immunity tracking, debuff timers, multiscan |

## Project Structure

```
docs/                           API reference and guides
  superwow-api.md               SuperWoW DLL functions and events
  nampower-api.md               Nampower Lua functions (30+)
  nampower-events.md            Nampower custom events (30+)
  nampower-cvars.md             Nampower CVar configuration
  unitxp-api.md                 UnitXP_SP3 functions
  cleveroid-syntax.md           SuperCleveRoidMacros slash commands and syntax
  cleveroid-conditionals.md     Full 100+ conditionals reference
  vanilla-api-essentials.md     Curated vanilla 1.12 Lua API
  patterns.md                   Annotated macro pattern templates
  warrior-rotations.md          Warrior rotation priorities and mechanics
  warrior-guide.md              Full warrior guide (source material)
macros/
  _template.lua                 Header convention for macro files
  class/warrior/                Warrior-specific macros
  general/                      Class-agnostic (targeting, consumables, movement, utility)
  pvp/                          PvP macros
  raid/                         Raid macros
snippets/
  detection.lua                 Mod/addon detection helpers
  helpers.lua                   Reusable Lua fragments
plans/                          Implementation plans and task tracking
```

## Docs Overview

| File | Covers |
|------|--------|
| `superwow-api.md` | SuperWoW functions, enhanced vanilla overrides, events, CVars |
| `nampower-api.md` | Nampower Lua functions: spell queuing, DBC data, cast info, cooldowns |
| `nampower-events.md` | Nampower custom events: buff/debuff tracking, spell casts, combat, unit death |
| `nampower-cvars.md` | CVars that enable optional Nampower event categories |
| `unitxp-api.md` | Distance, LoS, behind checks, advanced targeting, timers |
| `cleveroid-syntax.md` | `/cast` syntax, slash commands, target overrides, negation, multi-value |
| `cleveroid-conditionals.md` | All 100+ conditionals with arguments and examples |
| `vanilla-api-essentials.md` | Core vanilla 1.12 API functions relevant to macro writing |
| `patterns.md` | Reusable macro patterns: stance dance, slam rotation, mouseover, AoE |
| `warrior-rotations.md` | Fury/Arms rotation priorities, slam timing, execute phase |

## Macro File Format

Every macro file uses a standard header defined in `macros/_template.lua`:

```lua
--[[ @name  @class  @spec  @description  @requires  @optional  @author  @version  @date  @tags  @notes --]]
```

`@requires` lists mandatory mods. `@notes` documents CVar setup or other prerequisites.

## Setup Notes

**CVar requirements** -- Some Nampower events are off by default. Set these in `Config/config.wtf` or via `/run SetCVar(...)`:
- `NP_EnableAutoAttackEvents=1` -- enables `AUTO_ATTACK_SELF/OTHER` events
- `NP_EnableAuraCastEvents=1` -- enables `AURA_CAST_ON_SELF/OTHER` and aura cap tracking
- `NP_EnableSpellHealEvents=1` -- enables `SPELL_HEAL_BY/ON_SELF/OTHER` events

**SuperMacro addon** -- Vanilla has a 255-character macro limit. SuperMacro removes it by storing long macros in book storage. Call child macros with `{MacroName}` syntax in CleveroidMacros or `/runmacro Name`.

**Reactive abilities** -- Abilities like Overpower and Riposte must be placed on an action bar slot for `[reactive:Overpower]` conditionals to detect them.

**Nampower copy parameter** -- Table-returning functions (`GetSpellRec`, `GetUnitData`, etc.) reuse the same table. Store values immediately or pass `copy=1` to get a fresh copy.
