# Skull/X Priority + Lowest-HP Targeting Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add skull/X mark priority targeting and lowest-HP fallback to `/idps` and `/icleave` warrior DPS rotations.

**Architecture:** Two new loosely-coupled functions (`TargetSkullX()` and `TargetLowestHP()`) inserted into the `/idps` and `/icleave` rotation chains after the existing `TargetEnemy()`. Each function is self-gating and independent — either can be disabled or removed without affecting the other. Config via `/iwin skulltarget [on/off]`.

**Tech Stack:** IWinEnhanced addon (Lua), SuperWoW mark unit tokens (`"mark7"`, `"mark8"`), UnitXP distance/cycling API.

**Design doc:** `docs/plans/2026-02-13-skull-targeting-design.md`

---

### Task 1: Add `skulltarget` Config Option

**Files:**
- Modify: `addons/IWinEnhanced/warrior/event.lua:32` (add default after tabSunder)
- Modify: `addons/IWinEnhanced/warrior/setup.lua:64-70` (add validation block)
- Modify: `addons/IWinEnhanced/warrior/setup.lua:132-134` (add setter)
- Modify: `addons/IWinEnhanced/warrior/setup.lua:136-149` (add help line)

**Step 1: Add default setting in event.lua**

After line 32 (`if IWin_Settings["tabSunder"] == nil then IWin_Settings["tabSunder"] = "on" end`), add:

```lua
		if IWin_Settings["skullTarget"] == nil then IWin_Settings["skullTarget"] = "on" end
```

**Step 2: Add validation block in setup.lua**

After the `tabsunder` validation block (lines 64-70), add:

```lua
	elseif arguments[1] == "skulltarget" then
		if arguments[2] ~= "on"
			and arguments[2] ~= "off"
			and arguments[2] ~= nil then
				DEFAULT_CHAT_FRAME:AddMessage("|cff0066ff Unkown parameter. Possible values: on, off.|r")
				return
		end
```

**Step 3: Add setter in setup.lua**

After the `tabsunder` setter (lines 132-134), add:

```lua
	elseif arguments[1] == "skulltarget" then
	    IWin_Settings["skullTarget"] = arguments[2]
	    DEFAULT_CHAT_FRAME:AddMessage("|cff0066ff Skull Target: |r" .. IWin_Settings["skullTarget"])
```

**Step 4: Add help line in setup.lua**

After the tabsunder help message (line 149), add:

```lua
		DEFAULT_CHAT_FRAME:AddMessage("|cff0066ff /iwin skulltarget [|r" .. IWin_Settings["skullTarget"] .. "|cff0066ff]:|r Prioritize skull/X marked targets in /idps and /icleave")
```

**Step 5: Commit**

```bash
git add addons/IWinEnhanced/warrior/event.lua addons/IWinEnhanced/warrior/setup.lua
git commit -m "feat(config): add skulltarget setting for mark-priority targeting"
```

---

### Task 2: Implement TargetSkullX()

**Files:**
- Modify: `addons/IWinEnhanced/warrior/action.lua` (add function after TargetLooseMob, around line 1400)

**Step 1: Write TargetSkullX() function**

Insert after the `TargetLooseMob()` function (after line 1399) in `warrior/action.lua`:

```lua
function IWin:TargetSkullX()
	if IWin_Settings["skullTarget"] ~= "on" then return end
	if not UnitAffectingCombat("player") then return end

	-- Check which marked targets exist and are valid (alive + hostile)
	local skullValid = UnitExists("mark8") and not UnitIsDead("mark8") and not UnitIsFriend("mark8", "player")
	local xValid = UnitExists("mark7") and not UnitIsDead("mark7") and not UnitIsFriend("mark7", "player")

	if not skullValid and not xValid then return end

	local chosenMark = nil
	if skullValid and not xValid then
		chosenMark = "mark8"
	elseif xValid and not skullValid then
		chosenMark = "mark7"
	else
		-- Both valid: pick whichever is closer
		local distSkull = UnitXP("distanceBetween", "player", "mark8", "meleeAutoAttack")
		local distX = UnitXP("distanceBetween", "player", "mark7", "meleeAutoAttack")
		if distSkull >= 0 and (distX < 0 or distSkull <= distX) then
			chosenMark = "mark8"
		else
			chosenMark = "mark7"
		end
	end

	-- Skip if already targeting the chosen mark
	if UnitIsUnit("target", chosenMark) then return end

	local _, markGuid = UnitExists(chosenMark)
	if markGuid then
		TargetUnit(markGuid)
	end
end
```

Key design decisions in this code:
- **Guard: in combat** — prevents pre-pull target snapping
- **Guard: config check** — respects `/iwin skulltarget off`
- **`UnitIsUnit` check** — avoids redundant `TargetUnit` calls when already on the mark
- **Distance tiebreaker** — `distSkull >= 0` guards against invalid distance returns (-1)
- **GUID-based targeting** — uses `TargetUnit(guid)` not `TargetUnit("mark8")` to match the proven pattern from TargetLooseMob

**Step 2: Commit**

```bash
git add addons/IWinEnhanced/warrior/action.lua
git commit -m "feat(targeting): add TargetSkullX() for skull/X mark priority"
```

---

### Task 3: Implement TargetLowestHP()

**Files:**
- Modify: `addons/IWinEnhanced/warrior/action.lua` (add function after TargetSkullX)

**Step 1: Write TargetLowestHP() function**

Insert after the `TargetSkullX()` function in `warrior/action.lua`:

```lua
function IWin:TargetLowestHP()
	-- Only run when we need a new target (dead, missing, or friendly)
	if UnitExists("target")
		and not UnitIsDead("target")
		and not UnitIsFriend("target", "player") then
			return
	end

	if not UnitAffectingCombat("player") then return end

	local bestGuid = nil
	local bestHpPct = 101

	local maxCycles = 8
	for i = 1, maxCycles do
		UnitXP("target", "nextEnemyConsideringDistance")

		if not UnitExists("target") then break end

		local _, cycledGuid = UnitExists("target")
		if not cycledGuid then break end

		-- Skip dead or friendly
		if not UnitIsDead("target") and not UnitIsFriend("target", "player") then
			-- Only consider targets in melee range
			local dist = UnitXP("distanceBetween", "player", "target", "meleeAutoAttack")
			if dist >= 0 and dist <= 8 then
				local hpPct = UnitHealth("target") / UnitHealthMax("target") * 100
				if hpPct < bestHpPct then
					bestHpPct = hpPct
					bestGuid = cycledGuid
				end
			end
		end
	end

	if bestGuid then
		TargetUnit(bestGuid)
	else
		TargetNearestEnemy()
	end
end
```

Key design decisions in this code:
- **Need-target guard** — only runs when current target is dead/missing/friendly (same condition as `TargetEnemy()`)
- **In-combat guard** — prevents pre-pull cycling
- **8-yard melee range** — matches TargetLooseMob's range filter
- **bestHpPct = 101** — initial sentinel ensures any real mob will be lower
- **`TargetNearestEnemy()` fallback** — if cycling finds nothing in melee range, fall back to vanilla behavior
- **No original GUID restore needed** — we only enter this function when we have no valid target, so there's nothing to restore

**Step 2: Commit**

```bash
git add addons/IWinEnhanced/warrior/action.lua
git commit -m "feat(targeting): add TargetLowestHP() for lowest-health fallback"
```

---

### Task 4: Wire Functions into /idps and /icleave Rotation Chains

**Files:**
- Modify: `addons/IWinEnhanced/warrior/rotation.lua:4-6` (/idps chain)
- Modify: `addons/IWinEnhanced/warrior/rotation.lua:62-64` (/icleave chain)

**Step 1: Update /idps chain**

Change lines 4-6 from:

```lua
function SlashCmdList.IDPSWARRIOR()
	IWin:InitializeRotation()
	IWin:TargetEnemy()
	IWin:BattleShoutRefreshOOC()
```

To:

```lua
function SlashCmdList.IDPSWARRIOR()
	IWin:InitializeRotation()
	IWin:TargetEnemy()
	IWin:TargetSkullX()
	IWin:TargetLowestHP()
	IWin:BattleShoutRefreshOOC()
```

**Step 2: Update /icleave chain**

Change lines 62-65 from:

```lua
function SlashCmdList.ICLEAVEWARRIOR()
	IWin:InitializeRotation()
	IWin:TargetEnemy()
	IWin:BattleShoutRefreshOOC()
```

To:

```lua
function SlashCmdList.ICLEAVEWARRIOR()
	IWin:InitializeRotation()
	IWin:TargetEnemy()
	IWin:TargetSkullX()
	IWin:TargetLowestHP()
	IWin:BattleShoutRefreshOOC()
```

**Step 3: Commit**

```bash
git add addons/IWinEnhanced/warrior/rotation.lua
git commit -m "feat(rotation): wire TargetSkullX + TargetLowestHP into /idps and /icleave"
```

---

### Task 5: Deploy and Test

**Step 1: Deploy to live addon folder**

```bash
cp -r addons/IWinEnhanced/* C:/Games/TurtleWoW/Interface/AddOns/IWinEnhanced/
```

**Step 2: In-game testing checklist**

1. `/reload` in-game
2. `/iwin` — verify `skulltarget` appears in help with default `on`
3. `/iwin skulltarget off` — verify feedback message
4. `/iwin skulltarget on` — verify feedback message

**Test skull/X targeting:**
5. Mark a target dummy or mob with skull (raid mark 8)
6. Target a different mob, press `/idps` — should swap to skull
7. Mark a second mob with X (raid mark 7), stand closer to X — `/idps` should target X
8. Move closer to skull — `/idps` should target skull
9. Remove all marks — `/idps` should behave normally

**Test lowest-HP targeting:**
10. Pull 2+ mobs with no marks, DPS one to ~50% HP
11. Kill current target, press `/idps` — should pick up the ~50% HP mob, not a full-health one
12. With no marks and no valid target, press `/idps` — should target nearest enemy (fallback)

**Test config off:**
13. `/iwin skulltarget off`
14. Mark a mob with skull, target a different mob, press `/idps` — should NOT swap to skull
15. `/iwin skulltarget on` — re-enable

**Test /icleave:**
16. Repeat tests 5-15 using `/icleave` instead of `/idps`

**Test no interference:**
17. Press `/itank` and `/ihodor` — verify they do NOT skull-target (unchanged)

**Step 3: Report results to user for confirmation**

---

### Task 6: Final Commit (after user confirms tests pass)

**Step 1: Commit all remaining changes if any**

```bash
git add addons/IWinEnhanced/warrior/action.lua addons/IWinEnhanced/warrior/rotation.lua addons/IWinEnhanced/warrior/setup.lua addons/IWinEnhanced/warrior/event.lua
git commit -m "feat(targeting): skull/X priority + lowest-HP fallback for /idps and /icleave"
```
