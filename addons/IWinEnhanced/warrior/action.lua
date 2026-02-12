if UnitClass("player") ~= "Warrior" then return end

function IWin:InitializeRotation()
	IWin:InitializeRotationCore()
	IWin_CombatVar["reservedRage"] = 0
	IWin_CombatVar["slamQueued"] = false
	IWin_CombatVar["swingAttackQueued"] = false
	if IWin_CombatVar["reservedRageStanceLast"] +  IWin_Settings["GCD"] < GetTime() then
		IWin_CombatVar["reservedRageStance"] = nil
	end
	-- Time-decay safety: clear stale slamCasting if Slam cast should have finished
	if IWin_CombatVar["slamCasting"] > 0 and GetTime() > IWin_CombatVar["slamCasting"] + 0.5 then
		IWin_CombatVar["slamCasting"] = 0
	end
end

function IWin:BattleShout()
	if IWin:IsSpellLearnt("Battle Shout")
		and IWin_CombatVar["queueGCD"]
		and not IWin:IsBuffActive("player","Battle Shout")
		and IWin:IsRageAvailable("Battle Shout")
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Battle Shout")
	end
end

function IWin:BattleShoutRefresh()
	if IWin:IsSpellLearnt("Battle Shout")
		and IWin_CombatVar["queueGCD"]
		and IWin:GetBuffRemaining("player","Battle Shout") < 9
		and IWin:IsRageAvailable("Battle Shout")
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Battle Shout")
	end
end

function IWin:BattleShoutRefreshOOC()
	if IWin:IsSpellLearnt("Battle Shout")
		and IWin_CombatVar["queueGCD"]
		and IWin:GetBuffRemaining("player","Battle Shout") < 30
		and IWin:IsRageAvailable("Battle Shout")
		and UnitMana("player") > 60
		and not UnitAffectingCombat("player")
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Battle Shout")
	end
end

function IWin:BerserkerRage()
	if IWin:IsSpellLearnt("Berserker Rage")
		and IWin_CombatVar["queueGCD"]
		and IWin:IsStanceActive("Berserker Stance")
		and not IWin:IsBlacklistFear()
		and not IWin:IsOnCooldown("Berserker Rage")
		and UnitAffectingCombat("player")
		and UnitMana("player") < 70
		and (
				IWin:IsTanking()
				or IWin:GetTalentRank(2, 14) ~= 0
			)
		and not IWin_CombatVar["slamQueued"] then
				IWin_CombatVar["queueGCD"] = false
				CastSpellByName("Berserker Rage")
	end
end

function IWin:BerserkerRageImmune()
	if IWin:IsSpellLearnt("Berserker Rage")
		and IWin_CombatVar["queueGCD"]
		and not IWin:IsOnCooldown("Berserker Rage")
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			if not IWin:IsStanceActive("Berserker Stance") then
				CastSpellByName("Berserker Stance")
			else
				CastSpellByName("Berserker Rage")
			end
	end
end

function IWin:Bloodrage()
	if IWin:IsSpellLearnt("Bloodrage")
		and UnitMana("player") < 70
		and IWin:GetHealthPercent("player") > 25
		and not IWin:IsBuffActive("player","Enrage")
		and not IWin:IsOnCooldown("Bloodrage")
		and (
					(
						IWin:IsStanceActive("Defensive Stance")
						and not IWin:IsInRange("Charge","ranged")
					)
				or (
					UnitAffectingCombat("player")
					and (
							IWin:IsSpellLearnt("Mortal Strike")
							or IWin:IsSpellLearnt("Bloodthirst")
							or IWin:IsSpellLearnt("Shield Slam")
							or IWin:GetTalentRank(2, 9) ~= 0
							or GetNumPartyMembers() ~= 0
						)
					)
			) then
				CastSpellByName("Bloodrage")
	end
end

function IWin:Bloodthirst(queueTime)
	if IWin:IsSpellLearnt("Bloodthirst")
		and IWin_CombatVar["queueGCD"]
		and IWin:GetCooldownRemaining("Bloodthirst") < queueTime
		and IWin:IsRageAvailable("Bloodthirst")
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Bloodthirst")
	end
end

function IWin:SetReservedRageBloodthirst()
	if not IWin:IsHighAP() then 
		IWin:SetReservedRage("Bloodthirst", "cooldown")
	end
end

function IWin:BloodthirstHighAP(queueTime)
	if IWin:IsSpellLearnt("Bloodthirst")
		and IWin_CombatVar["queueGCD"]
		and IWin:GetCooldownRemaining("Bloodthirst") < queueTime
		and IWin:IsRageAvailable("Bloodthirst")
		and UnitMana("player") < 60
		and IWin:IsHighAP()
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Bloodthirst")
	end
end

function IWin:SetReservedRageBloodthirstHighAP()
	if IWin:IsHighAP() then
		IWin:SetReservedRage("Bloodthirst", "cooldown")
	end
end

function IWin:SetReservedRageMortalStrikeTank()
	if IWin:IsSpellLearnt("Mortal Strike") then
		IWin:SetReservedRage("Mortal Strike", "cooldown")
	end
end

function IWin:SetReservedRageBloodthirstTank()
	if IWin:IsSpellLearnt("Bloodthirst") then
		IWin:SetReservedRage("Bloodthirst", "cooldown")
	end
end

function IWin:Charge()
	if IWin:IsSpellLearnt("Charge")
		and not IWin:IsOnCooldown("Charge")
		and IWin:IsInRange("Charge","ranged")
		and not UnitAffectingCombat("player") then
			IWin_CombatVar["queueGCD"] = false
			if not IWin:IsStanceActive("Battle Stance")
				and (
						IWin:IsStanceSwapMaxRageLoss(25, "Charge")
						or UnitIsPVP("target")
					) then
					CastSpellByName("Battle Stance")
			end
			if IWin:IsStanceActive("Battle Stance") then
				CastSpellByName("Charge")
				IWin_CombatVar["charge"] = GetTime()
				IWin:MarkSkull()
			end
	end
end

function IWin:ChargePartySize()
	local partySize = IWin_Settings["charge"]
	if (
			UnitInRaid("player")
			and IWin_PartySize[partySize] == 40
		) or (
			GetNumPartyMembers() ~= 0
			and IWin_PartySize[partySize] >= 5
		) or (
			GetNumPartyMembers() == 0
			and IWin_PartySize[partySize] >= 1
		) or (
			IWin_Settings["charge"] == "targetincombat"
			and UnitAffectingCombat("target")
		) or (
			IWin_Settings["chargewl"] == "on"
			and IWin:IsWhitelistCharge()
		) then
			IWin:Charge()
	end
end

function IWin:Cleave()
	if IWin:IsSpellLearnt("Cleave") then
		if IWin:IsRageAvailable("Cleave")
			or UnitMana("player") > 75 then
				IWin_CombatVar["swingAttackQueued"] = true
				IWin_CombatVar["startAttackThrottle"] = GetTime() + 0.2
				CastSpellByName("Cleave")
		else
			--SpellStopCasting()
		end
	end
end

function IWin:CleaveAOE()
	if IWin:IsSpellLearnt("Cleave") then
		-- AoE tank variant: no +20 swing tax (multi-mob incoming damage replaces lost rage)
		-- Still respects reservedRage for Thunder Clap/Shield Slam/Sunder
		local rageNeeded = IWin_RageCost["Cleave"] + IWin_CombatVar["reservedRage"]
		if UnitMana("player") >= rageNeeded then
				IWin_CombatVar["swingAttackQueued"] = true
				IWin_CombatVar["startAttackThrottle"] = GetTime() + 0.2
				CastSpellByName("Cleave")
		end
	end
end

function IWin:CleaveStance()
	if IWin:IsStanceActive("Defensive Stance") then
		if not IWin:IsSpellLearnt("Sweeping Strikes")
			and IWin:IsSpellLearnt("Berserker Stance") then
				CastSpellByName("Berserker Stance")
		elseif IWin:IsSpellLearnt("Battle Stance") then
			CastSpellByName("Battle Stance")
		end
	end
end

function IWin:ConcussionBlow()
	if IWin:IsSpellLearnt("Concussion Blow")
		and IWin_CombatVar["queueGCD"]
		and not IWin:IsOnCooldown("Concussion Blow")
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Concussion Blow")
	end
end

function IWin:DemoralizingShout()
	if IWin:IsSpellLearnt("Demoralizing Shout")
		and IWin_CombatVar["queueGCD"]
		and IWin:IsRageAvailable("Demoralizing Shout")
		and not IWin:IsBlacklistAOEDebuff()
		and IWin_Settings["demo"] == "on"
		and IWin:IsInRange("Intimidating Shout")
		and not IWin:IsBuffActive("target", "Demoralizing Shout")
		and IWin:GetTimeToDie() > 10
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Demoralizing Shout")
	end
end

function IWin:SetReservedRageDemoralizingShout()
	if not IWin:IsBlacklistAOEDebuff()
		and IWin_Settings["demo"] == "on"
		and not IWin:IsBuffActive("target", "Demoralizing Shout")
		and IWin:GetTimeToDie() > 10 then
			IWin:SetReservedRage("Demoralizing Shout", "buff", "target")
	end
end

function IWin:DPSStance()
	if IWin:IsStanceActive("Defensive Stance") then
		if IWin:IsSpellLearnt("Berserker Stance") then
			CastSpellByName("Berserker Stance")
		else
			CastSpellByName("Battle Stance")
		end
	end
end

function IWin:DPSStanceDefault()
	if IWin:IsInRange("Rend") then
		if IWin:IsSpellLearnt("Berserker Stance")
			and IWin:IsReservedRageStance("Berserker Stance")
			and UnitExists("target")
			and (
					UnitAffectingCombat("player")
					or IWin:IsInRange()
				) then
				if not IWin:IsStanceActive("Berserker Stance") then
					IWin:SetReservedRageStanceCast()
					CastSpellByName("Berserker Stance")
				end
		elseif IWin:IsSpellLearnt("Battle Stance")
			and IWin:IsReservedRageStance("Battle Stance")
			and UnitExists("target") then
				if not IWin:IsStanceActive("Battle Stance") then
					IWin:SetReservedRageStanceCast()
					CastSpellByName("Battle Stance")
				end
		end
	end
end

function IWin:Execute()
	if IWin:IsSpellLearnt("Execute")
		and IWin_CombatVar["queueGCD"]
		and IWin:IsExecutePhase()
		and IWin:IsRageAvailable("Execute")
		and (
				UnitIsPVP("target")
				or IWin:GetHealthPercent("player") < 40
				or IWin:IsElite()
				or (
						not IWin:Is2HanderEquipped()
						and (
								UnitInRaid("player")
								or UnitMana("player") < 40
							)
					)
				or IWin:GetTimeToDie() < 4
			)
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			if IWin:IsStanceActive("Defensive Stance") then
				CastSpellByName("Battle Stance")
			else
				CastSpellByName("Execute")
			end
	end
end

function IWin:SetReservedRageExecute()
	local lowHealthTarget = (UnitHealthMax("player") * 0.3 > UnitHealth("target"))
	if (
			lowHealthTarget
			or IWin:IsExecutePhase()
		)
		and (
				UnitIsPVP("target")
				or IWin:GetHealthPercent("player") < 40
				or IWin:IsElite()
				or (
						not IWin:Is2HanderEquipped()
						and (
								UnitInRaid("player")
								or UnitMana("player") < 40
							)
					)
				or IWin:GetTimeToDie() < 4
			) then 
			IWin:SetReservedRage("Execute", "cooldown")
	end
end

function IWin:Execute2Hander()
	if IWin:IsSpellLearnt("Execute")
		and IWin_CombatVar["queueGCD"]
		and IWin:IsExecutePhase()
		and IWin:IsRageAvailable("Execute")
		and IWin:Is2HanderEquipped()
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			if IWin:IsStanceActive("Defensive Stance") then
				CastSpellByName("Battle Stance")
			else
				CastSpellByName("Execute")
			end
	end
end

function IWin:ExecuteDefensiveTactics()
	if IWin:IsSpellLearnt("Execute")
		and IWin_CombatVar["queueGCD"]
		and IWin:IsExecutePhase()
		and IWin:IsRageAvailable("Execute")
		and IWin:IsDefensiveTacticsActive()
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			if IWin:IsStanceActive("Defensive Stance")
				and IWin:IsDefensiveTacticsActive("Battle Stance") then
					CastSpellByName("Battle Stance")
			elseif IWin:IsStanceActive("Defensive Stance")
				and IWin:IsDefensiveTacticsActive("Berserker Stance") then
					CastSpellByName("Berserker Stance")
			end
			if IWin:IsStanceActive("Battle Stance")
				or IWin:IsStanceActive("Berserker Stance") then
					CastSpellByName("Execute")
			end
	end
end

function IWin:SetReservedRageExecuteDefensiveTactics()
	local lowHealthTarget = (UnitHealthMax("player") * 0.3 > UnitHealth("target"))
	if (
			lowHealthTarget
			or IWin:IsExecutePhase()
		)
		and (
				IWin:IsDefensiveTacticsActive("Battle Stance")
				or IWin:IsDefensiveTacticsActive("Berserker Stance")
			) then 
			IWin:SetReservedRage("Execute", "cooldown")
	end
end

function IWin:Hamstring()
	if IWin:IsSpellLearnt("Hamstring")
		and IWin_CombatVar["queueGCD"]
		and not IWin:IsOnCooldown("Hamstring")
		and IWin:IsInRange("Hamstring")
		and IWin:IsRageCostAvailable("Hamstring")
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Hamstring")
	end
end

function IWin:HamstringJousting()
	if IWin:IsSpellLearnt("Hamstring")
		and IWin_CombatVar["queueGCD"]
		and not IWin:IsOnCooldown("Hamstring")
		and IWin:IsInRange("Hamstring")
		and IWin:IsRageCostAvailable("Hamstring")
		and GetNumPartyMembers() == 0
		and IWin_Settings["jousting"] == "on"
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Hamstring")
	end
end

function IWin:HamstringWindfury()
	if IWin:IsSpellLearnt("Hamstring")
		and IWin_CombatVar["queueGCD"]
		and not IWin:IsOnCooldown("Hamstring")
		and IWin:IsRageAvailable("Hamstring")
		and not IWin:IsStanceActive("Defensive Stance")
		and IWin:IsBuffActive("player", "Windfury Totem")
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Hamstring")
	end
end

function IWin:SetReservedRageHamstringWindfury()
	if not IWin:IsStanceActive("Defensive Stance")
		and IWin:IsBuffActive("player", "Windfury Totem") then
		IWin:SetReservedRage("Hamstring", "cooldown")
	end
end

function IWin:HeroicStrike()
	if IWin:IsSpellLearnt("Heroic Strike") then
		if IWin:IsRageAvailable("Heroic Strike")
			or (
					UnitMana("player") > 75
					and (
							not IWin:IsSpellLearnt("Whirlwind")
							or IWin:GetCooldownRemaining("Whirlwind") > 0
						)
				) then
					IWin_CombatVar["swingAttackQueued"] = true
					IWin_CombatVar["startAttackThrottle"] = GetTime() + 0.2
					CastSpellByName("Heroic Strike")
		else
			--SpellStopCasting()
		end
	end
end

function IWin:HeroicStrikeTank()
	if IWin:IsSpellLearnt("Heroic Strike") then
		-- Tank variant: no +20 swing tax (incoming damage replaces lost rage)
		-- Still respects reservedRage for Shield Slam/Revenge/Sunder
		local rageNeeded = IWin_RageCost["Heroic Strike"] + IWin_CombatVar["reservedRage"]
		if UnitMana("player") >= rageNeeded then
				IWin_CombatVar["swingAttackQueued"] = true
				IWin_CombatVar["startAttackThrottle"] = GetTime() + 0.2
				CastSpellByName("Heroic Strike")
		end
	end
end

function IWin:Intercept()
	if IWin:IsSpellLearnt("Intercept")
		and IWin_CombatVar["queueGCD"]
		and not IWin:IsOnCooldown("Intercept")
		and IWin:IsInRange("Intercept","ranged")
		and not IWin:IsCharging()
		and (
				(
					not UnitAffectingCombat("player")
					and IWin:IsOnCooldown("Charge")
				)
				or UnitAffectingCombat("player")
				or (
						IWin:IsStanceActive("Berserker Stance")
						and not IWin:IsStanceSwapMaxRageLoss(25)
						and not UnitIsPVP("target")
					)
			)
		and (
				(
					IWin:IsRageCostAvailable("Intercept")
					and (
							IWin:IsStanceActive("Berserker Stance")
							or IWin:GetStanceSwapRageRetain() >= IWin_RageCost["Intercept"]
						)
				)
				or not IWin:IsOnCooldown("Bloodrage")
			)
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			if IWin:IsStanceActive("Battle Stance")
				or (
						IWin:IsStanceActive("Defensive Stance")
						and not IWin:IsTanking()
					) then
				CastSpellByName("Berserker Stance")
			end
			if not IWin:IsRageCostAvailable("Intercept") then
				CastSpellByName("Bloodrage")
			end
			if IWin:IsStanceActive("Berserker Stance") then
				CastSpellByName("Intercept")
			end
	end
end

function IWin:InterceptPartySize()
	local partySize = IWin_Settings["charge"]
	if (
			UnitInRaid("player")
			and IWin_PartySize[partySize] == 40
		) or (
			GetNumPartyMembers() ~= 0
			and IWin_PartySize[partySize] >= 5
		) or (
			GetNumPartyMembers() == 0
			and IWin_PartySize[partySize] >= 1
		) or (
			IWin_Settings["charge"] == "targetincombat"
			and UnitAffectingCombat("target")
		) or (
			IWin_Settings["chargewl"] == "on"
			and IWin:IsWhitelistCharge()
		) then
			IWin:Intercept()
	end
end

function IWin:Intervene()
	if IWin:IsSpellLearnt("Intervene")
		and IWin_CombatVar["queueGCD"]
		and not IWin:IsOnCooldown("Intervene")
		and (
				(
					IWin:IsInRange("Intervene","ranged","target")
					and UnitIsFriend("player", "target")
				) or (
					IWin:IsInRange("Intervene","ranged","targettarget")
					and UnitIsFriend("player", "targettarget")
				)
			)
		and not IWin:IsCharging()
		and IWin:IsBehind()
		and not IWin:IsTanking()
		and (
				(
					IWin:IsRageCostAvailable("Intervene")
					and (
							IWin:IsStanceActive("Defensive Stance")
							or IWin:GetStanceSwapRageRetain() >= IWin_RageCost["Intervene"]
						)
				)
				or not IWin:IsOnCooldown("Bloodrage")
			)
		and not IWin_CombatVar["slamQueued"] then
			if IWin:IsStanceActive("Defensive Stance") then
				CastSpellByName("Defensive Stance")
			end
			if not IWin:IsRageCostAvailable("Intervene") then
				CastSpellByName("Bloodrage")
			end
			if IWin:IsStanceActive("Defensive Stance") then
				IWin_CombatVar["queueGCD"] = false
				if IWin:IsInRange("Intervene","ranged","target")
					and UnitIsFriend("player", "target") then
						CastSpellByName("Intervene", "target")
				elseif IWin:IsInRange("Intervene","ranged","targettarget")
					and UnitIsFriend("player", "targettarget") then
						CastSpellByName("Intervene", "targettarget")
				end
			end
	end
end

function IWin:IntervenePartySize()
	local partySize = IWin_Settings["charge"]
	if (
			UnitInRaid("player")
			and IWin_PartySize[partySize] == 40
		) or (
			GetNumPartyMembers() ~= 0
			and IWin_PartySize[partySize] >= 5
		) or (
			GetNumPartyMembers() == 0
			and IWin_PartySize[partySize] >= 1
		) or (
			IWin_Settings["charge"] == "targetincombat"
			and UnitAffectingCombat("target")
		) or (
			IWin_Settings["chargewl"] == "on"
			and IWin:IsWhitelistCharge()
		) then
			IWin:Intervene()
	end
end

function IWin:MasterStrike()
	if IWin:IsSpellLearnt("Master Strike")
		and IWin_CombatVar["queueGCD"]
		and not IWin:IsOnCooldown("Master Strike")
		and IWin:IsRageAvailable("Master Strike")
		and (
				IWin:IsTanking()
				or UnitIsPVP("target")
			)
		and not IWin_CombatVar["slamQueued"] then
				IWin_CombatVar["queueGCD"] = false
				CastSpellByName("Master Strike")
	end
end

function IWin:SetReservedRageMasterStrike()
	if IWin:IsTanking()
		or UnitIsPVP("target") then
			IWin:SetReservedRage("Master Strike", "cooldown")
	end
end

function IWin:MasterStrikeWindfury()
	if IWin:IsSpellLearnt("Master Strike")
		and IWin_CombatVar["queueGCD"]
		and not IWin:IsOnCooldown("Master Strike")
		and IWin:IsRageAvailable("Master Strike")
		and IWin:IsBuffActive("player", "Windfury Totem") then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Master Strike")
	end
end

function IWin:SetReservedRageMasterStrikeWindfury()
	if IWin:IsBuffActive("player", "Windfury Totem") then
		IWin:SetReservedRage("Master Strike", "cooldown")
	end
end

function IWin:MockingBlow()
	if IWin:IsSpellLearnt("Mocking Blow")
		and IWin_CombatVar["queueGCD"]
		and not IWin:IsTanking()
		and IWin:IsOnCooldown("Taunt")
		and not IWin:IsOnCooldown("Mocking Blow")
		and not IWin:IsTaunted() then
			IWin_CombatVar["queueGCD"] = false
			if not IWin:IsStanceActive("Battle Stance") then
				CastSpellByName("Battle Stance")
			else
				CastSpellByName("Mocking Blow")
			end
	end
end

function IWin:MortalStrike(queueTime)
	if IWin:IsSpellLearnt("Mortal Strike")
		and IWin_CombatVar["queueGCD"]
		and IWin:GetCooldownRemaining("Mortal Strike") < queueTime
		and IWin:IsRageAvailable("Mortal Strike")
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Mortal Strike")
	end
end

function IWin:Overpower()
	-- Overpower is exempt from slamQueued: reactive proc (5s window), cheap (5 rage),
	-- and the rotation guide says "Overpower instead of Slam" when it procs
	if IWin:IsSpellLearnt("Overpower")
		and IWin_CombatVar["queueGCD"]
		and IWin:IsOverpowerAvailable()
		and not IWin:IsOnCooldown("Overpower")
		and (
				IWin:IsRageAvailable("Overpower")
				or IWin:IsStanceActive("Battle Stance")
			)
		and IWin:IsRageCostAvailable("Overpower")
		and IWin:IsReservedRageStance("Battle Stance") then
			IWin_CombatVar["queueGCD"] = false
			if not IWin:IsStanceActive("Battle Stance")
				and (
						(
							IWin:IsStanceSwapMaxRageLoss(25)
							and IWin:GetStanceSwapRageRetain() >= IWin_RageCost["Overpower"]
						)
						or UnitIsPVP("target")
					) then
						IWin:SetReservedRageStance("Battle Stance")
						IWin:SetReservedRageStanceCast()
						CastSpellByName("Battle Stance")
			end
			if IWin:IsStanceActive("Battle Stance") then
				IWin:SetReservedRageStance("Battle Stance")
				CastSpellByName("Overpower")
			end
	end
end

function IWin:OverpowerDefensiveTactics()
	if IWin:IsSpellLearnt("Overpower")
		and IWin_CombatVar["queueGCD"]
		and IWin:IsOverpowerAvailable()
		and not IWin:IsOnCooldown("Overpower")
		and (
				IWin:IsRageAvailable("Overpower")
				or IWin:IsStanceActive("Battle Stance")
			)
		and IWin:IsRageCostAvailable("Overpower")
		and IWin:IsReservedRageStance("Battle Stance")
		and IWin:IsDefensiveTacticsStanceAvailable("Battle Stance") then
			IWin_CombatVar["queueGCD"] = false
			if not IWin:IsStanceActive("Battle Stance")
				and (
						IWin:IsStanceSwapMaxRageLoss(15)
						or UnitIsPVP("target")
					) then
						IWin:SetReservedRageStance("Battle Stance")
						IWin:SetReservedRageStanceCast()
						CastSpellByName("Battle Stance")
			end
			if IWin:IsStanceActive("Battle Stance") then
				IWin:SetReservedRageStance("Battle Stance")
				CastSpellByName("Overpower")
			end
	end
end

function IWin:PiercingHowl()
	if IWin:IsSpellLearnt("Piercing Howl")
		and IWin_CombatVar["queueGCD"]
		and IWin:IsInRange("Intimidating Shout")
		and IWin:IsRageCostAvailable("Piercing Howl") then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Piercing Howl")
	end
end

function IWin:Pummel()
	if IWin:IsSpellLearnt("Pummel")
		and IWin_CombatVar["queueGCD"]
		and not IWin:IsOnCooldown("Pummel")
		and (
				(
					IWin:IsRageCostAvailable("Pummel")
					and (
							IWin:IsStanceActive("Berserker Stance")
							or IWin:GetStanceSwapRageRetain() >= IWin_RageCost["Pummel"]
						)
				)
				or not IWin:IsOnCooldown("Bloodrage")
			)
		and (
				not IWin:IsShieldEquipped()
				or not IWin:IsStanceActive("Defensive Stance")
			) then
				IWin_CombatVar["queueGCD"] = false
				if IWin:IsStanceActive("Defensive Stance") then
					CastSpellByName("Battle Stance")
				else
					if not IWin:IsRageCostAvailable("Pummel") then
						CastSpellByName("Bloodrage")
					end
					if IWin_CombatVar["slamCasting"] > GetTime() then
						SpellStopCasting()
					end
					CastSpellByName("Pummel")
				end
	end
end

function IWin:PummelWindfury()
	if IWin:IsSpellLearnt("Pummel")
		and IWin_CombatVar["queueGCD"]
		and not IWin:IsOnCooldown("Pummel")
		and IWin:IsRageAvailable("Pummel")
		and not IWin:IsStanceActive("Defensive Stance")
		and IWin:IsBuffActive("player", "Windfury Totem")
		and not IWin:IsBlacklistKick() then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Pummel")
	end
end

function IWin:SetReservedRagePummelWindfury()
	if not IWin:IsStanceActive("Defensive Stance")
		and IWin:IsBuffActive("player", "Windfury Totem")
		and not IWin:IsBlacklistKick() then
		IWin:SetReservedRage("Pummel", "cooldown")
	end
end

function IWin:Rend()
	if IWin:IsSpellLearnt("Rend")
		and IWin_CombatVar["queueGCD"]
		and IWin:IsRageAvailable("Rend")
		and IWin:GetTimeToDie() > 9
		and not UnitInRaid("player")
		and not IWin:IsBuffActive("target","Rend")
		and not (
					UnitCreatureType("target") == "Undead"
					or UnitCreatureType("target") == "Mechanical"
					or UnitCreatureType("target") == "Elemental"
				)
		and not IWin:IsStanceActive("Berserker Stance")
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Rend")
	end
end

function IWin:Revenge()
	if IWin:IsSpellLearnt("Revenge")
		and IWin_CombatVar["queueGCD"]
		and not IWin:IsOnCooldown("Revenge")
		and IWin:IsRageCostAvailable("Revenge")
		and IWin:IsRevengeAvailable()
		and IWin:IsReservedRageStance("Defensive Stance")
		and not IWin_CombatVar["slamQueued"]
		and (
				not IWin:IsDefensiveTacticsAvailable()
				or IWin:IsDefensiveTacticsStanceAvailable("Defensive Stance")
			) then
				IWin_CombatVar["queueGCD"] = false
				if not IWin:IsStanceActive("Defensive Stance")
					and (
							IWin:IsStanceSwapMaxRageLoss(5)
							or UnitIsPVP("target")
						) then
							IWin:SetReservedRageStance("Defensive Stance")
							IWin:SetReservedRageStanceCast()
							CastSpellByName("Defensive Stance")
				end
				if IWin:IsStanceActive("Defensive Stance") then
					IWin:SetReservedRageStance("Defensive Stance")
					CastSpellByName("Revenge")
				end
	end
end

function IWin:SetReservedRageRevenge()
	if IWin:IsTanking()
		and IWin:IsStanceActive("Defensive Stance") then
		IWin:SetReservedRage("Revenge", "cooldown")
	end
end

function IWin:ShieldBash()
	if IWin:IsSpellLearnt("Shield Bash")
		and IWin_CombatVar["queueGCD"]
		and not IWin:IsOnCooldown("Shield Bash")
		and IWin:IsShieldEquipped() 
		and (
				(
					IWin:IsRageCostAvailable("Shield Bash")
					and (
							not IWin:IsStanceActive("Berserker Stance")
							or IWin:GetStanceSwapRageRetain() >= IWin_RageCost["Shield Bash"]
						)
				)
				or not IWin:IsOnCooldown("Bloodrage")
			)
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			if IWin:IsStanceActive("Berserker Stance") then
				CastSpellByName("Defensive Stance")
			else
				if not IWin:IsRageCostAvailable("Shield Bash") then
					CastSpellByName("Bloodrage")
				end
				CastSpellByName("Shield Bash")
			end
	end
end

function IWin:ShieldBlock()
	if IWin:IsSpellLearnt("Shield Block")
		and not IWin:IsOnCooldown("Shield Block")
		and IWin:IsShieldEquipped()
		and IWin:IsTanking()
		and IWin:IsBuffActive("target", "Sunder Armor")
		and IWin:IsRageAvailable("Shield Block")
		and not IWin:IsBuffActive("player", "Improved Shield Slam")
		and not IWin:IsBuffActive("player", "Shield Block")
		and IWin:GetCooldownRemaining("Revenge") <  IWin_Settings["GCD"]
		and not IWin:IsRevengeAvailable()
		and IWin:IsStanceActive("Defensive Stance") then
			CastSpellByName("Shield Block")
	end
end

function IWin:ShieldBlockFRD()
	if IWin:IsSpellLearnt("Shield Block")
		and not IWin:IsOnCooldown("Shield Block")
		and IWin:IsShieldEquipped()
		and IWin:IsTanking()
		and IWin:IsRageAvailable("Shield Block")
		and IWin:IsItemEquipped(17, "Force Reactive Disk")
		and IWin:IsStanceActive("Defensive Stance") then
			CastSpellByName("Shield Block")
	end
end

function IWin:ShieldSlam(queueTime)
	if IWin:IsSpellLearnt("Shield Slam")
		and IWin_CombatVar["queueGCD"]
		and IWin:IsShieldEquipped() 
		and IWin:GetCooldownRemaining("Shield Slam") < queueTime
		and IWin:IsRageAvailable("Shield Slam")
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Shield Slam")
	end
end

function IWin:Shoot()
	local rangedLink = GetInventoryItemLink("player", 18)
	local itemSubType = nil
	if rangedLink then
		_, _, _, _, _, itemSubType = GetItemInfo(tonumber(IWin:GetItemID(rangedLink)))
	end
	if itemSubType == "Bows" then
		CastSpellByName("Shoot Bow")
	elseif itemSubType == "Guns" then
		CastSpellByName("Shoot Gun")
	elseif itemSubType == "Crossbows" then
		CastSpellByName("Shoot Crossbow")
	elseif itemSubType == "Thrown" then
		CastSpellByName("Throw")
	end
	IWin:MarkSkull()
end

function IWin:Slam()
	if IWin:IsSpellLearnt("Slam")
		and IWin_CombatVar["queueGCD"]
		and IWin_CombatVar["reservedRageStanceLast"] + 0.2 < GetTime()
		and IWin:IsRageAvailable("Slam")
		and IWin:Is2HanderEquipped()
		-- Only one Slam per swing cycle: skip if grace period active (Slam already fired)
		and IWin_CombatVar["slamGCDAllowed"] < GetTime()
		and (
				not st_timer
				or st_timer > UnitAttackSpeed("player") * 0.5
			)
		and (
				not IWin:IsStanceActive("Battle Stance")
				or not IWin:IsSpellLearnt("Berserker Stance")
			) then
				IWin_CombatVar["queueGCD"] = false
				CastSpellByName("Slam")
	end
end

function IWin:SlamThreat()
	if IWin:IsSpellLearnt("Slam", "Rank 5") then
		IWin:Slam()
	end
end

function IWin:SetSlamQueued()
	-- st_timer counts DOWN: weaponSpeed -> 0 (time remaining until next auto)
	-- Slam fires when st_timer > attackSpeed * 0.5 (first half of swing cycle)
	-- Block GCD abilities during the Slam window so they don't steal the GCD
	if not st_timer then return end
	if not IWin:IsSpellLearnt("Slam") then return end
	if not IWin:Is2HanderEquipped() then return end

	local attackSpeed = UnitAttackSpeed("player")
	local slamCastTime = IWin:GetCastTime("Slam") or 1.5
	local slamWindow = attackSpeed * 0.5

	-- We're in the Slam window: enough time remains on swing for Slam to cast
	-- AND we haven't just finished casting Slam (slamGCDAllowed grace period)
	-- AND we have enough rage to actually Slam
	if st_timer > slamWindow
		and st_timer > slamCastTime
		and IWin_CombatVar["slamGCDAllowed"] < GetTime()
		and IWin:IsRageCostAvailable("Slam") then
			IWin_CombatVar["slamQueued"] = true
			if IWin_Settings["slamdebug"] == "on" then
				DEFAULT_CHAT_FRAME:AddMessage(
					"|cffff8800[Slam]|r QUEUED st=" .. string.format("%.2f", st_timer)
					.. " window=" .. string.format("%.2f", slamWindow)
					.. " cast=" .. string.format("%.2f", slamCastTime)
					.. " rage=" .. UnitMana("player")
				)
			end
	elseif IWin_Settings["slamdebug"] == "on" and st_timer > 0.1 then
		DEFAULT_CHAT_FRAME:AddMessage(
			"|cff888888[Slam]|r skip st=" .. string.format("%.2f", st_timer)
			.. " window=" .. string.format("%.2f", slamWindow)
			.. " gcdOK=" .. tostring(IWin_CombatVar["slamGCDAllowed"] < GetTime())
			.. " rage=" .. UnitMana("player")
		)
	end
end

function IWin:SetSlamQueuedThreat()
	if (not st_timer) or (not IWin:IsSpellLearnt("Slam", "Rank 5")) then return end
	IWin:SetSlamQueued()
end

function IWin:SetReservedRageSlam()
	-- Only reserve rage for Slam if it can fire (grace period expired)
	-- During grace (Slam already fired this cycle), free the rage for MS/WW
	if IWin:Is2HanderEquipped()
		and IWin_CombatVar["slamGCDAllowed"] < GetTime() then
		IWin:SetReservedRage("Slam", "nocooldown")
	end
	if IWin_CombatVar["slamCasting"] > GetTime() then
		IWin:SetReservedRage("Slam", "nocooldown")
	end
end

function IWin:SetReservedRageSlamThreat()
	if IWin:IsSpellLearnt("Slam", "Rank 5") then
		IWin:SetReservedRageSlam()
	end
end

function IWin:SunderArmor()
	if IWin:IsSpellLearnt("Sunder Armor")
		and IWin_CombatVar["queueGCD"]
		and IWin:IsRageAvailable("Sunder Armor")
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Sunder Armor")
	end
end

function IWin:SunderArmorFirstStack()
	if IWin:IsSpellLearnt("Sunder Armor")
		and IWin_CombatVar["queueGCD"]
		and IWin:IsRageCostAvailable("Sunder Armor")
		and not IWin:IsBuffActive("target", "Sunder Armor")
		and not IWin:IsBuffActive("target", "Expose Armor")
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Sunder Armor")
	end
end

function IWin:SunderArmorDPS()
	if IWin:IsSpellLearnt("Sunder Armor")
		and IWin_CombatVar["queueGCD"]
		and IWin:IsRageAvailable("Sunder Armor")
		and not (IWin_Settings["sunder"] == "off")
		and IWin:GetTimeToDie() > 5
		and not IWin:IsBuffStack("target", "Sunder Armor", 5)
		and not IWin:IsBuffActive("target", "Expose Armor")
		and not IWin:IsGCDActive()
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Sunder Armor")
	end
end

function IWin:SetReservedRageSunderArmorDPS()
	if IWin:IsSpellLearnt("Sunder Armor")
		and not (IWin_Settings["sunder"] == "off")
		and IWin:GetTimeToDie() > 5
		and not IWin:IsBuffStack("target", "Sunder Armor", 5)
		and not IWin:IsBuffActive("target", "Expose Armor")
		and not IWin:Is2HanderEquipped() then
			IWin:SetReservedRage("Sunder Armor", "nocooldown")
	end
end

function IWin:SunderArmorDPS2Hander()
	if IWin:Is2HanderEquipped() then
		IWin:SunderArmorDPS()
	end
end

function IWin:SetReservedRageSunderArmorDPS2Hander()
	if IWin:IsSpellLearnt("Sunder Armor")
		and not (IWin_Settings["sunder"] == "off")
		and IWin:GetTimeToDie() > 5
		and not IWin:IsBuffStack("target", "Sunder Armor", 5)
		and not IWin:IsBuffActive("target", "Expose Armor")
		and IWin:Is2HanderEquipped() then
			IWin:SetReservedRage("Sunder Armor", "nocooldown")
	end
end

function IWin:SunderArmorElite()
	if IWin:IsSpellLearnt("Sunder Armor")
		and IWin_CombatVar["queueGCD"]
		and IWin:IsRageAvailable("Sunder Armor")
		and IWin_Settings["sunder"] == "high"
		and IWin:GetTimeToDie() > 5
		and IWin:IsElite()
		and not IWin:IsBuffStack("target", "Sunder Armor", 5)
		and not IWin:IsBuffActive("target", "Expose Armor")
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Sunder Armor")
	end
end

function IWin:SunderArmorDPSRefresh()
	if IWin:IsSpellLearnt("Sunder Armor")
		and IWin_CombatVar["queueGCD"]
		and IWin:IsRageCostAvailable("Sunder Armor")
		and not (IWin_Settings["sunder"] == "off")
		and IWin:IsBuffActive("target", "Sunder Armor")
		and IWin:GetBuffRemaining("target", "Sunder Armor") < 6
		and IWin:GetBuffRemaining("target", "Sunder Armor") < IWin:GetTimeToDie()
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Sunder Armor")
	end
end

function IWin:SunderArmorWindfury()
	if IWin:IsSpellLearnt("Sunder Armor")
		and IWin_CombatVar["queueGCD"]
		and IWin:IsRageAvailable("Sunder Armor")
		and IWin:IsBuffActive("player", "Windfury Totem")
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Sunder Armor")
	end
end

function IWin:SetReservedRageSunderArmorWindfury()
	if IWin:IsBuffActive("player", "Windfury Totem") then
		IWin:SetReservedRage("Sunder Armor", "nocooldown")
	end
end

function IWin:SweepingStrikes()
	if IWin:IsSpellLearnt("Sweeping Strikes")
		and IWin:IsReservedRageStance("Battle Stance")
		and not IWin_CombatVar["slamQueued"]
		and IWin:IsTimeToReserveRage("Sweeping Strikes", "cooldown") then
			if not IWin:IsStanceActive("Battle Stance")
				and UnitAffectingCombat("player") then
					IWin:SetReservedRageStance("Battle Stance")
					IWin:SetReservedRageStanceCast()
					CastSpellByName("Battle Stance")
			end
			if IWin:IsStanceActive("Battle Stance") then
				IWin:SetReservedRageStance("Battle Stance")
				if IWin:IsRageAvailable("Sweeping Strikes") then
					CastSpellByName("Sweeping Strikes")
				end
			end
	end
end

function IWin:TankStance()
	if IWin:IsSpellLearnt("Defensive Stance")
		and (
				not IWin:IsDefensiveTacticsAvailable()
				or (
						not IWin:IsDefensiveTacticsActive()
						and IWin:IsDefensiveTacticsStanceAvailable("Defensive Stance")
					)
			)
		and UnitAffectingCombat("player")
		and not IWin:IsStanceActive("Defensive Stance") then
			CastSpellByName("Defensive Stance")
	elseif IWin:IsSpellLearnt("Battle Stance")
		and (
					(
						not IWin:IsDefensiveTacticsAvailable()
						and not IWin:IsSpellLearnt("Defensive Stance")
					)
				or (
						not IWin:IsDefensiveTacticsActive()
						and IWin:IsDefensiveTacticsStanceAvailable("Battle Stance")
					)
			)
		and not IWin:IsStanceActive("Battle Stance") then
			CastSpellByName("Battle Stance")
	elseif IWin:IsSpellLearnt("Berserker Stance")
		and not IWin:IsDefensiveTacticsActive()
		and IWin:IsDefensiveTacticsStanceAvailable("Berserker Stance")
		and not IWin:IsStanceActive("Berserker Stance") then
			CastSpellByName("Berserker Stance")
	end
end

function IWin:Taunt()
	if IWin:IsSpellLearnt("Taunt")
		and not IWin:IsTanking()
		and not IWin:IsOnCooldown("Taunt")
		and not IWin:IsTaunted() then
			if not IWin:IsStanceActive("Defensive Stance") then
				CastSpellByName("Defensive Stance")
			else
				CastSpellByName("Taunt")
			end
	end
end

function IWin:ThunderClap(queueTime)
	if IWin:IsSpellLearnt("Thunder Clap")
		and IWin_CombatVar["queueGCD"]
		and IWin:IsRageAvailable("Thunder Clap")
		and IWin:IsInRange()
		and IWin:GetCooldownRemaining("Thunder Clap") < queueTime
		and not IWin_CombatVar["slamQueued"] then
			IWin_CombatVar["queueGCD"] = false
			if IWin:IsStanceActive("Berserker Stance") then
				CastSpellByName("Defensive Stance")
			else
				CastSpellByName("Thunder Clap")
			end
	end
end

function IWin:ThunderClapDPS()
	if IWin:IsSpellLearnt("Thunder Clap")
		and IWin_CombatVar["queueGCD"]
		and IWin:IsRageAvailable("Thunder Clap")
		and IWin:IsInRange()
		and not IWin:IsOnCooldown("Thunder Clap")
		and not IWin_CombatVar["slamQueued"]
		and not IWin:IsStanceActive("Berserker Stance") then
			IWin_CombatVar["queueGCD"] = false
			CastSpellByName("Thunder Clap")
	end
end

function IWin:Whirlwind(queueTime)
	if not IWin:IsBlacklistAOEDamage() then
		IWin:WhirlwindAOE(queueTime)
	end
end

function IWin:WhirlwindAOE(queueTime)
	if IWin:IsSpellLearnt("Whirlwind")
		and IWin_CombatVar["queueGCD"]
		and IWin:IsReservedRageStance("Berserker Stance")
		and not IWin_CombatVar["slamQueued"]
		and IWin:IsTimeToReserveRage("Whirlwind", "cooldown")
		and (
				IWin:GetCooldownRemaining("Whirlwind") < queueTime
				or not IWin:IsOnCooldown("Whirlwind")
			)
		and UnitAffectingCombat("player") then
			IWin_CombatVar["queueGCD"] = false
			if not IWin:IsStanceActive("Berserker Stance") then
				IWin:SetReservedRageStance("Berserker Stance")
				IWin:SetReservedRageStanceCast()
				CastSpellByName("Berserker Stance")
			end
			if IWin:IsInRange("Rend")
				and IWin:IsStanceActive("Berserker Stance") then
					IWin:SetReservedRageStance("Berserker Stance")
					if IWin:IsRageAvailable("Whirlwind") then
						CastSpellByName("Whirlwind")
					end
			end
	end
end

-- Tab-Sunder: find highest-priority loose/unsundered mob in melee range
-- Priority: (1) not targeting us + no sunder, (2) not targeting us + sundered,
--           (3) targeting us + no sunder, (4) no switch needed
function IWin:TargetLooseMob()
	if IWin_Settings["tabSunder"] ~= "on" then return end
	if not UnitAffectingCombat("player") then return end
	if not IWin_CombatVar["queueGCD"] then return end
	if IWin_CombatVar["slamQueued"] then return end

	local _, originalGuid = UnitExists("target")
	if not originalGuid then return end

	-- Check current target state
	local currentHasSunder = IWin:IsBuffActive("target", "Sunder Armor")
		or IWin:IsBuffActive("target", "Expose Armor")
	local currentTargetingUs = UnitIsUnit("targettarget", "player")

	-- If current target is loose (not targeting us), stay on it
	if not currentTargetingUs then return end

	-- If current target needs sunder, stay on it (sunder first, cycle next press)
	if not currentHasSunder then return end

	local bestGuid = nil
	local bestScore = 0
	-- Score: 4 = loose + no sunder, 3 = loose + sundered, 2 = targeting us + no sunder

	local maxCycles = 8
	for i = 1, maxCycles do
		UnitXP("target", "nextEnemyConsideringDistance")
		local _, cycledGuid = UnitExists("target")

		-- Cycled back to original = done
		if not cycledGuid or cycledGuid == originalGuid then break end

		-- Skip dead or friendly
		if not UnitIsDead("target") and not UnitIsFriend("target", "player") then
			-- Skip out-of-melee targets (sunder is melee range)
			local dist = UnitXP("distanceBetween", "player", "target", "meleeAutoAttack")
			if dist >= 0 and dist <= 8 then
				local hasSunder = IWin:IsBuffActive("target", "Sunder Armor")
					or IWin:IsBuffActive("target", "Expose Armor")
				local targetingUs = UnitIsUnit("targettarget", "player")

				local score = 0
				if not targetingUs and not hasSunder then
					score = 4
				elseif not targetingUs and hasSunder then
					score = 3
				elseif targetingUs and not hasSunder then
					score = 2
				end

				if score > bestScore then
					bestScore = score
					bestGuid = cycledGuid
				end

				-- Early exit on perfect candidate
				if bestScore == 4 then break end
			end -- dist check
		end -- dead/friendly check
	end

	-- Switch to best candidate, or restore original
	if bestGuid and bestScore > 0 then
		if bestScore >= 3 or (bestScore >= 2 and currentHasSunder) then
			TargetUnit(bestGuid)
			IWin:StartAttack()
		else
			TargetUnit(originalGuid)
		end
	else
		TargetUnit(originalGuid)
	end
end