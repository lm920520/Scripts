--[[ Ultimate Lee Sin 2.0 by HeX]]--

if myHero.charName ~= "LeeSin" then return end

--[[	Variables	]]--
--[[	Ranges	]]--
local qRange = 975
local qWidth = 75 -- Increase if Q is hitting creep with collision ON.
local wRange = 700
local eRange = 425
local eBuffer = 275
local rRange = 375
--[[	Draw	]]--
local waittxt = {}
local floattext = {"Skills on cooldown.","Killable","Easy kill","Ultimate him!"}
local killable = {}
local calculationenemy = 1
--[[	Ready	]]--
local ignite = nil
local BRKSlot, DFGSlot, HXGSlot, BWCSlot, TMTSlot, RAHSlot, RNDSlot, YGBSlot = nil, nil, nil, nil, nil, nil, nil, nil
local QREADY, WREADY, EREADY, RREADY, IREADY = false, false, false, false, false
--[	[Q Prediction	]]--
local rCast = false
local qp = TargetPrediction(qRange, 1.5, 250)
--[[	Auto Attacks	]]--
local lastBasicAttack = 0
local swingDelay = 0.25
local swing = 0
--[[	Q Dodge	]]--
local qDelay = nil
local qCast = false
local dodgeMinion = nil
local dodgeHero = nil
local wDelay = 0
local qMultiplier = 1.1 --Increase if Q-Shield combo is too fast
--[[	Ward Jump	]]--
local WardTable = {}
local SWard, VWard, SStone, RSStone, Wriggles = 2044, 2043, 2049, 2045, 3154
local SWardSlot, VWardSlot, SStoneSlot, RSStoneSlot, WrigglesSlot = nil, nil, nil, nil, nil
local jumpReady = false
local jumpRange = 540
local wardRange = 600
local jumpDelay = 0

function OnLoad()
	Menu()
end

--[[======================================Tick/Combo======================================]]--
function OnTick()
	ts:update()
	allyMinions:update()
	enemyMinions:update()
	Checks()
	
--[[	Ultimate Close	]]--
	if LeeSinConfig.rClose then
		ClosestUlt()
	end
	
--[[	Auto Ultimate	]]--
 	if not myHero.dead and LeeSinConfig.autoult then
		AutoUlt()
	end
	
--[[	Q Dodge	]]--
	if LeeSinConfig.qDodge and ts.target ~= nil then
		DodgeBall()
	end
	
--[[	Basic Combo	]]--
	if LeeSinConfig.scriptActive and ts.target ~= nil then
		UseItems(ts.target)
		BasicCombo(ts.target)
	end
	
--[[	Quick Jump	]]--
--	if LeeSinConfig.quickJump then
--		QuickJump()
--	end
	
--[[	Ignite	]]--
	if LeeSinConfig.autoignite then    
		AutoIgnite()
	end
	
--[[	Ward Jump	]]--
	if jumpReady == true then
		JumpReady()
	end
	if LeeSinConfig.wardjump then
		JumpCheck()
	end
end

function OnDraw()
	Draw()
end

--[	[DONT GO BELOW THIS LINE	]]--
function OnCreateObj(object)
  if WardCheck(object) then table.insert(WardTable, object) end
end

function OnProcessSpell(unit, spell)
	if unit.isMe and (spell.name:find("Attack") ~= nil) then
		swing = 1
		lastBasicAttack = os.clock()
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

function findFurthestMinion()
	local FurthestMinion = nil
	local currentMinion = nil
	for _, minion in pairs(allyMinions.objects) do
		currentMinion = minion
		if FurthestMinion == nil then
			FurthestMinion = currentMinion
		elseif GetDistance(currentMinion) > GetDistance(FurthestMinion) then
			FurthestMinion = currentMinion
		end
	end
return FurthestMinion
end

--[[	Combo Functions	]]--
function AutoUlt() 
	if RREADY then
		local rDmg = 0    
		for i = 1, heroManager.iCount, 1 do
			local enemyhero = heroManager:getHero(i)
			if ValidTarget(enemyhero, (rRange+50)) then
				rDmg = getDmg("R", enemyhero, myHero)
				if enemyhero.health <= rDmg then
					CastSpell(_R, enemyhero)
				end
			end
		end
	end
end

function ClosestUlt()
	findClosestEnemy()
	if RREADY and findClosestEnemy() ~= nil and GetDistance(findClosestEnemy()) <= (rRange) then
		CastSpell(_R, findClosestEnemy())
	end
end

function BasicCombo(target)
	if predic ~= nil and QREADY and GetDistance(predic) <= qRange and myHero:GetSpellData(_Q).name == "BlindMonkQOne" then
		if not minionCollision(predic, qWidth, qRange) then
			CastSpell(_Q, predic.x, predic.z)
		end
	end
	if GetDistance(target) <= 1100 and QREADY and not rCast then
		CastSpell(_Q)
	elseif QREADY and GetDistance(target) <= 1100 and LeeSinConfig.useUlti and rCast then
		CastSpell(_Q)
	end
	if swing == 0 and GetDistance(target) <= eRange then
		myHero:Attack(target)
		if EREADY and GetDistance(target) <= eBuffer and myHero:GetSpellData(_E).name == "blindmonketwo" then
			CastSpell(_E)
		end
	elseif swing == 1 then
		if EREADY and GetDistance(target) <= eBuffer and myHero:GetSpellData(_E).name == "BlindMonkEOne" then
			CastSpell(_E)
			myHero:Attack(target)
		end
	end
	if EREADY and GetDistance(target) >= eRange and myHero:GetSpellData(_E).name == "blindmonketwo" then
		CastSpell(_E)
		myHero:Attack(target)
	end
	if RREADY and GetDistance(target) <= rRange and LeeSinConfig.useUlti and QREADY then
		CastSpell(_R, target)
		rCast = true
	end
end

function DodgeBall()
--	Setting
	for i=1, heroManager.iCount do
		local allytarget = heroManager:GetHero(i)
		if allytarget.team == myHero.team and not allytarget.dead and GetDistance(allytarget, targetPosition) < 750 and allytarget.charName ~= myHero.charName then
			dodgeHero = allytarget
		end
	end

	dodgeMinion = findFurthestMinion()
--	Cast
	if predic ~= nil and QREADY and GetDistance(predic) <= qRange and myHero:GetSpellData(_Q).name == "BlindMonkQOne" then
		if not minionCollision(predic, qWidth, qRange) then
			CastSpell(_Q, predic.x, predic.z)
		end
	end
	if (dodgeMinion ~= nil and dodgeMinion ~= dead) or (dodgeHero ~= nil and dodgeHero ~= dead) then
		if GetDistance(ts.target) <= 1100 and myHero:GetSpellData(_Q).name == "blindmonkqtwo" and WREADY then
			CastSpell(_Q)
			qCast = true
			qDelay = os.clock()
			wDelay = ((GetDistance(predic)/1600) * qMultiplier)
		end
		
		if qCast == true and not QREADY and dodgeMinion ~= nil and GetDistance(dodgeMinion, ts.target) < 750 then
			if os.clock() - qDelay > wDelay then
				CastSpell(_W, dodgeMinion)
				qCast = false
			end
		elseif qCast == true and not QREADY and dodgeHero ~= nil then
			if os.clock() - qDelay > wDelay then
				CastSpell(_W, dodgeHero)
				qCast = false
			end
		end
	end
end

--[[	Ward Jump	]]--
function WardCheck(object)
	return object and object.valid and (string.find(object.name, "Ward") ~= nil or string.find(object.name, "Wriggle") ~= nil)
end

function JumpReady()
	if jumpReady == true then
		for i,object in ipairs(WardTable) do
			if object ~= nil and object.valid and math.sqrt((object.x-mousePos.x)^2+(object.z-mousePos.z)^2) < 150 then
				CastSpell(_W, object)
				jumpReady = false
			end
   end
	end
end

function JumpCheck()
	local x = mousePos.x
	local z = mousePos.z
	local dx = x - player.x
	local dz = z - player.z
	local rad1 = math.atan2(dz, dx)
	
	SWardSlot = GetInventorySlotItem(SWard)
	VWardSlot = GetInventorySlotItem(VWard)
	SStoneSlot = GetInventorySlotItem(SStone) 
	RSStoneSlot = GetInventorySlotItem(RSStone)
	WrigglesSlot = GetInventorySlotItem(Wriggles)

	if RSStoneSlot ~= nil and CanUseSpell(RSStoneSlot) == READY then
		wardSlot = RSStoneSlot 
	elseif SStoneSlot ~= nil and CanUseSpell(SStoneSlot) == READY then
		wardSlot = SStoneSlot 
	elseif SWardSlot ~= nil then
		wardSlot = SWardSlot 
	elseif VWardSlot ~= nil then
		wardSlot = VWardSlot 
	elseif WrigglesSlot ~= nil then
		wardSlot = WrigglesSlot 
	else wardSlot = nil
	end

	if wardSlot ~= nil then
		local dx1 = jumpRange*math.cos(rad1)
		local dz1 = jumpRange*math.sin(rad1)
		local x1 = x - dx1
		local z1 = z - dz1
		if WREADY and math.sqrt(dx*dx + dz*dz) <= 600 then
			CastSpell( wardSlot, x, z )
			jumpReady = true
		elseif WREADY then player:MoveTo(x1, z1) 
			else myHero:StopPosition() 
		end
	end
end

--[[	Auto Ignite	]]--
function AutoIgnite() 
	if IREADY then
		local ignitedmg = 0    
		for i = 1, heroManager.iCount, 1 do
			local enemyhero = heroManager:getHero(i)
			if ValidTarget(enemyhero, 600) then
				ignitedmg = 50 + 20 * myHero.level
				if enemyhero.health <= ignitedmg then
					CastSpell(ignite, enemyhero)
				end
			end
		end
	end
end

--[[	Ready and Items	]]--
function Checks()
	BRKSlot, DFGSlot, HXGSlot, BWCSlot, TMTSlot, RAHSlot, RNDSlot, YGBSlot = GetInventorySlotItem(3153), GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3077), GetInventorySlotItem(3074),  GetInventorySlotItem(3143), GetInventorySlotItem(3142)
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
	BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
	BRKREADY = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
	TMTREADY = (TMTSlot ~= nil and myHero:CanUseSpell(TMTSlot) == READY)
	RAHREADY = (RAHSlot ~= nil and myHero:CanUseSpell(RAHSlot) == READY)
	RNDREADY = (RNDSlot ~= nil and myHero:CanUseSpell(RNDSlot) == READY)
	YGBREADY = (YGBSlot ~= nil and myHero:CanUseSpell(YGBSlot) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	
	if tick == nil or GetTickCount()-tick>=200 then
		tick = GetTickCount()
		SCDmgCalculation()
	end
	if swing == 1 and os.clock() > lastBasicAttack + 0.4 then
		swing = 0
	end
	if ts.target ~= nil then
		predic = qp:GetPrediction(ts.target)
	end
end
	
function UseItems(target)
	if GetDistance(target) < 550 then
		if DFGREADY then CastSpell(DFGSlot, target) end
		if HXGREADY then CastSpell(HXGSlot, target) end
		if BWCREADY then CastSpell(BWCSlot, target) end
		if BRKREADY then CastSpell(BRKSlot, target) end
		if YGBREADY then CastSpell(YGBSlot, target) end
		if TMTREADY and GetDistance(target) < 275 then CastSpell(TMTSlot) end
		if RAHREADY and GetDistance(target) < 275 then CastSpell(RAHSlot) end
		if RNDREADY and GetDistance(target) < 275 then CastSpell(RNDSlot) end
	end
end

--[[	Base Functions	]]--
function Menu()
	PrintChat("<font color='#CCCCCC'> >> Ultimate Lee Sin 2.0 loaded! <<</font>")
	LeeSinConfig = scriptConfig("LeeSin Config", "LeeSincombo")
	LeeSinConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	LeeSinConfig:addParam("wardjump", "Ward Jump", SCRIPT_PARAM_ONKEYDOWN, false, 71)
	LeeSinConfig:addParam("qDodge", "Jump Shield Combo", SCRIPT_PARAM_ONKEYDOWN, false, 84)
	--LeeSinConfig:addParam("quickJump", "Quick Jump", SCRIPT_PARAM_ONKEYDOWN, false, 90)
	LeeSinConfig:addParam("rClose", "Ult Closest Enemy", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	LeeSinConfig:addParam("useUlti", "Use Ult in combo", SCRIPT_PARAM_ONOFF, false)
	LeeSinConfig:addParam("drawcirclesEnemy", "DrawCircles - Enemies", SCRIPT_PARAM_ONOFF, false)
	LeeSinConfig:addParam("drawcirclesSelf", "DrawCircles - Self", SCRIPT_PARAM_ONOFF, false)
	LeeSinConfig:addParam("drawtext", "DrawText - Enemies", SCRIPT_PARAM_ONOFF, true)
	LeeSinConfig:addParam("autoult", "Ult when killable", SCRIPT_PARAM_ONOFF, false)
	LeeSinConfig:addParam("autoignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
	LeeSinConfig:permaShow("scriptActive")
	LeeSinConfig:permaShow("wardjump")
	LeeSinConfig:permaShow("qDodge")
	--LeeSinConfig:permaShow("quickJump")
	LeeSinConfig:permaShow("autoult")
	
	ts = TargetSelector(TARGET_LOW_HP,1250,DAMAGE_PHYSICAL)
	ts.name = "LeeSin"
	LeeSinConfig:addTS(ts)
	
	enemyMinions = minionManager(MINION_ENEMY, 1200, player)
	allyMinions = minionManager(MINION_ALLY, 1000, player)
	
	for i = 0, objManager.maxObjects, 1 do
		local object = objManager:GetObject(i)
			if WardCheck(object) then table.insert(WardTable, object) end
  end	

	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2
	end
	for i=1, heroManager.iCount do waittxt[i] = i*3 end
end

function Draw()
	if LeeSinConfig.wardjump and not myHero.dead then
		DrawCircle(myHero.x, myHero.y, myHero.z, wRange, 0x0000FF)
	end
	if LeeSinConfig.drawcirclesSelf and not myHero.dead then
		DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0xCCFF33)
		DrawCircle(myHero.x, myHero.y, myHero.z, rRange, 0xFF0000)
		DrawCircle(myHero.x, myHero.y, myHero.z, wRange, 0x0000FF)
	end
	if ts.target ~= nil and LeeSinConfig.drawcirclesEnemy then
		for e=0, 10 do
			DrawCircle(ts.target.x, ts.target.y, ts.target.z, 40 + e*1.5, 0x00FF00)
		end
	end
	for i=1, heroManager.iCount do
		local enemydraw = heroManager:GetHero(i)
		if ValidTarget(enemydraw) then
			if LeeSinConfig.drawcirclesEnemy then
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
			if LeeSinConfig.drawtext and waittxt[i] == 1 and killable[i] ~= 0 then
				PrintFloatText(enemydraw,0,floattext[killable[i]])
			end
		end
		if waittxt[i] == 1 then waittxt[i] = 30
			else waittxt[i] = waittxt[i]-1 
		end
	end
end

function SCDmgCalculation()
	local enemy = heroManager:GetHero(calculationenemy)
	if ValidTarget(enemy) then
		local ignitedamage, bwcdamage, brkdamage = 0, 0, 0
		local qdamage = getDmg("Q",enemy,myHero)
		local edamage = getDmg("E",enemy,myHero)
		local rdamage = getDmg("R",enemy,myHero,1)
		local hitdamage = getDmg("AD",enemy,myHero)
		local ignitedamage = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
		local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)
		local brkdamage = (BRKSlot and getDmg("RUINEDKING",enemy,myHero) or 0)
		local combo1 = hitdamage*2 + qdamage + edamage + rdamage
		local combo2 = hitdamage*2 
		local combo3 = hitdamage*1
		local combo4 = 0
	if QREADY then
		combo2 = combo2 + qdamage
		combo3 = combo3 + qdamage
		end
	if EREADY then
		combo2 = combo2 + edamage
	end
	if RREADY then
		combo2 = combo2 + rdamage
		combo4 = combo4 + rdamage
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