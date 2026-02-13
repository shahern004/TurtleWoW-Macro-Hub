# Tank Rotation Delta Analysis: /itank & /ihodor vs Warrior Guide

> Date: 2026-02-08
> Sources: `docs/warrior-rotations.md`, `docs/warrior-guide.md`, `addons/IWinEnhanced/warrior/rotation.lua`, `addons/IWinEnhanced/warrior/action.lua`
> Scope: Furyprot single-target (`/itank`), Furyprot multi-target (`/ihodor`), and Defensive Tactics Prot (all tanking)

---

## How to Read This Document

Each section compares a **Guide Priority** (from warrior-rotations.md / warrior-guide.md) against the **Addon Priority** (the actual execution order in rotation.lua + gating logic in action.lua). Deltas are marked:

- **MATCH** — Addon implements the guide's recommendation correctly
- **DELTA** — Addon diverges from the guide in a meaningful way
- **MISSING** — Guide recommends something the addon doesn't implement
- **EXTRA** — Addon does something the guide doesn't mention

Impact ratings consider **threat output** (the primary tank metric), not DPS.

---

## 1. /itank — Furyprot Single Target

### Guide Priority (warrior-rotations.md lines 115-124; warrior-guide.md lines 268-284)

```
1. Sunder Armor       — Until 5 stacks. First GCD on pull. If Revenge isn't up, this is next after BT
2. Bloodthirst        — Keep on CD. Primary threat generator. Scales with AP
3. Heroic Strike      — Rage dump with HIGH static threat modifier. Drop at low rage
4. Revenge            — After block/dodge/parry, use after BT. Force via Shield Block. Best threat/rage but no scaling
5. Battle Shout       — Slightly more ST threat than Sunder at 5 party members
6. Shield Bash        — Interrupt priority (Defensive Stance, unlike Pummel)
```

Key quote from guide: *"Any time you have insane amounts of rage being generated, [HS] becomes responsible for a massive portion of your threat generated, thanks to a high static threat modifier."*

### Addon Priority (/itank chain, rotation.lua lines 107-143)

```
Pos  Function                          Effective Gate                              Guide Equiv
───  ──────────────────────────────    ──────────────────────────────────────────  ──────────
108  TargetEnemy                        Auto-target                                 setup
110  CancelSalvation                    Remove salv buff                            setup
111  BattleShoutRefreshOOC              Buff < 30s + OOC + rage > 60                setup
112  ChargePartySize / Intercept        Gap closer                                  setup
115  TankStance                         Enter Defensive (DT-aware)                  setup
116  Bloodrage                          Rage gen                                    setup
117  ShieldBlock                        5 sunders + Revenge about to be up          --
118  SlamThreat                         Rank 5 Slam + 2H + swing timing             --
120  SetSlamQueuedThreat                Block GCD during slam window                --
121  ExecuteDefensiveTactics            HP <= 20% + DT proc                         --
123  OverpowerDefensiveTactics          Proc + DT Battle Stance available           --
124  ShieldSlam(GCD)                    Shield + CD < GCD                           DT Prot #1
126  MortalStrike(GCD)                  CD < GCD                                    Arms only
128  Bloodthirst(GCD)                   CD < GCD                                    Guide #2 ✓
130  BattleShoutRefresh                 < 9s remaining                              Guide #5
131  SetReservedRage(BattleShout)       Reserve for refresh                         --
132  Revenge                            Proc + Defensive Stance                     Guide #4
134  HeroicStrike                       Rage > 75 or WW on CD                       Guide #3 ★
135  ConcussionBlow                     Off CD                                      DT Prot
136  SunderArmorFirstStack              Not sundered + no Expose Armor              Guide #1 ★
137  DemoralizingShout                  /iwin demo on                               --
139  SunderArmor                        Rage available (no stack limit)             Guide #1
141  BerserkerRage                      Rage farm                                   --
143  StartAttack                        Begin auto-attack                           --
```

### Deltas

---

#### DELTA T1: Heroic Strike at position 134 — Guide says #3 (after BT)

**Guide says:** HS is #3 priority with a "high static threat modifier." Spam while rage allows, only drop when rage-starved.

**Addon does:** HS at position 134, gated on `rage > 75 OR (WW on CD)`. This places it after BattleShoutRefresh (130), Revenge (132), and ConcussionBlow (135). The rage > 75 gate means HS rarely fires during normal tanking when rage hovers 40-60.

**Why it matters:** The guide emphasizes HS as a *core threat tool*, not a last-resort dump. The +138 flat threat modifier on HS rank 9 is significant. At typical raid rage income (15-25 rage/sec from boss hits), HS should be queued on almost every swing.

**Root cause:** The function itself (`action.lua:429-444`) has the `rage > 75 OR (WW on CD)` gate baked in. Additionally, the `IsRageAvailable` check adds +20 "swing replacement tax" on top of the 15 rage cost, effectively requiring 35+ rage after all reservations.

**Impact:** HIGH for threat. HS should fire much more often in tank context than in DPS context.

**Recommendation:** For `/itank`, move HS higher (after core GCD abilities) and make the rage threshold **reservation-aware** rather than flat. HS should fire when `rage >= 15 (HS cost) + reservedRage for Shield Slam/Revenge/Sunder`, leveraging the existing `IsRageAvailable` system. The +20 swing replacement tax in `IsRageAvailable` may need reduction for tank context (incoming damage generates replacement rage faster than DPS context). Must NOT rage-starve Shield Slam, Taunt (via /itaunt), or other group-saving utility.

---

#### DELTA T2: Sunder Armor not first action — Guide says #1

**Guide says:** Sunder is #1 priority. *"If you don't have Revenge up, this is your next ability to use after Bloodthirst."* First GCD on pull.

**Addon does:** `SunderArmorFirstStack` at position 136 — after BT (128), BattleShoutRefresh (130), Revenge (132), HS (134), and ConcussionBlow (135). `SunderArmor` (no stack cap) at position 139 is even later.

**On pull:** The first GCD goes to BT (if off CD) or BattleShoutRefresh (if < 9s) — not Sunder. This means pull threat is weaker because the mob's armor isn't reduced yet, making all subsequent physical hits (including BT) do less damage and therefore less threat.

**Why it matters:** Every second without 5 sunders is ~8% less physical damage per missing stack. On a pull, stacking sunders ASAP amplifies all subsequent threat. The guide specifically says first GCD = Sunder.

**Impact:** MEDIUM-HIGH on pull, LOW during sustain (SunderArmor at 139 eventually caps stacks).

**Recommendation:** Move `SunderArmorFirstStack` above BT. On pull (0 stacks), Sunder should win. Once at 5 stacks, it auto-skips and BT fires.

---

#### DELTA T3: Revenge below BattleShoutRefresh — Guide says use "right after BT"

**Guide says:** *"Anytime you block, dodge, or parry an attack, and this is off CD, use this right after Bloodthirst."* Revenge is #4 but the "right after BT" language means it should follow BT closely.

**Addon does:** Revenge at position 132, after BattleShoutRefresh (130). BattleShout consumes a GCD that could have been Revenge.

**Mitigating factor:** BattleShoutRefresh only fires when buff < 9s remaining, which is infrequent. Most keypresses, BShout is skipped.

**Impact:** LOW. The delta exists but is rarely triggered. BShout refresh is a ~2-3 second window every 2 minutes.

---

#### DELTA T4: ShieldSlam and MortalStrike above Bloodthirst — wrong spec priority

**Guide says:** For Furyprot, BT is #2 (the primary threat generator). Shield Slam is a deep Prot talent that Furyprot doesn't have. Mortal Strike is Arms-only.

**Addon does:** ShieldSlam (124) and MortalStrike (126) sit above BT (128). Both are gated by `IsSpellLearnt()`, so they silently skip for actual Furyprot.

**Why this is structured this way:** The addon uses ONE `/itank` for all tank specs (Furyprot, DefTactics Prot, Deep Prot). ShieldSlam > BT is correct for Deep Prot. MS above BT is correct for Arms tanking (niche).

**Impact:** NONE for actual Furyprot gameplay (abilities auto-skip). But it means the addon can't specialize priority order per tank spec.

---

#### DELTA T5: No Shield Bash in /itank — Guide says #6

**Guide says:** Shield Bash is #6 priority. *"Can be used in Defensive Stance, unlike Pummel."* Interrupt priority.

**Addon does:** `/itank` has no `ShieldBash()` call. There's a separate `/ikick` command for interrupts.

**Design choice:** IWinEnhanced separates interrupt from rotation (different keybind). This is actually sensible — you don't want auto-interrupts firing on non-casters.

**Impact:** NONE (design difference, not a bug). The guide lists it as a priority because it's a threat tool; the addon delegates it to `/ikick`.

---

#### DELTA T6: ConcussionBlow with no rage check

**Guide doesn't mention:** Concussion Blow for Furyprot (it's a Prot talent that Furyprot typically doesn't take).

**Addon does:** ConcussionBlow at position 135 with NO rage check (`action.lua:213-221`). It only checks `IsSpellLearnt` + `queueGCD` + `not slamQueued` + CD. No `IsRageAvailable`.

**Risk:** If a DT Prot build takes CB, it fires freely at 0 rage. CB costs 15 rage — if the player has < 15 rage, the cast will fail silently (or succeed and leave 0 rage for the next ability).

**Impact:** LOW — `CastSpellByName` will fail if not enough rage, and CB is niche for Furyprot.

---

#### DELTA T7: ShieldBlock gates on 5 sunders — delays Shield Block

**Guide says:** *"You can force [Revenge] to always be active by using a shield and using Shield Block."*

**Addon does:** `ShieldBlock()` (`action.lua:858-871`) requires `IsBuffStack("target", "Sunder Armor", 5)` before it will fire. On pull or when stacks are building, Shield Block is locked out.

**Why this matters:** Shield Block → Block → Revenge proc. If Shield Block waits for 5 sunders, the first ~5 GCDs have no forced Revenge procs, losing one of the best threat/rage abilities.

**Mitigating factor:** You block naturally from incoming attacks, just less reliably without Shield Block.

**Impact:** MEDIUM on pull. Shield Block should ideally fire as soon as you're in melee, not wait for 5 sunders.

---

#### MATCH T1: Bloodthirst keep on CD ✓

**Guide says:** BT is primary threat gen, keep on CD.

**Addon does:** BT at position 128 with `CD < GCD` pre-queue. Among the first damage abilities to fire for Furyprot (ShieldSlam/MS skip).

**Status:** Good.

---

#### MATCH T2: TankStance Defensive Stance priority ✓

**Guide says:** Stay in Defensive Stance for threat modifier and damage reduction.

**Addon does:** `TankStance()` (action.lua:1134-1165) enters Defensive Stance on combat start. DT-aware: handles stance rotation for Defensive Tactics builds.

**Status:** Good. Sophisticated DT logic handles edge cases.

---

#### EXTRA T1: SlamThreat in /itank

**Guide says nothing** about Slam for Furyprot tanking.

**Addon does:** `SlamThreat` at position 118 — fires `Slam()` if Rank 5 is learned + 2H equipped. This means a 2H Furyprot tank slams between autos.

**Assessment:** Interesting choice. 2H Furyprot is niche (you lose Shield Block/Revenge), but if someone runs it, Slam adds threat. Gated on Rank 5 specifically, which is a design choice (only high-rank Slam is worth the swing reset for threat).

---

#### EXTRA T2: ExecuteDefensiveTactics and OverpowerDefensiveTactics

**Guide (DT Prot):** Execute and Overpower are high priority in DT stance rotations.

**Addon does:** Both at positions 121/123, early in the chain with DT-specific stance logic.

**Assessment:** Correct for DT Prot. These are specialized functions that only fire when DT is active.

---

## 2. /ihodor — Furyprot Multi Target

### Guide Priority (warrior-rotations.md lines 126-137; warrior-guide.md lines 286-303)

```
1. Sunder Armor       — First GCD, at least 1 per mob
2. Cleave             — "By far your best and most consistent ability for AOE." Hidden threat modifier. No CD
3. Bloodthirst        — Good for high-priority kill targets
4. Thunder Clap       — Zero scaling but good threat/rage on 4+ mobs. -10% attack speed
5. Revenge            — Keep on CD if shield equipped and everything else on CD
6. Demoralizing Shout — Once at pull start for initial aggro. Flat threat per target
7. Shield Bash        — Interrupt priority
```

Key quote: *"By far your best and most consistent ability you have for AOE in your toolkit. Has no CD, only tied to your swing timer."*

### Addon Priority (/ihodor chain, rotation.lua lines 146-185)

```
Pos  Function                          Effective Gate                              Guide Equiv
───  ──────────────────────────────    ──────────────────────────────────────────  ──────────
155  TankStance                         Enter Defensive (DT-aware)                  setup
156  Bloodrage                          Rage gen                                    setup
157  ShieldBlockFRD                     Force Reactive Disk equipped                FRD-specific
158  ThunderClap(GCD)                   CD < GCD                                    Guide #4
160  DemoralizingShout                  /iwin demo on                               Guide #6
162  BattleShoutRefresh                 < 9s remaining                              --
164  SlamThreat                         Rank 5 + 2H                                 --
166  SetSlamQueuedThreat                Block GCD during slam window                --
167  ExecuteDefensiveTactics            HP <= 20% + DT proc                         --
169  ShieldSlam(GCD)                    Shield + CD < GCD                           DT Prot
171  MortalStrike(GCD)                  CD < GCD                                    Arms
173  Bloodthirst(GCD)                   CD < GCD                                    Guide #3 ✓
175  Revenge                            Proc + Defensive                            Guide #5 ✓
177  ConcussionBlow                     Off CD                                      DT Prot
178  SunderArmorFirstStack              Not sundered                                Guide #1 ★
179  SunderArmor                        No stack limit                              Guide #1
182  Cleave                             Rage available                              Guide #2 ★★
184  StartAttack                        Begin auto-attack                           --
```

### Deltas

---

#### DELTA H1: Cleave is dead last (position 182) — Guide says #2

**Guide says:** Cleave is #2 priority for multi-target tanking. *"By far your best and most consistent ability."*

**Addon does:** Cleave at position 182, the absolute last ability before StartAttack.

**Why position matters less than you'd think:** Cleave is a **swing replacement** (off-GCD), so it doesn't compete with GCD abilities. Even at position 182, it fires because nothing else consumes `swingAttackQueued`. The rotation goes: GCD abilities → Cleave → StartAttack. Every keypress where rage is sufficient, Cleave queues onto the next swing.

**BUT the rage gate is the real problem:** `Cleave()` (action.lua:189-200) fires if `IsRageAvailable("Cleave") OR rage > 75`. The `IsRageAvailable` check adds +20 swing replacement tax: 20 (Cleave cost) + 20 (tax) + reservedRage. With BT reserved (~30), that's 70+ rage needed. At rage > 75, the OR kicks in.

**Impact:** MEDIUM. Position is fine (off-GCD). But the effective rage threshold is too high for AoE tanking where the guide says to spam Cleave. Should be lower — incoming damage from multiple mobs generates high rage, but the reservation system over-reserves.

**Recommendation:** Lower the effective rage threshold for Cleave in AoE tanking context. Approaches (pick one):
1. Reduce the swing replacement tax from +20 to +10 for Cleave in /ihodor (incoming AoE damage replaces the lost swing rage faster)
2. Add an AoE-aware Cleave variant (`CleaveAOE()`) with a lower threshold that still reserves rage for ThunderClap and Shield Slam
3. Use `IsRageCostAvailable` (raw cost only, no reservation) instead of `IsRageAvailable` when multiple mobs are hitting the tank

Must NOT rage-starve ThunderClap, Shield Slam, or emergency Taunt.

---

#### DELTA H2: Sunder deep in the chain — Guide says #1 first GCD

**Guide says:** Sunder is #1. *"At least sunder each mob you auto once."* First GCD.

**Addon does:** `SunderArmorFirstStack` at position 178, below ThunderClap (158), Demo Shout (160), BT (173), Revenge (175), and ConcussionBlow (177).

**On pull:** First GCD goes to ThunderClap (if off CD), then DemoralizingShout, then BT. Sunder doesn't fire until position 178.

**Counterargument:** ThunderClap hits all nearby mobs (-10% attack speed + threat) and Demo Shout generates flat threat per target. On an AoE pull, these may establish broader aggro faster than single-target Sunder. The guide's "#1 Sunder" is about physical damage amplification, which matters less when most AoE threat comes from TC/Demo/Cleave rather than single-target hits.

**Impact:** LOW-MEDIUM. The guide prioritizes Sunder for armor reduction, but AoE pulls benefit more from immediate multi-target threat via TC + Demo. This is a defensible design choice.

---

#### DELTA H3: ThunderClap at #1 position — Guide says #4

**Guide says:** Thunder Clap is #4 priority, after Sunder, Cleave, and BT.

**Addon does:** ThunderClap at position 158, the FIRST ability after setup. This means TC fires before anything else on an AoE pull.

**Assessment:** This is actually a reasonable deviation. TC hits all targets in range, applies -10% attack speed (damage reduction), and generates solid threat per rage on 4+ mobs. Leading with TC establishes immediate multi-target aggro. The guide may under-prioritize it because the guide assumes you're tab-sundering first, but in practice TC-first is a strong opener.

**Impact:** LOW (potentially beneficial deviation).

---

#### DELTA H4: DemoralizingShout at position 160 — Guide says #6 (once at pull start)

**Guide says:** Demo Shout is #6, used once at pull start for initial aggro.

**Addon does:** Demo Shout at position 160 (after TC), with gates: `/iwin demo on` + not already active + TTD > 10.

**Assessment:** Position 160 is actually correct for the "once at pull start" use case — TC fires first (AoE hit), then Demo (AoE threat), establishing multi-target aggro. The TTD > 10 gate prevents waste on short fights.

**Impact:** NONE. Good implementation of the guide's recommendation.

---

#### DELTA H5: No Heroic Strike in /ihodor

**Guide says nothing** about HS for multi-target tanking (it's single-target focused).

**Addon does:** /ihodor has no `HeroicStrike()` call. Only Cleave (position 182).

**Assessment:** Correct. In AoE, Cleave replaces HS as the swing replacement. You never want HS on an AoE pull — Cleave hits 2 targets.

**Impact:** NONE (correct design).

---

#### DELTA H6: /ihodor is FRD-specific via ShieldBlockFRD

**Guide says:** General multi-target Furyprot rotation.

**Addon does:** `ShieldBlockFRD` at position 157 checks `IsItemEquipped(17, "Force Reactive Disk")`. Only fires if wearing FRD.

**Assessment:** FRD (Force Reactive Disk) is a niche tanking shield that deals damage on block. ShieldBlockFRD is an optimization for FRD users. For non-FRD tanks, this line silently skips. The rest of /ihodor works for any AoE tank.

**Impact:** NONE (harmless specialization, doesn't break non-FRD use).

---

#### MATCH H1: Bloodthirst for high-priority targets ✓

**Guide says:** BT is #3, good for high-priority kill targets.

**Addon does:** BT at position 173 with pre-queue. Fires after AoE abilities (TC, Demo) but before Sunder. This means BT hits the current target (presumably the kill target) after establishing AoE aggro.

**Status:** Good.

---

#### MATCH H2: Revenge as filler ✓

**Guide says:** Revenge is #5, keep on CD if shield equipped and everything else on CD.

**Addon does:** Revenge at position 175, below BT and above Sunder. With proc + Defensive Stance gate.

**Status:** Good. Matches the guide's "use when available, but not top priority" positioning.

---

## 3. Defensive Tactics Prot (stance-specific)

### Guide Priority (warrior-rotations.md lines 140-177)

```
Defensive Stance: Shield Slam > Concussion Blow > Revenge > Sunder > HS
Battle Stance:    Overpower > Shield Slam/CB > Sunder > HS
Berserker Stance: Shield Slam/CB > Whirlwind > Sunder > HS
```

### Addon Implementation (/itank with DT settings)

The addon handles DT via:
- `TankStance()` — DT-aware stance selection using `/iwin dtbattle`, `/iwin dtdefensive`, `/iwin dtberserker`
- `ExecuteDefensiveTactics` — Execute with DT stance dance
- `OverpowerDefensiveTactics` — Overpower with DT Battle Stance swap

### Deltas

---

#### DELTA DT1: No stance-specific priority reordering

**Guide says:** Different priority chains per stance. Overpower is #1 in Battle Stance, WW is #2 in Berserker Stance.

**Addon does:** One flat priority chain for /itank regardless of current stance. The chain is: ShieldSlam > MS > BT > BShout > Revenge > HS > CB > Sunder.

**What this means for DT Prot:**
- In Defensive Stance: ShieldSlam fires first (correct per guide). Revenge fires when proc'd. ✓
- In Battle Stance: OverpowerDefensiveTactics (pos 123) fires before ShieldSlam (pos 124). ✓ Correct!
- In Berserker Stance: ShieldSlam fires, but Whirlwind is MISSING from /itank entirely. ✗

**Impact:** MEDIUM. Battle and Defensive stances work correctly due to function ordering. But Berserker Stance DT Prot has no Whirlwind — a core part of the Berserker rotation.

---

#### ~~DELTA DT2: No Whirlwind in /itank for Berserker Stance DT~~ RETRACTED

**Guide says:** Berserker Stance priority includes WW at #2 (after Shield Slam/CB).

**Addon does:** /itank has zero `Whirlwind()` or `WhirlwindAOE()` calls.

**Why this is actually correct:** DT Prot always uses 1H+Shield (talent requirement). WW damage formula uses weapon damage — with a 1H weapon (~55 DPS vs 70+ DPS 2H), WW hits are significantly weaker than Shield Slam or even Sunder. The GCD is better spent on higher-threat abilities. The guide's Berserker Stance WW recommendation may assume theoretical maximum, but in practice WW is not worth the GCD with tank weapons.

**Impact:** NONE. Correct omission.

---

#### MATCH DT1: Overpower in Battle Stance ✓

**Guide says:** Overpower is #1 priority in Battle Stance.

**Addon does:** `OverpowerDefensiveTactics()` at position 123 handles this correctly — swaps to Battle Stance and uses Overpower when proc is available.

**Status:** Good. The DT-aware stance swap logic is well-implemented.

---

#### MATCH DT2: Execute with DT stance dance ✓

**Guide doesn't explicitly list Execute** for DT Prot, but it's a strong ability in any stance.

**Addon does:** `ExecuteDefensiveTactics()` at position 121 handles stance swaps for Execute during DT windows.

**Status:** Good.

---

## Summary: Priority-Ranked Tank Deltas

| # | Delta | Rotation | Impact | Effort | Notes |
|---|-------|----------|--------|--------|-------|
| T1 | HS rage gate too high (75+), guide says #3 core threat tool | /itank | HIGH | MED | Must preserve rage for Shield Slam/Taunt |
| T2 | Sunder not first action on pull, guide says #1 | /itank | MED-HIGH | LOW | Reorder above ShieldSlam |
| H1 | Cleave rage threshold too high (70+ effective), guide says spam | /ihodor | MEDIUM | MED | Must reserve rage for TC/ShieldSlam/Taunt |
| T7 | ShieldBlock gates on 5 sunders, delays Revenge procs on pull | /itank | MEDIUM | LOW | Relax sunder gate |
| DT1 | No stance-specific priority reordering | /itank | MEDIUM | MEDIUM | Flat chain works OK for DT |
| H2 | Sunder at position 178, guide says #1 | /ihodor | LOW-MED | LOW | TC-first is defensible |
| T3 | Revenge below BattleShoutRefresh | /itank | LOW | LOW | Rare trigger |
| T6 | ConcussionBlow has no rage check | /itank | LOW | LOW | Add gate |
| H3 | ThunderClap at #1 (guide #4) — arguably better | /ihodor | LOW | NONE | Keep |
| ~~DT2~~ | ~~No WW in /itank~~ RETRACTED — 1H WW is weak | /itank | NONE | NONE | Correct omission |
| T4 | ShieldSlam/MS above BT (auto-skip by spec) | /itank | NONE | NONE | -- |
| T5 | No Shield Bash (separate /ikick) | /itank | NONE | NONE | Design choice |
| H4 | Demo Shout position (actually good) | /ihodor | NONE | NONE | -- |
| H5 | No HS in AoE (correct — Cleave replaces) | /ihodor | NONE | NONE | -- |
| H6 | ShieldBlockFRD specialization (harmless) | /ihodor | NONE | NONE | -- |

---

## Key Findings

### Context: Running DT Prot, not Furyprot

The user is running Defensive Tactics Prot (1H+Shield always). BT-related deltas are deprioritized since BT is not the primary threat gen — Shield Slam and Concussion Blow are. The focus is on DT Prot priority optimization.

### /itank (DT Prot Single Target)

The biggest issue is **Heroic Strike deprioritization** (T1). The guide calls HS a core threat tool with a +138 flat threat modifier, but the addon treats it as a last-resort rage dump at 75+ rage. For a tank taking boss melee hits (15-25 rage/sec income), HS should be queued more aggressively.

**However, rage safety is critical.** HS is a swing replacement — once queued, it consumes rage on the next swing whether you want it to or not. If Shield Slam comes off CD and you need 20 rage but HS just ate 15, you're stuck. The fix must be **smart rage-aware HS**, not blindly lowering the threshold. The existing reservation system can handle this: HS should fire when `rage >= HS cost + reserved rage for upcoming Shield Slam/Revenge/Sunder`, not at a flat 75.

The second issue is **Sunder on pull** (T2). The first GCD should be Sunder for armor reduction, amplifying all subsequent threat. Currently ShieldSlam fires first (for DT Prot), missing the multiplicative benefit of early armor reduction.

### /ihodor (AoE Tank)

The AoE rotation is well-designed. ThunderClap-first (H3) is a defensible opener. The main issue is **Cleave's effective rage threshold** (H1) being too high. Same rage safety principle applies: Cleave should fire more often, but must leave enough rage for ThunderClap, Shield Slam, and emergency Taunt (via `/itaunt`). The reservation system's +20 swing replacement tax may be overly conservative for AoE where incoming damage generates high rage.

### Defensive Tactics Prot

The DT stance dance logic is well-implemented for Battle Stance (Overpower) and Defensive Stance. WW was initially flagged as missing for Berserker Stance, but this is **correct** — WW with a 1H weapon is too weak to justify the GCD. DT Prot's Berserker Stance value comes from +3% crit on Shield Slam/CB, not from WW.
