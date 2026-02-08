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
    TR.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
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

    elseif event == "CHAT_MSG_COMBAT_SELF_HITS" then
        -- Melee swing landed — HS/Cleave has been consumed
        if TR.state.swingAttackQueued then
            TR.state.swingAttackQueued = false
            TR:Debug("Swing landed, HS/Cleave consumed")
        end

    elseif event == "PLAYER_TARGET_CHANGED" then
        -- Reset per-target state
        TR.state.autoAttacking = false
        TR.state.sunderCount = 0
        TR:Debug("Target changed, state reset")

    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Left combat — reset combat state flags
        TR.state.autoAttacking = false
        TR.state.swingAttackQueued = false
        TR:Debug("Left combat, flags reset")
    end
end
