--[[
@name         Arms Warrior ST Rotation
@class        Warrior
@spec         Arms
@description  One-button Arms single-target rotation for 3.5-3.8 speed weapons.
              Slam-centric priority with Overpower stance dancing, Sunder
              management (apply to 5 stacks then stop), and Execute phase.
              Uses /firstaction for priority-based evaluation.
@requires     SuperCleveRoidMacros, Nampower, SP_SwingTimer
@optional     UnitXP_SP3, TimeToKill
@author       TurtleWoW_Macros
@version      1.0
@date         2026-02-07
@tags         warrior, arms, rotation, slam, mortal-strike, overpower, stance-dance, pve, single-target
@notes        - Overpower must be on an action bar slot for [reactive] to work
              - Set NP_EnableAutoAttackEvents=1 in Config\config.wtf for slam timing
              - Store in SuperMacro book (exceeds 255-char vanilla limit)
              - Tunable: Execute rage threshold (myrawpower:>75), HS rage threshold (myrawpower:>60)
              - 5/5 Tactical Mastery assumed for stance-dance rage threshold (<=25)
--]]

-- Priority-based Arms ST rotation
-- Evaluated top-to-bottom, first matching condition fires

/firstaction

-- P1: Execute phase — target below 20% HP with enough rage for meaningful damage
/cast [hp:<20,myrawpower:>75] Execute

-- P2: Sunder to 5 stacks — [nodebuff:#>4] = "does NOT have 5+ stacks" = true at 0-4
/cast [nodebuff:"Sunder Armor">#4] Sunder Armor

-- P3a: Overpower — already in Battle Stance, free (no swap cost)
/cast [stance:1,reactive:Overpower] Overpower

-- P3b: Overpower — not in Battle Stance, swap only when rage <= 25 (no waste with 5/5 TM)
/cast [nostance:1,reactive:Overpower,myrawpower:<=25] Battle Stance

-- P4: Slam — core filler, only when it won't clip auto-attack
/cast [noslamclip] Slam

-- P5: Mortal Strike — primary damage, guarded so GCD expires before next auto
/cast [nonextslamclip] Mortal Strike

-- P6: Whirlwind — secondary damage, same Slam timing guard
/cast [nonextslamclip] Whirlwind

-- P7: Heroic Strike — on-next-swing rage dump when past Slam window
/cast [slamclip,myrawpower:>60] !Heroic Strike

/nofirstaction

-- Always keep auto-attack running (fires regardless of which priority matched)
/startattack
