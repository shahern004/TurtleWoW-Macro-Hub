# UnitXP Service Pack 3 - Macro API Reference

> Source: https://codeberg.org/konaka/UnitXP_SP3 | Wiki: https://codeberg.org/konaka/UnitXP_SP3/wiki/Home
> Version: v76 stable (2026-01-30) / v77 pre-release (2026-02-04) | Updated: 2026-02-06

Distance, line-of-sight, facing, and targeting functions for macro development. Non-macro features (camera, nameplates, FPS, combat text, weather, screenshots, debugging) are omitted -- see [full upstream wiki](https://codeberg.org/konaka/UnitXP_SP3/wiki/Home).

---

## Table of Contents

1. [Version Detection](#version-detection)
2. [Line of Sight](#line-of-sight)
3. [Distance](#distance)
4. [Behind (Facing)](#behind-facing)
5. [Targeting Functions](#targeting-functions)
6. [Targeting Configuration](#targeting-configuration)
7. [Timer](#timer)
8. [OS Notifications](#os-notifications)
9. [Quick Reference](#quick-reference)
10. [Removed Sections](#removed-sections)

---

## Version Detection

```lua
-- Check if xp3 is loaded
local xp3 = pcall(UnitXP, "nop", "nop")  --> true if loaded

-- Get build timestamp (UNIX timestamp, comparable numerically)
local ok, buildTime = pcall(UnitXP, "version", "coffTimeDateStamp")

-- Get version description string
local ok, info = pcall(UnitXP, "version", "additionalInformation")
```

---

## Line of Sight

### UnitXP("inSight", unit1, unit2) -> 1 | 0 | -1

Checks line-of-sight between two units.

| Param | Type | Description |
|-------|------|-------------|
| unit1 | string | Unit ID (`"player"`, `"target"`, `"party1"`, hex GUID `"0x..."`, or `"camera"`) |
| unit2 | string | Unit ID (same options) |

**Returns:** `1` = in LoS, `0` = not in LoS, `-1` = error (invalid unit/GUID)

**Notes:**
- Results cached with 100ms TTL + 0-60ms random dither
- Bidirectional: `inSight(A,B)` and `inSight(B,A)` share cache entry
- Only accepts Unit and Player object types

**See also:** `cleveroid-conditionals.md` (`[insight]` conditional)

---

## Distance

### UnitXP("distanceBetween", unit1, unit2 [, meter]) -> float | -1.0

Returns distance in game yards between two units.

| Param | Type | Description |
|-------|------|-------------|
| unit1 | string | Unit ID or hex GUID `"0x..."` |
| unit2 | string | Unit ID or hex GUID |
| meter | string | Distance calculation method (optional, default = ranged) |

### 5 Meter Types

| Meter | Use Case | Formula |
|-------|----------|---------|
| *(default)* | Ranged spells (bolts, heals) | `max(0, totalDist - combatReach0 - combatReach1)` |
| `"AoE"` | Nova-type AoE spells | `max(0, totalDist - mobCombatReach)` |
| `"meleeAutoAttack"` | Melee weapon swings (NOT melee spells like Taunt). Z-axis check: only if vertical sep < 6.0 | `max(0, horizDist - max(5.0, reach0 + reach1 + 1.333))` min 1.5 reach/unit |
| `"chains"` | Chain spells (uses bounding radii) | `max(0, totalDist - boundingRadius0 - boundingRadius1)` |
| `"Gaussian"` | Raw 3D Euclidean (no reach adjustment) | Raw distance |

**Returns:** `float` yards, `0.0` if same unit, `-1.0` on error

**See also:** `cleveroid-conditionals.md` (`[distance]` conditional)

---

## Behind (Facing)

### UnitXP("behind", unit1, unit2) -> boolean

Returns `true` if unit1 is behind unit2.

| Param | Type | Description |
|-------|------|-------------|
| unit1 | string | The unit to check |
| unit2 | string | The reference unit (facing direction) |

### UnitXP("behindThreshold", "set", angle)

Adjusts the "behind" cone threshold.

| Param | Type | Description |
|-------|------|-------------|
| angle | number | Threshold in radians, `0` to `pi`. Default: `pi/2`. Larger = narrower back zone |

**See also:** `cleveroid-conditionals.md` (`[behind]` conditional)

---

## Targeting Functions

All targeting functions share these rules:
- No target selected -> selects nearest enemy
- Selects enemies in line-of-sight and in front of camera (targeting cone)
- Ignores totems, pets, critters
- Returns `true` when a target is found
- In-combat: only selects in-combat enemies (unless `disableInCombatFilter` active)
- Validates: attackable, not dead

### UnitXP("target", "nearestEnemy") -> boolean

Target nearest enemy. **No cycling** -- always selects closest.

### UnitXP("target", "mostHP") -> boolean

Target enemy with most HP. **No cycling** -- always selects highest HP.

### UnitXP("target", "worldBoss") -> boolean

**Cycles** through world bosses (`CLASSIFICATION_WORLDBOSS`). LoS check skipped.

### UnitXP("target", "nextEnemyInCycle") -> boolean
### UnitXP("target", "previousEnemyInCycle") -> boolean

Cycles through all enemies in range. Guaranteed full coverage (each enemy selected once). Sorts by GUID internally.

### UnitXP("target", "nextEnemyConsideringDistance") -> boolean
### UnitXP("target", "previousEnemyConsideringDistance") -> boolean

Cycles with distance-based priority using 3 range buckets:

| Bucket | Range | Cycling Limit |
|--------|-------|---------------|
| Melee | 0-8 yards | All enemies |
| Charge | 8-25 yards | 3 nearest |
| Far | 25 to farRange (default 41) yards | 5 nearest |

Nearer bucket has priority -- farther buckets are ignored if nearer bucket has targets.

### UnitXP("target", "nextMarkedEnemyInCycle" [, order]) -> boolean
### UnitXP("target", "previousMarkedEnemyInCycle" [, order]) -> boolean

Cycles through raid-marked enemies.

**Default order** (highest to lowest): Skull(8) > Cross(7) > Square(6) > Moon(5) > Triangle(4) > Diamond(3) > Circle(2) > Star(1)

**Custom order:** Pass digit string as 3rd param. `"138"` = Star(1) -> Diamond(3) -> Skull(8).

**See also:** `cleveroid-syntax.md` (`/target` commands), `superwow-api.md` (mark1-8 unit IDs)

---

## Targeting Configuration

### UnitXP("target", "rangeCone", value)

Narrows targeting cone. Range: `2.0` to `inf`. Default: `2.2`. Larger = narrower.

### UnitXP("target", "farRange", value)

Sets max targeting range. Range: `26` to `60`. Default: `41`.

### UnitXP("target", "disableInCombatFilter")

Allows targeting out-of-combat enemies while player is in combat.

### UnitXP("target", "enableInCombatFilter")

Re-enables in-combat-only targeting (default).

---

## Timer

### UnitXP("timer", "arm", delay, repeat, callback) -> timer_id

Creates a timer that calls a Lua function.

| Param | Type | Description |
|-------|------|-------------|
| delay | number | Milliseconds before first trigger |
| repeat | number | Milliseconds between triggers. `0` = one-shot |
| callback | string | Function **name as string** (not a Lua reference) |

**Returns:** `timer_id` (passed as 1st arg to callback)

**Notes:**
- Runs in a **separate thread** -- does not cost game frame time
- Triggers only when due (not every frame)
- **Not stopped on game reload.** Addon authors must disarm in `PLAYER_LOGOUT`

### UnitXP("timer", "disarm", timer_id)

Stops a running timer.

### UnitXP("timer", "size") -> number

Returns count of currently running timers.

---

## OS Notifications

### UnitXP("notify", "taskbarIcon")

Flashes game's taskbar icon. Only effective when game is in background.

### UnitXP("notify", "systemSound")

Plays system sound alert. Only effective when game is in background.

---

## Quick Reference

| Function Call | Category | Returns |
|---|---|---|
| `pcall(UnitXP, "nop", "nop")` | Version | boolean |
| `pcall(UnitXP, "version", "coffTimeDateStamp")` | Version | boolean, number |
| `pcall(UnitXP, "version", "additionalInformation")` | Version | boolean, string |
| `UnitXP("inSight", u1, u2)` | Line of Sight | 1, 0, or -1 |
| `UnitXP("distanceBetween", u1, u2 [, meter])` | Distance | float or -1.0 |
| `UnitXP("behind", u1, u2)` | Facing | boolean |
| `UnitXP("behindThreshold", "set", angle)` | Facing | - |
| `UnitXP("target", "nearestEnemy")` | Targeting | boolean |
| `UnitXP("target", "mostHP")` | Targeting | boolean |
| `UnitXP("target", "worldBoss")` | Targeting | boolean |
| `UnitXP("target", "nextEnemyInCycle")` | Targeting | boolean |
| `UnitXP("target", "previousEnemyInCycle")` | Targeting | boolean |
| `UnitXP("target", "nextEnemyConsideringDistance")` | Targeting | boolean |
| `UnitXP("target", "previousEnemyConsideringDistance")` | Targeting | boolean |
| `UnitXP("target", "nextMarkedEnemyInCycle" [, order])` | Targeting | boolean |
| `UnitXP("target", "previousMarkedEnemyInCycle" [, order])` | Targeting | boolean |
| `UnitXP("target", "rangeCone", value)` | Config | - |
| `UnitXP("target", "farRange", value)` | Config | - |
| `UnitXP("target", "disableInCombatFilter")` | Config | - |
| `UnitXP("target", "enableInCombatFilter")` | Config | - |
| `UnitXP("timer", "arm", delay, repeat, callback)` | Timer | timer_id |
| `UnitXP("timer", "disarm", timer_id)` | Timer | - |
| `UnitXP("timer", "size")` | Timer | number |
| `UnitXP("notify", "taskbarIcon")` | Notification | - |
| `UnitXP("notify", "systemSound")` | Notification | - |

---

## Removed Sections

The following UnitXP features are not relevant to macro development and are documented in the [full upstream wiki](https://codeberg.org/konaka/UnitXP_SP3/wiki/Home):

| Feature | Functions |
|---------|-----------|
| Camera Control | `cameraHeight`, `cameraVerticalDisplacement`, `cameraHorizontalDisplacement`, `cameraPitch`, `cameraFollowTarget`, `cameraOrganicSmooth`, `cameraPinHeight` |
| Nameplate Control | `modernNameplateDistance`, `hideCritterNameplate`, `prioritizeTargetNameplate`, `prioritizeMarkedNameplate`, `nameplateCombatFilter`, `showInCombatNameplatesNearPlayer` |
| FPS Cap | `FPScap`, `backgroundFPScap` |
| Floating Combat Text | `combatTextSP3` (enable/font/height), `addCombatText` |
| Weather | `weatherAlwaysClear` |
| Screenshot | `screenshot` |
| Hide EXP Text | `hideEXPtext` |
| Performance Profile | `performanceProfile` |
| Game Locale | `gameLocale` |
| Lua Debugger | `debug breakpoint` |
