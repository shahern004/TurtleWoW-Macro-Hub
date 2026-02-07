--[[
@name         Fury Warrior DPS Rotation
@class        Warrior
@spec         Fury
@description  One-button Fury rotation with slam management, stance-dance
              for Overpower procs, and intelligent rage spending. Handles
              both single target and cleave (2+ melee enemies).
@requires     SuperCleveRoidMacros, Nampower
@optional     SuperWoW, UnitXP_SP3
@author       TurtleWoW_Macros
@version      1.0
@date         2026-02-06
@tags         warrior, fury, rotation, slam, overpower, stance-dance, pve
@notes        - Overpower must be on an action bar slot for [reactive] to work
              - Set NP_EnableAutoAttackEvents=1 in Config\config.wtf for slam timing
              - Uses /firstaction for priority-based evaluation (stops at first match)
              - Bloodthirst is primary rage dump; Heroic Strike used at high rage
--]]

-- Priority-based Fury rotation
-- Evaluated top-to-bottom, first matching condition fires

-- 1. Stance dance: if Overpower is reactive and we're not in Battle Stance, switch
/firstaction
/cast [stance:2/3,reactive:Overpower] Battle Stance

-- 2. Fire Overpower if reactive (only works in Battle Stance)
/cast [stance:1,reactive:Overpower] Overpower

-- 3. Return to Berserker Stance after Overpower (if we swapped for it)
/cast [stance:1,noreactive:Overpower,combat] Berserker Stance

-- 4. Execute phase — target below 20% HP
/cast [harm,hp:<20,cooldown:Execute<1] Execute

-- 5. Whirlwind if 2+ enemies in melee range (cleave)
/cast [meleerange:>1,cooldown:Whirlwind<1,noimmune] Whirlwind

-- 6. Slam when safe (won't clip next auto-attack)
/cast [noslamclip] Slam

-- 7. Bloodthirst on cooldown
/cast [nonextslamclip,cooldown:Bloodthirst<1] Bloodthirst

-- 8. Whirlwind single target filler (if BT on CD)
/cast [cooldown:Whirlwind<1,noimmune] Whirlwind

-- 9. Heroic Strike as rage dump (high rage, won't waste during slam)
/cast [slamclip,mypower:>60] Heroic Strike

-- Keep auto-attack running
/startattack
