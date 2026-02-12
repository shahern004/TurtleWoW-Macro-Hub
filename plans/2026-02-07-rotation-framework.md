# TurtleRotation Framework Implementation Plan

> **STATUS: SUPERSEDED (2026-02-07)**
> This plan has been superseded. After deep-diving IWinEnhanced's source code (`plans/iwin-solutions-to-port.md`), we determined that TurtleRotation v0.1 was rebuilding the same architecture IWinEnhanced already provides. We are now **using IWinEnhanced directly** and focusing on optimizing its `warrior/rotation.lua` for maximum Arms DPS instead of maintaining a separate addon. See `MEMORY.md` for current strategy.

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** ~~Build a reusable WoW addon framework (`TurtleRotation`)~~ **SUPERSEDED** — Build was abandoned in favor of extending IWinEnhanced. Original goal was to host warrior rotation logic, starting with Arms single-target. The framework replaces macro-based rotation files with addon-based self-gating ability functions, a queueGCD mutex, and event-driven state tracking — patterns proven by the IWinEnhanced study.

**Architecture:** Addon-based (`.toc` + Lua files). Each keypress runs a full priority chain of self-gating ability functions. A `queueGCD` boolean mutex prevents double-casting per keypress. Event handlers (`COMBAT_LOG`, `SPELLCAST_START/STOP`) track reactive windows (Overpower, Revenge) and slam timing. Rage reservation uses static thresholds initially (escalating `rageCost` checks for lower-priority abilities), with time-aware prediction deferred to a future task. Simple utility macros remain as CleveroidMacros `/cast` chains — this addon handles only rotation complexity.

**Tech Stack:** Vanilla 1.12 Lua API, SuperWoW (CastSpellByName with unit token, UnitBuff/UnitDebuff with auraId), Nampower (GetSpellIdCooldown, GetCastInfo, IsSpellInRange, IsSpellUsable), SP_SwingTimer (`st_timer` global for slam gating), UnitXP_SP3 (optional: behind check, distance).

**Dependencies studied:**
- `plans/iwin-enhanced-study.md` — full IWinEnhanced architecture analysis (queueGCD, rage reservation, self-gating, slam timing)
- `docs/nampower-api.md` — spell cooldown, cast info, range checking APIs
- `docs/superwow-api.md` — enhanced CastSpellByName, UnitBuff/UnitDebuff with auraId
- `docs/warrior-rotations.md` — Arms priority reference (Sunder → Slam → MS → WW → HS)

---

## File Structure

```
addons/TurtleRotation/
  TurtleRotation.toc         -- Load order + metadata
  core.lua                   -- Frame, event dispatch, rotation engine, debug system
  conditions.lua             -- Shared condition helpers (cooldown, rage, buff, range, learned)
  config.lua                 -- Tuning constants (rage costs, spell IDs, thresholds)
  warrior_state.lua          -- Warrior combat state table + per-press reset
  warrior_events.lua         -- Event handlers (dodge→overpower, slam tracking, swing timer)
  warrior_abilities.lua      -- Self-gating ability functions (one per ability)
  warrior_rotations.lua      -- Rotation definitions + slash commands (/armsdps, etc.)
```

**Load order matters:** .toc loads files top-to-bottom. `core.lua` creates the namespace, `conditions.lua` and `config.lua` provide helpers, then warrior files use them.

---

## Task 1: Addon Scaffold

**Files:**
- Create: `addons/TurtleRotation/TurtleRotation.toc`
- Create: `addons/TurtleRotation/core.lua`

**Step 1: Create .toc file**

```lua
## Interface: 11200
## Title: TurtleRotation
## Notes: Rotation framework for TurtleWoW. Warrior-first, extensible.
## Author: TurtleWoW_Macros
## Version: 0.1.0
## SavedVariablesPerCharacter: TurtleRotation_Settings
core.lua
config.lua
conditions.lua
warrior_state.lua
warrior_events.lua
warrior_abilities.lua
warrior_rotations.lua
```

**Step 2: Create core.lua with namespace + frame + load confirmation**

```lua
-- TurtleRotation Framework
-- Rotation addon for TurtleWoW. Handles complex rotation logic that exceeds
-- what /cast conditional chains can do (rage reservation, slam timing, queueGCD mutex).

TR = {}
TR.version = "0.1.0"
TR.debug = false

-- Main event frame
TR.frame = CreateFrame("Frame", "TurtleRotationFrame")
TR.frame:RegisterEvent("PLAYER_LOGIN")

TR.frame:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TurtleRotation v" .. TR.version .. " loaded.|r")
    end
end)
```

**Step 3: Verify in-game**

1. Copy `addons/TurtleRotation/` into TurtleWoW `Interface/AddOns/` directory
2. `/reload` (or restart client)
3. Expected: green "TurtleRotation v0.1.0 loaded." in chat

**Step 4: Commit**

```bash
git add addons/TurtleRotation/TurtleRotation.toc addons/TurtleRotation/core.lua
git commit -m "feat: scaffold TurtleRotation addon with toc and core frame"
```

---

## Task 2: Config Constants

**Files:**
- Create: `addons/TurtleRotation/config.lua`

**Step 1: Create config.lua with all tuning constants**

This file contains every hardcoded value the framework uses. Tuning a rotation means editing this file. Later, we'll add SavedVariables + `/tr` slash command to override at runtime.

```lua
-- TurtleRotation Config
-- All tuning constants in one place. Edit here to adjust rotation behavior.
-- Future: SavedVariablesPerCharacter will override these defaults.

TR.config = {
    -- GCD queue window (ms). Abilities cast if their CD remaining < this value.
    -- Matches IWinEnhanced: cast slightly early, let engine handle queue timing.
    queueWindow = 1500,

    -- Slam: only cast when swing timer is in first half (prevents auto-attack clip).
    -- Ratio of swing timer elapsed before slam is blocked. 0.5 = IWinEnhanced default.
    slamSwingRatio = 0.5,

    -- Overpower window duration (seconds). Dodge gives a 5-second react window.
    overpowerWindow = 5.0,

    -- Revenge window duration (seconds). Block/parry/dodge gives 5-second window.
    revengeWindow = 5.0,

    -- Rage costs per ability (base, before talent reductions).
    -- Update these if talents reduce costs (e.g., Improved Heroic Strike).
    rageCost = {
        ["Execute"]         = 15,  -- 15 base + extra rage consumed for damage
        ["Mortal Strike"]   = 30,
        ["Bloodthirst"]     = 30,
        ["Whirlwind"]       = 25,
        ["Slam"]            = 15,
        ["Heroic Strike"]   = 15,
        ["Cleave"]          = 20,
        ["Sunder Armor"]    = 15,  -- reduced by Improved Sunder
        ["Overpower"]       = 5,
        ["Revenge"]         = 5,
        ["Battle Shout"]    = 10,
        ["Hamstring"]       = 10,
        ["Thunder Clap"]    = 20,
        ["Shield Slam"]     = 20,
        ["Concussion Blow"] = 25,
    },

    -- Spell IDs for Nampower API calls (GetSpellIdCooldown, etc.).
    -- TurtleWoW spell IDs — verify in-game with /run print(GetSpellRec(ID).name)
    -- NOTE: These are max-rank IDs. Populate during Task 8 in-game verification.
    spellId = {
        ["Execute"]         = 0,  -- FILL IN-GAME
        ["Mortal Strike"]   = 0,  -- FILL IN-GAME
        ["Bloodthirst"]     = 0,  -- FILL IN-GAME
        ["Whirlwind"]       = 0,  -- FILL IN-GAME
        ["Slam"]            = 0,  -- FILL IN-GAME
        ["Heroic Strike"]   = 0,  -- FILL IN-GAME
        ["Cleave"]          = 0,  -- FILL IN-GAME
        ["Sunder Armor"]    = 0,  -- FILL IN-GAME
        ["Overpower"]       = 0,  -- FILL IN-GAME
        ["Revenge"]         = 0,  -- FILL IN-GAME
        ["Battle Shout"]    = 0,  -- FILL IN-GAME
        ["Battle Stance"]   = 0,  -- FILL IN-GAME
        ["Defensive Stance"]= 0,  -- FILL IN-GAME
        ["Berserker Stance"]= 0,  -- FILL IN-GAME
    },

    -- Stance IDs for GetShapeshiftFormInfo index
    stance = {
        battle    = 1,
        defensive = 2,
        berserker = 3,
    },

    -- Rage thresholds for Heroic Strike (on-next-swing dump).
    -- Only HS when rage exceeds this. Prevents rage-starving priority abilities.
    hsRageThreshold = 60,

    -- Execute rage threshold. Higher = bigger execute damage.
    executeRageThreshold = 30,

    -- Sunder target stacks. Stop sundering at this count.
    sunderMaxStacks = 5,

    -- Tactical Mastery: max rage retained on stance swap.
    -- 5/5 TM = 25. Only stance-dance when rage <= this.
    tacticalMasteryRage = 25,
}
```

**Step 2: Commit**

```bash
git add addons/TurtleRotation/config.lua
git commit -m "feat: add config.lua with all tuning constants"
```

---

## Task 3: Condition Helpers

**Files:**
- Create: `addons/TurtleRotation/conditions.lua`

**Step 1: Create conditions.lua with shared condition functions**

These are pure functions that read game state. No side effects. Every ability function calls these to self-gate.

```lua
-- TurtleRotation Condition Helpers
-- Pure read-only functions for checking game state.
-- All functions return truthy/falsy. No side effects.

-- Cache: spellbook name→index mapping, built once on PLAYER_LOGIN.
TR.spellbook = {}

--- Scan spellbook and cache name→index mapping.
-- Call once on PLAYER_LOGIN (or LEARNED_SPELL_IN_TAB).
function TR:ScanSpellbook()
    TR.spellbook = {}
    local i = 1
    while true do
        local name, rank = GetSpellName(i, BOOKTYPE_SPELL)
        if not name then break end
        -- Store highest rank (last seen) for each spell name
        TR.spellbook[name] = i
        i = i + 1
    end
    TR:Debug("Spellbook scanned: " .. (i - 1) .. " entries")
end

--- Check if a spell is learned (in spellbook).
function TR:IsSpellLearned(name)
    return TR.spellbook[name] ~= nil
end

--- Get cooldown remaining in ms for a spell (excluding GCD).
-- Uses Nampower GetSpellIdCooldown for precise data.
-- Returns 0 if spell is ready, or remaining ms.
function TR:GetCooldownRemaining(name)
    local id = TR.config.spellId[name]
    if not id or id == 0 then return 99999 end
    local info = GetSpellIdCooldown(id)
    if not info then return 0 end
    -- individualRemainingMs = actual spell CD (ignores GCD)
    return info.individualRemainingMs or 0
end

--- Get GCD remaining in ms.
function TR:GetGCDRemaining()
    local info = GetCastInfo()
    if not info then return 0 end
    return info.gcdRemainingMs or 0
end

--- Check if player has enough rage for an ability (accounting for reserved rage).
function TR:HasEnoughRage(name)
    local cost = TR.config.rageCost[name] or 0
    local currentRage = UnitMana("player")
    return currentRage >= (cost + TR.state.reservedRage)
end

--- Get current player rage.
function TR:GetRage()
    return UnitMana("player")
end

--- Check if player is in a specific stance (1=Battle, 2=Defensive, 3=Berserker).
function TR:IsInStance(stanceIndex)
    local _, _, active = GetShapeshiftFormInfo(stanceIndex)
    return active
end

--- Get current stance index (1, 2, or 3).
function TR:GetStance()
    for i = 1, 3 do
        local _, _, active = GetShapeshiftFormInfo(i)
        if active then return i end
    end
    return 0
end

--- Check if a spell is in range of target.
-- Uses Nampower IsSpellInRange (returns 1=yes, 0=no, -1=invalid).
function TR:IsInRange(name, unit)
    local result = IsSpellInRange(name, unit or "target")
    return result == 1
end

--- Check if a spell is usable (learned, reagents, etc. — NOT cooldown).
-- Uses Nampower IsSpellUsable.
function TR:IsSpellUsable(name)
    local usable, oom = IsSpellUsable(name)
    return usable == 1
end

--- Check if target exists and is alive.
function TR:HasValidTarget()
    return UnitExists("target") and not UnitIsDeadOrGhost("target")
end

--- Check target HP percentage.
function TR:TargetHPPercent()
    local hp = UnitHealth("target")
    local max = UnitHealthMax("target")
    if max == 0 then return 100 end
    return (hp / max) * 100
end

--- Count debuff stacks on target by name.
-- Uses SuperWoW enhanced UnitDebuff (returns auraId).
function TR:GetDebuffStacks(unit, debuffName)
    for i = 1, 40 do
        local name, rank, texture, stacks = UnitDebuff(unit, i)
        if not name then break end
        -- Texture-based matching is more reliable than name in 1.12
        -- but we use name for clarity. Caller can switch to auraId if needed.
        if name == debuffName then
            return stacks or 0
        end
    end
    return 0
end

--- Check if player is currently casting (has an active cast bar).
function TR:IsCasting()
    local _, _, _, casting, channeling = GetCurrentCastingInfo()
    return (casting == 1) or (channeling == 1)
end
```

**Step 2: Wire spellbook scan into core.lua PLAYER_LOGIN handler**

In `core.lua`, update the OnEvent handler:

```lua
TR.frame:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        TR:ScanSpellbook()
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TurtleRotation v" .. TR.version .. " loaded.|r")
    elseif event == "LEARNED_SPELL_IN_TAB" then
        TR:ScanSpellbook()
    end
end)

TR.frame:RegisterEvent("PLAYER_LOGIN")
TR.frame:RegisterEvent("LEARNED_SPELL_IN_TAB")
```

**Step 3: Verify in-game**

```
/reload
/run TR:ScanSpellbook(); print("Mortal Strike learned:", TR:IsSpellLearned("Mortal Strike"))
/run print("Stance:", TR:GetStance())
/run print("Rage:", TR:GetRage())
```

Expected: prints correct values for your character.

**Step 4: Commit**

```bash
git add addons/TurtleRotation/conditions.lua addons/TurtleRotation/core.lua
git commit -m "feat: add condition helpers (cooldown, rage, stance, range, spellbook)"
```

---

## Task 4: Warrior Combat State

**Files:**
- Create: `addons/TurtleRotation/warrior_state.lua`

**Step 1: Create warrior_state.lua with combat state table + reset**

This is the equivalent of IWinEnhanced's `IWin_CombatVar`. Reset on every keypress.

```lua
-- TurtleRotation Warrior State
-- Per-keypress and persistent combat state for warrior rotations.

TR.state = {
    -- Per-keypress state (reset by InitializeRotation)
    queueGCD = true,           -- mutex: prevents multiple GCD casts per keypress
    reservedRage = 0,          -- running sum of rage reserved for upcoming abilities

    -- Persistent state (set by events, NOT reset per keypress)
    overpowerUntil = 0,        -- GetTime() when overpower window expires
    revengeUntil = 0,          -- GetTime() when revenge window expires
    slamCasting = false,       -- true while Slam cast bar is active
    slamCastEnd = 0,           -- GetTime() when current slam cast finishes
    swingAttackQueued = false,  -- true when HS/Cleave is queued (on-next-swing)
    lastStanceSwap = 0,        -- GetTime() of last stance swap (prevent double-swap)
}

--- Reset per-keypress state. Called at the start of every rotation execution.
function TR:InitializeRotation()
    TR.state.queueGCD = true
    TR.state.reservedRage = 0
end

--- Add rage reservation for a lower-priority ability.
-- Called after each ability in the rotation chain.
function TR:ReserveRage(name)
    local cost = TR.config.rageCost[name] or 0
    TR.state.reservedRage = TR.state.reservedRage + cost
end

--- Check if Overpower is available (within react window from a dodge).
function TR:IsOverpowerAvailable()
    return GetTime() < TR.state.overpowerUntil
end

--- Check if Revenge is available (within react window from block/parry/dodge).
function TR:IsRevengeAvailable()
    return GetTime() < TR.state.revengeUntil
end

--- Check if slam timing allows a GCD ability.
-- Returns true if we are NOT in a slam cast right now.
function TR:IsSlamSafe()
    if not TR.state.slamCasting then return true end
    return GetTime() > TR.state.slamCastEnd
end

--- Check if swing timer allows a Slam cast (first half of swing).
-- Reads st_timer from SP_SwingTimer addon (global variable).
-- If SP_SwingTimer is not installed, always allows Slam.
function TR:IsSlamWindowOpen()
    if not st_timer then return true end  -- no swing timer addon = always allow
    local attackSpeed = UnitAttackSpeed("player")
    return st_timer > (attackSpeed * TR.config.slamSwingRatio)
end
```

**Step 2: Commit**

```bash
git add addons/TurtleRotation/warrior_state.lua
git commit -m "feat: add warrior combat state table with queueGCD mutex and slam/overpower tracking"
```

---

## Task 5: Warrior Event Handlers

**Files:**
- Create: `addons/TurtleRotation/warrior_events.lua`

**Step 1: Create warrior_events.lua with combat log + cast event handlers**

IWinEnhanced detects Overpower via combat log text parsing (`string.find(arg1, "dodge")`). We do the same but also register for `SPELLCAST_START`/`SPELLCAST_STOP` for slam tracking.

```lua
-- TurtleRotation Warrior Events
-- Event handlers for reactive abilities (Overpower, Revenge) and slam tracking.

--- Register warrior-specific events on the main frame.
function TR:RegisterWarriorEvents()
    TR.frame:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
    TR.frame:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
    TR.frame:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS")
    TR.frame:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES")
    TR.frame:RegisterEvent("SPELLCAST_START")
    TR.frame:RegisterEvent("SPELLCAST_STOP")
    TR.frame:RegisterEvent("SPELLCAST_FAILED")
    TR.frame:RegisterEvent("SPELLCAST_INTERRUPTED")
    TR.frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    TR:Debug("Warrior events registered")
end

--- Main event dispatcher for warrior events.
-- Called from core.lua OnEvent handler.
function TR:HandleWarriorEvent()
    if event == "CHAT_MSG_COMBAT_SELF_MISSES" then
        -- Player's attack was dodged → Overpower window
        if arg1 and string.find(arg1, "dodge") then
            TR.state.overpowerUntil = GetTime() + TR.config.overpowerWindow
            TR:Debug("Overpower window: dodge detected")
        end

    elseif event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS"
        or event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES" then
        -- Enemy attack was blocked/parried/dodged → Revenge window
        if arg1 and (string.find(arg1, "block") or string.find(arg1, "parr") or string.find(arg1, "dodge")) then
            TR.state.revengeUntil = GetTime() + TR.config.revengeWindow
            TR:Debug("Revenge window: block/parry/dodge detected")
        end

    elseif event == "SPELLCAST_START" then
        -- Slam cast started
        if arg1 == "Slam" then
            TR.state.slamCasting = true
            TR.state.slamCastEnd = GetTime() + (arg2 / 1000)
            TR:Debug("Slam cast started, ends in " .. arg2 .. "ms")
        end

    elseif event == "SPELLCAST_STOP"
        or event == "SPELLCAST_FAILED"
        or event == "SPELLCAST_INTERRUPTED" then
        -- Slam cast finished or was interrupted
        if TR.state.slamCasting then
            TR.state.slamCasting = false
            TR:Debug("Slam cast ended")
        end

    elseif event == "PLAYER_TARGET_CHANGED" then
        -- Could cache target properties here (elite, boss, etc.)
        -- For now, just debug output
        TR:Debug("Target changed")
    end
end
```

**Step 2: Wire into core.lua OnEvent handler**

Update core.lua OnEvent to dispatch warrior events:

```lua
TR.frame:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        TR:ScanSpellbook()
        TR:RegisterWarriorEvents()
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TurtleRotation v" .. TR.version .. " loaded.|r")
    elseif event == "LEARNED_SPELL_IN_TAB" then
        TR:ScanSpellbook()
    else
        TR:HandleWarriorEvent()
    end
end)
```

**Step 3: Verify in-game**

1. `/reload`
2. `/run TR.debug = true`
3. Attack a mob, let it dodge you → expect "Overpower window: dodge detected" in chat
4. Cast Slam → expect "Slam cast started" and "Slam cast ended" messages

**Step 4: Commit**

```bash
git add addons/TurtleRotation/warrior_events.lua addons/TurtleRotation/core.lua
git commit -m "feat: add warrior event handlers for overpower/revenge/slam tracking"
```

---

## Task 6: Debug System

**Files:**
- Modify: `addons/TurtleRotation/core.lua`

**Step 1: Add debug print function and /trdebug slash command**

```lua
--- Debug print — only outputs when TR.debug is true.
function TR:Debug(msg)
    if not TR.debug then return end
    DEFAULT_CHAT_FRAME:AddMessage("|cff888888[TR] " .. msg .. "|r")
end

--- Dump current state to chat.
function TR:DumpState()
    local s = TR.state
    DEFAULT_CHAT_FRAME:AddMessage("|cffff8800[TR State]|r")
    DEFAULT_CHAT_FRAME:AddMessage("  queueGCD: " .. tostring(s.queueGCD))
    DEFAULT_CHAT_FRAME:AddMessage("  reservedRage: " .. s.reservedRage)
    DEFAULT_CHAT_FRAME:AddMessage("  overpowerAvail: " .. tostring(TR:IsOverpowerAvailable()))
    DEFAULT_CHAT_FRAME:AddMessage("  revengeAvail: " .. tostring(TR:IsRevengeAvailable()))
    DEFAULT_CHAT_FRAME:AddMessage("  slamCasting: " .. tostring(s.slamCasting))
    DEFAULT_CHAT_FRAME:AddMessage("  stance: " .. TR:GetStance())
    DEFAULT_CHAT_FRAME:AddMessage("  rage: " .. TR:GetRage())
end

-- Slash commands
SLASH_TRDEBUG1 = "/trdebug"
SlashCmdList["TRDEBUG"] = function()
    TR.debug = not TR.debug
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TurtleRotation debug: " .. (TR.debug and "ON" or "OFF") .. "|r")
end

SLASH_TRSTATE1 = "/trstate"
SlashCmdList["TRSTATE"] = function()
    TR:DumpState()
end
```

**Step 2: Verify in-game**

```
/trdebug      -- should print "debug: ON"
/trstate      -- should print all state values
/trdebug      -- should print "debug: OFF"
```

**Step 3: Commit**

```bash
git add addons/TurtleRotation/core.lua
git commit -m "feat: add debug system with /trdebug toggle and /trstate dump"
```

---

## Task 7: Warrior Ability Functions

**Files:**
- Create: `addons/TurtleRotation/warrior_abilities.lua`

**Step 1: Create self-gating ability functions**

Each function follows the IWinEnhanced pattern: check all conditions internally, cast if valid, set `queueGCD = false` to claim the GCD. If any condition fails, return silently.

```lua
-- TurtleRotation Warrior Abilities
-- Self-gating ability functions. Each checks its own conditions and either
-- casts (claiming the GCD) or returns silently. Call order = priority order.

--- Execute — target below 20%, high rage for damage.
function TR:Execute()
    if not TR:IsSpellLearned("Execute") then return end
    if not TR.state.queueGCD then return end
    if TR:TargetHPPercent() >= 20 then return end
    if TR:GetRage() < TR.config.executeRageThreshold then return end
    if TR:GetCooldownRemaining("Execute") > TR.config.queueWindow then return end
    if not TR:IsSlamSafe() then return end

    TR.state.queueGCD = false
    CastSpellByName("Execute")
    TR:Debug(">> Execute (rage=" .. TR:GetRage() .. ")")
end

--- Sunder Armor — apply until max stacks.
function TR:SunderArmor()
    if not TR:IsSpellLearned("Sunder Armor") then return end
    if not TR.state.queueGCD then return end
    if not TR:HasEnoughRage("Sunder Armor") then return end
    if TR:GetDebuffStacks("target", "Sunder Armor") >= TR.config.sunderMaxStacks then return end
    if TR:GetCooldownRemaining("Sunder Armor") > TR.config.queueWindow then return end
    if not TR:IsSlamSafe() then return end

    TR.state.queueGCD = false
    CastSpellByName("Sunder Armor")
    TR:Debug(">> Sunder Armor (stacks=" .. TR:GetDebuffStacks("target", "Sunder Armor") .. ")")
end

--- Overpower — reactive from dodge, stance dance if needed.
-- Returns true if it initiated a stance swap (caller should stop chain).
function TR:Overpower()
    if not TR:IsSpellLearned("Overpower") then return end
    if not TR.state.queueGCD then return end
    if not TR:IsOverpowerAvailable() then return end
    if not TR:IsSlamSafe() then return end

    -- Already in Battle Stance: just cast
    if TR:IsInStance(TR.config.stance.battle) then
        TR.state.queueGCD = false
        CastSpellByName("Overpower")
        TR:Debug(">> Overpower (in Battle Stance)")
        return
    end

    -- Not in Battle Stance: swap if rage allows (Tactical Mastery cap)
    if TR:GetRage() <= TR.config.tacticalMasteryRage then
        -- Prevent double stance swap within 1.5s
        if GetTime() - TR.state.lastStanceSwap < 1.5 then return end
        TR.state.queueGCD = false
        TR.state.lastStanceSwap = GetTime()
        CastSpellByName("Battle Stance")
        TR:Debug(">> Battle Stance (for Overpower, rage=" .. TR:GetRage() .. ")")
    end
end

--- Slam — core filler, gated by swing timer.
function TR:Slam()
    if not TR:IsSpellLearned("Slam") then return end
    if not TR.state.queueGCD then return end
    if not TR:HasEnoughRage("Slam") then return end
    if not TR:IsSlamWindowOpen() then return end
    if TR.state.slamCasting then return end

    TR.state.queueGCD = false
    CastSpellByName("Slam")
    TR:Debug(">> Slam")
end

--- Mortal Strike — primary Arms damage.
function TR:MortalStrike()
    if not TR:IsSpellLearned("Mortal Strike") then return end
    if not TR.state.queueGCD then return end
    if TR:GetCooldownRemaining("Mortal Strike") > TR.config.queueWindow then return end
    if not TR:HasEnoughRage("Mortal Strike") then return end
    if not TR:IsSlamSafe() then return end

    TR.state.queueGCD = false
    CastSpellByName("Mortal Strike")
    TR:Debug(">> Mortal Strike")
end

--- Bloodthirst — primary Fury damage.
function TR:Bloodthirst()
    if not TR:IsSpellLearned("Bloodthirst") then return end
    if not TR.state.queueGCD then return end
    if TR:GetCooldownRemaining("Bloodthirst") > TR.config.queueWindow then return end
    if not TR:HasEnoughRage("Bloodthirst") then return end
    if not TR:IsSlamSafe() then return end

    TR.state.queueGCD = false
    CastSpellByName("Bloodthirst")
    TR:Debug(">> Bloodthirst")
end

--- Whirlwind — secondary damage / AoE.
function TR:Whirlwind()
    if not TR:IsSpellLearned("Whirlwind") then return end
    if not TR.state.queueGCD then return end
    if TR:GetCooldownRemaining("Whirlwind") > TR.config.queueWindow then return end
    if not TR:HasEnoughRage("Whirlwind") then return end
    if not TR:IsSlamSafe() then return end

    TR.state.queueGCD = false
    CastSpellByName("Whirlwind")
    TR:Debug(">> Whirlwind")
end

--- Heroic Strike — on-next-swing rage dump. Does NOT consume GCD.
function TR:HeroicStrike()
    if not TR:IsSpellLearned("Heroic Strike") then return end
    if TR.state.swingAttackQueued then return end
    if TR:GetRage() < TR.config.hsRageThreshold then return end
    -- Only HS when WW is on cooldown (IWinEnhanced pattern)
    if TR:GetCooldownRemaining("Whirlwind") == 0 then return end

    TR.state.swingAttackQueued = true
    CastSpellByName("Heroic Strike")
    TR:Debug(">> Heroic Strike (rage dump, rage=" .. TR:GetRage() .. ")")
end

--- Cleave — on-next-swing AoE. Does NOT consume GCD.
function TR:CleaveStrike()
    if not TR:IsSpellLearned("Cleave") then return end
    if TR.state.swingAttackQueued then return end
    if not TR:HasEnoughRage("Cleave") then return end

    TR.state.swingAttackQueued = true
    CastSpellByName("Cleave")
    TR:Debug(">> Cleave")
end

--- Battle Shout — refresh when not active.
function TR:BattleShout()
    if not TR:IsSpellLearned("Battle Shout") then return end
    if not TR.state.queueGCD then return end
    if not TR:HasEnoughRage("Battle Shout") then return end
    -- TODO: check if buff is already active (skip if so)
    -- For now, rely on the rotation placing this at low priority

    TR.state.queueGCD = false
    CastSpellByName("Battle Shout")
    TR:Debug(">> Battle Shout")
end

--- StartAttack — ensure auto-attack is running. No GCD.
function TR:StartAttack()
    if not TR:HasValidTarget() then return end
    -- Throttle to prevent toggle-off (IWinEnhanced pattern)
    if TR.state.swingAttackQueued then return end
    AttackTarget()
    TR:Debug(">> StartAttack")
end
```

**Step 2: Verify in-game**

```
/reload
/run TR.debug = true
/run TR:InitializeRotation(); TR:MortalStrike()
```

Expected: if you have a target and rage, should cast MS and print debug. If conditions fail, silent.

**Step 3: Commit**

```bash
git add addons/TurtleRotation/warrior_abilities.lua
git commit -m "feat: add self-gating warrior ability functions (MS, BT, WW, Slam, Execute, HS, OP, Sunder)"
```

---

## Task 8: Arms ST Rotation Definition

**Files:**
- Create: `addons/TurtleRotation/warrior_rotations.lua`

**Step 1: Create rotation definitions with slash commands**

Each rotation is a slash command that runs abilities in priority order. The function call order IS the priority — first function to successfully cast claims the GCD.

```lua
-- TurtleRotation Warrior Rotations
-- Each slash command runs a complete priority chain.
-- Bind these in a macro: /armsdps
-- Spam the keybind — each press evaluates the full chain.

--- Arms Single-Target DPS rotation.
-- Priority: Execute > Sunder(to 5) > Overpower > Slam > MS > WW > HS > StartAttack
SLASH_ARMSDPS1 = "/armsdps"
SlashCmdList["ARMSDPS"] = function()
    if not TR:HasValidTarget() then return end
    TR:InitializeRotation()

    -- P1: Execute phase
    TR:Execute()

    -- P2: Sunder to 5 stacks
    TR:SunderArmor()
    TR:ReserveRage("Sunder Armor")

    -- P3: Overpower (reactive from dodge, stance dances if needed)
    TR:Overpower()

    -- P4: Slam (core filler, swing-timer gated)
    TR:Slam()
    TR:ReserveRage("Slam")

    -- P5: Mortal Strike (primary damage)
    TR:MortalStrike()
    TR:ReserveRage("Mortal Strike")

    -- P6: Whirlwind (secondary damage)
    TR:Whirlwind()
    TR:ReserveRage("Whirlwind")

    -- P7: Heroic Strike (on-next-swing dump, does NOT consume GCD)
    TR:HeroicStrike()

    -- Always: ensure auto-attack is running
    TR:StartAttack()

    -- Reset swing attack flag for next press
    -- (HS/Cleave queued status resets on next melee swing event, but we
    -- clear it here to allow re-evaluation on next keypress)
    TR.state.swingAttackQueued = false
end

--- Arms Cleave rotation (2+ targets).
-- Priority: Execute > WW > Sunder(to 5) > Overpower > Slam > MS > Cleave > StartAttack
SLASH_ARMSCLEAVE1 = "/armscleave"
SlashCmdList["ARMSCLEAVE"] = function()
    if not TR:HasValidTarget() then return end
    TR:InitializeRotation()

    TR:Execute()
    TR:Whirlwind()
    TR:ReserveRage("Whirlwind")
    TR:SunderArmor()
    TR:Overpower()
    TR:Slam()
    TR:ReserveRage("Slam")
    TR:MortalStrike()
    TR:ReserveRage("Mortal Strike")
    TR:CleaveStrike()
    TR:StartAttack()

    TR.state.swingAttackQueued = false
end
```

**Step 2: Create an in-game macro to bind**

In WoW, create a macro named `ArmsDPS`:
```
/armsdps
```

Bind this macro to a key (e.g., mouse button or numpad key). Spam it.

**Step 3: Populate spell IDs in config.lua**

Run in-game to discover spell IDs for your character's max-rank abilities:

```
/run for i=1,400 do local n,r=GetSpellName(i,"spell"); if n and (n=="Mortal Strike" or n=="Slam" or n=="Execute" or n=="Whirlwind" or n=="Heroic Strike" or n=="Sunder Armor" or n=="Overpower" or n=="Battle Shout") then print(n,r,"bookIdx="..i) end end
```

Then use Nampower to find spell IDs from spellbook indices:
```
/run local n,r=GetSpellName(TR.spellbook["Mortal Strike"],"spell"); local rec=GetSpellRec(TR.spellbook["Mortal Strike"]); print("MS spellId=", rec and rec.id or "?")
```

**NOTE:** The exact method to get spell IDs may need adjustment based on how Nampower maps spellbook indices to IDs. The user should verify the correct approach in-game. Update `config.lua` `spellId` table with discovered values.

**Step 4: In-game smoke test**

1. `/reload`
2. `/trdebug` (enable debug output)
3. Target a training dummy or low-level mob
4. Spam the `/armsdps` keybind
5. Expected: debug output showing which ability fires per keypress
6. Verify: only ONE GCD ability fires per press (queueGCD mutex working)
7. Verify: Slam only fires in first half of swing timer (if SP_SwingTimer installed)
8. Verify: Heroic Strike fires at high rage when WW is on CD

**Step 5: Commit**

```bash
git add addons/TurtleRotation/warrior_rotations.lua
git commit -m "feat: add Arms ST and Cleave rotation definitions with slash commands"
```

---

## Task 9: Integration Testing Checklist

**No files to create** — this is a structured in-game test session.

Run each test with `/trdebug` enabled. Record pass/fail.

| # | Test | How to Verify | Expected |
|---|------|--------------|----------|
| 1 | Addon loads | `/reload`, check chat | Green "loaded" message |
| 2 | Spellbook scan | `/run print(TR:IsSpellLearned("Mortal Strike"))` | `true` (or `1`) |
| 3 | Cooldown check | `/run print(TR:GetCooldownRemaining("Mortal Strike"))` | Number (0 if ready, >0 if on CD) |
| 4 | queueGCD mutex | Spam `/armsdps`, watch debug | Only ONE `>>` ability per press |
| 5 | Slam swing gate | Attack mob, watch debug | Slam only fires when `st_timer > attackSpeed*0.5` |
| 6 | Overpower detect | Let mob dodge, watch debug | "Overpower window: dodge detected" |
| 7 | Overpower fires | Dodge detected + in Battle Stance | `>> Overpower` in debug |
| 8 | Stance dance | Dodge detected + NOT in Battle Stance + rage ≤ 25 | `>> Battle Stance (for Overpower)` |
| 9 | Sunder stops at 5 | Apply 5 sunders, press again | No sunder debug output |
| 10 | HS rage gate | Low rage (<60) | No HS debug output |
| 11 | HS fires | High rage (>60) + WW on CD | `>> Heroic Strike` |
| 12 | Execute phase | Target <20% HP | `>> Execute` takes priority |
| 13 | State dump | `/trstate` | All values printed, sensible |
| 14 | Debug toggle | `/trdebug` twice | ON then OFF |

**After all tests pass: commit the populated spell IDs in config.lua**

```bash
git add addons/TurtleRotation/config.lua
git commit -m "feat: populate spell IDs from in-game verification"
```

---

## Future Tasks (Not in This Plan)

These are deferred to separate plans after the framework is stable:

1. **SavedVariables config** — `/tr rage 70` to adjust HS threshold at runtime, persisted per character
2. **Time-aware rage reservation** — predict future rage income and reduce reservation proportionally (IWinEnhanced's `GetRageToReserve` pattern)
3. **Fury DPS rotation** — `/furydps` using Bloodthirst, different priority order
4. **Furyprot rotation** — `/furytank` with Revenge, Shield Slam, threat priority
5. **Arms AoE rotation** — Sweeping Strikes pre-pull timing, WW priority
6. **Buff tracking** — check Battle Shout duration, skip refresh if active
7. **Target caching** — elite/boss detection on PLAYER_TARGET_CHANGED (IWinEnhanced pattern)
8. **Multi-class extensibility** — if framework proves useful, extract warrior-specific code into a class module pattern

---

## Architecture Decisions Log

| Decision | Rationale |
|----------|-----------|
| Addon over macros | Rage reservation, slam timing, queueGCD mutex impossible in `/cast` chains. IWinEnhanced study confirmed addon approach. |
| `CastSpellByName` over `QueueSpellByName` | IWinEnhanced uses direct cast + pre-queue timing (CD < queueWindow). Proven pattern, simpler. |
| Self-gating functions | Each ability owns its conditions. Reordering priority = moving one function call. Trivial to add/remove abilities. |
| Static rage reservation first | `TR:ReserveRage("Slam")` adds flat 15 to reserved. Simple, testable. Time-aware version deferred. |
| Combat log text parsing for dodge/parry | Same approach as IWinEnhanced. Fragile on locale change but standard for 1.12. Nampower events could replace later. |
| SP_SwingTimer global (`st_timer`) | Optional dependency. Degrades gracefully (allows all Slams if missing). Same approach as IWinEnhanced. |
| Hardcoded spell IDs | Avoids runtime spellbook→ID lookup complexity. Populated once in-game per Task 8. |
| Separate files per concern | `.toc` load order ensures dependencies. Easy to add new classes as new files. |
