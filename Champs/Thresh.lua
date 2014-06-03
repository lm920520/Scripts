if myHero.charName ~= "Thresh" then return end

--[[
	Thresh: Does Your Chain Hang Low?
	by: Tux
--]]

local qRange = 1075
local eRange = 500
local rRadius = 450
local qWidth = 180
local summonerRange = 600
local enemyPos
local ts = TargetSelector(TARGET_LOW_HP, 1200, DAMAGE_PHYSICAL, true)

function OnLoad()
	MinionMarkerOnLoad()
	enemyMinions = minionManager(MINION_ENEMY, 1200, player)
    ThreshConfig = scriptConfig("Chain Warden", "Thresh")
    ThreshConfig:addParam("Pull", "Pull with Flay", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("E"))
    ThreshConfig:addParam("Push", "Push with Flay", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	ThreshConfig:addParam("Hook", "Pull with Chain", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Q"))
	ThreshConfig:addParam("Escape", "Box > Push Flay to Escape", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
	ThreshConfig:addParam("AExhaust", "Use Exhaust on Flay", SCRIPT_PARAM_ONOFF, false)
	ThreshConfig:addParam("Box", "Auto Ultimate", SCRIPT_PARAM_ONOFF, false)
	ThreshConfig:addParam("Ignite", "Ignite Killable Target", SCRIPT_PARAM_ONOFF, false)
	ThreshConfig:addParam("Marker", "Minion Marker", SCRIPT_PARAM_ONOFF, false)
	ThreshConfig:addParam("DoubleIgnite", "Don't Double Ignite", SCRIPT_PARAM_ONOFF, true)
    ThreshConfig:addParam("DrawAssist", "Draw Circles/Lines", SCRIPT_PARAM_ONOFF, true)
	ThreshConfig:addParam("BoxCount", "Enemy Count before Using Ulti", SCRIPT_PARAM_SLICE, 3, 0, 5, 0)
	ThreshConfig:addParam("BoxRange", "Use Auto Ult at this range", SCRIPT_PARAM_SLICE, 400, 0, 450, 0)
	ThreshConfig:permaShow("Box")
	ThreshConfig:permaShow("AExhaust")
    ts.name = "Thresh"
    ThreshConfig:addTS(ts)
    PrintChat(">> Thresh - Does Your Chain Hang Low? v1.0 <<")
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ign = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ign = SUMMONER_2
		else ign = nil
	end
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerExhaust") then exhaust = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerExhaust") then exhaust = SUMMONER_2
		else exhaust = nil
	end
end

function willHitMinion(predic, width)
	local hitCount = 0
	for _, minionObjectQ in pairs(enemyMinions.objects) do
		 if minionObjectQ ~= nil and string.find(minionObjectQ.name,"Minion_") == 1 and minionObjectQ.team ~= player.team and minionObjectQ.dead == false then
			 if predic ~= nil and player:GetDistance(minionObjectQ) < qRange then
				 ex = player.x
				 ez = player.z
				 tx = predic.x
				 tz = predic.z
				 dx = ex - tx
				 dz = ez - tz
				 if dx ~= 0 then
				 m = dz/dx
				 c = ez - m*ex
				 end
				 mx = minionObjectQ.x
				 mz = minionObjectQ.z
				 dis = (math.abs(mz - m*mx - c))/(math.sqrt(m*m+1))
				 if dis < width and math.sqrt((tx - ex)*(tx - ex) + (tz - ez)*(tz - ez)) > math.sqrt((tx - mx)*(tx - mx) + (tz - mz)*(tz - mz)) then
					hitCount = hitCount + 1
					if hitCount > 1 then
						return true
					end
				 end
			 end
		 end
	 end
	 return false
end

function OnCreateObj(obj)
	if ThreshConfig.Marker then
		MinionMarkerOnCreateObj(obj)
	end
end

function CanCast(Spell)
    return (player:CanUseSpell(Spell) == READY)
end

function IReady()
	if ign ~= nil then
		return (player:CanUseSpell(ign) == READY)
	end
end

function ExhaustReady()
	if exhaust ~= nil then
		return (player:CanUseSpell(exhaust) == READY)
	end
end

function OnTick()
	ts:update()
	enemyMinions:update()
	if ts.target ~= nil then
		if ThreshConfig.Escape then BoxEscape() end
		if ThreshConfig.Hook then Hook() end
		if ThreshConfig.Pull then FlayPull() end
		if ThreshConfig.Push then FlayPush() end
		if ThreshConfig.Box then AutoBox() end
		if ThreshConfig.Ignite and ign ~= nil then AutoIgnite() end
	end
end

function OnDraw()
	if ThreshConfig.DrawAssist and not myHero.dead then
		if CanCast(_Q) then
			DrawCircle(myHero.x,myHero.y,myHero.z,1075,0xFFFF0000)
			DrawCircle(myHero.x,myHero.y,myHero.z,1075,0xFFFF0000)
		end
		if CanCast(_E) then
			DrawCircle(myHero.x,myHero.y,myHero.z,500,0xFFFF0000)
			DrawCircle(myHero.x,myHero.y,myHero.z,500,0xFFFF0000)
		end
		if ValidTarget(ts.target, qRange) and CanCast(_Q) then
			local enemyPos = ts.nextPosition
			if enemyPos ~= nil then
				local x1, y1, OnScreen1 = get2DFrom3D(myHero.x, myHero.y, myHero.z)
				local x2, y2, OnScreen2 = get2DFrom3D(enemyPos.x, enemyPos.y, enemyPos.z)
				DrawLine(x1, y1, x2, y2, 3, 0xFFFF0000)
			end
		end
	end
	if ThreshConfig.Marker then
		MinionMarkerOnDraw()
	end
end

--[[
	Combat
--]]

function getPred(speed, delay, target)
	if target == nil then return nil end
	local travelDuration = (delay + GetDistance(myHero, target)/speed)
	travelDuration = (delay + GetDistance(GetPredictionPos(target, travelDuration))/speed)
	travelDuration = (delay + GetDistance(GetPredictionPos(target, travelDuration))/speed)
	travelDuration = (delay + GetDistance(GetPredictionPos(target, travelDuration))/speed) 	
	return GetPredictionPos(target, travelDuration)
end

function Hook()
	local qPred = getPred(1.9, 0.5, ts.target)
	if ValidTarget(ts.target, qRange)and qPred ~= nil and CanCast(_Q) and not willHitMinion(qPred, qWidth) then
		CastSpell(_Q, qPred.x, qPred.z)
	end
end

function FlayPull()
	if ThreshConfig.AExhaust then AutoExhaust() end
	if ValidTarget(ts.target, eRange) and CanCast(_E) then
		xPos = myHero.x + (myHero.x - ts.target.x)
		zPos = myHero.z + (myHero.z - ts.target.z)
		CastSpell(_E, xPos, zPos)
	end
end

function FlayPush()
	if ValidTarget(ts.target, eRange) and CanCast(_E) then
		CastSpell(_E, ts.target.x, ts.target.z)
	end
end

function AutoBox()
	if ThreshConfig.Box then
		if CanCast(_R) and CountEnemyHeroInRange(ThreshConfig.BoxRange) >= ThreshConfig.BoxCount then
			CastSpell(_R)
		end
	end
end

function BoxEscape()
	local qPred = getPred(1.2, 0.5, ts.target)
	if ValidTarget(ts.target, ThreshConfig.BoxRange) and CanCast(_R) then
		CastSpell(_R)
		if ValidTarget(ts.target, eRange) and CanCast(_E) then
			CastSpell(_E, ts.target.x, ts.target.z)
		end
	end
end	

function AutoIgnite()
	local iDmg = 0		
	if IReady and not myHero.dead then
		for i = 1, heroManager.iCount, 1 do
			local target = heroManager:getHero(i)
			if ValidTarget(target) then
				iDmg = 50 + 20 * myHero.level
				if target ~= nil and target.team ~= myHero.team and not target.dead and target.visible and GetDistance(target) < summonerRange and target.health < iDmg then
					if ThreshConfig.DoubleIgnite and not TargetHaveBuff("SummonerDot", target) then
						CastSpell(ign, target)
						elseif not ThreshConfig.DoubleIgnite then
							CastSpell(ign, target)
					end
				end
			end
		end
	end
end

function AutoExhaust()
	if ExhaustReady and not myHero.dead then
		if ValidTarget(ts.target, summonerRange) then
			CastSpell(exhaust, ts.target)
		end
	end
end

--[[
	Simple Minion Marker
	by: Kilua
--]]

function MinionMarkerOnLoad()
	minionTable = {}
	for i = 0, objManager.maxObjects do
		local obj = objManager:GetObject(i)
		if obj ~= nil and obj.type ~= nil and obj.type == "obj_AI_Minion" then 
			table.insert(minionTable, obj) 
		end
	end
end

function MinionMarkerOnDraw() 
	for i,minionObject in ipairs(minionTable) do
		if minionObject.valid and (minionObject.dead == true or minionObject.team == myHero.team) then
			table.remove(minionTable, i)
			i = i - 1
		elseif minionObject.valid and minionObject ~= nil and myHero:GetDistance(minionObject) ~= nil and myHero:GetDistance(minionObject) < 1500 and minionObject.health ~= nil and minionObject.health <= myHero:CalcDamage(minionObject, myHero.addDamage+myHero.damage) and minionObject.visible ~= nil and minionObject.visible == true then
			for g = 0, 6 do
				DrawCircle(minionObject.x, minionObject.y, minionObject.z,80 + g,255255255)
			end
        end
    end
end

function MinionMarkerOnCreateObj(object)
	if object ~= nil and object.type ~= nil and object.type == "obj_AI_Minion" then table.insert(minionTable, object) end
end