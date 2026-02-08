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
end
