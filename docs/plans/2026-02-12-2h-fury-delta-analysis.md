# 2H Fury Delta Analysis: /idps & /icleave vs. Warrior Guides

> Date: 2026-02-12 | Sources: `warrior-rotations.md`, `warrior-guide.md`, `warrior/rotation.lua`, `warrior/action.lua`

This analysis compares the current IWinEnhanced `/idps` and `/icleave` rotation chains against the 2H Fury rotation priorities documented in the warrior guides. Only 2H Fury-relevant behavior is considered.

---

## Guide Reference: 2H Fury Priorities

### Single Target (from guide)
> "Mostly the same as DW fury, but Heroic Strike is very low prio. Instead of Heroic Strike you use Slam right after your swing hits. Overpower is considerably better for 2H fury than DW fury, especially in lower gear."

Effective priority:
1. **Sunder Armor** — until 5 stacks
2. **Execute** — target <20% HP (BT over Execute at >2000 AP, 30-60 rage, non-extreme income)
3. **Bloodthirst** — keep on CD (if talented; if no BT, use Slam instead)
4. **Slam** — after every auto-attack swing
5. **Whirlwind** — keep on CD, don't clip BT
6. **Overpower** — "considerably better for 2H" (dodge proc, low rage cost)
7. **Heroic Strike** — very low priority (only if rage capping)
8. **Filler** — Master Strike/Pummel/Hamstring/Sunder for proc fishing

### Multi Target (from guide)
> "Same as DW fury, with even more emphasis on ww/cleave, and sometimes utilizing slam on mobs that live longer."

Effective priority:
1. **Sunder Armor** — first GCD, at least 1 per mob
2. **Sweeping Strikes** — pre-pop, use again on CD
3. **Whirlwind** — massive value, duplicated per mob
4. **Cleave** — best consistent AoE, no CD
5. **Execute** — still high damage but can ragestarve
6. **Bloodthirst** — outshined by multi-hit abilities
7. **Slam** — on longer-lived mobs
8. **Filler** — sunder unsundered mobs

---

## /idps Chain Analysis (Single Target)

Current chain order (2H Fury path, positions reflect execution priority):

| Pos | Function | Guide Priority | Notes |
|-----|----------|---------------|-------|
| 7 | BattleShout | Utility | OK — buff maintenance |
| 8 | SunderArmorDPSRefresh | 1 (refresh) | OK — refresh near-expiring sunders |
| 9 | SunderArmorElite | 1 (elite only) | OK — early sunder on elites |
| 10 | DPSStanceDefault | Stance | OK — ensure correct stance |
| 11 | **BloodthirstHighAP(GCD)** | 2-3 | **GOOD** — BT over Execute at high AP, <60 rage |
| 13 | **Execute** | 2 | **See DELTA 1** — heavy gating for 2H |
| 15 | **MortalStrike(GCD)** | N/A for BT builds | OK — only fires if MS is learned (Arms hybrid) |
| 17 | HamstringJousting | Utility | OK — solo jousting only |
| 18 | **Slam** | 4 | **GOOD** — swing-timer gated, first-half-of-cycle only |
| 20 | SetSlamQueued | Mutex | OK — blocks GCD abilities during slam window |
| 21 | **Execute2Hander** | 2 | **See DELTA 1** — unrestricted 2H execute |
| 22 | **SunderArmorDPS2Hander** | 1 | **See DELTA 2** — placed after Execute2Hander |
| 24 | ShieldSlam(GCD) | N/A | OK — only if learned (prot hybrid) |
| 26 | **Bloodthirst(GCD)** | 3 | OK — fallback BT when not high-AP |
| 28 | **Whirlwind(GCD)** | 5 | **See DELTA 3** — no pre-queue |
| 30 | **Overpower** | 6 | OK — stance-dance with rage guards |
| 31 | MasterStrike | Filler | OK — only if tanking or PvP |
| 33 | ConcussionBlow | Utility | OK — if talented |
| 34 | BattleShoutRefresh | Utility | OK |
| 35 | DemoralizingShout | Utility | OK |
| 37 | Rend | Filler | OK — solo only, not raid |
| 38 | **SunderArmorDPS** | 1 (DW path) | Skipped for 2H (Is2HanderEquipped guard in reservation) |
| 40 | BerserkerRage | Utility | **See DELTA 4** |
| 41 | **HeroicStrike** | 7 (very low) | **ALIGNED** — correctly at bottom |
| 43 | Perception | Utility | OK |
| 44-57 | Windfury fillers | Filler | OK — proc fishing |
| 58 | StartAttack | Always | OK |

---

## /icleave Chain Analysis (Multi Target)

| Pos | Function | Guide Priority | Notes |
|-----|----------|---------------|-------|
| 8 | SunderArmorDPSRefresh | 1 (refresh) | OK |
| 9 | CleaveStance | Stance | OK — exits Defensive, prefers Battle for SS |
| 12 | BattleShout | Utility | OK |
| 14 | **SweepingStrikes** | 2 | **ALIGNED** — stance-dances to Battle for SS |
| 16 | **WhirlwindAOE(GCD)** | 3 | **ALIGNED** — highest damage priority |
| 18 | SunderArmorElite | 1 | OK |
| 19 | DPSStanceDefault | Stance | OK |
| 20 | **BloodthirstHighAP(GCD)** | 6 | **See DELTA 5** — too high for AoE? |
| 22 | **Slam** | 7 | OK — only fires with 2H equipped |
| 24 | SetSlamQueued | Mutex | OK |
| 25 | **Execute** | 4 | **See DELTA 1** — same gating issue |
| 27 | **SunderArmorDPS2Hander** | 1 | OK — placed well in cleave |
| 29 | ShieldSlam(GCD) | N/A | OK — prot hybrid only |
| 31 | **MortalStrike(GCD)** | N/A for Fury | OK — only if MS learned |
| 33 | **Bloodthirst(GCD)** | 6 | OK — low in AoE, correct |
| 34 | **Overpower** | Filler | OK |
| 35 | ConcussionBlow | Utility | OK |
| 36 | **ThunderClapDPS** | ~4 (guide says TClap good on 4+) | **ALIGNED** |
| 37 | BattleShoutRefresh | Utility | OK |
| 38 | DemoralizingShout | Utility | OK |
| 40 | BerserkerRage | Utility | **See DELTA 4** |
| 41 | **SunderArmorDPS** | 1 (DW path) | Skipped for 2H |
| 42 | **Cleave** | 4 | **See DELTA 6** — should be higher? |
| 43 | Perception | Utility | OK |
| 44 | StartAttack | Always | OK |

---

## Identified Deltas

### DELTA 1: Execute() Gating Too Restrictive for 2H
**Severity: MEDIUM | Impact: MEDIUM**

`Execute()` (position 13 in /idps, 25 in /icleave) has heavy gating conditions for 2H:
```lua
-- Execute() requires ONE of:
-- UnitIsPVP("target")
-- player HP < 40%
-- target IsElite()
-- (NOT 2H equipped AND (in raid OR rage < 40))  <-- 2H NEVER passes this
-- GetTimeToDie() < 4
```

For 2H users, `Execute()` at position 13 **never fires** (the `not Is2HanderEquipped()` check blocks it). The actual 2H execute is `Execute2Hander()` at position 21, which has **no gating** beyond spell known + execute phase + rage available.

**Guide says:** Execute at priority 2, above BT. Use BT instead only at >2000 AP, 30-60 rage, with reasonable rage income.

**Current behavior:** `BloodthirstHighAP` at pos 11 handles the "BT over Execute" logic (>2000 AP, <60 rage). Then `Execute()` at 13 is dead code for 2H. `Execute2Hander()` at 21 fires but sits below Slam (pos 18).

**Assessment:** The effective 2H execute priority is: BT(high-AP) > MS > Slam > Execute2Hander. This **misaligns** with the guide which wants Execute above BT in most scenarios. The BT-over-Execute logic is correctly handled by BloodthirstHighAP's conditions, but Execute2Hander sitting below Slam means you might Slam instead of Execute during execute phase.

**However:** Slam has a swing-timer window guard (`st_timer > attackSpeed * 0.5`) that blocks it most of the time. During execute phase, Slam will usually not fire unless you just auto'd, and if you just auto'd, Slamming before Executing is actually correct per the guide ("Slam immediately after each auto-attack swing"). So in practice the impact is **low to moderate** — you might lose one Execute per fight when Slam fires at the start of execute phase and eats the GCD.

**Recommendation:** LOW PRIORITY — Current behavior is ~95% correct due to swing timer gating. Could move `Execute2Hander()` above `Slam()` for a marginal improvement, but the slam window guard already prevents most conflicts.

---

### DELTA 2: SunderArmorDPS2Hander Priority vs Guide
**Severity: LOW | Impact: LOW**

`SunderArmorDPS2Hander()` at position 22 in /idps (after Execute2Hander, Slam) is a mid-priority sunder that fires when:
- 2H equipped
- Target <5 sunders
- Target lives >5s
- Sunder setting is not "off"

**Guide says:** Sunder is priority 1 ("EVERY SINGLE MOB... SUNDERS... FIRST AND MOST IMPORTANT ACTION").

**Current behavior:** For fresh targets, `SunderArmorDPSRefresh` (pos 8) handles sunder refresh, and `SunderArmorElite` (pos 9) handles first sunders on elites. On non-elite mobs that already have 1+ sunders, sundering to 5 happens at position 22 (after BT, Slam, Execute).

**Assessment:** This is a **deliberate trade-off** for DPS optimization. The guide's "sunder first" advice is raid-level strategy (get sunders up ASAP from all warriors), not necessarily per-warrior priority. Once other warriors/rogue Expose Armor are considered, sundering to 5 stacks doesn't need to be your personal priority 1 on every press. The `SunderArmorDPSRefresh` at top correctly ensures existing sunders don't fall off.

**Recommendation:** NO CHANGE — Current prioritization correctly balances personal DPS vs. raid utility. The early-position SunderArmorElite covers bosses, and SunderArmorDPSRefresh prevents drops.

---

### DELTA 3: Whirlwind Not Pre-Queued (from existing backlog)
**Severity: MEDIUM | Impact: MEDIUM**

`Whirlwind(GCD)` means WW is queued with a GCD pre-queue window. However, the existing backlog item DELTA 2 from the DPS analysis notes:

> Change `Whirlwind(0)` to `Whirlwind(GCD)` in /idps

This was already done — WW uses `IWin_Settings["GCD"]` now. **This delta is resolved.**

**Recommendation:** ALREADY FIXED — Remove from backlog.

---

### DELTA 4: BerserkerRage Placement
**Severity: LOW | Impact: LOW**

`BerserkerRage()` at position 40 (near bottom) in both /idps and /icleave.

**Guide says:** "a very important ability... gives you a +60% rage bonus from damage taken... use instead of pummel/sunder/hamstring, never clip your bloodthirst/whirlwind cd with it."

**Current behavior:** Being at position 40 means it fires only after all damage abilities fail to cast. This means it won't clip BT/WW/Slam CDs, which is correct. But it also means on some presses where you could press BerserkerRage (all damage on CD), you might instead press a low-value filler like DemoralizingShout or Rend.

**Assessment:** The guide says use it INSTEAD of filler — current placement does exactly this by being after damage abilities but before the very end. The low-value fillers above it (Demo Shout, Rend) have their own conditions that prevent them from firing most of the time (demo="on" setting, raid check, etc). In practice, BerserkerRage fires in the correct "dead GCD" windows.

**Recommendation:** NO CHANGE — Placement is functionally correct.

---

### DELTA 5: BloodthirstHighAP Priority in /icleave
**Severity: LOW-MEDIUM | Impact: LOW**

In /icleave, `BloodthirstHighAP(GCD)` sits at position 20 — **above** Execute (25), Sunder2H (27), and Bloodthirst (33).

**Guide for multi-target:** BT is priority 5-6 in AoE, below WW, Cleave, Execute, and sunder. The guide says BT is "outshined by other buttons on AoE since they hit two or four mobs at once."

**Current behavior:** BloodthirstHighAP only fires when: BT learned, high AP (>2000), rage <60, BT off CD. In AoE situations you're often high rage from multi-mob hits, so the `<60 rage` guard makes it rarely fire. The regular Bloodthirst at position 33 is correctly low.

**Assessment:** When BloodthirstHighAP does fire in AoE (low rage, high AP), it's actually reasonable — at low rage, you can't afford Execute + AoE abilities anyway, and BT is more rage-efficient than Execute per the guide's own formula. The condition set makes this a niche case.

**Recommendation:** MINOR — Could move BloodthirstHighAP below Execute in /icleave for theoretical correctness, but the rage<60 guard means this almost never matters in multi-mob scenarios.

---

### DELTA 6: Cleave Priority in /icleave
**Severity: MEDIUM | Impact: MEDIUM**

`Cleave()` sits at position 42 in /icleave — **dead last** among damage abilities.

**Guide for multi-target:** Cleave is priority 3-4, described as "By far the best and most consistent ability you have for AOE. Has no CD, only tied to your swing timer."

**Current behavior:** Cleave is a next-swing-attack (like Heroic Strike), so it doesn't consume a GCD. It gets queued on the next melee swing. Because it doesn't use the GCD, its position in the chain only matters for **rage budgeting** — it fires last, meaning all GCD abilities get rage priority first.

**Assessment:** This is actually **correct behavior** for an off-GCD ability. The guide rates Cleave highly because of its damage-per-swing value, but since it doesn't compete for GCDs, putting it at the bottom ensures GCD abilities (WW, BT, Execute) get rage first, and Cleave catches whatever's left. If Cleave were higher, it would check `IsRageAvailable` before GCD abilities and potentially not reserve enough rage for them (via the +20 swing tax in the DPS `Cleave()` function).

The DPS `Cleave()` has a generous rage check: fires at `IsRageAvailable("Cleave")` OR `rage > 75`. This means at high rage it always fires regardless of reservations, and at moderate rage it respects reservations. This is smart — it acts as a rage dump similar to HS.

**Recommendation:** NO CHANGE — Bottom placement is correct for an off-GCD ability. Rage reservation system ensures GCD abilities aren't starved.

---

### DELTA 7: No Explicit "Pool Rage for Execute Phase" Logic
**Severity: LOW | Impact: LOW-MEDIUM**

**Guide says:** "when a mob is about to hit 20% hp, you should pause your rotation momentarily to pool rage for a 120 rage execute immediately."

**Current behavior:** No pooling logic exists. The rotation continues pressing abilities until execute phase (<20% HP), then fires Execute2Hander.

**Assessment:** Rage pooling is a manual optimization that's hard to automate without predicting exact boss HP trajectory. The guide's advice is more for manual play. An automated rotation that keeps pressing damage abilities until execute phase and then fires Execute immediately is arguably just as good — you're doing damage with those pre-execute GCDs rather than sitting idle. The only scenario where pooling beats continued damage is when you'd waste a partial Execute due to low rage.

**Recommendation:** NO CHANGE — Automated rotation doesn't benefit from idle pooling. The `BloodthirstHighAP` logic already handles the "BT vs Execute" decision dynamically.

---

### DELTA 8: MasterStrike Only Fires When Tanking/PvP
**Severity: LOW | Impact: LOW**

`MasterStrike()` at position 31 only fires when `IsTanking()` or `UnitIsPVP("target")`.

**Guide says:** Master Strike is filler for proc fishing (priority 6, same as Pummel/Hamstring/Sunder).

**However:** `MasterStrikeWindfury()` at position 50 fires whenever Windfury Totem is active, with no tanking/PvP restriction. So in raid with WF totem, Master Strike does fire as filler.

**Assessment:** In raids (where you have WF totem), Master Strike correctly fires as a proc-fishing filler. Without WF totem (dungeons without shaman), you skip it. This is slightly conservative but reasonable — in small groups without WF, proc fishing has less value.

**Recommendation:** NO CHANGE — WF variant covers the raid case.

---

## Summary Table

| Delta | Description | Severity | Recommendation |
|-------|-------------|----------|----------------|
| **1** | Execute2Hander below Slam in /idps | MEDIUM | LOW PRI — swing timer guard prevents most conflicts |
| **2** | Sunder to 5 stacks not personal prio 1 | LOW | NO CHANGE — deliberate DPS trade-off |
| **3** | WW pre-queue | RESOLVED | Already uses GCD pre-queue |
| **4** | BerserkerRage placement | LOW | NO CHANGE — correct dead-GCD fill |
| **5** | BloodthirstHighAP above Execute in /icleave | LOW-MED | MINOR — rage<60 guard limits impact |
| **6** | Cleave at bottom of /icleave | MEDIUM | NO CHANGE — off-GCD, correct placement |
| **7** | No explicit rage pooling before execute | LOW | NO CHANGE — not automatable |
| **8** | MasterStrike gated to tank/PvP | LOW | NO CHANGE — WF variant covers raids |

---

## Conclusion

The 2H Fury implementation is **well-aligned** with the warrior guides. The main rotation flow — Sunder refresh > BT(high-AP) > Slam (swing-gated) > Execute2Hander > Sunder to 5 > BT > WW > Overpower > fillers > HS — matches the guide's priorities with intelligent automation adaptations.

**Actionable items (ordered by impact):**

1. **DELTA 1 (Execute2Hander position):** Consider moving `Execute2Hander()` above `Slam()` in /idps. Impact is marginal due to slam window guard, but would be theoretically cleaner. ~1-2% of GCDs affected.

2. **DELTA 5 (BloodthirstHighAP in /icleave):** Consider moving below Execute in /icleave. Impact is minimal due to rage<60 guard in AoE.

3. **All other deltas:** No changes recommended.

**Overall grade: A-** — The rotation handles the 2H Fury nuances correctly, including slam window gating, BT-vs-Execute AP logic, overpower stance dancing, and proper HS deprioritization. The two minor improvements above are optimizations, not bugs.
