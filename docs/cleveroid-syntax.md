# SuperCleveRoidMacros Syntax Reference

> Source: [SuperCleveRoidMacros README](https://github.com/alcmiddleton/SuperCleveRoidMacros) | Updated: 2026-02-06

Slash command syntax and structure reference. For the full 100+ conditionals list, see `cleveroid-conditionals.md`.

## Requirements

| Mod | Required | Purpose |
|-----|:--------:|---------|
| [SuperWoW](https://github.com/balakethelock/SuperWoW/releases) | Yes | Extended API (addon won't load without it) |
| [Nampower](https://gitea.com/avitasia/nampower/releases) (v2.24+) | Yes | Spell queueing, DBC data, auto-attack events |
| [UnitXP_SP3](https://codeberg.org/konaka/UnitXP_SP3/releases) | Yes | Distance checks, `[multiscan]` enemy scanning |

## Basic Syntax

- **Conditionals** go in `[]` brackets, space or comma separated. See `cleveroid-conditionals.md` for all 100+ conditionals
- **Arguments** use colon: `[mod:alt]`, `[hp:>50]`
- **Negation** with `no` prefix: `[nobuff]`, `[nomod:alt]`
- **Target** with `@`: `[@mouseover,help]`, `[@party1,hp:<50]`
- **Spell names** with spaces: `"Mark of the Wild"` or `Mark_of_the_Wild`

## Multi-Value Logic

```
[buff:X/Y]        -- X OR Y (has either)
[buff:X&Y]        -- X AND Y (has both)
[nobuff:X/Y]      -- NOT X AND NOT Y (missing both) - operators flip for negation
```

## Comparisons

```
[hp:>50]           -- Health above 50%
[buff:"Name"<5]    -- Less than 5 seconds remaining
[debuff:"Name">#3] -- 3+ stacks (use ># for stacks)
```

Operators: `>`, `<`, `>=`, `<=`, `=`, `~=`, `>#` (stacks)

## Special Prefixes

| Prefix | Example | Description |
|:------:|---------|-------------|
| `!` | `!Attack` | Only use if not active |
| `?` | `?[equipped:Swords] Ability` | Hide from tooltip |
| `~` | `~Slow Fall` | Toggle buff on/off |

## Slash Commands with Conditional Support

| Command | UnitXP Scan | Description |
|---------|:-----------:|-------------|
| `/cast [cond] Spell` | -- | Cast spell with conditionals |
| `/castpet [cond] Spell` | -- | Cast pet spell |
| `/use [cond] Item` | -- | Use item by name/ID/slot |
| `/equip [cond] Item` | -- | Equip item (same as /use) |
| `/target [cond]` | Yes | Target with conditionals + enemy scan |
| `/startattack [cond]` | -- | Start auto-attack if conditions met |
| `/stopattack [cond]` | -- | Stop auto-attack if conditions met |
| `/stopcasting [cond]` | -- | Stop casting if conditions met |
| `/unqueue [cond]` | -- | Clear spell queue if conditions met |
| `/cleartarget [cond]` | -- | Clear target if conditions met |
| `/cancelaura [cond] Name` | -- | Cancel buff if conditions met |
| `/quickheal [cond]` | -- | Smart heal (requires QuickHeal) |
| `/stopmacro [cond]` | -- | Stop ALL macro execution (including parent macros) |
| `/skipmacro [cond]` | -- | Stop current submacro only, parent continues |
| `/firstaction [cond]` | -- | Stop on first successful `/cast` or `/use` |
| `/nofirstaction [cond]` | -- | Re-enable multi-queue after `/firstaction` |
| `/petattack [cond]` | -- | Pet attack with conditionals |
| `/petfollow [cond]` | -- | Pet follow with conditionals |
| `/petwait [cond]` | -- | Pet stay with conditionals |
| `/petpassive [cond]` | -- | Pet passive with conditionals |
| `/petdefensive [cond]` | -- | Pet defensive with conditionals |
| `/petaggressive [cond]` | -- | Pet aggressive with conditionals |
| `/castsequence` | -- | Sequence with reset conditionals |
| `/equipmh [cond] Item` | -- | Equip to main hand |
| `/equipoh [cond] Item` | -- | Equip to off hand |
| `/equip11` - `/equip14 [cond]` | -- | Equip to slot (rings/trinkets) |
| `/unshift [cond]` | -- | Cancel shapeshift if conditions met |
| `/applymain [cond] Item` | -- | Apply poison/oil to main hand |
| `/applyoff [cond] Item` | -- | Apply poison/oil to off hand |

## Commands without Conditional Support

| Command | Description |
|---------|-------------|
| `/retarget` | Clear invalid target, target nearest enemy |
| `/runmacro Name` | Execute macro by name |
| `/rl` | Reload UI |

## Priority Evaluation

`/firstaction` enables "first successful cast wins" behavior. Once a `/cast` or `/use` succeeds, the macro stops evaluating subsequent lines. `/nofirstaction` re-enables normal multi-queue behavior.

### /stopmacro vs /skipmacro vs /firstaction

| Command | Behavior |
|---------|----------|
| `/stopmacro [cond]` | Stop if condition is true (regardless of cast success) |
| `/skipmacro [cond]` | Stop current submacro only, parent continues |
| `/firstaction [cond]` | Stop on first **successful** cast/use (priority mode) |
| `/nofirstaction [cond]` | Re-enable multi-queue behavior after `/firstaction` |

## UnitXP 3D Enemy Scanning

`/target` with any conditionals automatically uses UnitXP 3D scanning to find enemies in line of sight, even without nameplates visible. Exception: `[help]` without `[harm]` (friendly-only targeting). If no matching target is found, your original target is preserved.

**See also:** `unitxp-api.md#targeting-functions` (underlying UnitXP targeting API)

## Multiscan Syntax

Scans enemies and soft-casts without changing your target. Requires UnitXP_SP3.
**See also:** `unitxp-api.md#targeting-functions` (UnitXP scanning API)

| Priority | Description |
|----------|-------------|
| `nearest` | Closest enemy |
| `farthest` | Farthest enemy |
| `highesthp` | Highest HP % |
| `lowesthp` | Lowest HP % |
| `highestrawhp` | Highest raw HP |
| `lowestrawhp` | Lowest raw HP |
| `markorder` | First mark in kill order (skull > cross > square > moon > triangle > diamond > circle > star) |
| `skull`, `cross`, `square`, `moon`, `triangle`, `diamond`, `circle`, `star` | Specific raid mark |

Scanned targets must be in combat with player, except current target and `@unit` specified in macro.

## Settings Commands

```
/cleveroid                      -- View settings
/cleveroid realtime 0|1         -- Instant updates (more CPU)
/cleveroid refresh 1-10         -- Update rate in Hz
/cleveroid debug 0|1            -- Debug messages
/cleveroid learn <id> <dur>     -- Manually set spell duration
/cleveroid forget <id|all>      -- Forget duration(s)
/combotrack show|clear|debug    -- Combo point tracking
```

## Immunity Commands

```
/cleveroid listimmune [school]
/cleveroid addimmune "NPC" school [buff]
/cleveroid listccimmune [type]
/cleveroid addccimmune "NPC" type [buff]
```

## SuperMacro Integration

- `{MacroName}` syntax in `/cast` lines calls another macro inline with full conditional support
- `/runmacro Name` executes a macro by name (no conditional support)
- `/firstaction` and `/nofirstaction` in child macros affect subsequent lines in the parent macro

**See also:** `patterns.md` (annotated macro examples using these features)

## Known Issues

| Issue | Details |
|-------|---------|
| Unique macro names | Names must be non-blank, non-duplicate, and not match spell names |
| Reactive abilities | Must be placed on an action bar slot for `[reactive:X]` detection |
| HealComm | Requires MarcelineVQ's LunaUnitFrames for SuperWoW compatibility |
