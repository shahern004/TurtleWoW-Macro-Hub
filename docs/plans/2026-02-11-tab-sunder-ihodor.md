# Tab-Sunder AoE Tank Rotation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add intelligent tab-sunder to `/ihodor` that automatically targets enemies not targeting the player (loose aggro), then enemies without Sunder Armor, while still weaving Thunder Clap and Demoralizing Shout per the warrior rotation guides.

**Architecture:** Insert a `TargetLooseMob()` function into the `/ihodor` rotation chain that cycles nearby enemies via `UnitXP("target", "nextEnemyConsideringDistance")`, evaluates each for threat status (`UnitIsUnit("targettarget", "player")`) and Sunder status (`IsBuffActive("target", "Sunder Armor")`), then targets the highest-priority unsundered/loose mob. The rotation chain order preserves TClap/Demo Shout weaving at their existing priority slots. A `/iwin tabsunder` config toggle controls the feature.

**Tech Stack:** IWinEnhanced addon (Lua), SuperWoW (GUID targeting), UnitXP_SP3 (enemy cycling), CleveRoids libdebuff (debuff detection)

---

## Design Decisions

### Target Priority Logic

When `tabsunder` is enabled and the GCD is available, `TargetLooseMob()` scans nearby enemies and picks the best target using this priority:

1. **Enemies NOT targeting player AND without Sunder** — highest priority (loose mob, no threat established)
2. **Enemies NOT targeting player WITH Sunder** — medium priority (losing aggro on established mob)
3. **Enemies targeting player WITHOUT Sunder** — lower priority (we have threat but need sunder stacks)
4. **Current target / all sundered + targeting us** — no switch needed (stable)

### Where in the Rotation Chain

```
Current /ihodor:
  Init → TargetEnemy → Stances → Bloodrage → ShieldBlockFRD
  → Execute → Overpower → SunderArmorFirstStack → ShieldSlam
  → MortalStrike → ThunderClap → ConcussionBlow → Demo → BattleShout
  → SunderArmor → BerserkerRage → CleaveAOE → StartAttack

New /ihodor:
  Init → TargetEnemy → Stances → Bloodrage → ShieldBlockFRD
  → Execute → Overpower
  → **TargetLooseMob()**          ← NEW: switches target if better candidate exists
  → SunderArmorFirstStack → ShieldSlam
  → MortalStrike → ThunderClap → ConcussionBlow → Demo → BattleShout
  → SunderArmor → BerserkerRage → CleaveAOE → StartAttack
```

**Rationale:** `TargetLooseMob()` runs AFTER Execute/Overpower (reactive procs should fire on current target first) but BEFORE SunderArmorFirstStack (so the sunder lands on the chosen loose mob). This means the first sunder always goes to the highest-priority target.

### Cycling Strategy

- Save original target GUID via `UnitExists("target")`
- Use `UnitXP("target", "nextEnemyConsideringDistance")` to cycle through melee-range enemies
- For each enemy: check `UnitIsUnit("targettarget", "player")` (threat) and `IsBuffActive("target", "Sunder Armor")` (sunder status)
- Score each enemy, remember the best GUID
- After cycling, `TargetUnit(bestGuid)` to switch to the winning candidate
- If no better candidate, `TargetUnit(originalGuid)` to restore

### Cycle Limit

Cap cycling at 8 iterations per keypress to bound worst-case cost. Dungeon pulls rarely exceed 6-8 mobs. The `nextEnemyConsideringDistance` function prioritizes melee range (0-8 yards) which is exactly what we want for sunder targets.

### Thunder Clap & Demo Shout Weaving

Per `warrior-rotations.md`:
- **Thunder Clap** (priority 4 in multi-target): fires on CD, good threat/rage on 4+ mobs, applies -10% attack speed. Keep at current position in chain (after ShieldSlam/MortalStrike, before ConcussionBlow).
- **Demoralizing Shout** (priority 6): use once at pull start for initial aggro, flat threat per target (not split). Already gated by `not IsBuffActive("target", "Demoralizing Shout")` and `demo == "on"`. Keep at current position.

No changes needed to TClap/Demo positions — they already weave correctly between sunder cycles.

### Config Toggle

Add `/iwin tabsunder [on/off]` setting. Default: `"on"`. Stored in `IWin_Settings["tabSunder"]`.

---

## Tasks

### Task 1: Add tabSunder config setting

**Files:**
- Modify: `addons/IWinEnhanced/warrior/setup.lua`

**Step 1: Read setup.lua to find the settings initialization and slash command handler**

Read the full file to locate where `IWin_Settings` defaults are set and where `/iwin` subcommands are handled.

**Step 2: Add tabSunder default setting**

Find where other settings are initialized (look for `IWin_Settings["demo"]` or similar defaults) and add:

```lua
if IWin_Settings["tabSunder"] == nil then IWin_Settings["tabSunder"] = "on" end
```

**Step 3: Add `/iwin tabsunder` slash command handler**

Find the slash command handler block (where `dtbattle`, `dtdefensive`, `demo` etc. are handled) and add a new case:

```lua
elseif command == "tabsunder" then
    if arg == "on" or arg == "off" then
        IWin_Settings["tabSunder"] = arg
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFFtabSunder|r set to |cFFFFFF00" .. arg .. "|r")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFFtabSunder|r is |cFFFFFF00" .. IWin_Settings["tabSunder"] .. "|r (on/off)")
    end
```

**Step 4: Deploy and test toggle in-game**

Run: `cp -r addons/IWinEnhanced/* C:/Games/TurtleWoW/Interface/AddOns/IWinEnhanced/`

Test: `/reload` then `/iwin tabsunder` should show current value. `/iwin tabsunder off` should set it to off.

**Step 5: Commit**

```bash
git add addons/IWinEnhanced/warrior/setup.lua
git commit -m "feat(tank): add /iwin tabsunder config toggle for AoE tab-sunder"
```

---

### Task 2: Implement TargetLooseMob() function

**Files:**
- Modify: `addons/IWinEnhanced/warrior/action.lua` (append new function at end of file, after line 1280)

**Step 1: Write the TargetLooseMob function**

Append to end of `warrior/action.lua`:

```lua
-- Tab-Sunder: find highest-priority loose/unsundered mob in melee range
-- Priority: (1) not targeting us + no sunder, (2) not targeting us + sundered,
--           (3) targeting us + no sunder, (4) no switch needed
function IWin:TargetLooseMob()
	if IWin_Settings["tabSunder"] ~= "on" then return end
	if not UnitAffectingCombat("player") then return end
	if not IWin_CombatVar["queueGCD"] then return end
	if IWin_CombatVar["slamQueued"] then return end

	local originalGuid = UnitExists("target")
	if not originalGuid then return end

	-- Check if current target already needs work (no sunder = stay on it)
	local currentHasSunder = IWin:IsBuffActive("target", "Sunder Armor")
		or IWin:IsBuffActive("target", "Expose Armor")
	local currentTargetingUs = UnitIsUnit("targettarget", "player")

	-- If current target is loose (not targeting us), stay on it regardless of sunder
	if not currentTargetingUs then return end

	-- If current target needs sunder, only switch if there's a loose mob
	-- (loose mobs are higher priority than finishing sunder stacks)

	local bestGuid = nil
	local bestScore = 0
	-- Score: 4 = loose + no sunder, 3 = loose + sundered, 2 = targeting us + no sunder
	-- Current target: don't score (we already have it)

	local maxCycles = 8
	for i = 1, maxCycles do
		UnitXP("target", "nextEnemyConsideringDistance")
		local cycledGuid = UnitExists("target")

		-- Cycled back to original = done
		if not cycledGuid or cycledGuid == originalGuid then break end

		-- Skip dead or friendly
		if not UnitIsDead("target") and not UnitIsFriend("target", "player") then
			local hasSunder = IWin:IsBuffActive("target", "Sunder Armor")
				or IWin:IsBuffActive("target", "Expose Armor")
			local targetingUs = UnitIsUnit("targettarget", "player")

			local score = 0
			if not targetingUs and not hasSunder then
				score = 4
			elseif not targetingUs and hasSunder then
				score = 3
			elseif targetingUs and not hasSunder then
				score = 2
			end
			-- score 0 = targeting us + sundered = no improvement

			if score > bestScore then
				bestScore = score
				bestGuid = cycledGuid
			end

			-- Early exit on perfect candidate
			if bestScore == 4 then break end
		end
	end

	-- Switch to best candidate, or restore original
	if bestGuid and bestScore > 0 then
		-- Only switch for "no sunder on current" if there's a loose mob (score 3+)
		-- OR if current target already has sunder (score 2+ is fine)
		if bestScore >= 3 or (bestScore >= 2 and currentHasSunder) then
			TargetUnit(bestGuid)
		else
			TargetUnit(originalGuid)
		end
	else
		TargetUnit(originalGuid)
	end
end
```

**Step 2: Deploy and verify function loads without errors**

Run: `cp -r addons/IWinEnhanced/* C:/Games/TurtleWoW/Interface/AddOns/IWinEnhanced/`

Test: `/reload` — no Lua errors. `/ihodor` on a training dummy should still work (single target = no switch).

**Step 3: Commit**

```bash
git add addons/IWinEnhanced/warrior/action.lua
git commit -m "feat(tank): add TargetLooseMob() for AoE tab-sunder target selection"
```

---

### Task 3: Wire TargetLooseMob() into /ihodor rotation chain

**Files:**
- Modify: `addons/IWinEnhanced/warrior/rotation.lua` (lines 148-181, the /ihodor function)

**Step 1: Insert TargetLooseMob() call after OverpowerDefensiveTactics and before SunderArmorFirstStack**

Current rotation.lua line 162-163:
```lua
	IWin:OverpowerDefensiveTactics()
	IWin:SunderArmorFirstStack()
```

Change to:
```lua
	IWin:OverpowerDefensiveTactics()
	IWin:TargetLooseMob()
	IWin:SunderArmorFirstStack()
```

**Step 2: Deploy and test with multiple mobs**

Run: `cp -r addons/IWinEnhanced/* C:/Games/TurtleWoW/Interface/AddOns/IWinEnhanced/`

Test: `/reload`, pull 3+ mobs, spam `/ihodor`. Expected behavior:
- First press: sunder current target
- After current target has sunder: auto-switches to an unsundered mob
- Mobs not targeting player get priority over unsundered mobs that ARE targeting player
- Thunder Clap and Demo Shout still fire at their normal priority positions

**Step 3: Commit**

```bash
git add addons/IWinEnhanced/warrior/rotation.lua
git commit -m "feat(tank): wire TargetLooseMob() into /ihodor rotation chain"
```

---

### Task 4: Add StartAttack after target switch

**Files:**
- Modify: `addons/IWinEnhanced/warrior/action.lua` (inside `TargetLooseMob()`)

**Step 1: Ensure auto-attack restarts after target switch**

When `TargetLooseMob()` switches target, auto-attack may stop. Add a `StartAttack()` call inside the successful switch branch. In the `TargetLooseMob()` function, find:

```lua
		if bestScore >= 3 or (bestScore >= 2 and currentHasSunder) then
			TargetUnit(bestGuid)
		else
```

Change to:
```lua
		if bestScore >= 3 or (bestScore >= 2 and currentHasSunder) then
			TargetUnit(bestGuid)
			IWin:StartAttack()
		else
```

**Step 2: Deploy and verify auto-attack continues after switch**

Run: `cp -r addons/IWinEnhanced/* C:/Games/TurtleWoW/Interface/AddOns/IWinEnhanced/`

Test: Pull mobs, `/ihodor` should switch target AND resume auto-attacking the new target.

**Step 3: Commit**

```bash
git add addons/IWinEnhanced/warrior/action.lua
git commit -m "fix(tank): restart auto-attack after TargetLooseMob switch"
```

---

### Task 5: Add melee range guard to TargetLooseMob cycling

**Files:**
- Modify: `addons/IWinEnhanced/warrior/action.lua` (inside `TargetLooseMob()`)

**Step 1: Add distance check to skip out-of-melee mobs**

While `nextEnemyConsideringDistance` prioritizes melee (0-8y), it CAN return mobs in the charge bucket (8-25y) if no melee targets exist. We should skip those — we can't sunder something at 20 yards.

In `TargetLooseMob()`, inside the cycling loop, after the dead/friendly check and before the sunder/threat checks, add a melee range guard:

```lua
		if not UnitIsDead("target") and not UnitIsFriend("target", "player") then
			-- Skip out-of-melee targets (sunder is melee range)
			local dist = UnitXP("distanceBetween", "player", "target", "meleeAutoAttack")
			if dist >= 0 and dist <= 8 then
				local hasSunder = IWin:IsBuffActive("target", "Sunder Armor")
```

And close the `if dist` block at the end of the scoring section (before the early exit):

```lua
				if bestScore == 4 then break end
			end -- dist check
		end -- dead/friendly check
```

**Step 2: Deploy and test**

Run: `cp -r addons/IWinEnhanced/* C:/Games/TurtleWoW/Interface/AddOns/IWinEnhanced/`

Test: With mobs at range (e.g. casters), `/ihodor` should NOT switch to them. Only melee-range mobs should be candidates.

**Step 3: Commit**

```bash
git add addons/IWinEnhanced/warrior/action.lua
git commit -m "fix(tank): add melee range guard to TargetLooseMob cycling"
```

---

### Task 6: Update warrior/init.lua with tabSunder combat var (if needed)

**Files:**
- Modify: `addons/IWinEnhanced/warrior/init.lua`

**Step 1: Verify no new combat vars needed**

Review `TargetLooseMob()` — it uses only local variables and existing `IWin_CombatVar` fields (`queueGCD`, `slamQueued`). No new persistent state is needed.

**Result:** No changes needed to `init.lua`. Skip this task if no new combat vars are required.

**Step 2: Commit (skip if no changes)**

---

### Task 7: Integration test and iteration

**Files:** None (testing only)

**Step 1: Full deploy**

Run: `cp -r addons/IWinEnhanced/* C:/Games/TurtleWoW/Interface/AddOns/IWinEnhanced/`

**Step 2: Test scenarios**

Test the following scenarios in-game:

| Scenario | Expected Behavior |
|----------|-------------------|
| Single mob | No target switch. Normal rotation. |
| 3 mobs, all targeting player, none sundered | Stays on current target (all targeting us, sunder needed — SunderArmorFirstStack handles it). Next press: switches to unsundered mob. |
| 3 mobs, 1 loose (not targeting player) | Switches to loose mob first. Sunders it. Then cycles to next unsundered. |
| All mobs sundered + targeting player | No switch. Normal rotation (TClap/Demo/Cleave). |
| `/iwin tabsunder off` | No auto-switching regardless of mob state. |
| Mobs at range (casters) | Not targeted by TargetLooseMob (melee range guard). |
| Target dies mid-pull | `TargetEnemy()` at top of chain picks new target. TargetLooseMob then evaluates. |

**Step 3: Report results**

Report any issues found during testing. Common failure modes:
- Target flickers (switches and immediately switches back) — check score logic
- Sunder not landing after switch — check GCD/queueGCD state
- TClap/Demo not firing — check they're not being blocked by target switch
- Auto-attack stopping — verify StartAttack() fires after switch

---

## Key API Reference (for implementer)

```lua
-- Save/restore target (SuperWoW GUID)
local guid = UnitExists("target")       -- returns GUID string or nil
TargetUnit(guid)                         -- restore via GUID string

-- Cycle enemies (UnitXP) — CHANGES global target
UnitXP("target", "nextEnemyConsideringDistance")  -- returns boolean, melee priority

-- Threat proxy (vanilla)
UnitIsUnit("targettarget", "player")    -- 1 if mob targeting player, nil otherwise

-- Debuff check (IWinEnhanced via libdebuff)
IWin:IsBuffActive("target", "Sunder Armor")  -- checks debuffs too (shared debuffs)

-- Melee distance (UnitXP)
UnitXP("distanceBetween", "player", "target", "meleeAutoAttack")  -- yards, -1 on error
```

## Rotation Priority Reference (warrior-rotations.md)

Multi-target tanking:
1. Sunder Armor — first GCD, at least 1 per mob
2. Cleave — best consistent AoE, hidden static threat modifier
3. Bloodthirst — N/A for DT Prot
4. Thunder Clap — zero scaling but good threat/rage on 4+ mobs, -10% attack speed
5. Revenge — N/A for DT Prot without dtdefensive
6. Demoralizing Shout — once at pull start, flat threat per target (not split)
