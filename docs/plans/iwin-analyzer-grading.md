# IWinEnhanced Analyzer — Grading Results

> Date: 2026-02-11
> Analyzer version: v1 (first run)
> Agent model: Claude Opus 4.6 (subagent)

---

## Scorecard — Known Issues (should detect)

| # | Known Issue | Source | Status | Detected? | Notes |
|---|------------|--------|--------|-----------|-------|
| 1 | MS at position 30 instead of ~17 in /idps | DELTA 1 | OPEN | **YES** | Rule 5, flagged as HIGH. Report says "position 17" (line 30 in rotation.lua). Correctly identified as major Arms DPS loss. |
| 2 | WW(0) should be WW(GCD) in /idps | DELTA 2 | OPEN | **NO** | Rule 11 reported PASS for /idps. The analyzer checked Whirlwind(GCD) at line 34 and saw it passes GCD — which is correct in the CURRENT code. **The fix was already applied.** This is actually a correct PASS, not a miss. See note below. |
| 3 | Execute gating too restrictive | DELTA 4 | OPEN | **NO** | Not flagged. Execute's complex gating (PvP OR low HP OR elite OR conditions) was not compared against a simpler ideal. Rule 8 (Ability Constraints) reported PASS. The analyzer doesn't have a "gating too strict" detection pattern — only "missing constraint." |
| 4 | MasterStrikeWindfury casts Hamstring | DELTA 21 | OPEN | **YES** | Rule 13, flagged as CRITICAL. Exact line cited (action.lua:639). Top recommendation. |
| 5 | BattleShout was below off-GCD HeroicStrikeTank | Tank fix | FIXED | **YES** | Rule 3 (GCD Ordering) for /itank reported PASS with note that BattleShoutRefresh is at pos 15 below HeroicStrikeTank pos 16 — wait, actually the report says BattleShoutRefresh (pos 15) is ABOVE HeroicStrikeTank (pos 16). This means it correctly sees the fix is in place. Scored as detected (PASS = previously fixed). |
| 6 | Revenge reserved rage in Battle Stance | Tank fix | FIXED | **YES** | Rule 2 for /itank: SetReservedRageRevenge now gates on `IsTanking() and IsStanceActive("Defensive Stance")` (action.lua:851-854). Report shows Rule 2 for /itank as WARN for MS/BT reservation leaks but Revenge reservation is clean. Correctly sees fix is in place. |
| 7 | BT/Revenge in /ihodor for DT Prot | Tank fix | FIXED | **YES** | Rule 4 for /ihodor: no BT or Revenge appear in /ihodor chain. The report correctly does NOT flag these as present. No Revenge noted under "Rotation Completeness" as LOW (intentional omission for AoE). |
| 8 | SunderFirstStack was below other abilities | Tank fix | FIXED | **YES** | /itank shows SunderArmorFirstStack at position 10 (after ShieldBlock, SlamThreat, ExecuteDT, OverpowerDT — all situational). /ihodor shows it at position 9. The report correctly sees these as reasonable positions. |
| 9 | HS used +20 swing tax in tank context | Tank fix | FIXED | **YES** | Rule 7 for /itank: "Uses HeroicStrikeTank (no +20 tax). Correct." Flagged as PASS. |
| 10 | Cleave used +20 swing tax in AoE tank | Tank fix | FIXED | **YES** | Rule 7 for /ihodor: "Uses CleaveAOE (no +20 tax). Correct for tank AoE." Flagged as PASS. |

### Detection Rate: 8/10

**Notes on misses:**
- **#2 (WW pre-queue):** Actually a false miss — the current code already has `Whirlwind(GCD)` at rotation.lua:34, so the analyzer correctly reported PASS. The delta was from BEFORE the fix. Arguably 9/10 if we count this.
- **#3 (Execute gating):** Genuine miss. The rules doc doesn't have a "gating too strict" pattern — Rule 8 only checks for MISSING constraints, not EXCESSIVE constraints. **Action:** Add a sub-rule to Rule 8: "Check if gating conditions are more restrictive than the guide suggests."

---

## Scorecard — Known False Positives (should NOT flag)

| # | Intentional Design Choice | Reason | Incorrectly Flagged? | Notes |
|---|--------------------------|--------|---------------------|-------|
| 1 | Rend in /idps (not in guide) | Gated to non-raid, valid for solo/dungeon | **NO** | Not flagged. Analyzer didn't mention Rend at all in /idps violations. |
| 2 | No WW in DT Prot | 1H WW is too weak — intentionally excluded | **NO** | /ihodor Rule 5: "No Whirlwind in /ihodor. Intentional (1H WW = weak)." Correctly marked as intentional. |
| 3 | Shield Bash not in /itank | Delegated to /ikick — design choice | **NO** | Not flagged. /itank Rule 10 says "Shield Bash intentionally in /ikick." |
| 4 | ShieldSlam/MS/BT all in /itank | Multi-spec design (IsSpellLearnt gates) | **PARTIAL** | /itank Rule 4 reported LOW for SlamThreat but acknowledged multi-spec support. However, /itank Rule 2 flagged MS/BT RESERVATIONS (not the abilities themselves) as HIGH. The reservation leak IS a real bug, not a false positive — the abilities are fine but the unconditional SetReservedRage is the problem. So this is **correctly flagged as a reservation issue, not a dead code issue.** |
| 5 | ConcussionBlow has no rage check | CastSpellByName fails gracefully, low priority | **NO** | Flagged as LOW in Ability Function Issues with note "CastSpellByName fails gracefully, so functional impact is minimal." Correctly rated LOW, not elevated. |

### False Positive Rate: 0/5

All intentional design choices were either not flagged or correctly identified as intentional/LOW severity.

---

## Bonus Findings (not in either scorecard)

The analyzer found several issues NOT in the known-issue scorecard:

| # | Finding | Severity | Verdict |
|---|---------|----------|---------|
| B1 | MS/BT reservation leak in /itank and /ihodor (unconditional SetReservedRage) | HIGH | **Valid bug.** SetReservedRage doesn't check IsSpellLearnt — 30-60 phantom rage reserved for DT Prot. |
| B2 | Double Sunder reservation in /ihodor (lines 162, 175) | MEDIUM | **Valid bug.** Over-reserves by 10 rage. |
| B3 | SunderArmorWindfury missing slamQueued check | MEDIUM | **Valid bug.** Could steal GCD during Slam window. |
| B4 | HamstringWindfury missing slamQueued check | MEDIUM | **Valid bug.** Same issue. |
| B5 | BerserkerRage consuming queueGCD (may be off-GCD) | MEDIUM | **Needs verification.** May or may not be off-GCD in Turtle WoW. |
| B6 | ConcussionBlow priority too low in /itank (pos 17 vs guide #2) | HIGH | **Valid observation.** Guide says #2 for DT Prot. Worth investigating. |
| B7 | No Execute in /icleave | MEDIUM | **Valid observation.** Guide lists Execute for AoE. |
| B8 | ShieldSlam reservation in DPS rotations without shield check | MEDIUM | **Valid bug.** Phantom 20 rage reserved. |

---

## Final Grade

| Metric | Score |
|--------|-------|
| Detection Rate | **8/10** (9/10 if WW pre-queue counted as already-fixed) |
| False Positive Rate | **0/5** |

| Grade | Detection Rate | False Positive Rate | Verdict |
|-------|---------------|--------------------|---------|
| **A** | >= 7/10 | <= 1/5 | **Keep in toolset** |

### Grade: A

The analyzer detected 8 of 10 known issues (including correctly recognizing 6 fixed issues as PASS), produced zero false positives against intentional design choices, and found 8 bonus issues — several of which are genuine bugs (reservation leaks, missing slamQueued checks).

---

## Rule Tuning Notes

1. **Rule 8 (Ability Constraints):** Add sub-pattern for "over-restrictive gating" — currently only detects missing constraints, not excessive ones. This would catch the Execute gating issue (DELTA 4).
2. **Rule 2 (Rage Reservation):** The analyzer correctly identified that `SetReservedRage` doesn't internally check `IsSpellLearnt`. This is a systemic issue — consider documenting as a meta-rule: "Every SetReservedRage should be gated by the same conditions as the ability it reserves for."
3. **Rule 11 (Pre-Queue):** The WW(0) vs WW(GCD) issue was already fixed in the code. The analyzer correctly reported PASS. No rule change needed.
4. **Rule 3 (GCD Ordering):** Could add a note about ConcussionBlow priority for DT Prot — the analyzer found this independently.
