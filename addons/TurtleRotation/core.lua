-- TurtleRotation Framework
-- Rotation addon for TurtleWoW. Handles complex rotation logic that exceeds
-- what /cast conditional chains can do (rage reservation, slam timing, queueGCD mutex).

TR = {}
TR.version = "0.1.0"
TR.debug = false

-- Main event frame
TR.frame = CreateFrame("Frame", "TurtleRotationFrame")

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

-- Event handler — dispatches to warrior events after login
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

TR.frame:RegisterEvent("PLAYER_LOGIN")
TR.frame:RegisterEvent("LEARNED_SPELL_IN_TAB")
