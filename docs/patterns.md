# Common Macro Patterns

> Project: TurtleWoW Macros
> Last updated: 2026-02-06
> Requires: SuperWoW, Nampower (v2.24+), UnitXP_SP3, SuperCleveRoidMacros

Annotated examples of common macro patterns using the full Turtle WoW addon stack. All macros use SuperCleveRoidMacros conditional syntax (`cleveroid-syntax.md`, `cleveroid-conditionals.md`).

---

## 1. Priority DPS (Warrior -- Arms)

**Requires:** SuperWoW, Nampower, UnitXP_SP3, SuperCleveRoidMacros, SP_SwingTimer (for `[noslamclip]`)
**See also:** `warrior-rotations.md#arms--single-target`, `cleveroid-conditionals.md` (`[reactive]`, `[noslamclip]`, `[meleerange]`)

A priority-based rotation that only executes the first successful cast.
Includes stance dancing for Overpower when the target dodges.

```lua
#showtooltip
-- Enable priority mode: first successful /cast wins, rest are skipped.
/firstaction
-- If target dodged and we are in Battle Stance, fire Overpower immediately.
/cast [reactive:Overpower, stance:1] Overpower
-- If target dodged but we are NOT in Battle Stance, swap to it first.
/cast [reactive:Overpower, nostance:1] Battle Stance
-- Slam only when it will not clip the next auto-attack swing.
/cast [noslamclip] Slam
-- Mortal Strike on cooldown (main damage ability).
/cast Mortal Strike
-- Whirlwind if 2+ enemies are in melee range (AoE value).
/cast [meleerange:>1] Whirlwind
-- Re-enable normal evaluation so /startattack always runs.
/nofirstaction
-- Ensure auto-attack is running even if all casts were on cooldown.
/startattack
```

---

## 2. Mouseover Heal (Priest -- Holy)

**Requires:** SuperWoW, Nampower, SuperCleveRoidMacros
**See also:** `cleveroid-conditionals.md` (`[hplost]`, `[@mouseover]`, `[help]`, `[alive]`)

Heals a mouseover target if friendly and injured; falls back to target;
self-heals on shift.

```lua
#showtooltip
-- Shift override: always heal yourself with max-rank Flash Heal.
/cast [mod:shift] Flash Heal
-- Mouseover: if friendly, exists, alive, and missing significant HP,
-- cast Greater Heal on them.
/cast [@mouseover, help, exists, alive, hplost:>2000] Greater Heal
-- Mouseover: if friendly and only lightly injured, use Flash Heal.
/cast [@mouseover, help, exists, alive, hplost:>500] Flash Heal
-- No mouseover or mouseover is full HP: heal current target.
/cast [help, alive, hplost:>2000] Greater Heal
/cast [help, alive, hplost:>500] Flash Heal
```

---

## 3. DoT Management (Druid -- Feral)

**Requires:** SuperWoW, Nampower, SuperCleveRoidMacros, Cursive (for `[cursive]`)
**See also:** `cleveroid-conditionals.md` (`[noimmune]`, `[cursive]`, `[combo]`, `[behind]`)

Applies bleeds on the current target using Cursive for GUID-based duration
tracking and immunity checks to skip immune mobs.

```lua
#showtooltip
/firstaction
-- Rake: apply only if target is NOT immune to physical+bleed,
-- AND Cursive says Rake is not already ticking (or about to expire).
/cast [noimmune, nocursive:Rake] Rake
-- Rip: apply at 5 combo points if target is not immune and
-- Rip is not already ticking. Pure bleed -- only bleed immunity matters.
/cast [noimmune, nocursive:Rip, combo:>=5] Rip
-- Ferocious Bite: spend combo points when all DoTs are running.
-- Only bite if we have 5 combo and enough energy for a strong bite.
/cast [combo:>=5, myrawpower:>55] Ferocious Bite
-- Filler: Shred from behind, Claw if not behind.
/cast [behind] Shred
/cast Claw
/nofirstaction
/startattack
```

---

## 4. Stance Dance (Warrior -- Overpower React)

**Requires:** SuperWoW, Nampower, SuperCleveRoidMacros
**See also:** `warrior-rotations.md`, `cleveroid-conditionals.md` (`[reactive]`, `[stance]`)

Dedicated stance-dance macro for warriors to catch Overpower procs.
Swaps to Battle Stance, uses Overpower, then returns to previous stance.

```lua
#showtooltip Overpower
-- If Overpower is available and we are already in Battle Stance, use it.
/cast [reactive:Overpower, stance:1] Overpower
-- If Overpower is available but we are in Defensive Stance, swap to Battle.
/cast [reactive:Overpower, stance:2] Battle Stance
-- If Overpower is available but we are in Berserker Stance, swap to Battle.
/cast [reactive:Overpower, stance:3] Battle Stance
-- After Overpower is used (no longer reactive), swap back to Berserker.
-- The [noreactive:Overpower] condition prevents swapping before OP is used.
-- Use with a second keypress to return to your preferred DPS stance.
/cast [noreactive:Overpower, stance:1] Berserker Stance
```

---

## 5. Equipment Swap (Trinket Swap)

**Requires:** SuperWoW, SuperCleveRoidMacros
**See also:** `cleveroid-syntax.md` (`/equip13`, `/equipmh`, `/equipoh`), `nampower-api.md` (`GetTrinketCooldown`, `UseTrinket`)

Swaps trinkets based on combat state. Equips a passive trinket out of combat
and an on-use trinket entering combat.

```lua
#showtooltip
-- Out of combat: equip the passive stat trinket into trinket slot 1.
/equip13 [nocombat] Blackhand's Breadth
-- In combat: use the equipped on-use trinket for its active effect.
-- Only use if it is actually equipped (not on cooldown check here;
-- the game will show the error if on CD).
/use [combat] 13
```

For weapon swapping (e.g., sword+shield for defensive, 2H for DPS):

```lua
#showtooltip
-- Shift: equip sword and shield (defensive mode).
/equipmh [mod:shift] Quel'Serrar
/equipoh [mod:shift] Drillborer Disk
-- No modifier: equip 2H weapon (DPS mode).
/equipmh [nomod:shift] Ashkandi
```

---

## 6. Defensive Cascade (Warrior -- Protection)

**Requires:** SuperWoW, Nampower, SuperCleveRoidMacros
**See also:** `warrior-rotations.md#cooldown-usage`, `cleveroid-conditionals.md` (`[usable]`, `[stance]`, `[equipped]`)

Priority-based emergency cooldowns. Uses the strongest available first.

```lua
#showtooltip
/firstaction
-- Shield Wall: strongest CD, only usable in Defensive Stance with a shield.
-- Check that it is not on cooldown (usable check) before burning GCD.
/cast [stance:2, usable:Shield_Wall] Shield Wall
-- Not in Defensive Stance? Swap to it first (Shield Wall requires it).
/cast [nostance:2, usable:Shield_Wall] Defensive Stance
-- Last Stand: off-GCD emergency HP boost, usable in any stance.
/cast [usable:Last_Stand] Last Stand
-- Shield Block: short CD, blocks next attacks. Requires shield + Def Stance.
/cast [stance:2, equipped:Shields] Shield Block
/nofirstaction
```

---

## 7. Multiscan AoE (Warrior -- Whirlwind)

**Requires:** SuperWoW, Nampower, UnitXP_SP3, SuperCleveRoidMacros, SP_SwingTimer (for `[noslamclip]`)
**See also:** `unitxp-api.md#targeting-functions`, `cleveroid-syntax.md#multiscan-syntax`, `cleveroid-conditionals.md` (`[meleerange]`)

Uses UnitXP_SP3 multiscan to count nearby enemies and decide between single-
target and AoE abilities.

```lua
#showtooltip
/firstaction
-- 3+ enemies in melee: Whirlwind for maximum cleave damage.
/cast [meleerange:>=3] Whirlwind
-- 2 enemies in melee: Cleave (on-swing) for efficient 2-target damage.
-- Uses ! prefix to not trigger if Cleave is already queued on swing.
/cast [meleerange:>=2] !Cleave
-- Single target: normal priority rotation.
/cast Bloodthirst
/cast [noslamclip] Slam
/nofirstaction
-- Ensure auto-attack is running.
/startattack
```

Multiscan can also soft-target enemies for spells without changing your
current target:

```lua
#showtooltip Taunt
-- Scan all enemies: find the nearest one NOT targeting a tank and Taunt it.
-- Your actual target does not change; the spell is cast via soft-target.
/cast [multiscan:nearest, notargeting:tank, harm] Taunt
```

---

## 8. Pet Management (Hunter)

**Requires:** SuperWoW, Nampower, SuperCleveRoidMacros
**See also:** `cleveroid-syntax.md` (`/petattack`, `/petfollow`, `/petwait`), `cleveroid-conditionals.md` (`[pet]`, `[reactive]`, `[inrange]`)

Conditional pet attack/follow with modifier controls and pet family checks.

```lua
#showtooltip
-- Shift+click: pet follow (recall pet from combat).
/petfollow [mod:shift]
-- Ctrl+click: pet stay at current position.
/petwait [mod:ctrl]
-- No modifier + hostile target: send pet to attack.
/petattack [nomod, harm, alive]
-- No modifier + no target or friendly target: pet follow.
/petfollow [nomod, noexists]
/petfollow [nomod, help]
```

Combined with a hunter shot macro that integrates pet commands:

```lua
#showtooltip
/firstaction
-- Kill Command if pet is attacking (reactive ability).
/cast [pet, reactive:Kill_Command] Kill Command
-- Aimed Shot if standing still and not in minimum range.
/cast [nomoving, inrange:Aimed_Shot] Aimed Shot
-- Multi-Shot if 2+ enemies are in range.
/cast [inrange:Multi-Shot>1] Multi-Shot
-- Arcane Shot as filler.
/cast Arcane Shot
/nofirstaction
-- Ensure auto-shot is running via auto-attack toggle.
/startattack
-- Send pet to attack if we have a hostile target.
/petattack [harm, alive]
```

---

## Pattern Notes

**General principles for all patterns:**

- Use `/firstaction` for priority-based rotations where only one ability
  should fire. Without it, Nampower may queue multiple spells.
- Use `/nofirstaction` before lines that should always execute (like
  `/startattack` or utility commands).
- Use `/stopmacro [cond]` to bail out of a macro early based on conditions
  (e.g., `[dead]` to skip everything if target is dead).
- Combine `[noimmune]` with `[nocursive:Spell]` for robust DoT management
  that respects both immunity and existing debuffs.
- Multiscan conditionals like `[meleerange:>N]` require UnitXP_SP3 for
  3D enemy scanning.
- Slam conditionals (`[noslamclip]`, `[nonextslamclip]`) require
  SP_SwingTimer addon integration.
- Modifier keys (`[mod:shift]`, `[mod:ctrl]`, `[mod:alt]`) allow packing
  multiple actions into a single keybind.
- The `!` prefix (e.g., `!Attack`) prevents toggling -- it only activates
  if not already active.

---

## Common Mistakes

| Mistake | Why It Fails | Fix |
|---------|-------------|-----|
| `[reactive:Overpower]` not triggering | Reactive abilities must be placed on an action bar slot | Put Overpower on any action bar slot |
| `[behind]` always false | UnitXP_SP3 not installed or not loaded | Install UnitXP_SP3 DLL + addon |
| `[cursive:Rake]` not working | Cursive addon not installed | Install Cursive addon |
| Missing `/nofirstaction` | Lines after last `/cast` never execute | Add `/nofirstaction` before `/startattack` or utility commands |
| `[noslamclip]` unreliable | SP_SwingTimer addon not installed | Install SP_SwingTimer |
| `[distance]` returns wrong values | Wrong meter type for use case | Default = ranged; use `"meleeAutoAttack"` for melee. See `unitxp-api.md#distance` |
| Macro name matches spell name | CleveroidMacros can't distinguish macro from spell | Use unique names that don't match any spell |
| `[multiscan]` misses enemies | Scanned enemies must be in combat with player | Exception: current target and `@unit` targets |
| Debuff time check wrong on target swap | Built-in `[debuff:X<5]` tracks your casts, not GUID-based | Use `[cursive:X<5]` for multi-target tracking |
