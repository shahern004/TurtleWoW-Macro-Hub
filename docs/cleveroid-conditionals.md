# SuperCleveRoidMacros Conditionals Reference

> Source: [SuperCleveRoidMacros README](https://github.com/alcmiddleton/SuperCleveRoidMacros) | Updated: 2026-02-06

All conditionals support negation with `no` prefix (e.g., `[nocombat]`, `[nobuff]`).
Some have semantic opposites: `help`/`harm`, `isplayer`/`isnpc`, `alive`/`dead`, `inrange`/`outrange`.
For slash command syntax, see `cleveroid-syntax.md`.

---

## Modifiers & Player State

| Conditional | Example | Description |
|-------------|---------|-------------|
| `mod` | `[mod:alt/ctrl/shift]` | Modifier key pressed (OR logic with `/`) |
| `combat` | `[combat]` `[combat:target]` | In combat (player or specified unit) |
| `form` / `stance` | `[form:1]` `[stance:2]` | Current shapeshift form or stance index |
| `stealth` | `[stealth]` | In stealth (Rogue/Druid) |
| `group` | `[group]` `[group:party/raid]` | Player is in a group of specified type |
| `resting` | `[resting]` | In a rest area (inn/city) |
| `swimming` | `[swimming]` | In water / can use aquatic form |
| `moving` | `[moving]` `[moving:>100]` | Moving / speed % (with MonkeySpeed) |
| `zone` | `[zone:"Ironforge"]` | Current zone name match |

---

## Resources

| Conditional | Example | Description |
|-------------|---------|-------------|
| `myhp` | `[myhp:<30]` | Player HP percentage |
| `myrawhp` | `[myrawhp:>1000]` | Player raw HP value |
| `myhplost` | `[myhplost:>500]` | Player HP lost (max - current) |
| `mypower` | `[mypower:>50]` | Player mana/rage/energy percentage |
| `myrawpower` | `[myrawpower:>500]` | Player raw power value |
| `mypowerlost` | `[mypowerlost:>200]` | Player power lost (max - current) |
| `druidmana` | `[druidmana:>=500]` | Druid mana while in shapeshift form |
| `combo` | `[combo:>=4]` | Current combo points |
| `stat` | `[stat:agi>100]` `[stat:ap>1000]` | Player stat check (see subtypes below) |

### Stat Subtypes

`str`, `agi`, `stam`, `int`, `spi`, `ap`, `rap`, `healing`, `armor`, `defense`, `arcane_power`, `fire_power`, `frost_power`, `nature_power`, `shadow_power`, `arcane_res`, `fire_res`, `frost_res`, `nature_res`, `shadow_res`

---

## Buffs & Debuffs

| Conditional | Example | Description |
|-------------|---------|-------------|
| `mybuff` | `[mybuff:"Name"<5]` | Player has buff (optional time remaining check) |
| `mydebuff` | `[mydebuff:"Name"]` | Player has debuff |
| `mybuffcount` | `[mybuffcount:>15]` `[nomybuffcount:>28]` | Player buff slot count (32 max) |
| `buff` | `[buff:"Name">#3]` | Target has buff (optional stack count with `>#`) |
| `debuff` | `[debuff:"Sunder">20]` | Target has debuff (optional time remaining) |
| `cursive` | `[cursive:Rake<3]` | Cursive addon GUID-based debuff tracking |

### Built-in Debuff Tracking Notes

- Existence checks (`[nodebuff]`, `[debuff]`) detect ANY debuff on target from any source
- Time-remaining checks (`[debuff:X<5]`) use internal tracking from your own casts
- Shared debuffs (Sunder Armor, Faerie Fire) are detected from any source
- The addon auto-learns debuff durations from your casts (335+ spells pre-configured)

### Cursive Integration

[Cursive](https://github.com/avitasia/Cursive) provides more accurate GUID-based tracking:

| Conditional | Example | Description |
|-------------|---------|-------------|
| `cursive` | `[cursive:Rake]` | Target has debuff tracked by Cursive |
| `nocursive` | `[nocursive:Rake]` | Target missing debuff (Cursive) |
| `cursive` (time) | `[cursive:Rake<3]` | Debuff time remaining < 3 seconds |
| `nocursive` (time) | `[nocursive:Rake>1.5]` | Missing OR about to expire |

**Advantages of Cursive over built-in tracking:**
- GUID-based (survives target switching)
- Tracks pending casts
- Works at debuff cap
- More accurate timing

---

## Cooldowns & Casting

| Conditional | Example | Description |
|-------------|---------|-------------|
| `cooldown` | `[cooldown:"Spell"<5]` | Cooldown remaining in seconds (ignores GCD). *Powered by `nampower-api.md#GetSpellIdCooldown`* |
| `cdgcd` | `[cdgcd:"Spell">0]` | Cooldown remaining (includes GCD). *Powered by `nampower-api.md#GetSpellIdCooldown`* |
| `gcd` | `[gcd]` `[gcd:<1]` | GCD is active / time remaining |
| `usable` | `[usable:"Spell"]` | Spell or item is currently usable |
| `reactive` | `[reactive:Overpower]` | Reactive ability is available |
| `known` | `[known:"Spell">#2]` | Spell or talent known (with rank check via `>#`) |
| `channeled` | `[channeled]` | Currently channeling a spell |
| `channeltime` | `[channeltime:<0.5]` | Channel time remaining in seconds |
| `selfcasting` | `[selfcasting]` | Player is currently casting or channeling |
| `casttime` | `[casttime:<0.5]` | Player cast time remaining in seconds |
| `checkcasting` | `[checkcasting]` `[checkcasting:Frostbolt]` | NOT casting (optionally a specific spell) |
| `checkchanneled` | `[checkchanneled]` `[checkchanneled:Blizzard]` | NOT channeling (optionally a specific spell) |
| `queuedspell` | `[queuedspell]` `[queuedspell:Fireball]` | Spell is queued via Nampower |
| `onswingpending` | `[onswingpending]` | An on-swing spell is pending |

---

## Target Checks

| Conditional | Example | Description |
|-------------|---------|-------------|
| `exists` | `[@mouseover,exists]` | Unit exists |
| `alive` | `[alive]` | Target is alive |
| `dead` | `[dead]` | Target is dead |
| `help` | `[help]` | Target is friendly |
| `harm` | `[harm]` | Target is hostile |
| `hp` | `[hp:<20]` `[hp:>30&<70]` | Target HP percentage (supports AND ranges) |
| `rawhp` | `[rawhp:>5000]` | Target raw HP value |
| `hplost` | `[hplost:>1000]` | Target HP lost (max - current) |
| `power` | `[power:<30]` | Target power percentage |
| `rawpower` | `[rawpower:>500]` | Target raw power value |
| `powerlost` | `[powerlost:>100]` | Target power lost (max - current) |
| `powertype` | `[powertype:mana/rage/energy]` | Target's power type |
| `level` | `[level:>60]` `[mylevel:=60]` | Unit level (skull = 63); `mylevel` for player |
| `class` | `[class:Warrior/Priest]` | Target class (players only) |
| `type` | `[type:Undead/Beast]` | Creature type |
| `isplayer` | `[isplayer]` | Target is a player character |
| `isnpc` | `[isnpc]` | Target is an NPC |
| `targeting` | `[targeting:player]` `[targeting:tank]` | Unit is targeting you / any pfUI tank |
| `istank` | `[istank]` `[@focus,istank]` | Unit is marked as tank (pfUI) |
| `casting` | `[casting:"Spell"]` | Unit is casting a specific spell |
| `party` | `[party]` `[party:focus]` | Unit is in your party |
| `raid` | `[raid]` `[raid:mouseover]` | Unit is in your raid |
| `member` | `[member]` | Target in party OR raid |
| `hastarget` | `[hastarget]` | Player has a target selected |
| `notarget` | `[notarget]` | Player has no target selected |
| `pet` | `[pet]` `[pet:Cat/Wolf]` | Has a pet (optionally check pet family) |
| `name` | `[name:Onyxia]` | Exact name match (case-insensitive) |
| `tag` | `[tag]` | Target is tapped (by anyone) |
| `notag` | `[notag]` | Target is not tapped |
| `mytag` | `[mytag]` | Target is tapped by you |
| `nomytag` | `[nomytag]` | Target is not tapped by you |
| `othertag` | `[othertag]` | Target is tapped by someone else |
| `noothertag` | `[noothertag]` | Not tapped by others (yours or unclaimed) |

---

## Range & Position

| Conditional | Example | Description |
|-------------|---------|-------------|
| `distance` | `[distance:<40]` | Distance to target in yards. *Powered by `unitxp-api.md#distance`* |
| `inrange` | `[inrange:"Spell"]` `[inrange:Spell>N]` | Target in spell range / count enemies in range |
| `outrange` | `[outrange:"Spell"]` `[outrange:Spell>N]` | Target out of spell range / count out of range |
| `meleerange` | `[meleerange]` `[meleerange:>N]` | In melee range / count enemies in melee range |
| `behind` | `[behind]` `[behind:>N]` | Behind target / count enemies you are behind. *Powered by `unitxp-api.md#behind-facing`* |
| `insight` | `[insight]` `[insight:>N]` | In line of sight / count enemies in LoS. *Powered by `unitxp-api.md#line-of-sight`* |

### Multi-Unit Count Mode

Add operator + number to count enemies matching the condition (requires UnitXP). Operators: `>`, `<`, `>=`, `<=`, `=`, `~=`

```lua
/cast [meleerange:>1] Whirlwind           -- AoE if 2+ enemies in melee
/cast [behind:>=2] Blade Flurry           -- Cleave if behind 2+ enemies
/cast [inrange:Multi-Shot>1] Multi-Shot   -- AoE if 2+ in spell range
/cast [insight:>0] Arcane Explosion        -- AoE if any enemy in LoS
```

---

## Equipment

| Conditional | Example | Description |
|-------------|---------|-------------|
| `equipped` | `[equipped:Daggers]` | Item or weapon type is equipped |
| `mhimbue` | `[mhimbue]` `[mhimbue:Instant_Poison]` | Main-hand has temporary imbue |
| `ohimbue` | `[ohimbue]` `[ohimbue:Crippling_Poison]` | Off-hand has temporary imbue |

### Imbue Details

Imbue conditionals detect temporary weapon enhancements (poisons, oils, sharpening stones) via tooltip time/charge markers, filtering out permanent enchants like Crusader.

| Conditional | Example | Description |
|-------------|---------|-------------|
| `mhimbue` | `[mhimbue]` | Has any temporary main-hand imbue |
| `mhimbue` (name) | `[mhimbue:Instant_Poison]` | Has specific imbue (tooltip match) |
| `mhimbue` (time) | `[mhimbue:<300]` | Imbue expires in < 300 seconds (5 min) |
| `mhimbue` (both) | `[mhimbue:Instant_Poison<300]` | Specific imbue with time check |
| `mhimbue` (charges) | `[mhimbue:>#5]` | Has > 5 charges remaining |
| `nomhimbue` | `[nomhimbue]` | No temporary imbue (apply needed) |
| `ohimbue` | `[ohimbue]` | Off-hand equivalents (same syntax as mhimbue) |

---

## CC & Immunity

| Conditional | Example | Description |
|-------------|---------|-------------|
| `cc` | `[cc]` `[cc:stun/fear]` | Target has crowd-control effect |
| `mycc` | `[mycc]` `[mycc:silence]` | Player has crowd-control effect |
| `immune` | `[immune:fire]` `[immune:stun]` | Target IS immune (skip cast) |
| `noimmune` | `[noimmune]` `[noimmune:bleed]` | Target NOT immune (allow cast) |
| `resisted` | `[resisted]` `[resisted:full/partial]` | Last spell was resisted |

### CC Types

stun, fear, root, snare/slow, sleep, charm, polymorph, banish, horror, disorient, silence, disarm, daze, freeze, shackle

### Loss-of-Control Types

Checked by bare `[cc]` without arguments: stun, fear, sleep, charm, polymorph, banish, horror, freeze, disorient, shackle

### Damage Schools

physical, fire, frost, nature, shadow, arcane, holy, bleed

### Immunity Usage

| Usage | What it checks |
|-------|----------------|
| `[noimmune]` | Auto-detects spell's school from current action |
| `[noimmune:fire]` | Fire immunity specifically |
| `[noimmune:bleed]` | Bleed immunity specifically |
| `[noimmune:stun]` | Stun CC immunity |

Split damage spells (Rake, Pounce, Garrote): `[noimmune]` auto-checks BOTH physical hit and bleed DoT immunities. See Immunity Tracking section for details.

---

## Addon Integrations

These conditionals require specific addons to be installed. Without the addon, the conditional will not function.

| Conditional | Required Addon | Example | Description |
|-------------|----------------|---------|-------------|
| `swingtimer` / `stimer` | SP_SwingTimer | `[swingtimer:<15]` | Swing percentage elapsed |
| `threat` | TWThreat | `[threat:>80]` | Threat percentage (100 = pull aggro) |
| `ttk` / `tte` | TimeToKill | `[ttk:<10]` `[tte:<5]` | Time to kill / time to execute (20% HP) |
| `cursive` | Cursive | `[cursive:Rake>3]` | GUID-based debuff tracking. See Cursive section below |
| `moving` (speed) | MonkeySpeed | `[moving:>100]` | Speed % (100 = normal). Basic `[moving]` works without addon |
| `targeting:tank` / `istank` | pfUI | `[targeting:tank]` | pfUI tank detection. See pfUI Tank section below |

---

## pfUI Tank Integration

### Tank Conditionals

| Conditional | Example | Description |
|-------------|---------|-------------|
| `targeting:tank` | `[targeting:tank]` | Target IS attacking any player marked as tank |
| `notargeting:tank` | `[notargeting:tank]` | Target is NOT attacking any tank (loose mob) |
| `istank` | `[istank]` `[@focus,istank]` | Target unit IS marked as tank |
| `noistank` | `[noistank]` | Target unit is NOT marked as tank |

### Setting Up Tanks in pfUI

**Nameplate Off-Tank Names (recommended):**
- `/pfui` -> Nameplates -> Off-Tank Names
- Add tank names separated by `#`: `#TankName1#TankName2#TankName3`
- These names show different colored nameplates AND work with `[targeting:tank]`

**Raid Frame Toggle:**
- Right-click a player in raid frames -> "Toggle as Tank"
- Only works when raid frames are visible

### Tank Macro Examples

```lua
-- Pick up loose mobs (not targeting any tank)
/cast [multiscan:nearest,notargeting:tank,harm] Taunt

-- Only taunt if mob is targeting you (tank)
/cast [targeting:player] Sunder Armor

-- Assist tanks - attack what they're tanking
/cast [multiscan:nearest,targeting:tank,harm] Sunder Armor

-- Emergency taunt on loose mob hitting a healer
/cast [notargeting:tank,notargeting:player] Taunt
```

**Debug Command:** `/cleveroid tankdebug` -- Shows all marked tanks, current target info, and conditional results.

---

## Warrior Slam Conditionals

For optimizing Slam rotations without clipping auto-attacks.

| Conditional | Example | Description |
|-------------|---------|-------------|
| `noslamclip` | `[noslamclip]` | True if casting Slam NOW will not clip auto-attack |
| `slamclip` | `[slamclip]` | True if casting Slam NOW WILL clip auto-attack |
| `nonextslamclip` | `[nonextslamclip]` | True if using an instant NOW will not cause NEXT Slam to clip |
| `nextslamclip` | `[nextslamclip]` | True if using an instant NOW WILL cause NEXT Slam to clip |

```lua
/cast [noslamclip] Slam
/cast [slamclip] Heroic Strike          -- Use HS when past slam window
/cast [nonextslamclip] Bloodthirst      -- Only BT if it won't delay next slam
```

---

## Auto-Attack Conditionals

**Requires:** Nampower v2.24+ with `NP_EnableAutoAttackEvents=1`. See `nampower-cvars.md#custom-event-toggles`.

### Outgoing Swing Conditionals

| Conditional | Example | Description |
|-------------|---------|-------------|
| `lastswing` | `[lastswing]` | Any melee swing in last 5 seconds |
| `lastswing` (type) | `[lastswing:crit]` | Last swing was a specific type |
| `lastswing` (time) | `[lastswing:<2]` | Last swing was < N seconds ago |
| `nolastswing` (type) | `[nolastswing:miss/dodge]` | Last swing was NOT type (AND logic with `/`) |

### Incoming Hit Conditionals

| Conditional | Example | Description |
|-------------|---------|-------------|
| `incominghit` | `[incominghit]` | Any incoming hit in last 5 seconds |
| `incominghit` (type) | `[incominghit:crushing]` | Last incoming hit was a specific type |
| `noincominghit` (type) | `[noincominghit:crushing]` | Last incoming hit was NOT type |

### Swing / Hit Types

| Type | Description | Applies To |
|------|-------------|------------|
| `crit` | Critical hit | lastswing, incominghit |
| `glancing` | Glancing blow | lastswing, incominghit |
| `crushing` | Crushing blow | incominghit only |
| `miss` | Attack missed | lastswing, incominghit |
| `dodge` / `dodged` | Target dodged | lastswing, incominghit |
| `parry` / `parried` | Target parried | lastswing, incominghit |
| `blocked` / `block` | Attack was blocked | lastswing, incominghit |
| `offhand` / `oh` | Off-hand swing | lastswing only |
| `mainhand` / `mh` | Main-hand swing | lastswing only |
| `hit` | Successful hit (not miss/dodge/parry) | lastswing, incominghit |

```lua
/cast [lastswing:dodge] Overpower        -- Overpower after enemy dodged
/use [incominghit:crushing] Last Stand   -- Emergency CD after crushing blow
/cast [lastswing:crit] Execute           -- Execute after crit proc
```

---

## Aura Cap Conditionals

**Requires:** Nampower v2.20+. For accurate tracking, enable `NP_EnableAuraCastEvents=1`. See `nampower-cvars.md#custom-event-toggles`.

| Conditional | Example | Description |
|-------------|---------|-------------|
| `mybuffcapped` | `[mybuffcapped]` | Player has 32 buffs (buff bar full) |
| `nomybuffcapped` | `[nomybuffcapped]` | Player has room for more buffs |
| `mydebuffcapped` | `[mydebuffcapped]` | Player has 16 debuffs (debuff bar full) |
| `nomydebuffcapped` | `[nomydebuffcapped]` | Player has room for more debuffs |
| `buffcapped` | `[buffcapped]` | Target buff bar is full (32 slots) |
| `nobuffcapped` | `[nobuffcapped]` | Target has room for more buffs |
| `debuffcapped` | `[debuffcapped]` | Target debuff bar is full |
| `nodebuffcapped` | `[nodebuffcapped]` | Target has room for more debuffs |

### Aura Capacity

- **Player:** 32 buff slots, 16 debuff slots
- **NPCs:** 16 debuff slots + 32 overflow = 48 total visual debuff capacity

```lua
/cast [nodebuffcapped,nocursive:Rake] Rake   -- Only DoT if room on target
/cast [nomybuffcapped] Mark of the Wild      -- Only buff self if room
/cast [@focus,nodebuffcapped] Corruption     -- Only DoT focus if room
```

---

## Debuff Tracking

### Built-in Tracking (`[debuff]`)

```lua
-- Basic: Only cast if target doesn't have Moonfire
/cast [nodebuff:Moonfire] Moonfire

-- Time check: Refresh when < 4 seconds left
/cast [debuff:Moonfire<4] Moonfire
```

- Existence checks (`[nodebuff]`, `[debuff]`) detect ANY debuff on target
- Time-remaining checks (`[debuff:X<5]`) use internal tracking from your casts
- Shared debuffs (Sunder, Faerie Fire) are detected from any source

### Cursive Integration (`[cursive]`)

See Cursive Integration section above for full syntax and GUID-based advantages.

---

## Immunity Tracking

The addon auto-learns NPC immunities from combat. When a spell fails with "immune", the addon remembers it for that NPC.

### Using `[noimmune]`

| Conditional | Example | Description |
|-------------|---------|-------------|
| `noimmune` | `[noimmune]` | Auto-detects spell's school from current action |
| `noimmune` (school) | `[noimmune:fire]` | Check fire immunity specifically |
| `noimmune` (bleed) | `[noimmune:bleed]` | Check bleed immunity specifically |
| `noimmune` (CC) | `[noimmune:stun]` | Check stun CC immunity |
| `immune` | `[immune:fire]` | Target IS immune to fire (true = immune) |

### Split Damage Spells

Rake, Pounce, Garrote have initial physical hit + bleed DoT. `[noimmune]` auto-checks BOTH immunities.

```lua
/cast [noimmune] Rake                          -- Checks physical AND bleed
/cast [noimmune:physical] Rake                 -- Only checks physical
/cast [noimmune:bleed] Rake                    -- Only checks bleed
/cast [noimmune, cursive:Rake<1.5] Rake        -- With time check
```

### Manual Immunity Commands

```lua
/cleveroid addimmune "Boss Name" bleed         -- Permanent bleed immunity
/cleveroid addimmune "Boss Name" fire "Shield" -- Fire immune only when buffed
/cleveroid addccimmune "Boss Name" stun        -- Permanent stun immunity
/cleveroid listimmune [school]                 -- View learned school immunities
/cleveroid listccimmune [type]                 -- View learned CC immunities
```

---

## MonkeySpeed Integration

**Requires:** [MonkeySpeed](https://github.com/jrc13245/MonkeySpeed) addon for speed comparisons.

| Conditional | Example | Description |
|-------------|---------|-------------|
| `moving` | `[moving]` | Player is moving (works without MonkeySpeed via position fallback) |
| `nomoving` | `[nomoving]` | Player is standing still |
| `moving` (speed) | `[moving:>100]` | Speed above threshold (requires MonkeySpeed) |

### Speed Reference

| Speed Value | Description |
|-------------|-------------|
| `0` | Standing still |
| `100` | Normal run speed |
| `160` | Level 40 mount |
| `200` | Epic mount |

```lua
/cast [nomoving] Aimed Shot          -- Only cast if standing still
/cast [moving] Arcane Shot           -- Cast instant while moving
/cast [moving:>100] Sprint           -- Already faster than normal
/cast [moving:<50] Escape Artist     -- Currently slowed
```

- Basic `[moving]`/`[nomoving]` works without MonkeySpeed (position fallback)
- Speed comparisons (`[moving:>100]`) require MonkeySpeed addon
- Speed values vary with buffs/debuffs affecting movement
