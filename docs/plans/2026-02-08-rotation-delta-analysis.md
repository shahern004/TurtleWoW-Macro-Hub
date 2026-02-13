# Rotation Delta Analysis: Warrior Guide vs IWinEnhanced

> Date: 2026-02-08
> Sources: `docs/warrior-rotations.md`, `docs/warrior-guide.md`, `addons/IWinEnhanced/warrior/rotation.lua`
> Purpose: Trace the guide's optimized rotations to the addon logic, find deltas that shape improvement priorities

---

## How to Read This Document

Each section compares a **Guide Priority** (from warrior-rotations.md / warrior-guide.md) against the **Addon Priority** (the actual execution order in rotation.lua). Deltas are marked:

- **MATCH** — Addon implements the guide's recommendation correctly
- **DELTA** — Addon diverges from the guide in a meaningful way
- **MISSING** — Guide recommends something the addon doesn't implement
- **EXTRA** — Addon does something the guide doesn't mention

---

## 1. Arms — Single Target

### Guide Priority (warrior-rotations.md, lines 79-97)
```
Sunder(5) → Slam → (auto) → Mortal Strike → Slam → (auto) → Whirlwind → Slam → (auto) → repeat from MS
- If auto fired and both MS+WW on CD: double Slam with 3.6-3.8 speed
- If about to ragecap: queue Heroic Strike instead of Slam
- Dodged attack + low rage: Overpower instead of Slam
- Execute phase: pool to 120 rage, then Execute chain with rage pot
```

### Addon Priority (/idps chain, rotation.lua lines 3-59)
```
Position  Function                      Effective Gate
───────── ──────────────────────────────  ─────────────────────────────────
 1-9      Pre-combat (shout, charge)     OOC setup
10        DPSStance                      Exit Defensive Stance
11        Bloodrage                      Rage < 70, HP > 25%
12        BattleShout                    Not active
14        SunderArmorDPSRefresh          Active + remaining < 6s
15        SunderArmorElite               /iwin sunder high + elite target + <5 stacks
16        DPSStanceDefault               Smart stance swap
17        BloodthirstHighAP              AP > 2000 + rage < 60 + CD < GCD
19        Execute                        HP <= 20% + (PvP OR HP<40% OR elite OR (1H+raid/lowrage) OR TTD<4)
21        HamstringJousting              Solo + jousting enabled
22        Slam                           2H + swing > 50% speed + not Battle Stance
26        SunderArmorDPS2Hander          2H + <5 stacks + TTD>5 + GCD idle
28        ShieldSlam                     Shield + CD < GCD
30        MortalStrike                   CD < GCD ← ★ CORE ARMS ABILITY
32        Bloodthirst                    CD < GCD
34        Whirlwind                      Berserker Stance + CD ready ← ★ CORE ARMS ABILITY
36        Overpower                      Proc available + Battle Stance swap
37        MasterStrike                   Tanking or PvP only
39        ConcussionBlow                 Off CD
40        BattleShoutRefresh             Remaining < 9s
41        DemoralizingShout              /iwin demo on + not active + TTD>10
43        Rend                           TTD>9 + not raid + not Undead/Mech/Elem
44        SunderArmorDPS                 <5 stacks + GCD idle + TTD>5
46        BerserkerRage                  Berserker Stance + rage < 70
47        HeroicStrike                   Rage available + (rage>75 + WW on CD)
50        MasterStrikeWindfury           Windfury active [BUG: casts Hamstring]
52-57     Windfury fillers               Pummel/Hamstring/Sunder when WF active
58        StartAttack
```

### Deltas

#### DELTA 1: Mortal Strike at position 30 — should be ~position 17
**Guide says:** MS is the #1 damage ability in the Arms cycle. After initial Sunder, the core loop is `Slam → MS → Slam → WW → Slam → repeat`.
**Addon does:** MS sits below BloodthirstHighAP (17), Execute (19), Slam (22), ShieldSlam (28). For Arms spec, MS should be the highest-priority spender after Sunder maintenance.
**Impact:** HIGH. Every keypress where MS is off-CD but a lower-priority ability fires first is a DPS loss. MS has a 6s CD — clipping it by even 1 GCD compounds over a fight.

#### DELTA 2: Whirlwind at position 34 with queueTime=0 — no pre-queuing
**Guide says:** WW is part of the 3-ability core cycle (MS → WW → fillers). Keep it on CD.
**Addon does:** `IWin:Whirlwind(0)` — the `0` means "only cast if CD is exactly 0" (no pre-queue window). Compare to `MortalStrike(IWin_Settings["GCD"])` which pre-queues when CD < 1.5s.
**Impact:** MEDIUM. Without pre-queuing, WW will sit idle for up to 1 GCD after coming off CD. Should be `Whirlwind(IWin_Settings["GCD"])` like other core abilities.

#### DELTA 3: No swing-timer interleaving cycle
**Guide says:** The Arms rotation is swing-timer driven: `Slam → (auto) → MS → Slam → (auto) → WW`. You weave Slam between auto-attacks, using MS/WW on CD during the GCD after an auto.
**Addon does:** Slam at position 22 fires whenever swing > 50% elapsed. MS/WW fire based on their position in the priority chain. There's no coordination between "auto just fired → now use MS" vs "mid-swing → use Slam."
**Impact:** MEDIUM. The addon uses a flat priority rather than a swing-aware cycle. The Slam timing gate (50% swing ratio) partially handles this, but doesn't distinguish "use MS after auto" from "use Slam mid-swing."

#### DELTA 4: Execute gating is overly restrictive
**Guide says:** Execute at < 20% HP, always. Pool to 120 rage before target hits 20% for burst.
**Addon does:** Execute requires HP ≤ 20% PLUS one of: PvP, player HP < 40%, elite, (1H + raid/low rage), TTD < 4s. A non-elite trash mob at 19% HP with the Arms warrior at full health won't trigger Execute.
**Impact:** MEDIUM. On non-elite trash, Execute simply won't fire unless TTD < 4s or rage < 40 with 1H. The guide treats Execute as universal at < 20%.

#### DELTA 5: BloodthirstHighAP above Mortal Strike
**Guide says:** For Arms, MS is always higher priority than BT (if Arms even has BT, which most don't). The BT > Execute logic is Fury-specific at AP > 2000.
**Addon does:** `BloodthirstHighAP` at position 17 fires before MS (30). If an Arms warrior somehow has BT talented (unusual), it would take priority over MS.
**Impact:** LOW for typical Arms (no BT). But the addon is spec-agnostic — it assumes you might have both MS and BT. For a standard 31/20 Arms build, BT is not available so this is harmless.

#### DELTA 6: Heroic Strike rage threshold
**Guide says:** Queue HS when about to ragecap (instead of Slam). HS is a rage dump to prevent waste.
**Addon does:** HS fires at position 47, requiring rage > 75 + WW on CD (or normal rage check). The +20 overhead in `IsRageAvailable` means it effectively needs 55+ rage after reservations.
**Impact:** LOW. The 75 threshold is reasonable. Guide says "about to ragecap" which is ~80-100, so 75 is slightly eager but close enough.

#### MATCH: Sunder maintenance
**Guide says:** Sunder is highest priority, 5 stacks on anything living > 4s.
**Addon does:** `SunderArmorDPSRefresh` (position 14, refreshes if < 6s remaining) + `SunderArmorElite` (position 15, high prio on elites) + `SunderArmorDPS` (position 44, builds stacks during idle GCDs).
**Status:** Good. The refresh-at-6s and elite-priority logic matches the guide well.

#### MATCH: Overpower stance dance
**Guide says:** Overpower on dodge, minimize rage waste from stance swaps.
**Addon does:** `Overpower` (position 36) checks proc timer, swaps to Battle Stance with 25-rage-loss guard, only if rage retained ≥ 5 (OP cost).
**Status:** Good. The rage-loss guard prevents wasteful swaps.

#### EXTRA: Rend in DPS rotation
**Guide says:** Rend is not mentioned in the Arms ST rotation at all.
**Addon does:** `Rend` at position 43 (TTD > 9s, not raid, not Berserker Stance, creature type filter).
**Impact:** LOW. Rend is reasonable for solo/dungeon but correctly excluded from raid via the `not UnitInRaid()` gate.

---

## 2. Fury (DW) — Single Target

### Guide Priority (warrior-rotations.md, lines 20-29)
```
1. Sunder Armor (until 5 stacks)
2. Execute (target < 20% HP — but see BT vs Execute threshold)
3. Bloodthirst (keep on CD, don't clip for WW)
4. Whirlwind (don't clip BT CD)
5. Heroic Strike (rage dump, first to drop if threatcapped)
6. Master Strike/Pummel/Hamstring/Sunder (proc fishing filler)
```

### Addon Priority (/idps — same chain as Arms)

The addon uses **one shared /idps** for both Arms and Fury. It uses `IsSpellLearnt()` to skip unavailable abilities.

### Deltas

#### DELTA 7: No "don't clip BT CD for WW" logic
**Guide says:** "When WW has 1 second left on CD and BT has 2 seconds, don't press WW. Wait and press BT."
**Addon does:** BT (position 32) and WW (position 34) use simple CD pre-queue checks. If both are near-ready, BT fires first by position alone. But if WW is ready and BT has 2s left, WW fires — there's no "wait for BT" holdback.
**Impact:** MEDIUM for Fury. The guide explicitly calls this out as a common rotation mistake. Implementing this would require WW to check `GetCooldownRemaining("Bloodthirst") > some_threshold`.

#### DELTA 8: BT vs Execute rage efficiency not fully implemented
**Guide says:** BT > Execute when: AP > 2000 AND rage 30-60 AND not extreme rage income AND expect more GCDs.
**Addon does:** `BloodthirstHighAP` at position 17 fires before Execute (19) if AP > 2000 AND rage < 60. This partially matches — but the guide's nuance about "not extreme rage income" and "expect more GCDs" isn't captured.
**Impact:** LOW. The AP > 2000 + rage < 60 heuristic is a reasonable simplification.

#### MATCH: Heroic Strike as rage dump
**Guide says:** HS is rage dump, first to drop if threatcapped.
**Addon does:** HS at position 47 (very late), requires rage > 75 + WW on CD. No threat check, but position handles it.
**Status:** Good. Late position ensures HS only fires when everything else is on CD.

#### MATCH: Proc fishing fillers
**Guide says:** Master Strike/Pummel/Hamstring/Sunder as fillers to proc WF/Flurry/Crusader.
**Addon does:** MasterStrike (37), MasterStrikeWindfury (50, BUGGED), PummelWindfury (52), HamstringWindfury (54), SunderArmorWindfury (56) — all gated on Windfury Totem active.
**Status:** Partial match. The WF-gated fillers are correct but MasterStrikeWindfury has the Hamstring bug (casts Hamstring instead of Master Strike).

---

## 3. Fury (2H) — Single Target

### Guide Priority (warrior-rotations.md, lines 42-51)
```
Same as DW Fury but:
- Heroic Strike very low priority
- Slam replaces HS: cast after each auto-attack
- Overpower stronger for 2H than DW
```

### Deltas

#### MATCH: HS de-prioritized for 2H
**Addon does:** HS at position 47 is already very late. Slam at position 22 is much earlier. For 2H, Slam fires and HS only fires as last resort. This matches the guide.

#### MATCH: Slam after auto-attack
**Addon does:** Slam gates on `st_timer > UnitAttackSpeed("player") * 0.5` — only fires when swing timer is past 50%. This effectively means "cast Slam after auto lands." Matches the guide.

#### DELTA 9: Overpower priority not elevated for 2H
**Guide says:** "Overpower is considerably better for 2H fury than DW fury."
**Addon does:** Overpower is at position 36 for all specs. No 2H-specific boost.
**Impact:** LOW. Overpower is reactive (proc-based), so position matters less — it fires when available regardless. But moving it up for 2H would be a minor optimization.

---

## 4. Arms — Multi Target

### Guide Priority (warrior-rotations.md, lines 99-111)
```
(prepop Sweeping Strikes)
1. Whirlwind (massive with SS, be ready to LIP)
2. Sunder Armor (at least 1 per mob)
3. Cleave (keep queued, slow swing timer limits value)
4. Mortal Strike (good when GCD open after WW)
5. Execute (last GCD or with rage pot only)
```

### Addon Priority (/icleave chain, rotation.lua lines 61-104)
```
Position  Function                      Effective Gate
───────── ──────────────────────────────  ─────────────────────────────────
 69       CleaveStance                   Exit Defensive
 70       Bloodrage                      Rage gen
 71       BattleShout                    Maintain buff
 73       SweepingStrikes                Battle Stance + CD ready
 75       WhirlwindAOE                   Berserker + CD < GCD ← ★ CORRECT: #1
 77       SunderArmorElite               Elite + <5 stacks
 78       DPSStanceDefault               Smart stance
 79       BloodthirstHighAP              AP>2000 + rage<60
 81       Slam                           2H + swing timing
 84       SunderArmorDPS2Hander          2H sunder filler
 86       ShieldSlam                     Shield equipped
 88       MortalStrike                   CD < GCD
 90       Bloodthirst                    CD < GCD
 92       Overpower                      Proc available
 93       ConcussionBlow                 Off CD
 94       ThunderClapDPS                 Not Berserker + off CD
 95       BattleShoutRefresh             < 9s remaining
 96       DemoralizingShout              /iwin demo on
 98       BerserkerRage                  Rage farm
 99       SunderArmorDPS                 <5 stacks, idle GCD
101       Cleave                         Rage available ← ★ LAST
103       StartAttack
```

### Deltas

#### DELTA 10: Cleave is dead last (position 101) — guide says #3
**Guide says:** "Cleave. Keep queued; slow swing timer limits value vs instants." It's #3 priority after WW and Sunder.
**Addon does:** Cleave is the absolute last ability before StartAttack. Since Cleave has no queueGCD gate (it's a swing replacement), it will still fire even if other abilities consumed the GCD. But it only fires if rage > 40 (20 cost + 20 overhead) or rage > 75.
**Impact:** MEDIUM. Cleave's position doesn't matter as much since it's off-GCD (swing replacement). But the rage threshold is high — the guide says keep Cleave queued constantly for AoE, which means it should fire at lower rage thresholds during AoE.

#### DELTA 11: No Execute in cleave rotation
**Guide says:** Execute is #5 priority for AoE (last GCD or with rage pot).
**Addon does:** /icleave has no Execute call at all.
**Impact:** LOW-MEDIUM. Guide says Execute is "heavily nerfed since 1.17.2, only worth using as a last GCD." Still, it's free damage on dying trash. An Execute call gated on TTD < 3s or rage > 80 would be appropriate.

#### MATCH: Sweeping Strikes pre-pop
**Guide says:** Activate SS before pull, use again during pull when it comes off CD.
**Addon does:** SweepingStrikes at position 73, auto-swaps to Battle Stance, reserves rage via cooldown tracking.
**Status:** Good. The rage reservation system ensures rage is available when SS comes off CD.

#### MATCH: Whirlwind #1 priority
**Guide says:** WW is #1 in AoE, massive with Sweeping Strikes.
**Addon does:** `WhirlwindAOE` at position 75 with `queueTime = GCD` (pre-queuing enabled).
**Status:** Good. WW is correctly the highest-priority damage ability in /icleave.

---

## 5. Furyprot — Single Target

### Guide Priority (warrior-rotations.md, lines 115-125; warrior-guide.md, lines 268-285)
```
1. Sunder Armor (until 5 stacks)
2. Bloodthirst (keep on CD, primary threat gen)
3. Heroic Strike (rage dump, high static threat modifier, drop at low rage)
4. Revenge (after block/dodge/parry, after BT, don't clip BT CD)
5. Battle Shout (slightly more ST threat than Sunder at 5 party members)
6. Shield Bash (interrupt priority)
```

### Addon Priority (/itank chain, rotation.lua lines 106-144)
```
Position  Function                      Effective Gate
───────── ──────────────────────────────  ─────────────────────────────────
115       TankStance                     Enter Defensive (DT-aware)
116       Bloodrage                      Rage gen
117       ShieldBlock                    Tanking + 5 sunders + Revenge about to be up
118       SlamThreat                     Rank 5 Slam + 2H + swing timing
121       ExecuteDefensiveTactics        HP<=20% + DT proc
123       OverpowerDefensiveTactics      Proc + DT Battle Stance available
124       ShieldSlam                     Shield + CD < GCD ← ★ NOT IN FURYPROT GUIDE
125       MortalStrike                   CD < GCD ← ★ NOT IN FURYPROT GUIDE
128       Bloodthirst                    CD < GCD
130       BattleShoutRefresh             < 9s remaining
132       Revenge                        Proc available + Defensive Stance
134       ConcussionBlow                 Off CD
135       SunderArmorFirstStack          Not sundered + no Expose Armor
137       DemoralizingShout              /iwin demo on
138       SunderArmor                    Rage available (no stack limit)
140       BerserkerRage                  Rage farm
141       HeroicStrike                   Rage > 75 or WW on CD
143       StartAttack
```

### Deltas

#### DELTA 12: ShieldSlam and MortalStrike above Bloodthirst — not furyprot abilities
**Guide says:** Furyprot uses BT as primary threat gen. Shield Slam is a prot-tree talent (Furyprot doesn't have it). Mortal Strike is an Arms talent (Furyprot doesn't have it).
**Addon does:** ShieldSlam (124) and MortalStrike (125) are called before Bloodthirst (128). Since these are gated by `IsSpellLearnt()`, they'll be skipped if not talented. But this means the addon's /itank is designed for ALL tank specs (Furyprot, DefTactics, Deep Prot), not just Furyprot.
**Impact:** NONE for actual furyprot (abilities skip due to IsSpellLearnt). But it means the addon can't optimize priority order per spec — a DefTactics prot would benefit from ShieldSlam > BT, while furyprot wants BT > everything.

#### DELTA 13: Heroic Strike is dead last (position 141)
**Guide says:** HS is #3 priority for furyprot — it has a "high static threat modifier" and should be spammed while rage allows.
**Addon does:** HS at position 141, gated on rage > 75 + WW on CD. This makes it a last-resort rage dump.
**Impact:** HIGH for threat. The guide emphasizes HS as a core threat tool for furyprot, not just a dump. "Any time you have insane amounts of rage being generated, this becomes responsible for a massive portion of your threat generated." The addon under-prioritizes it significantly.

#### DELTA 14: Revenge after BattleShoutRefresh
**Guide says:** Revenge is #4, after HS. "Anytime you block, dodge, or parry and this is off CD, use this right after BT."
**Addon does:** Revenge at position 132, after BattleShoutRefresh (130). BattleShout consumes a GCD that could have been Revenge.
**Impact:** LOW. BattleShoutRefresh only fires when buff < 9s, which is rare. Most keypresses, BattleShout is skipped and Revenge fires normally.

#### DELTA 15: Sunder not first action
**Guide says:** Sunder is #1 — first GCD on pull, maintain 5 stacks.
**Addon does:** `SunderArmorFirstStack` (135) is deep in the chain — after BT, Revenge, ConcussionBlow. `SunderArmor` (138) is even later with no stack limit.
**Impact:** MEDIUM on pull. First GCD should be Sunder (especially if no other warrior is sundering). During sustain, it matters less since SunderArmor has no stack cap and fires whenever other abilities are on CD.

#### MATCH: Bloodthirst keep on CD
**Guide says:** BT is primary threat gen, keep on CD.
**Addon does:** BT at position 128 with `CD < GCD` pre-queue. Among the first damage abilities to fire (after ShieldSlam/MS which are skipped for furyprot).
**Status:** Good for actual furyprot gameplay.

---

## 6. Furyprot — Multi Target

### Guide Priority (warrior-rotations.md, lines 126-137; warrior-guide.md, lines 286-303)
```
1. Sunder Armor (first GCD, at least 1 per mob)
2. Cleave (best consistent AoE, hidden threat modifier)
3. Bloodthirst (good for high-priority kill targets)
4. Thunder Clap (zero scaling but good threat/rage on 4+ mobs, -10% attack speed)
5. Revenge (keep on CD if shield + everything else on CD)
6. Demoralizing Shout (once at pull start)
7. Shield Bash (interrupt: healers > heal reduction > slows)
```

### Addon Priority (/ihodor chain, rotation.lua lines 146-185)
```
Position  Function                      Effective Gate
───────── ──────────────────────────────  ─────────────────────────────────
157       ShieldBlockFRD                 Force Reactive Disk equipped
158       ThunderClap                    CD < GCD ← matches #4
160       DemoralizingShout              /iwin demo on ← matches #6
162       BattleShoutRefresh             < 9s remaining
164       SlamThreat                     Rank 5 + 2H
167       ExecuteDefensiveTactics        HP<=20% + DT proc
169       ShieldSlam                     Shield + CD < GCD
171       MortalStrike                   CD < GCD
173       Bloodthirst                    CD < GCD ← matches #3
175       Revenge                        Proc + Defensive ← matches #5
177       ConcussionBlow                 Off CD
178       SunderArmorFirstStack          Not sundered
179       SunderArmor                    No stack limit
182       Cleave                         Rage available ← ★ LAST (guide says #2)
184       StartAttack
```

### Deltas

#### DELTA 16: Cleave is last again — guide says #2 for multi-target tanking
**Guide says:** "CLEAVE. By far the best and most consistent ability you have for AoE." #2 priority.
**Addon does:** Cleave at position 182, absolute last ability.
**Impact:** MEDIUM. Like DPS Cleave, it's a swing replacement (off-GCD) so position matters less. But the rage threshold (20 + 20 overhead = 40) means Cleave won't fire during rage-starved AoE situations where the guide says to prioritize it.

#### DELTA 17: /ihodor is FRD-specific, not general AoE tank
**Guide says:** General multi-target furyprot rotation.
**Addon does:** /ihodor's `ShieldBlockFRD` specifically checks for Force Reactive Disk. This is a niche tanking shield, not the general case.
**Impact:** LOW. The rotation still works without FRD (ShieldBlockFRD just won't fire). But there's no general AoE tank rotation — /itank is single-target.

---

## 7. Defensive Tactics Prot

### Guide Priority (warrior-rotations.md, lines 140-177)
```
Defensive Stance: Shield Slam → Concussion Blow → Revenge → Sunder → HS
Battle Stance: Overpower → Shield Slam/CB → Sunder → HS
Berserker Stance: Shield Slam/CB → Whirlwind → Sunder → HS
```

### Addon Implementation (/itank with DT settings)

The addon handles DefensiveTactics via settings (`/iwin dtbattle`, `/iwin dtdefensive`, `/iwin dtberserker`) and the `TankStance()` function which does DT-aware stance selection. `ExecuteDefensiveTactics` and `OverpowerDefensiveTactics` handle DT-specific stance dancing.

### Deltas

#### DELTA 18: No stance-specific priority reordering
**Guide says:** Different priority chains per stance (OP #1 in Battle, WW #2 in Berserker).
**Addon does:** One priority chain for /itank regardless of current stance. ShieldSlam/MS/BT are always in the same order.
**Impact:** MEDIUM. The addon can't optimize per-stance because it's a flat priority chain. A DT Prot in Battle Stance should prioritize Overpower above all else, but the addon has Overpower at position 123 (below ShieldSlam/MS/BT).

---

## 8. Cross-Cutting Issues

### DELTA 19: One /idps for all DPS specs
The addon uses a single /idps rotation for Arms, Fury DW, and Fury 2H. The `IsSpellLearnt()` gates skip unavailable abilities, but the PRIORITY ORDER can't vary by spec. This means:
- Arms: MS should be #1 spender → but it's at position 30 (below BT variants)
- Fury DW: BT should be #1 spender → BT is at position 32 (close to MS at 30)
- Fury 2H: Slam should be #1 spender → Slam is at position 22 (correct relative position)

**Recommendation:** Either split into `/idpsarms`, `/idpsfury`, `/idpsfury2h` OR dynamically detect spec and reorder.

### DELTA 20: SetSlamQueued() disabled — IMPLEMENTED (2026-02-08, pending test)
~~The `SetSlamQueued()` function is commented out in ALL rotations (lines 24, 83, 120).~~

**Status:** Re-enabled and rewritten. Three bugs fixed:
1. **Broken math** — original `st_timer + attackSpeed` was a no-op (`st_timer` counts DOWN, not up). Rewritten to compare `st_timer > slamWindow` directly.
2. **Slam re-cast loop** — Slam resets swing timer, so its conditions were instantly true again. Added `slamGCDAllowed` gate to Slam() itself: one Slam per swing cycle.
3. **Grace period too short** — `slamGCDAllowed = castFinish + 0.2s` gave only 200ms for fillers. Extended to `castFinish + attackSpeed*0.5 + 0.2s`, scaling with weapon speed. MS/WW now have a full filler window after each Slam.

**Additional fixes:**
- Slam rage reservation (`SetReservedRageSlam`) skipped during grace period, so MS needs 30 rage (not 45)
- Overpower exempted from `slamQueued` gate (reactive proc, 5s window, cheap — guide says "OP instead of Slam")
- Debug toggle: `/iwin slamdebug on|off` prints slam gating decisions to chat
- Uncommented in all 4 rotations: `/idps`, `/icleave`, `/itank`, `/ihodor`

### DELTA 21: MasterStrikeWindfury bug (confirmed, line ~609)
The function casts Hamstring instead of Master Strike. This is a copy-paste bug from HamstringWindfury. Every time Windfury procs and this function fires, the player wastes a GCD on Hamstring instead of Master Strike (which does significantly more damage).

---

## Summary: Priority-Ranked Deltas

| # | Delta | Spec | Impact | Effort |
|---|-------|------|--------|--------|
| 1 | MS at position 30, should be ~17 for Arms | Arms | HIGH | LOW (reorder lines) |
| 13 | HS at position 141 in /itank, guide says #3 for furyprot | Furyprot | HIGH | LOW (reorder lines) |
| 20 | ~~SetSlamQueued disabled~~ **IMPLEMENTED** — rewritten + re-enabled | Arms/2H | HIGH | DONE (pending test) |
| 2 | WW queueTime=0 — no pre-queuing | Arms/Fury | MEDIUM | LOW (change 0 to GCD) |
| 7 | No "don't clip BT CD for WW" holdback | Fury | MEDIUM | MEDIUM (add CD comparison) |
| 10 | Cleave dead last in /icleave | Arms AoE | MEDIUM | LOW (position or rage threshold) |
| 4 | Execute gating too restrictive | Arms/Fury | MEDIUM | LOW (relax conditions) |
| 3 | No swing-timer interleaving cycle | Arms | MEDIUM | HIGH (architectural) |
| 15 | Sunder not first action in /itank | Furyprot | MEDIUM | LOW (reorder) |
| 19 | One /idps for all DPS specs | All DPS | MEDIUM | MEDIUM (split or detect) |
| 16 | Cleave last in /ihodor | FP AoE | MEDIUM | LOW (rage threshold) |
| 18 | No stance-specific priority for DT | DT Prot | MEDIUM | MEDIUM (branching) |
| 11 | No Execute in /icleave | Arms AoE | LOW-MED | LOW (add call) |
| 21 | MasterStrikeWindfury bug | All DPS | LOW | LOW (fix one line) |
| 8 | BT vs Execute rage nuance incomplete | Fury | LOW | LOW |
| 9 | Overpower not elevated for 2H | 2H Fury | LOW | LOW |
| 5 | BloodthirstHighAP above MS (harmless for Arms) | Arms | LOW | NONE |
| 6 | HS 75 rage threshold (close enough) | All | LOW | NONE |
| 14 | Revenge after BattleShout (rare conflict) | Furyprot | LOW | NONE |
| 12 | ShieldSlam/MS in /itank (skipped by furyprot) | Furyprot | NONE | NONE |
| 17 | /ihodor is FRD-specific | FP AoE | LOW | NONE |
