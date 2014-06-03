--[[	Tristana Helper by HeX 1.2.1

Hotkeys:
	-Basic Combo: Space
	-Harass(Toggle): Z
	-Auto Jump(Toggle): X
	-Auto Ult(Toggle): C
	-Jump Ult Combo: G

Features:
	-Basic Combo: Items-> W-> E-> Q-> R(If killable)
	-Harass: E
	-Jump Ult Combo: W(behind target)-> R
	-Use ultimate in combo ON/OFF option in ingame menu.
	-Auto Ignite in combo ON/OFF option in ingame menu.
	-Item Support: Blade of the Ruined King, Bligewater Cutlass, Deathfire Grasp, Hextech Gunblade.
	
Explanation of the marks:
	-Green circle: Marks the current target to which you will do the combo
	-Blue circle: Killed with a combo, if all the skills were available
	-Red circle: Killed using Items + 2 Hits + W + E + R + Ignite(if available)
	-2 Red circles: Killed using Items + 1 Hit + W + E + Ignite(if available)
	-3 Red circles: Killed using R	
]]

if myHero.charName ~= "Tristana" then return end
--[[	Settings	]]--
local jumpBuffer = 200 --Distance behind target you will jump, Jump Ult combo. 200 by Default.
local rDelay = 300 --Delay before using ultimate in Jump Combo. 300 by Default.
local MinMana = 40 --Minimum amount of mana you need to use Q in combo(Percent) 40% by Default.
--[[	Ranges	]]--
local Arange = 0
local Wrange = 900
local Erange = 0
local Rrange = 700
local Crange = 600
--[[	Prediction	]]--
local wSpeed = 1.5
local travelDuration = 0
local ts
--[[	Jump Combo	]]--
local jumpTick = 0
local jumpDelay = 0
local eUsed = false
--[[	Attacks	]]--
local nextTick = 0
local lastBasicAttack = 0
local startAttackSpeed = 0.625
local swing = 0
--[[	Damage Calculation	]]--
local calculationenemy = 1
local killable = {}
--[[	Items	]]--
local ignite = nil
local QREADY, WREADY, EREADY, RREADY  = false, false, false, false
local DFGREADY, BRKREADY, HXGREADY, BWCREADY = false, false, false, false
local DFGSlot, BRKSlot, HXGSlot, BWCSlot = nil, nil, nil, nil

function OnLoad()
	PrintChat("<font color='#CCCCCC'> >> Tristana Helper 1.2.1 loaded! <<</font>")
	THConfig = scriptConfig("Tristana Helper", "TristanaHelper")
	THConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	THConfig:addParam("ultCombo", "Jump Ult Combo", SCRIPT_PARAM_ONKEYDOWN, false, 71)
	THConfig:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, 90)
	THConfig:addParam("autojump", "Jump when Killable", SCRIPT_PARAM_ONKEYTOGGLE, true, 88)
	THConfig:addParam("autoult", "Ult when Killable", SCRIPT_PARAM_ONKEYTOGGLE, true, 67)
	THConfig:addParam("autoignite", "Ignite when Killable", SCRIPT_PARAM_ONOFF, true)
	THConfig:addParam("useR", "Use Ultimate in Combo", SCRIPT_PARAM_ONOFF, true)
	THConfig:addParam("movement", "Basic Orb Walking", SCRIPT_PARAM_ONOFF, true)
	THConfig:addParam("drawcirclesSelf", "Draw Circles - Self", SCRIPT_PARAM_ONOFF, false)
	THConfig:addParam("drawcirclesEnemy", "Draw Circles - Enemy", SCRIPT_PARAM_ONOFF, false)
	THConfig:permaShow("scriptActive")
	THConfig:permaShow("ultCombo")
	THConfig:permaShow("Harass")
	THConfig:permaShow("autojump")
--	THConfig:permaShow("autoult")
	
	ts = TargetSelector(TARGET_LOW_HP, Crange+150, DAMAGE_MAGIC)
	ts.name = "Tristana"
	THConfig:addTS(ts)
	
	Arange = 550 + ((myHero.level-1) * 9)
	Erange = 625 + ((myHero.level-1) * 9)
	
	lastBasicAttack = os.clock()
	
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
	Arange = 550 + ((myHero.level-1) * 9)
	Erange = 625 + ((myHero.level-1) * 9)

	AttackDelay = 1/(myHero.attackSpeed*startAttackSpeed)
	if swing == 1 and os.clock() > lastBasicAttack + AttackDelay then
		swing = 0
	end
	
	if tick == nil or GetTickCount()-tick>=100 then
		tick = GetTickCount()
		DmgCalculation()
	end
	
	if ts.target ~= nil then
		RDMG = getDmg("R",ts.target,myHero)
	end
	
	DFGSlot, BRKSlot, HXGSlot, BWCSlot = GetInventorySlotItem(3153), GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144)
	DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	BRKREADY = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
	HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
	BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)

	--[[	Auto Ignite	]]--
	if THConfig.autoignite then    
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
	
	if ts.target ~= nil and not myHero.dead then
		travelDuration = GetDistance(ts.target, myHero)/wSpeed
		jumpDelay = travelDuration
	end	
	if ts.target ~= nil and WREADY and travelDuration ~= nil then 
		predic = GetPredictionPos(ts.target, travelDuration) 
	end 

	--[[	Auto Jump	]]--
	if THConfig.autojump and WREADY then
		for i = 1, heroManager.iCount, 1 do
			local Target = heroManager:getHero(i)
			local wDamage = getDmg("W",Target,myHero)
			if Target ~= nil and not myHero.dead then
				travelDuration = GetDistance(Target, myHero)/wSpeed
				jumpDelay = travelDuration
				predic = GetPredictionPos(Target, travelDuration) 
			end	 
			if predic ~= nil and ValidTarget(Target, Wrange) and Target.health < wDamage then
				CastSpell(_W, predic.x, predic.z)
			end
		end
	end
	
	--[[	Ult Combo	]]--
	if ts.target ~= nil and THConfig.ultCombo then
		local tickCount = GetTickCount()
		if predic ~= nil then
			TargetPos = Vector(predic.x, predic.y, predic.z)
			MyPos = Vector(myHero.x, myHero.y, myHero.z)
			JumpPos = TargetPos + (TargetPos-MyPos)*((jumpBuffer/GetDistance(ts.target)))
		end
		if JumpPos ~= nil and WREADY and GetDistance(JumpPos) < Wrange and not ts.target.dead and GetTickCount() > jumpTick and RREADY then
			CastSpell(_W, JumpPos.x, JumpPos.z)
			jumpTick = GetTickCount() + jumpDelay
			eUsed = true
		end
		if not WREADY and RREADY and GetTickCount() > (jumpTick + rDelay) and eUsed == true then
			CastSpell(_R, ts.target)
			eUsed = false
		end
	end

	--[[	Auto Ult	]]--
	if THConfig.autoult and RREADY then
		for i = 1, heroManager.iCount, 1 do
			local Target = heroManager:getHero(i)
			local rDamage = getDmg("R",Target,myHero)
			if ValidTarget(Target, Rrange) and Target.health < rDamage then
				CastSpell(_R, Target)
			end
		end
	end
	
	--[[	Harass	]]--
	if ts.target ~= nil and THConfig.Harass  then
		if EREADY and GetDistance(ts.target) < Erange then
			CastSpell(_E, ts.target)
		end
	end  

	--[[	Basic Combo	]]--
	if ts.target ~= nil and THConfig.scriptActive and not ts.target.dead then
		--[[	Items	]]--
		if GetDistance(ts.target) < Crange then
			if DFGREADY then CastSpell(DFGSlot, ts.target) end
			if BRKREADY then CastSpell(BRKSlot, ts.target) end
			if HXGREADY then CastSpell(HXGSlot, ts.target) end
			if BWCREADY then CastSpell(BWCSlot, ts.target) end
		end
		--[[	Abilities	]]--
		if predic ~= nil and WREADY and GetDistance(predic) < Wrange then
			CastSpell(_W, predic.x, predic.z)
		end
		if THConfig.useR and RREADY and GetDistance(ts.target) < Rrange and ts.target.health < RDMG then
			CastSpell(_R, ts.target)
		end
	--[[	Attacks	]]--
		local tick = GetTickCount()
		if swing == 0 then
			if GetDistance(ts.target) < Arange and GetTickCount() > nextTick then
				myHero:Attack(ts.target)
				nextTick = GetTickCount()
			end
			elseif swing == 1 then
			if QREADY and GetDistance(ts.target) < Arange and MinMana <= ((myHero.mana/myHero.maxMana)*100) then
				CastSpell(_Q)
			end
			if EREADY and GetDistance(ts.target) < Erange and GetTickCount() > (nextTick + 225) then
				CastSpell(_E, ts.target)
				swing = 0
			end
			if THConfig.movement and GetTickCount() > (nextTick + 250) then
				myHero:MoveTo(mousePos.x, mousePos.z)
			end
		end
	end
end

--[[
Explanation of the marks:
	-Green circle: Marks the current target to which you will do the combo
	-Blue circle: Killed with a combo, if all the skills were available
	-Red circle: Killed using Items + 2 Hits + W + E + R + Ignite(if available)
	-2 Red circles: Killed using Items + 1 Hit + W + E + Ignite(if available)
	-3 Red circles: Killed using R	
]]
function DmgCalculation()
	local enemy = heroManager:GetHero(calculationenemy)
	if ValidTarget(enemy) then
		local ignitedamage, dfgdamage, hxgdamage, bwcdamage, brkdamage = 0, 0, 0, 0, 0
		local wdamage = getDmg("W",enemy,myHero)
		local edamage = getDmg("E",enemy,myHero)
		local rdamage = getDmg("R",enemy,myHero,1)
		local hitdamage = getDmg("AD",enemy,myHero)
		local ignitedamage = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
		local dfgdamage = (DFGSlot and getDmg("DFG",enemy,myHero) or 0)
		local hxgdamage = (HXGSlot and getDmg("HXG",enemy,myHero) or 0)
		local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)
		local brkdamage = (BRKSlot and getDmg("RUINEDKING",enemy,myHero) or 0)
		local combo1 = hitdamage*2 + wdamage + edamage + rdamage
		local combo2 = hitdamage*2 
		local combo3 = hitdamage*1
		local combo4 = 0
	if WREADY then
		combo2 = combo2 + wdamage
		combo3 = combo3 + wdamage
	end
	if EREADY then
		combo2 = combo2 + edamage
		combo3 = combo3 + edamage
	end
	if RREADY then
		combo2 = combo2 + rdamage
		combo4 = combo4 + rdamage
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
	if THConfig.drawcirclesSelf and not myHero.dead then
		DrawCircle(myHero.x, myHero.y, myHero.z, Wrange, 0x00FF00)
		DrawCircle(myHero.x, myHero.y, myHero.z, Erange, 0x00FFFF)
	end
	if ts.target ~= nil and THConfig.drawcirclesEnemy then
		for j=0, 10 do
			DrawCircle(ts.target.x, ts.target.y, ts.target.z, 40 + j*1.5, 0x00FF00)
		end
	end
	for i=1, heroManager.iCount do
		local enemydraw = heroManager:GetHero(i)
		if ValidTarget(enemydraw) then
			if THConfig.drawcirclesEnemy then
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