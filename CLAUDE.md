# TurtleWoW Macros Project

## Golden Directive
**ALWAYS ask the user to provide missing information before filling knowledge gaps with assumptions or searching the internet.**
- Do not guess API signatures, function behaviors, addon capabilities, or server-specific features
- If documentation is unclear or missing, ask the user first
- Verify against Turtle WoW docs — vanilla 1.12 API behavior often differs here

## Macro Creation Workflow

1. **Clarify** — understand class, spec, desired behavior, modifier keys, fallback logic. Ask if anything is ambiguous
2. **Check existing work** — search `macros/` and `patterns.md` for similar implementations to build on
3. **Read docs** — use the **Task Routing** table to pick which `docs/` files to read. Always read before using any custom API function
4. **Write** — choose the right approach: `/cast` conditional chains for simple macros, `/run` Lua for complex logic, or addon-based (frame + events) for full rotation automation. Include `@header` metadata for macro files (see **Macro File Format**)
5. **Present & test** — show the complete macro and **wait for the user's in-game verification**. Do NOT commit or push until the user explicitly confirms it passed
6. **Iterate or commit** — if the test fails, fix and re-present. If it passes, commit only when the user asks

## Project Structure
```
addons/IWinEnhanced/      # IWinEnhanced dev copy (edit here, deploy to live)
  warrior/rotation.lua    # Rotation priority chains (/idps, /icleave, /itank, /ihodor)
  warrior/action.lua      # Ability function implementations (self-gating, rage checks)
  warrior/setup.lua       # Config system (/iwin slash command)
  warrior/data.lua        # Rage cost table
docs/                     # API reference (read on-demand per task)
  superwow-api.md         # SuperWoW DLL functions, events, CVars
  nampower-api.md         # Nampower Lua functions (30+)
  nampower-events.md      # Nampower custom events (30+)
  nampower-cvars.md       # Nampower CVar configuration
  unitxp-api.md           # UnitXP_SP3 functions (distance, LoS, targeting)
  cleveroid-syntax.md     # SuperCleveRoidMacros slash commands & syntax
  cleveroid-conditionals.md  # Full 100+ conditionals reference
  vanilla-api-essentials.md  # Curated vanilla 1.12 Lua API
  patterns.md             # Annotated macro pattern templates
  warrior-rotations.md    # Warrior rotation priorities & mechanics (extracted from warrior-guide.md)
  warrior-guide.md        # Full warrior guide (opinions, gear, consumes -- source material)
  iwin-code-review-rules.md  # 17 rule categories for IWinEnhanced code review
  _VERSIONS.md            # Dependency version tracking
.claude/skills/           # Claude Code skills (iwin-analyzer, etc.)
macros/class/<class>/     # Class-specific macros (warrior/, rogue/, etc.)
macros/general/           # Class-agnostic (targeting/, consumables/, movement/, utility/)
macros/pvp/ macros/raid/  # PvP and raid macros
snippets/                 # Reusable Lua fragments (detection.lua, helpers.lua)
plans/                    # Implementation plans and research notes
```

## Which Docs to Read (Task Routing)

| Task | Read These Docs |
|------|----------------|
| **Writing a `/cast` rotation macro** | `cleveroid-syntax.md` (slash commands) + `cleveroid-conditionals.md` (conditions) + `patterns.md` (examples) |
| **Warrior macro specifically** | Above + `warrior-rotations.md` (priorities & mechanics) |
| **Using distance, LoS, or behind checks** | `unitxp-api.md` (5 meter types, LoS caching, targeting) |
| **Querying DBC data (spell/item/unit info)** | `nampower-api.md` (GetSpellRec, GetItemStats, GetUnitData -- mind reusable tables!) |
| **Listening for combat events** | `nampower-events.md` (30+ events) + `nampower-cvars.md` (CVar gates) |
| **Writing `/run` Lua snippets** | `vanilla-api-essentials.md` (base API) + `superwow-api.md` (enhanced functions) |
| **Tracking debuffs across target swaps** | `cleveroid-conditionals.md#debuff-tracking` (built-in vs Cursive) |
| **Checking immunity / CC** | `cleveroid-conditionals.md#cc--immunity` + `cleveroid-conditionals.md#immunity-tracking` |
| **Spell queuing behavior** | `nampower-api.md#spell-casting-and-queuing` + `nampower-cvars.md#spell-queuing-controls` |
| **IWinEnhanced code review** | `iwin-code-review-rules.md` (17 rule categories) + `warrior-rotations.md` (expected priorities) |

## Dependency Stack
| Source | Doc File(s) | Purpose |
|--------|------------|---------|
| **SuperWoW** (DLL) | `superwow-api.md` | Enhanced Lua API: GUID via UnitExists, aura IDs via UnitBuff/UnitDebuff, file I/O, UNIT_CASTEVENT, mark1-8 units, CastSpellByName with unit arg |
| **Nampower** (DLL) | `nampower-api.md`, `nampower-events.md`, `nampower-cvars.md` | Spell queuing (QueueSpellByName), DBC data (GetSpellRec, GetItemStats, GetUnitData), cast/cooldown info, 30+ custom events |
| **SuperCleveRoidMacros** (addon) | `cleveroid-syntax.md`, `cleveroid-conditionals.md` | Conditional macro system: 100+ conditionals, /cast with [cond], multiscan, immunity tracking, debuff timers |
| **UnitXP_SP3** (DLL) | `unitxp-api.md` | Distance (5 meters), line-of-sight, behind check, advanced targeting, timers |
| **Vanilla 1.12 API** | `vanilla-api-essentials.md` | Base WoW API (many functions enhanced by SuperWoW) |
| **IWinEnhanced** (addon) | `addons/IWinEnhanced/warrior/` | Rotation automation: `/idps`, `/icleave`, `/itank`, `/ihodor` with queueGCD mutex, rage reservation, slam timing. Dev copy in repo, deploy to live with `cp -r` |

## SuperCleveRoidMacros Quick Reference
**Basic syntax:** `/cast [cond1,cond2] Spell; [cond3] Other Spell`
- Conditionals in `[]`, comma/space = AND, semicolon = else-if chain
- Arguments via colon: `[mod:alt]`, `[hp:>50]`, `[buff:"Name"<5]`
- Negation: `no` prefix — `[nobuff]`, `[nocombat]`, `[nomod:alt]`
- Target override: `[@mouseover,help]`, `[@party1,hp:<50]`
- Multi-value: `/` = OR, `&` = AND — `[buff:X/Y]` = has X or Y
- Stacks: `>#N` — `[debuff:"Sunder">#4]` = 5+ stacks
- Prefixes: `!Spell` (only if not active), `?[cond] Spell` (hide tooltip), `~Spell` (toggle)

**15 Most-Used Conditionals:**
| Conditional | Example | What it checks |
|-------------|---------|---------------|
| `mod` | `[mod:alt]` | Modifier key |
| `combat` | `[combat]` | In combat |
| `form/stance` | `[stance:1]` | Shapeshift form (1=Battle,2=Def,3=Zerk) |
| `myhp` | `[myhp:<30]` | Player HP % |
| `mypower` | `[mypower:>50]` | Player power % (mana/rage/energy) |
| `buff/debuff` | `[debuff:"Sunder"<5]` | Target buff/debuff (with time check) |
| `mybuff` | `[mybuff:"Flurry"]` | Player has buff |
| `cooldown` | `[cooldown:"Spell"<2]` | CD remaining (ignores GCD) |
| `hp` | `[hp:<20]` | Target HP % |
| `harm/help` | `[harm]` | Target is hostile/friendly |
| `exists` | `[@mouseover,exists]` | Unit exists |
| `distance` | `[distance:<8]` | Distance in yards (UnitXP) |
| `meleerange` | `[meleerange:>1]` | Count enemies in melee range |
| `noimmune` | `[noimmune:bleed]` | Target NOT immune to school |
| `reactive` | `[reactive:Overpower]` | Reactive ability available |

**Key Slash Commands:** `/cast`, `/use`, `/target`, `/startattack`, `/stopcasting`, `/cancelaura`, `/stopmacro`, `/skipmacro`, `/firstaction`, `/nofirstaction`, `/unshift`, `/castsequence`, `/equipmh`, `/equipoh`

## Key API Functions Quick Reference
```lua
-- SuperWoW
UnitExists("unit")                    --> guid (enhanced: returns GUID string)
UnitBuff("unit", index)               --> name, rank, texture, auraId (enhanced)
UnitDebuff("unit", index)             --> name, rank, texture, auraId (enhanced)
CastSpellByName("spell", "unit")      --> cast on specific unit (enhanced)
SpellInfo(spellId)                    --> name, rank, texture, minRange, maxRange
ImportFile("file") / ExportFile("file","text")  --> file I/O in imports/
UnitPosition("unit")                  --> coordinates
GetSpeed()                            --> runSpeed, swimSpeed (yards/sec)

-- Nampower
QueueSpellByName("spell")             --> force-queue spell
GetCastInfo()                         --> {spellId, castRemainingMs, gcdRemainingMs, ...}
GetCurrentCastingInfo()               --> castId, visId, autoId, casting, channeling, onswing, autoattack
GetSpellIdCooldown(spellId)           --> {isOnCooldown, cooldownRemainingMs, ...}
GetItemIdCooldown(itemId)             --> same structure as spell cooldown
IsSpellInRange("spell", "unit")       --> 1=yes, 0=no, -1=invalid
IsSpellUsable("spell")               --> usable, oomFlag
GetSpellRec(spellId)                  --> full DBC spell record table
GetUnitData("unit")                   --> full unit data table (health, stats, auras...)
GetUnitField("unit", "fieldName")     --> single field from unit data
GetItemStats(itemId)                  --> full DBC item record table
FindPlayerItemSlot(idOrName)          --> bag, slot
GetSpellModifiers(spellId, modType)   --> flat, percent, ret

-- UnitXP_SP3
UnitXP("distanceBetween", u1, u2)           --> distance in yards (default=ranged)
UnitXP("distanceBetween", u1, u2, "AoE")    --> AoE-accurate distance
UnitXP("distanceBetween", u1, u2, "meleeAutoAttack") --> melee-accurate
UnitXP("inSight", u1, u2)                   --> 1/0/-1 (LoS check, 100ms cache)
UnitXP("behind", u1, u2)                    --> true if u1 behind u2
UnitXP("target", "nearestEnemy")             --> target nearest (no cycle)
UnitXP("target", "nextEnemyConsideringDistance") --> TAB-target with range priority
```

## Key Events
```lua
-- SuperWoW
UNIT_CASTEVENT      -- arg1=casterGUID, arg2=targetGUID, arg3=type(START/CAST/FAIL/CHANNEL/MAINHAND/OFFHAND), arg4=spellId, arg5=duration
RAW_COMBATLOG       -- arg1=originalEvent, arg2=textWithGUIDs

-- Nampower (always on)
SPELL_QUEUE_EVENT   -- arg1=eventCode(0-5), arg2=spellId
SPELL_CAST_EVENT    -- arg1=success, arg2=spellId, arg3=castType, arg4=targetGuid, arg5=itemId
BUFF/DEBUFF_ADDED/REMOVED_SELF/OTHER -- arg1=guid, arg2=slot, arg3=spellId, arg4=stacks, arg5=level
UNIT_DIED           -- arg1=guid

-- Nampower (require CVars)
AUTO_ATTACK_SELF/OTHER          -- NP_EnableAutoAttackEvents=1 | 9 args inc. hitInfo, victimState
AURA_CAST_ON_SELF/OTHER         -- NP_EnableAuraCastEvents=1 | spellId, caster, target, duration, auraCapStatus
SPELL_HEAL_BY/ON_SELF/OTHER     -- NP_EnableSpellHealEvents=1 | target, caster, spellId, amount, crit, periodic
```

## Macro File Format
```lua
--[[ @name  @class  @spec  @description  @requires  @optional  @author  @version  @date  @tags  @notes --]]
```
See `macros/_template.lua` for full template. Key fields: `@requires` lists mandatory mods, `@notes` for CVar setup.

## Common Patterns
```lua
-- Warrior Stance Dance (Overpower from any stance)
/cast [stance:1,reactive:Overpower] Overpower
/cast [stance:2/3,reactive:Overpower] Battle Stance

-- Warrior Slam Rotation (macro-based, no auto-attack clip)
-- NOTE: For complex rotations (slam interleaving, rage reservation), we use
-- IWinEnhanced addon (/idps, /icleave). See plans/iwin-solutions-to-port.md
/firstaction
/cast [noslamclip] Slam
/cast [slamclip,reactive:Overpower] Overpower
/cast [nonextslamclip,cooldown:Bloodthirst<1] Bloodthirst
/cast [slamclip] Heroic Strike
/startattack

-- Mouseover Heal (falls through to target)
/cast [@mouseover,help,hp:<80] Flash Heal; [help,hp:<80] Flash Heal

-- Multiscan AoE (Whirlwind if 2+ enemies in melee)
/cast [meleerange:>1,noimmune] Whirlwind
/cast [meleerange:=1] Bloodthirst
```

## Casting Function Disambiguation

| Function | Source | When to Use |
|----------|--------|-------------|
| `/cast [cond] Spell` | CleveroidMacros | **Default for macros.** Conditional evaluation, priority chains, multiscan. Integrates with `/firstaction` |
| `CastSpellByName("spell", "unit")` | SuperWoW | **In `/run` scripts.** Direct cast on specific unit token. No queuing, no conditionals |
| `QueueSpellByName("spell")` | Nampower | **In `/run` scripts when queuing matters.** Forces spell into queue even outside normal queue window. Use for tight rotation scripting |
| `CastSpellByNameNoQueue("spell")` | Nampower | **In `/run` scripts when queuing must NOT happen.** Immediate cast attempt, bypasses queue entirely |

**Rule of thumb:** Use `/cast` for simple macros and conditional chains. For complex rotation logic (rage budgeting, swing timer interleaving), we use **IWinEnhanced** addon directly — it provides `/idps`, `/icleave`, `/itank`, `/ihodor` slash commands with queueGCD mutex, rage reservation, and slam timing built in. Customize via `warrior/rotation.lua` (priority chains) and `warrior/action.lua` (ability functions). See `plans/iwin-solutions-to-port.md` for code patterns. Use `QueueSpellByName` when forcing queue timing matters. Use `CastSpellByNameNoQueue` only when you explicitly need to bypass queuing.

## Gotchas
- **255 char limit**: Vanilla macro limit. SuperMacro addon removes it — use book storage for long scripts. Call child macros with `{MacroName}` syntax in CleveroidMacros or `/runmacro Name`
- **Spell name case**: Case-sensitive in CastSpellByName. Use exact names from spellbook
- **cooldown vs cdgcd**: `[cooldown]` ignores GCD — use for rotation priority logic ("is the real CD ready?"). `[cdgcd]` includes GCD — use for "is the spell truly castable right now?" checks. In most rotation macros, `[cooldown]` is correct
- **copy parameter**: Nampower table-returning functions reuse the same table. Store values immediately or pass `copy=1`
- **CVar requirements**: Auto-attack events need `NP_EnableAutoAttackEvents=1`. Aura cap tracking needs `NP_EnableAuraCastEvents=1`. Set in `Config\config.wtf` or via `/run SetCVar(...)`
- **Reactive abilities**: Must be on an action bar slot for `[reactive:Overpower]` to work
- **UnitXP distance cache**: `inSight` results cached 100ms. `distanceBetween` has 5 meter types — default is ranged, use "meleeAutoAttack" for melee
- **Macro names**: Must be unique, non-blank, and not match spell names (CleveroidMacros requirement)
- **Multiscan**: Scanned enemies must be in combat with player (except current target and @unit)
- **Buff slots**: Player has 32 buff / 16 debuff slots. NPCs have 16 debuff + 32 overflow. Check with `[nomybuffcapped]`
