# Warrior Rotations & Mechanics

> Source: Extracted from `warrior-guide.md` (community guide) | Updated: 2026-02-06

Mechanical reference for warrior rotation priorities, execute logic, and cooldown usage across all raid specs. For macro implementations, see `patterns.md`.

---

## General Rules

- **Sunder Armor** is the highest-priority action on any mob living >4 seconds. All warriors sunder, not just tanks. 5 sunders = ~40% more physical damage = more rage = more abilities.
- **Heroic Strike** prevents miss and glance on mainhand while hitcapped.
- **Whirlwind** and shouts gain extra range when used while jumping (hitbox extension).
- **Berserker Rage** grants +60% rage from damage taken while active. Use on raid-wide damage fights.
- **Weapon swaps** reset swing timer. Shields swap instantly with no penalty.
- **Demo Shout bug:** Never apply Demo Shout before Curse of Recklessness. The -AP is canceled by CoR's +AP, leaving a bugged zero-effect debuff until it expires. Another warrior with Improved Shouts can fix by overwriting.

---

## Fury (DW) -- Single Target

| Priority | Ability | Condition / Notes |
|----------|---------|-------------------|
| 1 | Sunder Armor | Until 5 stacks on target |
| 2 | Execute | Target <20% HP (see BT vs Execute below) |
| 3 | Bloodthirst | Keep on cooldown. If WW has 1s left and BT has 2s, wait for BT |
| 4 | Whirlwind | Don't clip BT cooldown. Dagger MH: prio below HS |
| 5 | Heroic Strike | Rage dump. First ability to drop if threatcapped |
| 6 | Filler (MS/Pummel/Hamstring/Sunder) | Proc fishing only. Never clip BT/WW cooldown |

## Fury (DW) -- Multi Target

| Priority | Ability | Condition / Notes |
|----------|---------|-------------------|
| 1 | Sunder Armor | First GCD. At least 1 sunder per mob |
| 2 | Whirlwind | Damage duplicated per mob (up to 4) |
| 3 | Cleave | No CD, best consistent AOE. Rage cost = lost swing rage |
| 4 | Execute | High damage but can ragestarve on packs |
| 5 | Bloodthirst | Outshined by multi-hit abilities |
| 6 | Filler | Proc fishing. Sunder unsundered mobs |

## Fury (2H) -- Single Target

Same priority as DW Fury with these changes:

- **Heroic Strike** drops to very low priority
- **Slam** replaces HS: cast immediately after each auto-attack swing
- Slam scales with Flurry and haste. With 3.7-3.8 speed weapon, two Slams can fit between autos
- **Overpower** is stronger for 2H than DW, especially in lower gear. Minimize rage waste from stance swaps

**See also:** `patterns.md#2` (Slam rotation macro), `cleveroid-conditionals.md` (`[noslamclip]`, `[reactive:Overpower]`)

## Fury (2H) -- Multi Target

Same as DW Fury multi-target. Extra emphasis on Whirlwind/Cleave. Use Slam on longer-lived mobs.

---

## Bloodthirst vs Execute Decision

Execute formula: `600 + (20 * extra_rage) = 900 damage at 30 rage`
Bloodthirst formula: `200 + (0.35 * AP)`

**BT is more rage-efficient than Execute when ALL conditions are met:**

| Condition | Threshold |
|-----------|-----------|
| Attack Power | > 2000 |
| Current rage | 30-60 (not capping) |
| Rage income | Not extreme (no Recklessness/Loatheb/Thaddius buff) |
| Fight duration | Expect at least 1 more GCD for Execute after |

At 100 rage, always Execute -- rage overflow wastes more than BT's efficiency gain.

---

## Arms -- Single Target

**Standard rotation (3.5-3.8 speed weapon):**

```
Sunder -> Slam -> (auto) -> Mortal Strike -> Slam -> (auto) -> Whirlwind -> Slam -> (auto) -> repeat from MS
```

- If auto fired and both MS + WW on CD: double Slam with 3.6-3.8 speed
- If about to ragecap: queue Heroic Strike instead of Slam
- Dodged attack + low rage cost: Overpower instead of Slam

**Faster weapon variant (3.4 speed or high haste):**

```
Sunder -> Slam -> (auto) -> Mortal Strike -> Whirlwind -> (auto) -> Slam -> (auto) -> MS > WW > Slam
```

**Execute phase:** Pool to 120 rage before target hits 20%. Execute immediately, use Mighty/Great Rage Potion for second high-rage Execute, auto-swing into third.

**See also:** `patterns.md#1` (Arms priority macro), `cleveroid-conditionals.md` (`[noslamclip]`, `[reactive:Overpower]`)

## Arms -- Multi Target

Pre-pop Sweeping Strikes before pull. Use again when it comes off cooldown mid-pull (charges last nearly the full CD).

| Priority | Ability | Notes |
|----------|---------|-------|
| 1 | Whirlwind | Massive with Sweeping Strikes. Be ready to LIP if threat |
| 2 | Sunder Armor | At least 1 per mob |
| 3 | Cleave | Keep queued; slow swing timer limits value vs instants |
| 4 | Mortal Strike | Good damage/rage when GCD is open after WW |
| 5 | Execute | Last GCD or with rage potion only |

**Sweeping Strikes timing trick:** Activate SS as early as possible before pull while ensuring charges aren't wasted. CD starts on activation and charges last nearly the full duration, so you can enter a pull with expiring charges, WW, then re-activate SS when it comes off CD for a second set.

---

## Furyprot -- Single Target

| Priority | Ability | Condition / Notes |
|----------|---------|-------------------|
| 1 | Sunder Armor | Until 5 stacks |
| 2 | Bloodthirst | Keep on CD. Primary threat generator |
| 3 | Heroic Strike | Rage dump. High static threat modifier. Drop at low rage |
| 4 | Revenge | After block/dodge/parry. Use after BT, don't clip BT CD. Force via Shield Block |
| 5 | Battle Shout | Slightly more single-target threat than Sunder at 5 party members hit. Doesn't proc weapon effects |
| 6 | Shield Bash | Interrupt priority. Usable in Defensive Stance (unlike Pummel) |

## Furyprot -- Multi Target

| Priority | Ability | Condition / Notes |
|----------|---------|-------------------|
| 1 | Sunder Armor | First GCD, at least 1 per mob |
| 2 | Cleave | Best consistent AOE. Has hidden static threat modifier |
| 3 | Bloodthirst | Good for high-priority kill targets |
| 4 | Thunder Clap | Zero scaling but good threat/rage on 4+ mobs. Applies -10% attack speed |
| 5 | Revenge | Keep on CD if shield equipped and everything else is on CD |
| 6 | Demoralizing Shout | Use once at pull start for initial aggro. Flat threat per target (not split) |
| 7 | Shield Bash | Interrupt priority: healers > healing reduction > slows |

---

## Defensive Tactics Prot -- Stance Rotations

Requires shield equipped at all times (Defensive Tactics talent requirement). Three distinct rotations depending on stance used.

### Defensive Stance

| Priority | Ability |
|----------|---------|
| 1 | Shield Slam |
| 2 | Concussion Blow |
| 3 | Revenge |
| 4 | Sunder Armor |
| 5 | Heroic Strike (rage permitting) |

### Battle Stance

+10% damage taken, +10% damage done vs Defensive Stance. Gains Overpower (80%+ crit in endgame tank gear).

| Priority | Ability |
|----------|---------|
| 1 | Overpower |
| 2 | Shield Slam / Concussion Blow |
| 3 | Sunder Armor |
| 4 | Heroic Strike (rage permitting) |

### Berserker Stance

+20% damage taken, +10% damage done, +3% crit vs Defensive Stance. Best for threat chasing or AOE.

| Priority | Ability |
|----------|---------|
| 1 | Shield Slam / Concussion Blow |
| 2 | Whirlwind |
| 3 | Sunder Armor |
| 4 | Heroic Strike (rage permitting) |

**AOE (any stance):** Whirlwind -> Cleave -> other abilities.

---

## Cooldown Usage

| Cooldown | Duration | CD | Usage Guidelines |
|----------|----------|-----|-----------------|
| Death Wish | 30s | 3min | Time to expire at boss death. Use on AOE/cleave pulls. >5min without pressing = missed opportunity |
| Bloodrage + Enrage | 8s | 1min | Use on CD in combat. High relative uptime on trash. Save for boss execute phase when relevant |
| Recklessness | 15s | 30min | Plan ahead per raid. Usable on AOE trash. +20% damage taken, fear immune |
| Berserker Rage | -- | 30s | Break fears + 60% rage from damage taken. Use on raid damage. Don't clip BT/WW CD |
| Sweeping Strikes (Arms) | ~30s charges | 30s | Pre-pull timing for double use. See Arms Multi Target section |

**Boss timing:** Align CD expiration with boss death. 30s CD -> activate 30s before kill. Record kill times weekly to learn HP% thresholds.

**Mighty Rage Potion:** Use during execute phase for burst. Pool rage + potion + execute chain (see Arms Execute Phase).

---

## Cross-References

| Topic | Document |
|-------|----------|
| Arms priority macro | `patterns.md#1` |
| Slam rotation macro | `patterns.md#2` |
| Stance dance macro | `patterns.md` |
| `[noslamclip]` conditional | `cleveroid-conditionals.md` |
| `[reactive:Overpower]` conditional | `cleveroid-conditionals.md` |
| `[stance:N]` conditional | `cleveroid-conditionals.md` |
| `[meleerange:>N]` conditional | `cleveroid-conditionals.md` |
| Sunder tracking `[debuff:"Sunder Armor"]` | `cleveroid-conditionals.md` |
| Full warrior guide (opinions, gear, consumes) | `warrior-guide.md` |
