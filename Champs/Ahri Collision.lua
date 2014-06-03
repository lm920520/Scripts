--[[	Ahri Helper by HeX 1.3.2 VIP Prediction

Hot Keys:
	-Basic Combo: Space
	-Harass(Toggle): Z
	-Charm: C
Features:
	-Basic Combo: Items-> R-> E-> Q-> W-> R*2
	-Harass: Q
	-Use ulti in combo ON/OFF option in ingame menu.
	-Use E in combo ON/OFF option in ingame menu.
	-Mark killable target with a combo.
	-Target configuration, Press shift to configure.
	-Auto ignite and/or Ulti killable enemy ON/OFF option in ingame menu.
	-Item Support: DFG, Hextech Gunblade, Bligewater Cutlass, Blade of the Ruined King.
	-Basic orb walking ON/OFF option in ingame menu. It will follow your mouse so you can kite targets if you want.
	
Explanation of the marks:
	-Green circle: Marks the current target to which you will do the combo
	-Blue circle: Killed with a combo, if all the skills were available
	-Red circle: Killed using Items + Q + W + E + R + Ignite(if available)
	-2 Red circles: Killed using Items + Q + W + E + Ignite(if available)
	-3 Red circles: Killed using Q + W	
]]--

if myHero.charName ~= "Ahri" then return end
--[[	Settings	]]--
local rBuffer = 300 --Wont use R unless they are further than this.
--[[ Ranges	]]--
local qRange = 800
local wRange = 800
local eRange = 975
local rRange = 1000
--[[	Damage Calculation	]]--
local calculationenemy = 1
local killable = {}
--[[	Prediction	]]--
if VIP_USER then
	require "Collision"
	qp = TargetPredictionVIP(880, 1700, 0.25)
	ep = TargetPredictionVIP(975, 1600, 0.1)
	PrintChat("Ahri Helper - VIP Prediction Used")
else
	qp = TargetPrediction(880, 1.7, 250)
	ep = TargetPrediction(975, 1.6, 100)
	PrintChat("Ahri Helper - Basic Prediction Used")
end
--[[	Attacks	]]--
local lastBasicAttack = 0
local swing = 0
local startAttackSpeed = 0.625
local nextTick = 0
--[[	Items	]]--
local ignite = nil
local QREADY, WREADY, EREADY, RREADY = false, false, false, false
local BRKSlot, DFGSlot, HXGSlot, BWCSlot = nil, nil, nil, nil
local BRKREADY, DFGREADY, HXGREADY, BWCREADY = false, false, false, false

function OnLoad()
	PrintChat("<font color='#CCCCCC'> >> Ahri Helper 1.3.2 loaded! <<</font>")
	AHConfig = scriptConfig("AhriHelper", "Ahri Helper")
	AHConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	AHConfig:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, 90)
	AHConfig:addParam("Charm", "Charm", SCRIPT_PARAM_ONKEYDOWN, false, 67)
	AHConfig:addParam("useE", "Use E in combo", SCRIPT_PARAM_ONOFF, true)
	AHConfig:addParam("useR", "Use R in combo", SCRIPT_PARAM_ONOFF, true)
	AHConfig:addParam("mouseDash", "Dash to Mouse", SCRIPT_PARAM_ONOFF, true)
	AHConfig:addParam("movement", "Use basic orb walking", SCRIPT_PARAM_ONOFF, true)
	AHConfig:addParam("attacks", "Use Auto Attacks", SCRIPT_PARAM_ONOFF, true)
	AHConfig:addParam("autoignite", "Ignite when Killable", SCRIPT_PARAM_ONOFF, true)
	AHConfig:addParam("drawcirclesSelf", "Draw Circles - Self", SCRIPT_PARAM_ONOFF, false)
	AHConfig:addParam("drawcirclesEnemy", "Draw Circles - Enemy", SCRIPT_PARAM_ONOFF, true)
	AHConfig:permaShow("scriptActive")
	AHConfig:permaShow("Harass")
	
	ts = TargetSelector(TARGET_LOW_HP, wRange+100, DAMAGE_MAGIC)
	ts.name = "Ahri"
	AHConfig:addTS(ts)
	
	lastBasicAttack = os.clock()
	enemyMinions = minionManager(MINION_ENEMY, 1200, player)
	
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2
	end
end

function OnProcessSpell(unit, spell)
	if unit.isMe and (spell.name:find("Attack") ~= nil) then
		swing = 1
		lastBasicAttack = os.clock() 
	end
end 

function OnTick()
	ts:update()
	enemyMinions:update()
	enemyMinions = minionManager(MINION_ENEMY, 1200, player)
	
	AttackDelay = 1/(myHero.attackSpeed*startAttackSpeed)
	if swing == 1 and os.clock() > lastBasicAttack + AttackDelay then
		swing = 0
	end

	BRKSlot, DFGSlot, HXGSlot, BWCSlot = GetInventorySlotItem(3153), GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144)
	DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
	BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
	BRKREADY = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)

	if ts.target ~= nil then
		qPred = qp:GetPrediction(ts.target)
		ePred = ep:GetPrediction(ts.target)
	end
	if tick == nil or GetTickCount()-tick>=100 then
		tick = GetTickCount()
		DmgCalculation()
	end
	
	--[[	Auto Ignite	]]--
	if AHConfig.autoignite then    
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

	--[[	Harass	]]--
	if ts.target ~= nil and AHConfig.Harass then
		if qPred ~= nil and GetDistance(ts.target) < qRange then
			if VIP_USER and qp:GetHitChance(ts.target) > 0.5 then
				CastSpell(_Q, qPred.x, qPred.z)
			elseif not VIP_USER then
				CastSpell(_Q, qPred.x, qPred.z)
			end
		end
	end
	
	--[[	Charm	]]--
	if AHConfig.Charm then
		if EREADY and findClosestEnemy() ~= nil then
			ePred2 = ep:GetPrediction(findClosestEnemy())
			if ePred2 and GetDistance(ePred2) <= eRange then
				if VIP_USER and ep:GetHitChance(findClosestEnemy()) > 0.5 then
					local col = Collision(975, 1600, 0.1, 70)
					if not col:GetMinionCollision(myHero, ePred2) then
						CastSpell(_E, ePred2.x, ePred2.z)
					end
				elseif not VIP_USER then
					if not minionCollision(ePred2, 90, eRange) then
						CastSpell(_E, ePred2.x, ePred2.z)
					end
				end
			end
		end
	end

	--[[	Combo	]]--
	if ts.target ~= nil and AHConfig.scriptActive then
		--[[	Items	]]--
		if GetDistance(ts.target) < 600 then
			if DFGREADY then CastSpell(DFGSlot, ts.target) end
			if HXGREADY then CastSpell(HXGSlot, ts.target) end
			if BWCREADY then CastSpell(BWCSlot, ts.target) end
			if BRKREADY then CastSpell(BRKSlot, ts.target) end
		end
		--[[	Combo	]]--
		if RREADY and AHConfig.useR and GetDistance(ts.target) > rBuffer and GetDistance(ts.target) < rRange and not AHConfig.mouseDash then
			CastSpell(_R, ts.target.x, ts.target.z)
		elseif RREADY and AHConfig.useR and GetDistance(ts.target) < rRange and AHConfig.mouseDash then
			CastSpell(_R, mousePos.x, mousePos.z)
		end
		if EREADY and AHConfig.useE and ePred and GetDistance(ePred) <= eRange then
			if VIP_USER and ep:GetHitChance(ts.target) > 0.5 then
				local col = Collision(975, 1600, 0.1, 70)
				if not col:GetMinionCollision(myHero, ePred) then
					CastSpell(_E, ePred.x, ePred.z)
				end
			elseif not VIP_USER then
				if not minionCollision(ePred, 90, eRange) then
					CastSpell(_E, ePred.x, ePred.z)
				end
			end
		end
		if QREADY and qPred ~= nil and GetDistance(ts.target) < qRange then
			if VIP_USER and qp:GetHitChance(ts.target) > 0.5 then
				CastSpell(_Q, qPred.x, qPred.z)
			elseif not VIP_USER then
				CastSpell(_Q, qPred.x, qPred.z)
			end
		end
		if WREADY and GetDistance(ts.target) < wRange then
			CastSpell(_W)
		end
		--[[	Attacks	]]--
		if swing == 0 then
			if GetDistance(ts.target) < (myHero.range+100) and AHConfig.attacks then
				myHero:Attack(ts.target)
				nextTick = GetTickCount()
			end
		elseif swing == 1 then
			if AHConfig.movement and GetTickCount() > (nextTick + 250) then
				myHero:MoveTo(mousePos.x, mousePos.z)
			end
		end
	end
end

--[[
Explanation of the marks:
	-Green circle: Marks the current target to which you will do the combo
	-Blue circle: Killed with a combo, if all the skills were available
	-Red circle: Killed using Items + Q + W + E + R + Ignite(if available)
	-2 Red circles: Killed using Items + Q + W + E + Ignite(if available)
	-3 Red circles: Killed using Q + W	
]]
function DmgCalculation()
	local enemy = heroManager:GetHero(calculationenemy)
	if ValidTarget(enemy) then
		local ignitedamage, dfgdamage, hxgdamage, bwcdamage, brkdamage = 0, 0, 0, 0, 0
		local qdamage = getDmg("Q",enemy,myHero)
		local wdamage = getDmg("W",enemy,myHero)
		local edamage = getDmg("E",enemy,myHero)
		local rdamage = getDmg("R",enemy,myHero,1)
		local ignitedamage = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
		local dfgdamage = (DFGSlot and getDmg("DFG",enemy,myHero) or 0)
		local hxgdamage = (HXGSlot and getDmg("HXG",enemy,myHero) or 0)
		local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)
		local brkdamage = (BRKSlot and getDmg("RUINEDKING",enemy,myHero) or 0)
		local combo1 = qdamage + wdamage + edamage + rdamage
		local combo2 = 0
		local combo3 = 0
		local combo4 = 0
	if QREADY then
		combo2 = combo2 + qdamage
		combo3 = combo3 + qdamage
		combo4 = combo4 + qdamage
	end	
	if WREADY then
		combo2 = combo2 + wdamage
		combo3 = combo3 + wdamage
		combo4 = combo4 + wdamage
	end
	if EREADY then
		combo2 = combo2 + edamage
		combo3 = combo3 + edamage
	end
	if RREADY then
		combo2 = combo2 + rdamage
	end
	if DFGREADY then
		combo1 = combo1 + dfgdamage
		combo2 = combo2 + dfgdamage
		combo3 = combo3 + dfgdamage
	end
	if HXGREADY then
		combo1 = combo1 + hxgdamage
		combo2 = combo2 + hxgdamage
		combo3 = combo3 + hxgdamage
	end
	if BWCREADY then
		combo1 = combo1 + bwcdamage
		combo2 = combo2 + bwcdamage
		combo3 = combo3 + bwcdamage
	end
	if BRKREADY then
		combo1 = combo1 + brkdamage
		combo2 = combo2 + brkdamage
		combo3 = combo3 + brkdamage
	end
	if IREADY then
		combo1 = combo1 + ignitedamage
		combo2 = combo2 + ignitedamage
		combo3 = combo3 + ignitedamage
	end
	if combo4 >= enemy.health then killable[calculationenemy] = 4
		elseif combo3 >= enemy.health then killable[calculationenemy] = 3
		elseif combo2 >= enemy.health then killable[calculationenemy] = 2
		elseif combo1 >= enemy.health then killable[calculationenemy] = 1
		else killable[calculationenemy] = 0 end
	end
		if calculationenemy == 1 then calculationenemy = heroManager.iCount
			else calculationenemy = calculationenemy-1 
		end
end

function OnDraw()	
	if AHConfig.drawcirclesSelf and not myHero.dead then
		DrawCircle(myHero.x,myHero.y,myHero.z, qRange, 0x00FF00)
		DrawCircle(myHero.x,myHero.y,myHero.z, eRange, 0x00FFFF)
	end
	if ts.target ~= nil and AHConfig.drawcirclesEnemy then
		for j=0, 10 do
			DrawCircle(ts.target.x, ts.target.y, ts.target.z, 40 + j*1.5, 0x00FF00)
		end
	end
	for i=1, heroManager.iCount do
		local enemydraw = heroManager:GetHero(i)
		if ValidTarget(enemydraw) then
			if AHConfig.drawcirclesEnemy then
				if killable[i] == 1 then
					for e=0, 15 do
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + e*1.5, 0x0000FF)
					end
					elseif killable[i] == 2 then
					for e=0, 10 do
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + e*1.5, 0xFF0000)
					end
					elseif killable[i] == 3 then
					for e=0, 10 do
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + e*1.5, 0xFF0000)
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + e*1.5, 0xFF0000)
					end
					elseif killable[i] == 4 then
					for e=0, 10 do
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + e*1.5, 0xFF0000)
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + e*1.5, 0xFF0000)
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 140 + e*1.5, 0xFF0000)
					end
				end
			end
		end
	end
end

function findClosestEnemy()
	local closestEnemy = nil
	local currentEnemy = nil
	for i=1, heroManager.iCount do
		currentEnemy = heroManager:GetHero(i)
		if currentEnemy.team ~= myHero.team and not currentEnemy.dead and currentEnemy.visible then
			if closestEnemy == nil then
				closestEnemy = currentEnemy
				elseif GetDistance(currentEnemy) < GetDistance(closestEnemy) then
					closestEnemy = currentEnemy
			end
		end
	end
return closestEnemy
end

function minionCollision(predic, width, range)
	for _, minionObjectE in pairs(enemyMinions.objects) do
		if predic ~= nil and player:GetDistance(minionObjectE) < range then
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
			mx = minionObjectE.x
			mz = minionObjectE.z
			distanc = (math.abs(mz - m*mx - c))/(math.sqrt(m*m+1))
			if distanc < width and math.sqrt((tx - ex)*(tx - ex) + (tz - ez)*(tz - ez)) > math.sqrt((tx - mx)*(tx - mx) + (tz - mz)*(tz - mz)) then
				return true
			end
		end
	end
return false
end