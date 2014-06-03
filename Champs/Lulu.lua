--[[
	Lulu Pix-Glitterlance Combo 2.1
		by eXtragoZ

	Press spacebar to hit the enemy

	1?? The script searches for TargetSelector target in range of E to do E -> Q
	2?? The script searches for the closest enemy in range of Q from you or pix to do Q
	3?? The script searches for the closest creep or ally to the enemy in the range of Q and in the range of E from you to do E (creep or ally) -> Q

	Features:
		- Full combo: E -> Q
		- The circle indicates the range of E
		- Draws the how the script will use the Q
		- PredictionVIP for Q (if you dont are VIP the script will use the current position of the enemy)
		- Pix position check
		- Target configuration (only when the enemy is in E range)
		- Press shift to configure
]]
--MissileSpeed	"1400.0000"
--Lulu_Q_Mis.troy
--delay 250 + latency
if myHero.charName ~= "Lulu" then return end
--[[		Config		]]
local HK = 32
--[[		Code		]]
local range = 2000
local qrange = 925
local erange = 650 + 25
--
local objminionTable = {}
local minionnearenemy = {}
local minionnearenemydist = {}
local PixObj = nil
local lessdistance = qrange
local Qtarget = nil
local Qcastedfrom = nil
-- Active
local tsE
local qDelay = 0.25
local qSpeed = 1400
local wayPointManager = WayPointManager()
local targetPrediction2 = TargetPredictionVIP(10000, qSpeed, qDelay)
--
local ignite = nil
local DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LBSlot, IGSlot, LTSlot, BTSlot, STISlot, ROSlot, BRKSlot = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local QREADY, WREADY, EREADY, RREADY, DFGREADY, HXGREADY, BWCREADY, STIREADY, ROREADY, BRKREADY, IREADY = false, false, false, false, false, false, false, false, false, false, false
function OnLoad()
	LPGConfig = scriptConfig("Lulu Pix-Glitterlance Combo 2.1", "lulupixglitterlance")
	LPGConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, HK)
	LPGConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	tsE = TargetSelector(TARGET_LESS_CAST_PRIORITY,erange,DAMAGE_PHYSICAL)
	tsE.name = "Lulu"
	LPGConfig:addTS(tsE)
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
	LPGLoadMinions()
	PrintChat(" >> Lulu Pix-Glitterlance Combo 2.1 loaded!")
end
function OnTick()
	tsE:update()
	DFGSlot, HXGSlot, BWCSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144)
	SheenSlot, TrinitySlot, LBSlot = GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
	IGSlot, LTSlot, BTSlot = GetInventorySlotItem(3025), GetInventorySlotItem(3151), GetInventorySlotItem(3188)
	STISlot, ROSlot, BRKSlot = GetInventorySlotItem(3092),GetInventorySlotItem(3143),GetInventorySlotItem(3153)
	QREADY = myHero:CanUseSpell(_Q) == READY
	WREADY = myHero:CanUseSpell(_W) == READY
	EREADY = myHero:CanUseSpell(_E) == READY
	RREADY = myHero:CanUseSpell(_R) == READY
	DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
	BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
	STIREADY = (STISlot ~= nil and myHero:CanUseSpell(STISlot) == READY)
	ROREADY = (ROSlot ~= nil and myHero:CanUseSpell(ROSlot) == READY)
	BRKREADY = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	local qcast = false
	local ecast = false
	for e=1, heroManager.iCount do
		minionnearenemy[e] = nil
		minionnearenemydist[e] = qrange
	end
	lessdistance = qrange
	Qtarget = nil
	Qcastedfrom = nil
	if not myHero.dead then	
		for i,object in ipairs(objminionTable) do
			if object and not object.dead and object.visible and object.name ~= "RobotBuddy" and GetDistance(object) <= erange then
				local edamage = getDmg("E",object,myHero)
				if myHero.team == object.team or object.health > edamage*1.1  then
					for e=1, heroManager.iCount do
						local enemy = heroManager:GetHero(e)
						if ValidTarget(enemy, range) then
							local distanceenemy = GetDistance(enemy,object)
							if distanceenemy <= minionnearenemydist[e] then
								minionnearenemy[e] = object
								minionnearenemydist[e] = distanceenemy
							end
						end
					end
				end
			end
		end
		for i=1, heroManager.iCount do
			local teammate = heroManager:GetHero(i)
			if ValidTarget(teammate, erange, false) then
				for e=1, heroManager.iCount do
					local enemy = heroManager:GetHero(e)
					if ValidTarget(enemy, range) then
						local distanceenemy = GetDistance(teammate,enemy)
						if distanceenemy <= minionnearenemydist[e] then
							minionnearenemy[e] = teammate
							minionnearenemydist[e] = distanceenemy
						end
					end
				end
			end
		end
		for i=1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if ValidTarget(enemy) then
				if PixObj then
					local distancePixenemy = GetDistance(PixObj,enemy)
					if distancePixenemy <= lessdistance then
						lessdistance = distancePixenemy
						Qtarget = enemy
						Qcastedfrom = PixObj
					end
				end
				local distanceenemy = GetDistance(enemy)
				if distanceenemy <= lessdistance then
					lessdistance = distanceenemy
					Qtarget = enemy
					Qcastedfrom = myHero
				end
			end
		end
		if LPGConfig.scriptActive then
			if tsE.target ~= nil then
				local distancetstarget = GetDistance(tsE.target)
				if DFGREADY and distancetstarget<=500 then CastSpell(DFGSlot, tsE.target) end
				if HXGREADY and distancetstarget<=500 then CastSpell(HXGSlot, tsE.target) end
				if BWCREADY and distancetstarget<=500 then CastSpell(BWCSlot, tsE.target) end
				if BRKREADY and distancetstarget<=500 then CastSpell(BRKSlot, tsE.target) end
				if STIREADY and distancetstarget<=380 then CastSpell(STISlot, myHero) end
				if ROREADY and distancetstarget<=500 then CastSpell(ROSlot) end
			end
			if tsE.target ~= nil and EREADY then
				CastSpell(_E, tsE.target)
				ecast = true
				if QREADY then
					if VIP_USER then
						local QPos, t = targetPrediction2:GetPrediction(tsE.target)
						if QPos then
							CastSpell(_Q, QPos.x, QPos.z)
							qcast = true
						end
					else
						CastSpell(_Q, tsE.target.x, tsE.target.z)
						qcast = true
					end
				end
			end
			if QREADY and not qcast and Qtarget then
				if VIP_USER then
					local QPos, t = targetPrediction2:GetPrediction(Qtarget)
					if QPos and GetDistance(Qcastedfrom,QPos) <= qrange then
						CastSpell(_Q, QPos.x, QPos.z)
						qcast = true
					end
				else
					CastSpell(_Q, Qtarget.x, Qtarget.z)
					qcast = true
				end
			end
			if QREADY and EREADY and not qcast and not ecast then
				for i=1, heroManager.iCount do
					local enemy = heroManager:GetHero(i)
					if minionnearenemy[i] and not qcast then
						if VIP_USER then
							local QPos, t = targetPrediction2:GetPrediction(enemy)
							if QPos then
								CastSpell(_E, minionnearenemy[i])
								CastSpell(_Q, QPos.x, QPos.z)
								qcast = true
							end
						else
							CastSpell(_E, minionnearenemy[i])
							CastSpell(_Q, enemy.x, enemy.z)
							qcast = true
						end
					end
				end
			end
		end
	end
end
function OnDraw()
	if LPGConfig.drawcircles and not myHero.dead then
		DrawCircle(myHero.x, myHero.y, myHero.z, erange, 0x992D3D)
		if QREADY then
			if Qcastedfrom then
				local maxdistposq = Qcastedfrom + (Vector(Qtarget) - Qcastedfrom):normalized()*qrange
				DrawLineBorder3D(Qcastedfrom.x, Qcastedfrom.y, Qcastedfrom.z, maxdistposq.x, maxdistposq.y, maxdistposq.z, 40*2, ARGB(255,0,255,255), 1)
			elseif EREADY then
				for i=1, heroManager.iCount do
					local enemy = heroManager:GetHero(i)
					if minionnearenemy[i] then
						local maxdistposq = minionnearenemy[i] + (Vector(enemy) - minionnearenemy[i]):normalized()*qrange
						DrawLineBorder3D(minionnearenemy[i].x, minionnearenemy[i].y, minionnearenemy[i].z, maxdistposq.x, maxdistposq.y, maxdistposq.z, 40*2, ARGB(255,0,255,255), 1)
					end
				end
			end
		end
	end
end
function OnCreateObj(object)
	if object and object.type == "obj_AI_Minion" then
		if object.name:find("T200") or object.name:find("Red") or object.name:find("T100") or object.name:find("Blue") then
			table.insert(objminionTable, object)
		end
	end
	if object and object.type == "obj_AI_Minion" and object.name == "RobotBuddy" then
		PixObj = object
	end
end
function OnDeleteObj(object)
	for i,v in ipairs(objminionTable) do
		if not v.valid or object.name:find(v.name) then
			table.remove(objminionTable,i)
		end
	end
	if object and object.type == "obj_AI_Minion" and object.name == "RobotBuddy" then
		PixObj = nil
	end
end
function LPGLoadMinions()
	for i=1, objManager.maxObjects do
		local object = objManager:getObject(i)
		if object and object.type == "obj_AI_Minion" and not object.dead then
			table.insert(objminionTable, object)
		end
		if object and object.type == "obj_AI_Minion" and object.name == "RobotBuddy" then
			PixObj = object
		end
	end
end