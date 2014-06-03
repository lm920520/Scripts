if myHero.charName ~= "Veigar" then return end -- not veigar => quit

local qRange = 650
local wRange = 900
local cageSpellRange = 650
local cageItselfRange = 375
local cageDiff = 50
local cageRange = cageSpellRange + (cageItselfRange/2) - cageDiff -- spell range + range of cage
local autoAttackRange = 525
local dfgRange = 750

--                1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8
local levelUps = {1,2,3,1,3,4,2,1,1,1,4,3,3,3,2,4,2,2} -- Veigar skils sequence

local myObjectsTable = {}
local nextDelay = os.clock()
local lastTick = os.clock()

function objectIsValid(object)
	return object ~= nil and object.valid and object.dead == false
end

function OnLoad()
	for i = 0, objManager.maxObjects, 1 do
		local object = objManager:GetObject(i)

		if objectIsValid(object) then
			object.lastDfg = nil

			table.insert(myObjectsTable, object)
		end
	end

	VConfig = scriptConfig("Auto Veigar by Lesiuk", "AutoVeigar")
	VConfig:addParam("autoQweakest", "Auto hit with Q weakest target in range", SCRIPT_PARAM_ONOFF, true)
	VConfig:addParam("deathFireKill", "Use DFG to kill people", SCRIPT_PARAM_ONOFF, true)
	VConfig:addParam("autoKill", "Auto Ultimate Killable", SCRIPT_PARAM_ONOFF, true)
	VConfig:addParam("autoCage", "Automatic Cage placment", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("S"))
	VConfig:addParam("autoW", "Auto W", SCRIPT_PARAM_ONOFF, true)
	VConfig:addParam("autoLevel", "Auto level up skills", SCRIPT_PARAM_ONOFF, true)
	VConfig:addParam("autoPotions", "Automatic potions using", SCRIPT_PARAM_ONOFF, true)
	VConfig:addParam("autoSeraph", "Automatic Seraph", SCRIPT_PARAM_ONOFF, true)
	VConfig:addParam("antiStun", "Automatic QuickSilver", SCRIPT_PARAM_ONOFF, true)
	VConfig:addParam("stunEnemiesAttackedByTurret", "Stun ennemies attacked by turret", SCRIPT_PARAM_ONOFF, true)
	VConfig:addParam("debug", "Debug informations", SCRIPT_PARAM_ONOFF, false)
	VConfig:addParam("qfarm", "Auto Q farm", SCRIPT_PARAM_ONOFF, true)
	player = GetMyHero()
end

function OnCreateObj(object)
	if objectIsValid(object) then
		object.lastDfg = nil

		table.insert(myObjectsTable, object)
	end
end

function HpLeftAfterShot(target, damage)
	local damage = player:CalcMagicDamage(target, damage)
	if target.lastDfg and os.clock() - target.lastDfg < 4 then
		damage = damage * 1.2
	end

	return target.health - damage
end

function IsGoodTarget(target, range)
	return player:GetDistance(target) < range and target.valid and target.dead == false
	and target.bMagicImunebMagicImune ~= true and target.bInvulnerable ~= true and target.visible
end

local DFG = 3128
local ZHONYA = 3157
local SERAPH = 3040
local POTION = 2003
local STASH = 3140
local CRYSTAL = 2041
local SPIRIT = 3206

function IsBetterTargetThan(oldTarget, newTarget, healthModifier, damage)
	if TargetHaveBuff("UndyingRage", newTarget) then
		return false
	end

	if newTarget.charName == "Alistar" or newTarget.charName == "Anivia" or newTarget.charName == "Zac" then
		return false
	end

	if newTarget.charName == "Kassadin" then
		damage = damage * .85
	end

	if newTarget.charName == "Poppy" then
		damage = damage * .5
	end

	local damageToNewTarget = (newTarget.health * healthModifier) + player:CalcMagicDamage(newTarget, damage)
	if newTarget.lastDfg and os.clock() - newTarget.lastDfg < 4 then
		damageToNewTarget = damageToNewTarget * 1.2
	end

	if newTarget.health - (newTarget.health * healthModifier) < damageToNewTarget then

		-- it would kill but damage is too low
		if newTarget.health < damageToNewTarget * .49 then
			return false
		end

		if oldTarget ~= nil then
			-- blitzcrank case
			if newTarget.charName == "Blitzcrank" and damageToNewTarget < newTarget.health - (newTarget.health * healthModifier) + (newTarget.mana / 2) then
				return false
			end

			if newTarget.health > oldTarget.health then
				return true
			else
				return false
			end
		else
			return true
		end
	end

	return false
end

function BetterTargetLowHP(oldTarget, newTarget, damage)
	if oldTarget ~= nil then
		if HpLeftAfterShot(newTarget, damage) < 0 and HpLeftAfterShot(oldTarget, damage) > 0 then
			return true
		else
			if HpLeftAfterShot(oldTarget, damage) < HpLeftAfterShot(newTarget, damage) then
				return true
			else
				return false
			end
		end
	else
		return true
	end

end

function OtherTeam(target)
	return target.team ~= player.team
end

function StunSpell(spell)
	-- Talon
	if spell == "TalonShadowAssault" then return true end

	-- Lux
	if spell == "LuxLightBinding" then return true end

	-- Rengar
	if spell == "RengarR" then return true end

	-- Nunu
	if spell == "AbsoluteZero" then return true end

	-- Ryze
	if spell == "RunePrison" then return true end

	-- Lissandra
	if spell == "LissandraR" then return true end

	-- Katarina
	if spell == "KatarinaR" then return true end

	-- Malzahar
	if spell == "AlZaharNetherGrasp" then return true end

	-- Shen
	if spell == "ShenStandUnited" then return true end

	-- Swain
	if spell == "Crowstorm" then return true end

	-- Miss Fortune
	if spell == "MissFortuneBulletTime" then return true end

	-- Pantheon
	if spell == "Pantheon_Heartseeker" then return true end

	-- Caitlyn
	if spell == "CaitlynAceintheHole" then return true end

	-- Master Yi
	if spell == "Meditate" then return true end

	-- Galio
	if spell == "GalioIdolOfDurand" then return true end

	-- Other
	if spell == "FallenOne" then return true end
	if spell == "ReapTheWhirlwind" then return true end
	if spell == "InfiniteDuress" then return true end
	if spell == "gate" then return true end

	return false
end

function OnProcessSpell(object, spellProc)
	if object.type == "obj_AI_Hero" and player:GetDistance(object) < cageRange and OtherTeam(object) then
		if player:CanUseSpell(_E) == READY and StunSpell(spellProc.name) then
			local position = CagePosition(player, object, false)

			if position ~= nil then
				CastSpell(_E, position.x, position.z)
			end
		end

		if VConfig.debug then
			PrintChat(spellProc.name)
		end
	elseif false and VConfig.stunEnemiesAttackedByTurret and object.type == "obj_AI_Turret" and GetDistance(player, object) < cageRange then -- need rework
		local shouldStun = nil

		for i=0, heroManager.iCount, 1 do
			local enemy = heroManager:GetHero(i)

			if OtherTeam(enemy) and BetterTargetLowHP(lowestHero, enemy, Qdamage()) and GetDistance(player, enemy) < cageRange then
				shouldStun = enemy
			end

		end

		if shouldStun ~= nil then
			local position = CagePosition(player, shouldStun, true)

			if position ~= nil then
				CastSpell(_E, position.x, position.z)
			end
		end

	end
end

function Rdamage(target)
	return math.floor(target.ap * .8 + (player:GetSpellData(_R).level-1)*125 + 250 + player.ap * 1.2)
end

function Wdamage()
	return math.floor((player:GetSpellData(_W).level-1)*50 + 120 + player.ap)
end

function Qdamage()
	return math.floor((player:GetSpellData(_Q).level-1)*40 + 80 + player.ap * .6)
end

-- needed for quicksilver
local stash = false

function OnTick()
	if os.clock() < nextDelay then return end -- OnTick is called every 10-50 ms, we dont need that frequent

	if VConfig.antiStun and GetInventoryItemIsCastable(STASH) then
		if TargetHaveBuff("suppression", player) or TargetHaveBuff("fizzmarinerdoombomb", player) or stash then
			CastItem(STASH)
			stashDelay = nil
			return
		end
	end

	if TargetHaveBuff("zedulttargetmark", player) then
		stash = true
	end

	-- 1 hit enemy with R or harras
	local lowestHero = nil
	local lowestAfterW = nil
	local mostHpButWillDie = nil
	local mostDeathFireR = nil
	local mostDeathFireQ = nil

	for i=0, heroManager.iCount, 1 do
		local enemy = heroManager:GetHero(i)

		if OtherTeam(enemy) then
			if IsGoodTarget(enemy, qRange) then

				if player:CanUseSpell(_R) == READY then
					if IsBetterTargetThan(mostHpButWillDie, enemy, 0, Rdamage(enemy) * .93) then
						mostHpButWillDie = enemy
					elseif GetInventoryItemIsCastable(DFG, player) and IsBetterTargetThan(mostDeathFireR, enemy, 0.15, Rdamage(enemy) * 1.2 * .93) then -- deathfire grasp
						mostDeathFireR = enemy
					end
				end

				if player:CanUseSpell(_Q) == READY then
					if GetInventoryItemIsCastable(DFG, player) and IsBetterTargetThan(mostDeathFireQ, enemy, 0.15, Qdamage() * 1.2 * .93) then
						mostDeathFireQ = enemy
					elseif BetterTargetLowHP(lowestHero, enemy, Qdamage()) then
						lowestHero = enemy
					end
				end

				-- combo dg kill
				if GetInventoryItemIsCastable(DFG, player) then
					local cast = true

					local QREADY = (player:CanUseSpell(_Q) == READY)
					local EREADY = (player:CanUseSpell(_E) == READY)
					local WREADY = (player:CanUseSpell(_W) == READY and enemy.canMove ~= true)
					local RREADY = false

					local comboDamage = 0
					if QREADY then
						comboDamage = Qdamage()
					end

					if WREADY then
						comboDamage = comboDamage + Wdamage()
					end

					if not IsBetterTargetThan(nil, enemy, 0.15, comboDamage * 0.93) then
						RREADY = (player:CanUseSpell(_R) == READY)

						if not RREADY or not IsBetterTargetThan(nil, enemy, 0.15, (comboDamage + Rdamage(enemy)) * 0.93) then
							cast = false
						end
					end

					if cast then
						if WREADY then
							CastSpell(_W, enemy)
						end

						CastItem(DFG, enemy)
						enemy.lastDfg = os.clock()

						if QREADY then
							CastSpell(_Q, enemy)
						end

						if RREADY then
							CastSpell(_R, enemy)
						end

						return
					end

				end
			end

			-- shots with W stunned enemy
			if VConfig.autoW and player:CanUseSpell(_W) == READY and enemy.canMove ~= true and IsGoodTarget(enemy, wRange) then

				CastSpell(_W, enemy)
				return
			end
		end

	end

	-- kill enemy who have most hp but would died
	if VConfig.autoKill and mostHpButWillDie ~= nil then
		CastSpell(_R, mostHpButWillDie) -- cast spell
		return
	end

	-- deathfire kill
	if VConfig.deathFireKill then
		if mostDeathFireQ ~= nil then
			CastItem(DFG, mostDeathFireQ)
			mostDeathFireQ.lastDfg = os.clock()

			CastSpell(_Q, mostDeathFireQ)
			return
		elseif mostDeathFireR ~= nil then
			CastItem(DFG, mostDeathFireR)
			mostDeathFireR.lastDfg = os.clock()

			CastSpell(_R, mostDeathFireR)
			return
		end
	end

	-- harras
	if VConfig.autoQweakest and lowestHero ~= nil then
		CastSpell(_Q, lowestHero) -- cast spell
		return
	end

	if VConfig.autoSeraph and GetInventoryItemIsCastable(SERAPH) and player.health < player.maxHealth / 4 then
		CastItem(SERAPH)
		return
	end

	-- kill minions with Q
	
	
		if player:CanUseSpell(_Q) == READY and VConfig.qfarm then
			for i, minionObjectI in ipairs(myObjectsTable) do
				if objectIsValid(minionObjectI) then
					if minionObjectI.type == "obj_AI_Minion" and OtherTeam(minionObjectI) and player:GetDistance(minionObjectI) < qRange then
						local damage = player:CalcMagicDamage(minionObjectI, Qdamage())

							if minionObjectI.health < damage and minionObjectI.health > damage * .25 then
						CastSpell(_Q, minionObjectI) -- cast spell
						return
					end
				end
			else
				table.remove(myObjectsTable, i)
			end
		end
	end


	-- automatic potions
	if VConfig.autoPotions and player.health < player.maxHealth - 350 and not TargetHaveBuff("Recall", player) and not InFountain() then
		if GetInventoryItemIsCastable(CRYSTAL) and not TargetHaveBuff("ItemCrystalFlask", player) then
			CastItem(CRYSTAL)
			return
		elseif GetInventoryItemIsCastable(POTION) and not TargetHaveBuff("RegenerationPotion", player) then
			CastItem(POTION)
			return
		end
	end

	-- add delay
	nextDelay = os.clock() + 0.25

	-- automatic level up
	if VConfig.autoLevel then
		autoLevelSetSequence(levelUps)
		return
	end
end

function CagePosition(player, enemy, prediction)
	if IsGoodTarget(enemy, cageRange) and OtherTeam(enemy) then
		local enemyPred = nil

		if prediction == true then
			enemyPred = GetPredictionPos(enemy, 500)
		else
			enemyPred = enemy
		end

		-- calculation of cage position
		local a = (enemyPred.z - player.z) / (enemyPred.x - player.x)
		local b = player.z - a * player.x

		local pos = { }
		pos.x = player.x + 1
		pos.z = a * pos.x + b

		local plusX  = (GetDistance(player, enemyPred) - cageItselfRange + cageDiff) / GetDistance(player, pos)

		if GetDistance(enemyPred, pos) < GetDistance(enemyPred, player) then
			pos.x = player.x + plusX
		else
			pos.x = player.x - plusX
		end

		pos.z = a * pos.x + b
		pos.y = player.y

		return pos
	else
		return nil
	end
end

function OnWndMsg(msg, key)

	if VConfig.autoCage then
		local lowest = nil
		local lowPos = nil

		for i=0, heroManager.iCount, 1 do
			local enemy = heroManager:GetHero(i)
			local position = CagePosition(player, enemy, true)

			if position ~= nil and BetterTargetLowHP(lowest, enemy, Wdamage()) then
				lowPos = position
				lowest = enemy
			end
		end

		if lowest ~= nil and player:CanUseSpell(_E) == READY then
			CastSpell(_E, lowPos.x, lowPos.z)
		end

	end

end

drawDelay = os.clock()

function OnDraw()
	if not VConfig.debug or os.clock() < drawDelay then return end

	local lowest = nil
	local lowPos = nil
	for i=0, heroManager.iCount, 1 do
		local enemy = heroManager:GetHero(i)
		local position = CagePosition(player, enemy, true)

		if position ~= nil and BetterTargetLowHP(lowest, enemy, Wdamage()) then
			lowest = enemy
			lowPos = position
		end
	end

	if lowest ~= nil then
		DrawCircle(lowPos.x, lowPos.y, lowPos.z, cageItselfRange, 0xFF0000)
	end

	drawDelay = drawDelay + 0.5
end

PrintChat(" >> Auto Veigar by Lesiuk")