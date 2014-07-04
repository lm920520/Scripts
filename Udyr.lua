--[[
Udyr -Spirit Guard- Combo
by burn

Credits: HeX (stun cycle), Manciuszz & eXtragoZ (for their Auto TS Priority Arranger, AutoSmitee & Predator Vision & Simple OrbWalking)

Features:
*Auto Ignite
*Auto Smite
*Predator vision
*Auto TS Priority Arranger
*Auto potions
*Auto cast Items
*Auto level up
*OrbWalking in combo

Combos: -dynamic, according to the spells you have leveled-
*E-AA-Q-AA-R-AAx4-W (Max Damage - proc 2x R flames)
*E-AA-R-AAx4-W
*E-AA-Q-AA-W
*Q-AA-R-AAx4-W
*E-AA-Q-AA-R-AAx4
*R-AAx4-W
*E-AA-Q
*Q or R
*extra: Stun Cycle --]]
if myHero.charName ~= "Udyr" then return end
--[[ Config ]]--
local levelSequence = {4,2,4,3,4,2,4,2,4,2,2,3,1,3,3,3,1,1} --Trick2g Phoenix jungle style
--[[ CODE ]]--
local UdyrConfig, ts
local lastAttack = GetTickCount()
local walkDistance = 300
local lastWindUpTime = 0
local lastAttackCD = 0
local lastAnimation = ""
local ignite = nil
local stunTarget = nil
local lastCast = "none"
local AAcount = 0
local lastNameTarget = myHero.name
local priorityTable = {
	AP = {
		"Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
		"Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
		"Rumble", "Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra", "MasterYi",
	},
	Support = {
		"Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Sona", "Soraka", "Thresh", "Zilean",
	},
	Tank = {
		"Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Shen", "Singed", "Skarner", "Volibear",
		"Warwick", "Yorick", "Zac", "Nunu", "Taric", "Alistar",
	},
	AD_Carry = {
		"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "KogMaw", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
		"Talon", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Zed",
	},
	Bruiser = {
		"Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nautilus", "Nocturne", "Olaf", "Poppy",
		"Renekton", "Rengar", "Riven", "Shyvana", "Trundle", "Tryndamere", "Udyr", "Vi", "MonkeyKing", "XinZhao", "Aatrox"
	},
}
local minionVisionRange = 1250
local heroVisionRange = 1450
local storedminions = {}
local useDebug = false
--Auto Smite vars
local range = 800
local smiteSlot = nil
local smiteDamage = 0
local canusesmite = false
local Vilemaw,Nashor,Dragon,Golem1,Golem2,Lizard1,Lizard2 = nil,nil,nil,nil,nil,nil,nil

function OnLoad()
	UdyrConfig = scriptConfig("Udyr Combo", "UdyrCombo")
	UdyrConfig:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	UdyrConfig:addParam("StunCycle", "Stun Cycle press C", SCRIPT_PARAM_ONKEYDOWN, false, 67) --c
	UdyrConfig:addParam("drawCircles", "Draw circles", SCRIPT_PARAM_ONOFF, true)
	UdyrConfig:addParam("autoignite", "Auto Ignite killable", SCRIPT_PARAM_ONOFF, true)
	UdyrConfig:addParam("autoTS", "Auto Arrenge TS priority", SCRIPT_PARAM_ONOFF, true)
	UdyrConfig:addParam("autoPotions", "Use potions when HP < 60%", SCRIPT_PARAM_ONOFF, true)
	UdyrConfig:addParam("PredatorVision", "Toggle X for use Predator Vision", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("X"))
	UdyrConfig:addParam("autoLevel", "Auto level spells", SCRIPT_PARAM_ONOFF, false)
	UdyrConfig:addParam("moveToMouse", "Move to Mouse", SCRIPT_PARAM_ONOFF, false)
	UdyrConfig:addParam("AutoSmiteInfo", "--- Auto Smite Settings ---", SCRIPT_PARAM_INFO)
	UdyrConfig:addParam("EnableAutoSmite", "Enable AutoSmite (Turn On/Off)", SCRIPT_PARAM_ONOFF, true)
	UdyrConfig:addParam("UseAutoSmite", "Use AutoSmite", SCRIPT_PARAM_ONOFF, true)
	UdyrConfig:addParam("TempStopStartAutoSmite", "Press Ctrl to temporarily stop/start AS", SCRIPT_PARAM_ONKEYDOWN, false, 17) --Ctrl
	UdyrConfig:addParam("smiteRange", "Draw Smite Range", SCRIPT_PARAM_ONOFF, true)
	UdyrConfig:addParam("drawAStext", "Draw Remaining %HP monsters", SCRIPT_PARAM_ONOFF, true)
	UdyrConfig:permaShow("Combo")
	UdyrConfig:permaShow("StunCycle")
	UdyrConfig:permaShow("PredatorVision")
	UdyrConfig:permaShow("UseAutoSmite")
	ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 600, DAMAGE_PHYSICAL, false)
	ts.name = "Udyr"
	UdyrConfig:addTS(ts)
	PrintChat(">> Udyr -Spirit Guard- Combo v1.3 loaded!")
	if UdyrConfig.autoTS then
		if #GetEnemyHeroes() > 1 then
			TargetSelector(TARGET_LESS_CAST_PRIORITY, 0)
			arrangePrioritys(#GetEnemyHeroes())
		end
	end
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
	--Predator Vision
	LoadMinions()
	--Auto Smite Check
	if myHero:GetSpellData(SUMMONER_1).name:find("Smite") then smiteSlot = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("Smite") then smiteSlot = SUMMONER_2 end
	if smiteSlot ~= nil then ASLoadMinions() end
end

function OnProcessSpell(object, spell)
	if myHero.dead then return end
	if object.isMe then
		if spell.name:lower():find("attack") then
			lastAttack = GetTickCount() - GetLatency()/2
			lastWindUpTime = spell.windUpTime*1000
			lastAttackCD = spell.animationTime*1000
			AAcount = AAcount + 1
		end
	end
end

function OnAnimation(unit,animationName)
	if myHero.dead then return end
	if unit.isMe and lastAnimation ~= animationName then lastAnimation = animationName end
end

function OnTick()
	ts:SetDamages((40*GetSpellData(_R).level+.25*myHero.ap), myHero.totalDamage,0)
	ts:update()
	if myHero.dead then return end
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)

	--[[ Auto Level ]]--
	if UdyrConfig.autoLevel then
		autoLevelSetSequence(levelSequence)
	end

	--[[ Move to Mouse ]]--
	if UdyrConfig.moveToMouse and ts.target == nil and UdyrConfig.Combo then
		myHero:MoveTo(mousePos.x, mousePos.z)
	end

	--[[ Auto Smite ]]--
	if smiteSlot ~= nil then
		UdyrConfig.UseAutoSmite = ((UdyrConfig.EnableAutoSmite and not UdyrConfig.TempStopStartAutoSmite) or (not UdyrConfig.EnableAutoSmite and UdyrConfig.TempStopStartAutoSmite))
		if UdyrConfig.UseAutoSmite then
			checkDeadMonsters()
			smiteDamage = 460+30*myHero.level
			canusesmite = (myHero:CanUseSpell(smiteSlot) == READY)
			if canusesmite then
				if Vilemaw ~= nil then checkMonster(Vilemaw) end
				if Nashor ~= nil then checkMonster(Nashor) end
				if Dragon ~= nil then checkMonster(Dragon) end
				if Golem1 ~= nil then checkMonster(Golem1) end
				if Golem2 ~= nil then checkMonster(Golem2) end
				if Lizard1 ~= nil then checkMonster(Lizard1) end
				if Lizard2 ~= nil then checkMonster(Lizard2) end
			end
		end
	end

	--[[ Auto Potions ]]--
	if UdyrConfig.autoPotions then
		if tickPotions == nil or (GetTickCount() - tickPotions > 1000) then
			PotionSlot = GetInventorySlotItem(2003)
			if PotionSlot ~= nil then --we have potions
				if myHero.health/myHero.maxHealth < 0.60 and not TargetHaveBuff("RegenerationPotion", myHero) and not InFountain() then
					CastSpell(PotionSlot)
				end
			end
			tickPotions = GetTickCount()
		end
	end

	--[[ Ignite ]]--
	if UdyrConfig.autoignite then
		if IREADY then
			local ignitedmg = 0
			for i = 1, heroManager.iCount, 1 do
				local enemyhero = heroManager:getHero(i)
				if ValidTarget(enemyhero,600) then
					ignitedmg = 50 + 20 * myHero.level
					if enemyhero.health <= ignitedmg then
						CastSpell(ignite, enemyhero)
					end
				end
			end
		end
	end

	--[[ Reset AA Count ]]--
	if ts.target ~= nil then
		if ts.target.name ~= lastNameTarget then
			lastNameTarget = ts.target.name
			AAcount = 0
			lastCast = "none"
		end
	else
		AAcount = 0
		lastCast = "none"
	end

	--[[ Combo ]]--
	if UdyrConfig.Combo and ts.target ~= nil then
		if GetInventoryItemIsCastable(3128) then CastSpell(GetInventorySlotItem(3128), ts.target) end
		if GetInventoryItemIsCastable(3146) then CastSpell(GetInventorySlotItem(3146), ts.target) end
		if GetInventoryItemIsCastable(3144) then CastSpell(GetInventorySlotItem(3144), ts.target) end
		if GetInventoryItemIsCastable(3153) then CastSpell(GetInventorySlotItem(3153), ts.target) end
		if GetInventoryItemIsCastable(3131) and GetDistance(ts.target) < 350 then CastSpell(GetInventorySlotItem(3131)) end
		if GetInventoryItemIsCastable(3077) and GetDistance(ts.target) < 350 then CastSpell(GetInventorySlotItem(3077)) end
		if GetInventoryItemIsCastable(3074) and GetDistance(ts.target) < 350 then CastSpell(GetInventorySlotItem(3074)) end
		if GetInventoryItemIsCastable(3143) and GetDistance(ts.target) < 350 then CastSpell(GetInventorySlotItem(3143)) end
		--We have E-Q-R-W
		if myHero:GetSpellData(_Q).level >= 1 and myHero:GetSpellData(_W).level >= 1 and myHero:GetSpellData(_E).level >= 1 and myHero:GetSpellData(_R).level >= 1 then
			if EREADY and CheckForBearStun(ts.target) == false then
				CastSpell(_E)
				lastCast = "E"
				AAcount = 0
			elseif (CheckForBearStun(ts.target) == true and QREADY) and (lastCast == "E" or lastCast == "none" or lastCast == "W") and AAcount >= 1 then
				CastSpell(_Q)
				lastCast = "Q"
				AAcount = 0
			elseif (CheckForBearStun(ts.target) == true and RREADY) and lastCast == "Q" and AAcount >= 1 then
				CastSpell(_R)
				lastCast = "R"
				AAcount = 0
			elseif (CheckForBearStun(ts.target) == true and WREADY) and lastCast == "R" and AAcount >= 4 then
				CastSpell(_W)
				lastCast = "W"
				AAcount = 0
			end
			OrbWalk()
		--We have E-R-W
		elseif myHero:GetSpellData(_W).level >= 1 and myHero:GetSpellData(_E).level >= 1 and myHero:GetSpellData(_R).level >= 1 and myHero:GetSpellData(_Q).level == 0 then
			if EREADY and CheckForBearStun(ts.target) == false then
				CastSpell(_E)
				lastCast = "E"
				AAcount = 0
			elseif (CheckForBearStun(ts.target) == true and RREADY) and (lastCast == "E" or lastCast == "none" or lastCast == "W") and AAcount >= 1 then
				CastSpell(_R)
				lastCast = "R"
				AAcount = 0
			elseif (CheckForBearStun(ts.target) == true and WREADY) and lastCast == "R" and AAcount >= 4 then
				CastSpell(_W)
				lastCast = "W"
				AAcount = 0
			end
			OrbWalk()
		--We have E-Q-W
		elseif myHero:GetSpellData(_W).level >= 1 and myHero:GetSpellData(_E).level >= 1 and myHero:GetSpellData(_Q).level >= 1 and myHero:GetSpellData(_R).level == 0 then
			if EREADY and CheckForBearStun(ts.target) == false then
				CastSpell(_E)
				lastCast = "E"
				AAcount = 0
			elseif (CheckForBearStun(ts.target) == true and QREADY) and (lastCast == "E" or lastCast == "none" or lastCast == "W") and AAcount >= 1 then
				CastSpell(_Q)
				lastCast = "Q"
				AAcount = 0
			elseif (CheckForBearStun(ts.target) == true and WREADY) and lastCast == "Q" and AAcount >= 1 then
				CastSpell(_W)
				lastCast = "W"
				AAcount = 0
			end
			OrbWalk()
		--We have Q-W-R
		elseif myHero:GetSpellData(_W).level >= 1 and myHero:GetSpellData(_E).level == 0 and myHero:GetSpellData(_Q).level >= 1 and myHero:GetSpellData(_R).level >= 1 then
			if QREADY and ((lastCast == "R" and AAcount >= 4) or lastCast == "none") then
				CastSpell(_Q)
				lastCast = "Q"
				AAcount = 0
			elseif WREADY and lastCast == "Q" and AAcount >= 1 then
				CastSpell(_W)
				lastCast = "W"
				AAcount = 0
			elseif RREADY and lastCast == "W" then
				CastSpell(_R)
				lastCast = "R"
				AAcount = 0
			end
			OrbWalk()
		--We have E-Q-R
		elseif myHero:GetSpellData(_W).level == 0 and myHero:GetSpellData(_E).level >=1 and myHero:GetSpellData(_Q).level >= 1 and myHero:GetSpellData(_R).level >= 1 then
			if EREADY and CheckForBearStun(ts.target) == false then
				CastSpell(_E)
				lastCast = "E"
				AAcount = 0
			elseif CheckForBearStun(ts.target) == true and QREADY and (((lastCast == "E" or lastCast == "none") and AAcount >= 1) or (lastCast == "R" and AAcount >= 4)) then
				CastSpell(_Q)
				lastCast = "Q"
				AAcount = 0
			elseif CheckForBearStun(ts.target) == true and RREADY and lastCast == "Q" and AAcount >= 1 then
				CastSpell(_R)
				lastCast = "R"
				AAcount = 0
			end
			OrbWalk()
		--We have R-W
		elseif myHero:GetSpellData(_W).level >= 1 and myHero:GetSpellData(_R).level >= 1 and myHero:GetSpellData(_Q).level == 0 and myHero:GetSpellData(_E).level == 0 then
			if RREADY and (lastCast == "none" or lastCast == "W") and AAcount >= 0 then
				CastSpell(_R)
				lastCast = "R"
				AAcount = 0
			elseif WREADY and lastCast == "R" and AAcount >= 4 then
				CastSpell(_W)
				lastCast = "W"
				AAcount = 0
			end
			OrbWalk()
		--We have E-Q
		elseif myHero:GetSpellData(_W).level == 0 and myHero:GetSpellData(_R).level == 0 and myHero:GetSpellData(_Q).level >= 1 and myHero:GetSpellData(_E).level >= 1 then
			if EREADY and CheckForBearStun(ts.target) == false then
				CastSpell(_E)
				lastCast = "E"
				AAcount = 0
			elseif CheckForBearStun(ts.target) == true and QREADY and (lastCast == "E" or lastCast == "none" or lastCast == "Q") and AAcount >= 1 then
				CastSpell(_Q)
				lastCast = "Q"
				AAcount = 0
			end
			OrbWalk()
		--We have Q or R
		elseif (myHero:GetSpellData(_Q).level >= 1 or myHero:GetSpellData(_R).level >= 1) and myHero:GetSpellData(_W).level == 0 and myHero:GetSpellData(_E).level == 0 then
			if QREADY and AAcount >= 0 then CastSpell(_Q) AAcount = 0 end
			if RREADY and AAcount >= 1 then CastSpell(_R) AAcount = 0 end
			OrbWalk()
		end
	end

	--[[ Stun Cycle ]]--
	if UdyrConfig.StunCycle then
		stunTarget = findClosestEnemy()
		if stunTarget ~= nil and GetDistance(stunTarget) <= 600 then
			if EREADY then
				CastSpell(_E)
				lastCast = "E"
			end
			myHero:Attack(stunTarget)
		end
	end
end

function OrbWalk()
	if not TargetHaveBuff("udyrbearstuncheck", ts.target) then
		myHero:Attack(ts.target)
	else
		if GetDistance(ts.target) <= myHero.range + 65 then
			if timeToShoot() then
				myHero:Attack(ts.target)
			elseif heroCanMove() then
				moveToCursor()
			end
		else
			myHero:Attack(ts.target)
		end
	end
end

function CheckForBearStun(target)
	--oldtarget = GetTarget()	
	SetTarget(target)	
	if TargetHaveBuff("udyrbearstuncheck", target) then
		--SetTarget(oldtarget)
		return true
	else
		--SetTarget(oldtarget)
		return false
	end
end

function findClosestEnemy()
	local closestEnemy = nil
	local currentEnemy = nil
	for i=1, heroManager.iCount do
		currentEnemy = heroManager:GetHero(i)
		if ValidTarget(currentEnemy, 600) and CheckForBearStun(currentEnemy) == false then
			if closestEnemy == nil then
				closestEnemy = currentEnemy
			elseif GetDistance(currentEnemy) < GetDistance(closestEnemy) then
				closestEnemy = currentEnemy
			end
		end
	end
	return closestEnemy
end

function heroCanMove()
	return (GetTickCount() + GetLatency()/2 > lastAttack + lastWindUpTime + 20)
end

function timeToShoot()
	return (GetTickCount() + GetLatency()/2 > lastAttack + lastAttackCD)
end

function moveToCursor()
	if GetDistance(mousePos) > 1 or lastAnimation == "Idle1" then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized()*walkDistance
		myHero:MoveTo(moveToPos.x, moveToPos.z)
	end
end

function OnDraw()
	if useDebug then
		DrawText("AutoAttack Count: "..AAcount,17,WINDOW_W - (WINDOW_W/3*2.45),WINDOW_H - (WINDOW_H/13.3),ARGB(0xFF,0xFF,0xF0,0x00))
		DrawText("Last Cast: "..lastCast,17,WINDOW_W - (WINDOW_W/3*2.45),WINDOW_H - (WINDOW_H/7.3),ARGB(0xFF,0xFF,0xF0,0x00))
		DrawText("Last Target Name: "..tostring(lastNameTarget),17,WINDOW_W - (WINDOW_W/3*2.45),WINDOW_H - (WINDOW_H/5.3),ARGB(0xFF,0xFF,0xF0,0x00))
		if ts.target ~= nil then
			if TargetHaveBuff("udyrbearstuncheck", ts.target) then
				DrawText("Enemy STUNNED Recently",17,WINDOW_W - (WINDOW_W/3*2.45),WINDOW_H - (WINDOW_H/9.3),ARGB(0xFF,0xFF,0xF0,0x00))
			else
				DrawText("Enemy NO stunned",17,WINDOW_W - (WINDOW_W/3*2.45),WINDOW_H - (WINDOW_H/9.3),ARGB(0xFF,0xFF,0xF0,0x00))
			end
		end
	end
	if not myHero.dead and UdyrConfig.drawCircles then
		if ts.target ~= nil then
			DrawCircle(ts.target.x, ts.target.y, ts.target.z, 150, 0x7A24DB)
		end
		DrawCircle(myHero.x, myHero.y, myHero.z, 600, 0xC2743C)
	end
	--predator vision
	if UdyrConfig.PredatorVision then
		DrawCircle(mousePos.x, mousePos.y, mousePos.z, 100, 0xFF00FF00)
		for i,obj in ipairs(storedminions) do --loop the table that minions are stored.
			if obj ~= nil then
				if (GetDistance(obj, mousePos) < 100) then
					if obj.team ~= myHero.team and obj.type == "obj_AI_Minion" and not obj.dead then -- If the enemy minion is not dead
						if GetDistance(obj,myHero) <= minionVisionRange then
							DrawCircle(obj.x, obj.y, obj.z, minionVisionRange, 0xFFFF0000) --IF MINION CAN SEE YOU, CHANGE THE COLOR to RED
						else
							DrawCircle(obj.x, obj.y, obj.z, minionVisionRange, 0xFF00FF00) --IF MINION CAN'T SEE YOU, CHANGE THE COLOR to GREEN
						end
					end
				end
			end
		end
		for i,hero in ipairs(GetEnemyHeroes()) do
			if hero ~= nil then
				if (GetDistance(hero, mousePos) < 100) then
					if hero.team ~= myHero.team and hero.type == "obj_AI_Hero" and not hero.dead then
						if GetDistance(hero,myHero) <= heroVisionRange then
							DrawCircle(hero.x, hero.y, hero.z, heroVisionRange, 0xFF00FF00)
						else
							DrawCircle(hero.x, hero.y, hero.z, heroVisionRange, 0xFF00FF00)
						end
					end
				end
			end
		end
	end
	--Auto Smite
	if smiteSlot ~= nil and UdyrConfig.UseAutoSmite and UdyrConfig.smiteRange and not myHero.dead then
		if canusesmite then DrawCircle(myHero.x, myHero.y, myHero.z, range, 0x992D3D) end
	end
	if not myHero.dead and (UdyrConfig.drawAStext or UdyrConfig.smiteRange) and smiteSlot ~= nil and UdyrConfig.UseAutoSmite then
		if Vilemaw ~= nil then MonsterDraw(Vilemaw) end
		if Nashor ~= nil then MonsterDraw(Nashor) end
		if Dragon ~= nil then MonsterDraw(Dragon) end
		if Golem1 ~= nil then MonsterDraw(Golem1) end
		if Golem2 ~= nil then MonsterDraw(Golem2) end
		if Lizard1 ~= nil then MonsterDraw(Lizard1) end
		if Lizard2 ~= nil then MonsterDraw(Lizard2) end
	end
end

function SetPriority(table, hero, priority)
	for i=1, #table, 1 do
		if hero.charName:find(table[i]) ~= nil then
			TS_SetHeroPriority(priority, hero.charName)
		end
	end
end

function arrangePrioritys(enemies)
	local priorityOrder = {
		[2] = {1,1,2,2,2},
		[3] = {1,1,2,3,3},
		[4] = {1,2,3,4,4},
		[5] = {1,2,3,4,5},
	}
	for i, enemy in ipairs(GetEnemyHeroes()) do
		SetPriority(priorityTable.AD_Carry, enemy, priorityOrder[enemies][1])
		SetPriority(priorityTable.AP,       enemy, priorityOrder[enemies][2])
		SetPriority(priorityTable.Support,  enemy, priorityOrder[enemies][3])
		SetPriority(priorityTable.Bruiser,  enemy, priorityOrder[enemies][4])
		SetPriority(priorityTable.Tank,     enemy, priorityOrder[enemies][5])
	end
end

function LoadMinions()
	for i = 1, objManager.maxObjects do
		local object = objManager:getObject(i)
		if object and object.team ~= myHero.team and object.type == "obj_AI_Minion" and not object.dead then
			table.insert(storedminions, object)
		end
	end
end

function OnCreateObj(obj)
	if obj and obj.type == "obj_AI_Minion" and (obj.name:find((myHero.team == TEAM_BLUE and "T200" or "T100")) or obj.name:find((myHero.team == TEAM_BLUE and "Red" or "Blue"))) then
		table.insert(storedminions, obj)
	end
	if obj ~= nil and obj.type == "obj_AI_Minion" and obj.name ~= nil and smiteSlot ~= nil then
		if obj.name == "TT_Spiderboss7.1.1" then Vilemaw = obj
		elseif obj.name == "Worm12.1.1" then Nashor = obj
		elseif obj.name == "Dragon6.1.1" then Dragon = obj
		elseif obj.name == "AncientGolem1.1.1" then Golem1 = obj
		elseif obj.name == "AncientGolem7.1.1" then Golem2 = obj
		elseif obj.name == "LizardElder4.1.1" then Lizard1 = obj
		elseif obj.name == "LizardElder10.1.1" then Lizard2 = obj end
	end
end

function OnDeleteObj(obj)
	for i,v in ipairs(storedminions) do
		if obj and obj.name:find(v.name) then
			table.remove(storedminions,i)
		end
	end
	if obj ~= nil and obj.name ~= nil and smiteSlot ~= nil then
		if obj.name == "TT_Spiderboss7.1.1" then Vilemaw = nil
		elseif obj.name == "Worm12.1.1" then Nashor = nil
		elseif obj.name == "Dragon6.1.1" then Dragon = nil
		elseif obj.name == "AncientGolem1.1.1" then Golem1 = nil
		elseif obj.name == "AncientGolem7.1.1" then Golem2 = nil
		elseif obj.name == "LizardElder4.1.1" then Lizard1 = nil
		elseif obj.name == "LizardElder10.1.1" then Lizard2 = nil end
	end
end

function checkDeadMonsters()
	if Vilemaw ~= nil and (not Vilemaw.valid or Vilemaw.dead or Vilemaw.health <= 0) then Vilemaw = nil end
	if Nashor ~= nil and (not Nashor.valid or Nashor.dead or Nashor.health <= 0) then Nashor = nil end
	if Dragon ~= nil and (not Dragon.valid or Dragon.dead or Dragon.health <= 0) then Dragon = nil end
	if Golem1 ~= nil and (not Golem1.valid or Golem1.dead or Golem1.health <= 0) then Golem1 = nil end
	if Golem2 ~= nil and (not Golem2.valid or Golem2.dead or Golem2.health <= 0) then Golem2 = nil end
	if Lizard1 ~= nil and (not Lizard1.valid or Lizard1.dead or Lizard1.health <= 0) then Lizard1 = nil end
	if Lizard2 ~= nil and (not Lizard2.valid or Lizard2.dead or Lizard2.health <= 0) then Lizard2 = nil end
end

function ASLoadMinions()
	for i = 1, objManager.maxObjects do
		local obj = objManager:getObject(i)
		if obj ~= nil and obj.type == "obj_AI_Minion" and obj.name ~= nil then
			if obj.name == "TT_Spiderboss7.1.1" then Vilemaw = obj
			elseif obj.name == "Worm12.1.1" then Nashor = obj
			elseif obj.name == "Dragon6.1.1" then Dragon = obj
			elseif obj.name == "AncientGolem1.1.1" then Golem1 = obj
			elseif obj.name == "AncientGolem7.1.1" then Golem2 = obj
			elseif obj.name == "LizardElder4.1.1" then Lizard1 = obj
			elseif obj.name == "LizardElder10.1.1" then Lizard2 = obj end
		end
	end
end

function checkMonster(object)
	if object ~= nil and not object.dead and object.visible and object.x ~= nil then
		if canusesmite and GetDistance(object) <= range and object.health <= smiteDamage then
			CastSpell(smiteSlot, object)
		end
	end
end

function MonsterDraw(object)
	if object ~= nil and not object.dead and object.visible and object.x ~= nil and smiteSlot ~= nil then
		if UdyrConfig.UseAutoSmite and UdyrConfig.smiteRange and canusesmite and GetDistance(object) <= range then
			local healthradius = object.health*100/object.maxHealth
			DrawCircle(object.x, object.y, object.z, healthradius+100, 0x00FF00)
			if canusesmite then
				local smitehealthradius = smiteDamage*100/object.maxHealth
				DrawCircle(object.x, object.y, object.z, smitehealthradius+100, 0x00FFFF)
			end
		end
		if UdyrConfig.drawAStext and GetDistance(object) <= range*2 then
			local wtsobject = WorldToScreen(D3DXVECTOR3(object.x,object.y,object.z))
			local objectX, objectY = wtsobject.x, wtsobject.y
			local onScreen = OnScreen(wtsobject.x, wtsobject.y)
			if onScreen then
				local statusdmgS = smiteDamage*100/object.health
				local statuscolorS = (canusesmite and 0xFF00FF00 or 0xFFFF0000)
				local textsizeS = statusdmgS < 100 and math.floor((statusdmgS/100)^2*20+8) or 28
				textsizeS = textsizeS > 16 and textsizeS or 16
				DrawText(string.format("%.1f", statusdmgS).."% - Smite", textsizeS, objectX-40, objectY+38, statuscolorS)
			end
		end
	end
end