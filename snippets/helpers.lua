-- Reusable Lua helper fragments for macros
-- Copy relevant sections into your macros as needed

-- Print to chat (shorter than DEFAULT_CHAT_FRAME:AddMessage)
local function p(msg) DEFAULT_CHAT_FRAME:AddMessage(msg) end

-- Check if player has a specific buff by name
local function HasBuff(unit, name)
    for i = 1, 32 do
        if UnitBuff(unit, i) == name then return true end
    end
    return false
end

-- Check if target has a specific debuff by name
local function HasDebuff(unit, name)
    for i = 1, 16 do
        if UnitDebuff(unit, i) == name then return true end
    end
    return false
end

-- Safe cast: only cast if not already casting (requires Nampower)
local function SafeCast(spell)
    if QueueSpellByName then
        QueueSpellByName(spell)
    else
        CastSpellByName(spell)
    end
end

-- Get current stance (1=Battle, 2=Defensive, 3=Berserker for warrior)
local function GetStance()
    for i = 1, GetNumShapeshiftForms() do
        local _, _, active = GetShapeshiftFormInfo(i)
        if active then return i end
    end
    return 0
end

-- Check if spell is on cooldown
local function OnCD(spell)
    local start, dur = GetSpellCooldown(spell, BOOKTYPE_SPELL)
    return start > 0 and dur > 1.5
end

-- Modifier key helpers (compact)
local shift = IsShiftKeyDown
local ctrl = IsControlKeyDown
local alt = IsAltKeyDown
