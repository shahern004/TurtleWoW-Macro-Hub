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
