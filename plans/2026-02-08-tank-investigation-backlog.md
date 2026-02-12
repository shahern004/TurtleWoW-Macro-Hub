# Tank Rotation Investigation Backlog

> Date: 2026-02-08
> Context: DT Prot warrior, IWinEnhanced addon
> Status: Investigation 2 DONE (2026-02-11). Investigation 1 superseded by tab-sunder.

---

## Investigation 1: Smart Thunder Clap — snap aggro on loose mobs

**Goal:** Fire TClap when there are mobs in combat that we aren't targeting AND don't have threat on. Use TClap as reactive snap aggro, not a spam ability.

**Current behavior:** TClap fires on CD as a filler in /ihodor. No awareness of threat state or loose mobs.

**Desired behavior:** TClap fires when:
- Mobs in combat with the group but NOT targeting us (we don't have threat)
- Fresh mobs join the pull (no sunder, no threat)
- NOT when all mobs are controlled and sundered

**Questions to investigate:**
1. Can IWinEnhanced detect "mobs in combat not targeting me"? Check for `IWin:IsTanking()` per-unit or threat API
2. Does `UnitXP` provide nearby enemy enumeration? Check `unitxp-api.md` for targeting functions
3. Can we use `multiscan` / `meleerange` from CleveroidMacros conditionals to count threatening mobs?
4. Is there a `UnitThreatSituation()` equivalent in 1.12 / SuperWoW / Nampower?
5. Could we check if any mob in melee range has `target != player` as a proxy for "loose mob"?

**Potential approaches:**
- A. New function `ThunderClapSnapAggro()` — only fires if nearby enemies are not targeting player
- B. Conditional in existing TClap — add threat check gate
- C. Separate `/isnap` slash command for manual use

**Docs to read:** `unitxp-api.md` (targeting, distance), `superwow-api.md` (GUID, unit targeting), `cleveroid-conditionals.md` (meleerange, multiscan), `nampower-events.md` (threat events)

---

## Investigation 2: Auto-tab to unsundered mobs

**Goal:** Automatically target the nearest mob without Sunder Armor, so the tab-sunder flow is seamless with `/ihodor`.

**Current behavior:** User manually presses Tab to cycle targets, then presses `/ihodor` which applies SunderArmorFirstStack if target has 0 sunders.

**Desired behavior:** `/ihodor` automatically finds and targets an unsundered mob in melee range when the current target already has 1+ sunder stacks.

**Questions to investigate:**
1. Does `UnitXP("target", "nextEnemyConsideringDistance")` cycle to nearby enemies? Can we filter by debuff?
2. Can we scan nearby enemies via SuperWoW GUID enumeration + debuff check?
3. Does CleveroidMacros `multiscan` expose per-unit debuff info?
4. Could we use `TargetNearestEnemy()` + debuff check + re-target if sundered?
5. Performance: how expensive is scanning all nearby mobs for debuffs per keypress?

**Potential approaches:**
- A. New function `TargetUnsundered()` — scan nearby enemies, target first without Sunder
- B. Use `UnitXP("target", "nextEnemyConsideringDistance")` in a loop until unsundered mob found
- C. Track sundered GUIDs in a table, target anything not in the table

**Docs to read:** `unitxp-api.md` (targeting functions), `superwow-api.md` (UnitExists GUID, unit enumeration), `cleveroid-conditionals.md` (multiscan mechanics)

---

## Priority

Both investigations require understanding what targeting/threat APIs are available in the TurtleWoW modded client. Start by reading the docs listed above, then prototype.

Investigation 2 (auto-tab sunder) has higher immediate value — it directly streamlines the most common AoE tanking action.
