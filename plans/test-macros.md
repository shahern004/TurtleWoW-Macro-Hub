# Plan: Capability Test Macros

## Goal
Validate each addon/module in the dependency stack works correctly before building complex macros. Small, focused macros that each test one layer.

## Prerequisites
- All docs/ optimized (see `plans/docs-optimization.md`) — do this first
- `macros/class/warrior/fury-rotation.lua` deleted (built from guessed data)

## Test Macros

### Macro A: `macros/class/warrior/test-sunder-startattack.lua`
**Tests:** SuperCleveRoidMacros basic `/cast` + `/startattack` + tooltip trick
**Source:** warrior-guide.md line 29-33 (guide's own recommendation)
**In-game content:**
```
/run --CastSpellByName("Sunder Armor")
/startattack
/cast Sunder Armor
```
**What it validates:**
- CleveroidMacros parses `/cast` correctly
- `/startattack` fires auto-attack
- Commented `/run --CastSpellByName()` first line causes button to show spell tooltip/cooldown
**Pass criteria:** Button shows Sunder Armor tooltip/cooldown. Pressing it starts auto-attack and casts Sunder.

### Macro B: `macros/class/warrior/test-stance-conditional.lua`
**Tests:** SuperCleveRoidMacros conditionals — `[stance:N]`
**In-game content:**
```
/cast [stance:1] Overpower
/cast [stance:2] Shield Bash
/cast [stance:3] Pummel
```
**What it validates:**
- `[stance:N]` conditional evaluates correctly per warrior stance
- CleveroidMacros falls through `/cast` lines until a condition matches
**Pass criteria:** Fires Overpower in Battle, Shield Bash in Defensive, Pummel in Berserker.

### Macro C: `macros/class/warrior/test-nampower-info.lua`
**Tests:** Nampower API — `GetCurrentCastingInfo()`
**In-game content:**
```
/run local c,v,a,casting,chan,os,aa=GetCurrentCastingInfo() DEFAULT_CHAT_FRAME:AddMessage("cast="..tostring(casting).." chan="..tostring(chan).." auto="..tostring(aa))
```
**What it validates:**
- Nampower DLL is loaded and Lua API is callable
- Function returns values without error
**Pass criteria:** Prints casting/channeling/autoattack state to chat. No Lua errors. Can test in town.

### Macro D: `macros/class/warrior/test-unitxp-distance.lua`
**Tests:** UnitXP_SP3 API — `UnitXP("distanceBetween", ...)` and `UnitXP("inSight", ...)`
**In-game content:**
```
/run local d=UnitXP("distanceBetween","player","target") local s=UnitXP("inSight","player","target") DEFAULT_CHAT_FRAME:AddMessage("dist="..format("%.1f",d or 0).." LoS="..tostring(s))
```
**What it validates:**
- UnitXP_SP3 DLL is loaded and dispatches function calls
- Distance returns a number in yards
- inSight returns 1/0/-1
**Pass criteria:** Prints distance and LoS to chat when targeting any unit. No Lua errors.

## Test Procedure
1. Create each macro in SuperMacro in-game (paste only the slash command lines, not the metadata header)
2. Bind to action bar
3. Test per pass criteria above
4. Report Pass/Fail for each
5. Fix any failures, re-test
6. Only after all 4 pass: commit

## After Tests Pass
- Update CLAUDE.md Common Patterns section with guide-sourced patterns (replace guessed ones)
- Begin building real rotation/utility macros from `docs/warrior-rotations.md`
