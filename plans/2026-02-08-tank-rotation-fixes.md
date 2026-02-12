# Tank Rotation Optimization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix the 4 highest-impact deltas from the tank rotation analysis to improve threat output for DT Prot, without rage-starving core abilities.

**Architecture:** Create tank-specific variants of HeroicStrike and Cleave that bypass the +20 swing replacement tax but respect the reservation system. Reorder `/itank` and `/ihodor` priority chains. Relax ShieldBlock's sunder gate.

**Tech Stack:** Lua (WoW 1.12 API), IWinEnhanced addon framework

**Testing:** No automated tests — all verification is in-game via `/reload`. Each task includes a test plan with specific in-game checks.

**Deploy command:** `cp -r addons/IWinEnhanced/* C:/Games/TurtleWoW/Interface/AddOns/IWinEnhanced/` then `/reload` in-game.

---

### Task 1: Create HeroicStrikeTank() — reservation-aware, no swing tax

**Files:**
- Modify: `addons/IWinEnhanced/warrior/action.lua` (after line 446, after existing `HeroicStrike()`)

**Why:** The existing `HeroicStrike()` uses `IsRageAvailable("Heroic Strike")` which adds +20 swing replacement tax (action.lua:315), requiring 15 (cost) + 20 (tax) + reservedRage = 35+ rage minimum. In tank context, incoming boss melee replaces lost swing rage quickly, so the tax over-penalizes. But we MUST still respect reservedRage so Shield Slam (20), Revenge (5), Sunder (10) are never rage-starved.

**Step 1: Add HeroicStrikeTank function**

Insert after the closing `end` of `HeroicStrike()` (after line 446):

```lua
function IWin:HeroicStrikeTank()
	if IWin:IsSpellLearnt("Heroic Strike") then
		-- Tank variant: no +20 swing tax (incoming damage replaces lost rage)
		-- Still respects reservedRage for Shield Slam/Revenge/Sunder
		local rageNeeded = IWin_RageCost["Heroic Strike"] + IWin_CombatVar["reservedRage"]
		if UnitMana("player") >= rageNeeded then
				IWin_CombatVar["swingAttackQueued"] = true
				IWin_CombatVar["startAttackThrottle"] = GetTime() + 0.2
				CastSpellByName("Heroic Strike")
		end
	end
end
```

**Design notes:**
- `IWin_RageCost["Heroic Strike"]` = 15 (minus Improved HS talent points)
- `reservedRage` accumulates from `SetReservedRage()` calls earlier in the chain
- No fallback `rage > 75` OR — purely reservation-driven
- Example: Shield Slam reserved (20) + Revenge reserved (5) → rageNeeded = 15 + 25 = 40. HS fires at 40+ rage
- Example: Nothing reserved (all on CD) → rageNeeded = 15. HS fires at 15+ rage (aggressive but safe since nothing else needs rage)

**Step 2: Commit**

```bash
git add addons/IWinEnhanced/warrior/action.lua
git commit -m "feat(tank): add HeroicStrikeTank() — reservation-aware, no swing tax"
```

---

### Task 2: Create CleaveAOE() — reservation-aware, no swing tax

**Files:**
- Modify: `addons/IWinEnhanced/warrior/action.lua` (after line 200, after existing `Cleave()`)

**Why:** Same issue as HS. `Cleave()` uses `IsRageAvailable("Cleave")` which adds +20 tax: 20 (cost) + 20 (tax) + reservedRage = 40+ minimum. In AoE tanking with 4+ mobs hitting you, rage income is very high and the tax over-penalizes. Guide says Cleave is "#2 best and most consistent AoE ability."

**Step 1: Add CleaveAOE function**

Insert after the closing `end` of `Cleave()` (after line 200):

```lua
function IWin:CleaveAOE()
	if IWin:IsSpellLearnt("Cleave") then
		-- AoE tank variant: no +20 swing tax (multi-mob incoming damage replaces lost rage)
		-- Still respects reservedRage for Thunder Clap/Shield Slam/Sunder
		local rageNeeded = IWin_RageCost["Cleave"] + IWin_CombatVar["reservedRage"]
		if UnitMana("player") >= rageNeeded then
				IWin_CombatVar["swingAttackQueued"] = true
				IWin_CombatVar["startAttackThrottle"] = GetTime() + 0.2
				CastSpellByName("Cleave")
		end
	end
end
```

**Design notes:**
- `IWin_RageCost["Cleave"]` = 20
- Example: TC reserved (20) + ShieldSlam reserved (20) → rageNeeded = 20 + 40 = 60. Still conservative but 10 rage cheaper than current (60 vs 70+)
- Example: Nothing reserved → rageNeeded = 20. Cleave fires freely when flush with rage
- Preserves the existing `Cleave()` function untouched for DPS rotations (`/icleave`)

**Step 2: Commit**

```bash
git add addons/IWinEnhanced/warrior/action.lua
git commit -m "feat(tank): add CleaveAOE() — reservation-aware, no swing tax"
```

---

### Task 3: Reorder /itank — Sunder first, HS after Revenge

**Files:**
- Modify: `addons/IWinEnhanced/warrior/rotation.lua` (lines 107-143, the `/itank` chain)

**Why:** Two reordering fixes:
1. **T2:** SunderArmorFirstStack should be the first GCD ability (before ShieldSlam) so pull threat benefits from armor reduction on all subsequent hits
2. **T1:** HeroicStrikeTank replaces HeroicStrike, moved up to after Revenge (where the guide says #3)

**Step 1: Replace the /itank function body**

Current chain (lines 107-143):
```lua
function SlashCmdList.ITANKWARRIOR()
	IWin:InitializeRotation()
	IWin:TargetEnemy()
	IWin:CancelSalvation()
	IWin:BattleShoutRefreshOOC()
	IWin:ChargePartySize()
	IWin:IntervenePartySize()
	IWin:InterceptPartySize()
	IWin:TankStance()
	IWin:Bloodrage()
	IWin:ShieldBlock()
	IWin:SlamThreat()
	IWin:SetReservedRageSlamThreat()
	IWin:SetSlamQueuedThreat()
	IWin:ExecuteDefensiveTactics()
	IWin:SetReservedRageExecuteDefensiveTactics()
	IWin:OverpowerDefensiveTactics()
	IWin:ShieldSlam(IWin_Settings["GCD"])
	IWin:SetReservedRage("Shield Slam", "cooldown")
	IWin:MortalStrike(IWin_Settings["GCD"])
	IWin:SetReservedRage("Mortal Strike", "cooldown")
	IWin:Bloodthirst(IWin_Settings["GCD"])
	IWin:SetReservedRage("Bloodthirst", "cooldown")
	IWin:BattleShoutRefresh()
	IWin:SetReservedRage("Battle Shout", "buff", "player")
	IWin:Revenge()
	IWin:SetReservedRageRevenge()
	IWin:HeroicStrike()
	IWin:ConcussionBlow()
	IWin:SunderArmorFirstStack()
	IWin:DemoralizingShout()
	IWin:SetReservedRageDemoralizingShout()
	IWin:SunderArmor()
	IWin:SetReservedRage("Sunder Armor", "nocooldown")
	IWin:BerserkerRage()
	IWin:Perception()
	IWin:StartAttack()
end
```

New chain:
```lua
function SlashCmdList.ITANKWARRIOR()
	IWin:InitializeRotation()
	IWin:TargetEnemy()
	IWin:CancelSalvation()
	IWin:BattleShoutRefreshOOC()
	IWin:ChargePartySize()
	IWin:IntervenePartySize()
	IWin:InterceptPartySize()
	IWin:TankStance()
	IWin:Bloodrage()
	IWin:ShieldBlock()
	IWin:SlamThreat()
	IWin:SetReservedRageSlamThreat()
	IWin:SetSlamQueuedThreat()
	IWin:ExecuteDefensiveTactics()
	IWin:SetReservedRageExecuteDefensiveTactics()
	IWin:OverpowerDefensiveTactics()
	IWin:SunderArmorFirstStack()                        -- MOVED UP: first GCD on pull (0 stacks)
	IWin:ShieldSlam(IWin_Settings["GCD"])
	IWin:SetReservedRage("Shield Slam", "cooldown")
	IWin:MortalStrike(IWin_Settings["GCD"])
	IWin:SetReservedRage("Mortal Strike", "cooldown")
	IWin:Bloodthirst(IWin_Settings["GCD"])
	IWin:SetReservedRage("Bloodthirst", "cooldown")
	IWin:Revenge()                                      -- MOVED UP: guide says "right after BT"
	IWin:SetReservedRageRevenge()
	IWin:HeroicStrikeTank()                             -- CHANGED: tank variant, after Revenge (guide #3)
	IWin:BattleShoutRefresh()
	IWin:SetReservedRage("Battle Shout", "buff", "player")
	IWin:ConcussionBlow()
	IWin:DemoralizingShout()
	IWin:SetReservedRageDemoralizingShout()
	IWin:SunderArmor()
	IWin:SetReservedRage("Sunder Armor", "nocooldown")
	IWin:BerserkerRage()
	IWin:Perception()
	IWin:StartAttack()
end
```

**Changes summarized:**
1. `SunderArmorFirstStack` moved from position 136 to after OverpowerDefensiveTactics (before ShieldSlam). Only fires at 0 stacks — once sundered, auto-skips.
2. `Revenge` moved from after BattleShoutRefresh to after Bloodthirst. Guide: "use right after BT."
3. `HeroicStrike()` → `HeroicStrikeTank()` — reservation-aware tank variant, positioned after Revenge (guide #3).
4. `BattleShoutRefresh` moved below HeroicStrikeTank (less urgent than Revenge/HS for threat).

**Step 2: Commit**

```bash
git add addons/IWinEnhanced/warrior/rotation.lua
git commit -m "feat(tank): reorder /itank — Sunder first on pull, HS after Revenge"
```

---

### Task 4: Reorder /ihodor — use CleaveAOE

**Files:**
- Modify: `addons/IWinEnhanced/warrior/rotation.lua` (lines 146-185, the `/ihodor` chain)

**Why:** Replace `Cleave()` with `CleaveAOE()` for the lower rage threshold. No reordering needed — Cleave position is fine (off-GCD, fires regardless of chain position).

**Step 1: Replace Cleave call in /ihodor**

Change line 182 from:
```lua
	IWin:Cleave()
```
To:
```lua
	IWin:CleaveAOE()
```

**Step 2: Commit**

```bash
git add addons/IWinEnhanced/warrior/rotation.lua
git commit -m "feat(tank): use CleaveAOE in /ihodor for lower rage threshold"
```

---

### Task 5: Relax ShieldBlock sunder gate

**Files:**
- Modify: `addons/IWinEnhanced/warrior/action.lua` (line 863)

**Why (T7):** ShieldBlock gates on `IsBuffStack("target", "Sunder Armor", 5)` — won't fire until target has 5 sunders. This delays Shield Block → Block → Revenge proc chain on pull. Shield Block's purpose is to force blocks for Revenge procs and damage reduction, not to wait for armor reduction.

**Step 1: Remove the sunder 5 gate**

Change line 863 from:
```lua
		and IWin:IsBuffStack("target", "Sunder Armor", 5)
```
To:
```lua
		and IWin:IsBuffActive("target", "Sunder Armor")
```

**Design notes:**
- `IsBuffActive` returns true if ANY stacks of Sunder exist (>= 1), not specifically 5
- This means Shield Block fires after the first Sunder application (Task 3 moves Sunder first, so this happens on GCD 2)
- On a fresh pull with 0 sunders, Shield Block still waits for 1 Sunder — this is correct because you want at least some armor reduction before spending the Shield Block CD
- The other gates remain: shield equipped, tanking, Revenge about to be up, Defensive Stance

**Step 2: Commit**

```bash
git add addons/IWinEnhanced/warrior/action.lua
git commit -m "fix(tank): relax ShieldBlock gate from 5 sunders to 1 sunder"
```

---

### Task 6: Deploy and test in-game

**Files:** None (deployment + verification)

**Step 1: Deploy to live addon folder**

```bash
cp -r addons/IWinEnhanced/* C:/Games/TurtleWoW/Interface/AddOns/IWinEnhanced/
```

**Step 2: In-game verification checklist**

After `/reload`, test each fix:

1. **Sunder first on pull (T2):**
   - Target a training dummy or mob
   - Press `/itank` — first ability cast should be Sunder Armor
   - Verify via combat log: "You cast Sunder Armor" appears before "You cast Shield Slam"

2. **HeroicStrikeTank fires more often (T1):**
   - Engage a mob, let rage build to ~40-50
   - Press `/itank` repeatedly — HS should queue on swings when rage allows
   - Compare: at 45 rage with Shield Slam reserved, old HS wouldn't fire (needs 75+), new fires (needs 15 + 20 reserved = 35)
   - Watch for rage starvation: Shield Slam should still fire on CD without rage issues

3. **ShieldBlock fires earlier (T7):**
   - Engage mob, apply 1 Sunder
   - Press `/itank` — Shield Block should fire (if other conditions met: Revenge about to be up, etc.)
   - Previously required 5 sunders

4. **CleaveAOE in /ihodor (H1):**
   - Pull 2+ mobs, let rage build to ~40
   - Press `/ihodor` — Cleave should queue on swings
   - Compare: old Cleave needed 70+ rage effective, new needs 20 + reservedRage

5. **Rage safety check (CRITICAL):**
   - During sustained tanking, verify Shield Slam fires on CD
   - If HS is eating rage and Shield Slam skips, the HS threshold needs raising
   - Watch for: "I pressed /itank but nothing happened" (rage-starved)

**Step 3: Report results**

User confirms pass/fail for each check. If any fail, iterate before committing deployment.
