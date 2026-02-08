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

--- Sunder Armor — apply until max stacks (tracked manually).
-- SuperWoW's UnitDebuff returns auraId, not stacks, so we track count ourselves.
-- Count increments on cast, resets on target change.
function TR:SunderArmor()
    if not TR:IsSpellLearned("Sunder Armor") then return end
    if not TR.state.queueGCD then return end
    if TR.state.sunderCount >= TR.config.sunderMaxStacks then return end
    if not TR:HasEnoughRage("Sunder Armor") then return end
    if TR:GetCooldownRemaining("Sunder Armor") > TR.config.queueWindow then return end
    if not TR:IsSlamSafe() then return end

    TR.state.queueGCD = false
    TR.state.sunderCount = TR.state.sunderCount + 1
    CastSpellByName("Sunder Armor")
    TR:Debug(">> Sunder Armor (" .. TR.state.sunderCount .. "/" .. TR.config.sunderMaxStacks .. ")")
end

--- Overpower — reactive from dodge, stance dance if needed.
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

    TR.state.queueGCD = false
    CastSpellByName("Battle Shout")
    TR:Debug(">> Battle Shout")
end

--- StartAttack — ensure auto-attack is running. No GCD.
-- Uses autoAttacking flag to avoid toggling auto-attack off.
-- Flag is reset on PLAYER_REGEN_ENABLED and PLAYER_TARGET_CHANGED.
function TR:StartAttack()
    if not TR:HasValidTarget() then return end
    if TR.state.autoAttacking then return end
    AttackTarget()
    TR.state.autoAttacking = true
    TR:Debug(">> StartAttack")
end
