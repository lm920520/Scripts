--[[
	Godly Shen beta by jbman
	based on eXtragoZ scripts
	
	Requires the AllClass and Spell Damage Library

	-Supports Deathfire Grasp, Bilgewater Cutlass, Hextech Gunblade, Sheen, Trinity, Lich Bane and Ignite
	-Mark killable target with a combo
	-Target configuration, Press shift to configure
	-Option to auto ignite when enemy is killable (this affect also for damage calculation)
	-Auto calculation for Ulti
	-Notification of when a ally needs an ult (currently @ 25%)
	-Option to auto ult or cast to ally nearest mouse
	-In built Melee Last hit
	-In built Q Last hit
	
	COMBOS/Keybinds
	X - E-Q-AA-W-AA-Q
	Z - Q-AA-W-AA-Q
	C -  Q-AA-Q
	O - Move and dash to cursor for escapes
	T - Toggle Auto ult will dactivate notification (I wait for notification, then decide if I want to activate or not, just in case your ally is an idiot and will get you both killed)
	Y - Ult @ cursor
	`(~) - Melee last hit when pressed
	F1 - Q last hit when held down
	[ & ] to increase Ult Percentage default = 20%
	- and + to increase ult range default is 18500 which will get you from top to bottom lane.  Max of 22100 will teleport from fountain to fountain.
	
	
	

	Explanation of the marks:

	Green circle: Marks the current target to which you will do the combo
	Blue circle: Mark a target that can be killed with a combo, if all the skills were available
	Red circle: Mark a target that can be killed using Items + 2 hit + R + E + Q x3 + ignite
	2 Red circles: Mark a target that can be killed using Items + 1 hit + R + E + Q x2 + ignite
	3 Red circles: Mark a target that can be killed using Items (without Sheen, Trinity and Lich Bane) + R + E + Q
	
	
	Shen Notes:
	Particles
	shen_kiStrike_ready_indicator
	shen_kiStrike_tar
	

	
]]


if myHero.charName ~= "Shen" then return end
require "AllClass"
require "spellDmg"

--[[	Melee Last Hit Stuff	]]
local mousemoving = true
local movedelay = 0
local unitScanDelay = 200
local waitDelay = 300
local scanAdditionalRange = 500
local QunitScanDelay = 100
local QwaitDelay = 200
local QscanAdditionalRange = 600
local units = {}
local oldDelayTick = 0
local unitScanTick = 0
local holding = 0
local animPlayedTick = nil
local nextTick = 0
local RefreshRate = 33

local lasthiton = true

--[[	Code	]]
local range = 700
local qRange = 500
local tick = nil
local r = 500
-- draw
local waittxt = {}
local calculationenemy = 1
local floattext = {"Skills are not available","Able to fight","Killable","Murder him!"}
local killable = {}
-- ts
local ts
local ecastspeed = 500
--Attack and Cast stuff
local lastBasicAttack = 0
local swingDelay = 0.15
local swing = 0

local kiStrike = 0
local taunt = 0
local lastTaunt = 0
local feint = 0
local lastFeint = 0

--Ult Stuff
local SHOWR = false -- Show range of R
local ultPct = 20
local ultRange = 18500 
local champWarning = 0
local champName = nil
local reminder = false
local ultQuery = false
local ultCast = 0
local lastUlt = 0
--local minValue = 0.25

local targetSelected = true

local ignite = nil
local DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = nil, nil, nil, nil, nil, nil
local QREADY, EREADY, RREADY, DFGREADY, HXGREADY, BWCREADY, IREADY = false, false, false, false, false, false, false

function OnLoad()
	ShenConfig = scriptConfig("Shen Combo ", "shencombo")
		
	ShenConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	
	ShenConfig:addParam("QQ", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 67)
	
	ShenConfig:addParam("WQ", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 90)
	
	ShenConfig:addParam("RALLY", "Ult Ally", SCRIPT_PARAM_ONKEYDOWN, false, 89)
	
	ShenConfig:addParam("autoult", "Auto Ult", SCRIPT_PARAM_ONKEYTOGGLE, false, 84)	
	
	ShenConfig:addParam("autoAAFarm", "Auto AA Farm", SCRIPT_PARAM_ONKEYDOWN, false, 192)--SCRIPT_PARAM_ONKEYTOGGLE
	
	ShenConfig:addParam("autoQFarm", "Auto Q Farm", SCRIPT_PARAM_ONKEYDOWN, false, 112)--SCRIPT_PARAM_ONKEYTOGGLE
	
	ShenConfig:addParam("UltUp", "Ult Up", SCRIPT_PARAM_ONKEYDOWN, false, 221)
	
	ShenConfig:addParam("UltDn", "Ult Down", SCRIPT_PARAM_ONKEYDOWN, false, 219)
	
	ShenConfig:addParam("UltRangeUp", "Ult R Up", SCRIPT_PARAM_ONKEYDOWN, false, 187)
	
	ShenConfig:addParam("UltRangeDn", "Ult R Dn", SCRIPT_PARAM_ONKEYDOWN, false, 189)
	
	ShenConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	ShenConfig:addParam("drawtext", "Draw Text", SCRIPT_PARAM_ONOFF, true)
	ShenConfig:addParam("autoignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
	ShenConfig:permaShow("autoult")
	ShenConfig:permaShow("autoAAFarm")
	ShenConfig:permaShow("autoQFarm")
	ts = TargetSelector(TARGET_LOW_HP,range+50,DAMAGE_MAGIC)
	ts.name = "Shen"
	targetSelected = true
	ts:SetPrediction(ecastspeed)
	ShenConfig:addTS(ts)
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
	for i=1, heroManager.iCount do waittxt[i] = i*3 end
	PrintChat(">> Shen Combo loaded!")
	reminder = true
	
end



function OnProcessSpell(unit, spell)
	if unit.isMe and spell and string.find(string.lower(spell.name),"attack" ) then
		swing = 1
		lastBasicAttack = os.clock()
	end
	if unit.isMe and spell and string.find(string.lower(spell.name),"shenstandunited" )then
		ultCast = 1
		lastUlt = os.clock()
	end
	if unit.isMe and spell and string.find(string.lower(spell.name),"shenfeint" )then
		feint = 1
		lastFeint = os.clock()
		PrintFloatText(myHero,10,"+S")
	end
end

function OnCreateObj(obj) 
	if obj and string.find(string.lower(obj.name),"shen_kistrike_ready_indicator") and GetDistance(obj, myHero) < 100 then
		kiStrike = 1					
		PrintFloatText(myHero,0,"+KS")
	end
	if obj and string.find(string.lower(obj.name),"shen_shadowdash_unit_impact") and GetDistance(obj, myHero) < 350 then --and string.find(string.lower(obj.name),"global_taunt_multi_unit") then
		taunt = 1
		lastTaunt = os.clock()
		PrintFloatText(myHero,10,"+T")
	end
end

function OnDeleteObj(obj) 
	if obj and string.find(string.lower(obj.name),"shen_kistrike_ready_indicator") and GetDistance(obj, myHero) < 100 then
		kiStrike = 0			
		PrintFloatText(myHero,0,"-KS")
	end
	if obj and string.find(string.lower(obj.name),"global_taunt_multi_unit")  and GetDistance(obj, myHero) < 350 then-- and string.find(string.lower(obj.name),"global_taunt_multi_unit") then
		taunt = 0
		PrintFloatText(myHero,10,"+T")
	end
	if obj and string.find(string.lower(obj.name),"shen_feint_self")  and GetDistance(obj, myHero) < 100 then-- and string.find(string.lower(obj.name),"global_taunt_multi_unit") then		
		feint = 0
		PrintFloatText(myHero,10,"-S")
	end
end




function OnTick()
	if myHero.dead then
		return
	end
	
	if ShenConfig.UltDn then
		reminder = false
		if ultPct > 1 then
			ultPct = (ultPct-1)
		end
	end
	
	if ShenConfig.UltUp then
		reminder = false		
		if ultPct < 100 then
			ultPct = (ultPct+1)
		end
	end
	
	if ShenConfig.UltRangeUp then
		reminder = false
		if ultRange <= 22000 then
			ultRange = (ultRange+100)
		end
	end	
	
	if ShenConfig.UltRangeDn then
		reminder = false
		if ultRange >= 5000 then
			ultRange = (ultRange-100)
		end
	end		
	
	
	if ShenConfig.autoult and not RREADY then
		if ultCast == 1 and os.clock() > lastUlt + 30 then
			ultQuery = true		
	elseif ultCast == 1 and os.clock() > lastUlt + 40 then
			ultQuery = false
			ultCast = 0		
		end		
	end
	
	
	if swing == 1 and os.clock() > lastBasicAttack + 0.5 then
		swing = 0
	end
	
	if taunt == 1 and os.clock() > lastTaunt + 2 then
		taunt = 0
	end

	if feint == 1 and os.clock() > lastFeint + 3.5 then
		feint = 0
	end
	
	ts:update()	
	
	DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
	QREADY = (myHero:CanUseSpell(_Q) == READY)	
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
	BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)

	if tick == nil or GetTickCount()-tick >= 150 then
		tick = GetTickCount()
		ShenDmgCalculation()
	end
		
	if ShenConfig.autoQFarm then
		if mousemoving and GetTickCount() > nextTick then
			player:MoveTo(mousePos.x, mousePos.z)
		end    
		local tick = GetTickCount()
		
		if lasthiton then
		unitScanTick = tick
			for i = 1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.team ~= player.team and object.type == "obj_AI_Minion" and string.find(object.charName,"Minion") then
					if not object.dead and GetDistance(object,player) <= (player.range + QscanAdditionalRange) then
						if units[object.name] == nil then
							units[object.name] = { obj = object, markTick = 0 }
						end
					else
						units[object.name] = nil
					end
				end
			end
		end
		for i, unit in pairs(units) do
			if unit.obj == nil or unit.obj.dead or GetDistance(player,unit.obj) > (player.range + QscanAdditionalRange) then
				units[i] = nil
			else 
				local myQ = math.floor(getDmg("Q",unit.obj,myHero))           
				if unit.obj.health <= myQ then -- myHero:CalcMagicDamage(unit.obj,getXtraMDmg())
					if lasthiton and GetTickCount() > nextTick then
						CastSpell(_Q, unit.obj) ---PrintChat("ATTACKING")
						nextTick = GetTickCount() + QwaitDelay
						return
					end 
				end
			end     
		end
	end
	
	
	if ShenConfig.autoAAFarm then
		if mousemoving and GetTickCount() > nextTick then
			player:MoveTo(mousePos.x, mousePos.z)
		end    
		local tick = GetTickCount()
		if lasthiton then
		unitScanTick = tick
			for i = 1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.team ~= player.team and object.type == "obj_AI_Minion" and string.find(object.charName,"Minion") then
					if not object.dead and GetDistance(object,player) <= (player.range + scanAdditionalRange) then
						if units[object.name] == nil then
							units[object.name] = { obj = object, markTick = 0 }
						end
					else
						units[object.name] = nil
					end
				end
			end
		end
	if kiStrike == 1 then		
		for i, unit in pairs(units) do
			if unit.obj == nil or unit.obj.dead or GetDistance(player,unit.obj) > (player.range + scanAdditionalRange) then
				units[i] = nil
			else
			local KSdmg = math.floor(getDmg("P",unit.obj,myHero))
			if unit.obj.health <= (myHero:CalcDamage(unit.obj,myHero.totalDamage) + KSdmg) then --  myHero:CalcMagicDamage(unit.obj,getXtraMDmg())
						if lasthiton and GetTickCount() > nextTick then
							player:Attack(unit.obj) ---PrintChat("ATTACKING")
							nextTick = GetTickCount() + waitDelay	
						return
					end 
				end
			end     
		end
elseif kiStrike == 0 then
		for i, unit in pairs(units) do
			if unit.obj == nil or unit.obj.dead or GetDistance(player,unit.obj) > (player.range + scanAdditionalRange) then
				units[i] = nil
			else
				if unit.obj.health <= (myHero:CalcDamage(unit.obj,myHero.totalDamage)) then -- 
					if lasthiton and GetTickCount() > nextTick then
						player:Attack(unit.obj) ---PrintChat("ATTACKING")
						nextTick = GetTickCount() + waitDelay	
						return
					end 
				end
			end     
		end
	end	
end            
		
	
	if ShenConfig.autoignite then	
		if IREADY then
			local ignitedmg = 0	
			for j = 1, heroManager.iCount, 1 do
				local enemyhero = heroManager:getHero(j)
				if ValidTarget(enemyhero,600) and enemyhero.team ~= myHero.team then
					ignitedmg = 50 + 20 * myHero.level
					if enemyhero.health <= (ignitedmg - 33) then
						CastSpell(ignite, enemyhero)
					end
				end
			end
		end
	end
	
	
	if RREADY then
		for i=1, heroManager.iCount do  --(Champ.health / Champ.maxHealth < minValue) then
			local Champ = heroManager:GetHero(i) --PrintFloatText(myHero,0,"CotG Gone")
			if not ShenConfig.autoult and Champ.charName ~= myHero.charName and Champ.type == "obj_AI_Hero" and Champ.team == myHero.team and  Champ.dead == false and myHero:GetDistance(Champ) < ultRange and (Champ.health / Champ.maxHealth < ultPct / 100) then					
				--PrintFloatText(myHero,0,Champ.charName .." NEEDS SHIELD!")
				champName = Champ.charName
				champWarning = 1
		elseif not ShenConfig.autoult and Champ.charName ~= myHero.charName and Champ.type == "obj_AI_Hero" and Champ.team == myHero.team and  Champ.dead == false and myHero:GetDistance(Champ) < ultRange and (Champ.health / Champ.maxHealth > ultPct / 100) then
				champName = nil
				champWarning = 0
				
				--PrintFloatText(myHero,20,"Shield ".. Champ.charName .."!")			
		elseif ShenConfig.autoult and Champ.charName ~= myHero.charName and Champ.type == "obj_AI_Hero" and Champ.team == myHero.team and  Champ.dead == false and myHero:GetDistance(Champ) < ultRange and (Champ.health / Champ.maxHealth < ultPct / 100) then					
				CastSpell(_R, Champ)
			end			
		end
	end
	
	
	if ShenConfig.autoult and not RREADY then
		if ultCast == 1 and os.clock() > lastUlt + 30 then
			ultQuery = true
		end
		if ultQuery and ultCast == 1 and os.clock() > lastUlt + 40 then
			ultQuery = false
			ultCast = 0		
		end			
	end	
	
			
	
	
	
	if ShenConfig.RALLY and RREADY then
		for i=1, heroManager.iCount do
			local Champ = heroManager:GetHero(i)
			local Mdistance = GetDistance(mousePos, Champ)
			if Champ.type == "obj_AI_Hero" and Champ.charName ~= myHero.charName and Champ.team == myHero.team and Mdistance < 300 and  Champ.dead == false then					
				CastSpell(_R, Champ)					
			end
		end		
	end
	

	
	-- scriptActive
	if ShenConfig.scriptActive and ValidTarget(ts.target, range) then
			
		if DFGREADY then
			CastSpell(DFGSlot, ts.target)
	elseif HXGREADY then 
			CastSpell(HXGSlot, ts.target) 
	elseif BWCREADY then 
			CastSpell(BWCSlot, ts.target)
		end
		
		if EREADY and ValidTarget(ts.target, range) then 
			CastSpell(_E, ts.target.x, ts.target.z) 
		end
		
		if ValidTarget(ts.target, qRange) then 
			myHero:Attack(ts.target) 
		end
		
		if QREADY and myHero:CanUseSpell(_E) == COOLDOWN and swing == 0 then
			if (ValidTarget(ts.target, qRange) and GetDistance(ts.target) > 305) then 
				CastSpell(_Q, ts.target)
			end
	elseif QREADY and myHero:CanUseSpell(_E) == COOLDOWN and swing == 1 then
			if os.clock() - lastBasicAttack > swingDelay and ValidTarget(ts.target, qRange) then 
				CastSpell(_Q, ts.target)
				swing = 0 
			end
		end			
		if taunt == 0 and WREADY  and ValidTarget(ts.target, player.range + 150) then 
			CastSpell(_W) 
			--swing == 0and swing == 1 and os.clock() - lastBasicAttack > swingDelay
		end
		
	end
	
	-- WQ
	if ShenConfig.WQ and ValidTarget(ts.target, range) then
		
		if QREADY and swing == 0 then
			if (ValidTarget(ts.target, range) and GetDistance(ts.target) > 305) then 
				CastSpell(_Q, ts.target)
			end
	elseif QREADY and swing == 1 then
			if os.clock() - lastBasicAttack > swingDelay and ValidTarget(ts.target, qRange) then 
				CastSpell(_Q, ts.target)
				swing = 0 
			end
		end
		
	
		
		if kiStrike == 1 then
			if ValidTarget(ts.target, range) then  
				myHero:Attack(ts.target) 
			end
	elseif kiStrike == 0 then		
			if ValidTarget(ts.target, 350) then 
				myHero:Attack(ts.target) 
			end
		end
		
		if taunt == 0 and WREADY and swing == 1 and os.clock() - lastBasicAttack > swingDelay and ValidTarget(ts.target, qRange) then
			CastSpell(_W)
			swing = 0
		end
		
		if DFGREADY then
			CastSpell(DFGSlot, ts.target)
	elseif HXGREADY then 
			CastSpell(HXGSlot, ts.target) 
	elseif BWCREADY then 
			CastSpell(BWCSlot, ts.target)
		end
								
	end
	
		
	if ShenConfig.QQ and ValidTarget(ts.target, range) then
		
		if QREADY and swing == 0 then
			if (ValidTarget(ts.target, range) and GetDistance(ts.target) > 305) then 
				CastSpell(_Q, ts.target)
			end
	elseif QREADY and swing == 1 then
			if os.clock() - lastBasicAttack > swingDelay and ValidTarget(ts.target, qRange) then 
				CastSpell(_Q, ts.target)
				swing = 0 
			end
		end		
		
		if kiStrike == 1 then
			if ValidTarget(ts.target, range) then  
				myHero:Attack(ts.target) 
			end
	elseif kiStrike == 0 then		
			if ValidTarget(ts.target, 350) then 
				myHero:Attack(ts.target) 
			end
		end
		
		if DFGREADY then
			CastSpell(DFGSlot, ts.target)
	elseif HXGREADY then 
			CastSpell(HXGSlot, ts.target) 
	elseif BWCREADY then 
			CastSpell(BWCSlot, ts.target)
		end
						
					
	end
		
end



function ShenDmgCalculation()
	local enemy = heroManager:GetHero(calculationenemy)
	if ValidTarget(enemy) then
		local passivedamage = getDmg("P",enemy,myHero)
		local dfgdamage, hxgdamage, bwcdamage, ignitedamage, Sheendamage, Trinitydamage, LichBanedamage  = 0, 0, 0, 0, 0, 0, 0
		local qdamage = getDmg("Q",enemy,myHero)		
		local hitdamage = getDmg("AD",enemy,myHero)
		local dfgdamage = (DFGSlot and getDmg("DFG",enemy,myHero) or 0)
		local hxgdamage = (HXGSlot and getDmg("HXG",enemy,myHero) or 0)
		local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)
		local ignitedamage = (ignite and (getDmg("IGNITE",enemy,myHero)- 33) or 0)
		local Sheendamage = (SheenSlot and hitdamage or 0)
		local Trinitydamage = (TrinitySlot and hitdamage*1.5 or 0)
		local LichBanedamage = (LichBaneSlot and getDmg("LICHBANE",enemy,myHero) or 0)
		local combo1 = passivedamage + hitdamage*2 + Sheendamage + Trinitydamage + LichBanedamage --0 cd
		local combo2 = passivedamage + hitdamage*2 + Sheendamage + Trinitydamage + LichBanedamage
		local combo3 = passivedamage*2 + hitdamage*3 + qdamage + Sheendamage + Trinitydamage + LichBanedamage
		local combo4 = passivedamage*2 + hitdamage*4 + qdamage*2 + Sheendamage + Trinitydamage + LichBanedamage
		if QREADY then
			combo1 = combo1 + qdamage
			combo2 = combo2 + qdamage
			combo3 = combo3
			combo4 = combo2 + qdamage
		end			
		if DFGREADY and QREADY then        
			combo1 = combo1 + dfgdamage + qdamage           
			combo2 = combo2 + dfgdamage + qdamage
			combo3 = combo3 + dfgdamage
			combo4 = combo4 + dfgdamage
		end
		if HXGREADY and QREADY then               
			combo1 = combo1 + hxgdamage + qdamage   
			combo2 = combo2 + hxgdamage + qdamage
			combo3 = combo3 + hxgdamage
			combo4 = combo4 + hxgdamage
		end
		if BWCREADY and QREADY then
			combo1 = combo1 + bwcdamage + qdamage
			combo2 = combo2 + bwcdamage + qdamage
			combo3 = combo3 + bwcdamage
			combo4 = combo4 + bwcdamage
		end
		if IREADY and QREADY and ShenConfig.autoignite then
			combo1 = combo1 + ignitedamage + qdamage
			combo2 = combo2 + ignitedamage + qdamage
			combo3 = combo3 + ignitedamage
			combo4 = combo4 + ignitedamage
		end
		if combo4 >= enemy.health then killable[calculationenemy] = 4
		elseif combo3 >= enemy.health then killable[calculationenemy] = 3
		elseif combo2 >= enemy.health then killable[calculationenemy] = 2
		elseif combo1 >= enemy.health then killable[calculationenemy] = 1
		else killable[calculationenemy] = 0 end
	end
	if calculationenemy == 1 then
		calculationenemy = heroManager.iCount
	else 
		calculationenemy = calculationenemy-1
	end
end
function OnDraw()
	DrawText("\nPercent: "..ultPct.."%",16,50,150,0xFF80FF00)
	DrawText("\nUlt is: "..ultRange.." range",16,50,200,0xFF80FF00)
	if RREADY and champWarning == 1 then
		DrawText("Shield ".. champName .."!",40,850,750,0xFFFF0000)
	end
	if ultQuery then
		DrawText("WARNING! Auto-Ult still active! This message will expire in 10 seconds.",35,500,850,0xFFFF0000)
	end	
	if reminder then
		DrawText("Don't forget to set up your Ult! + & - for Ult range, [ & ] for Ult hp %",40,500,750,0xFF80FF08) --0xFF80FF08
	end
	if ShenConfig.drawcircles and not myHero.dead then
		if SHOWR and RREADY then DrawCircle(myHero.x, myHero.y, myHero.z, ultRange, 0xFF00CC) end--R range
		if EREADY then DrawCircle(myHero.x, myHero.y, myHero.z, range, 0xFF00CC) end--E range
		if QREADY then DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x9966CC) end --Q range
		if kiStrike == 0 then DrawCircle(myHero.x, myHero.y, myHero.z, 350, 0x9966CC) end
		if ts.target ~= nil then
			for j=0, 10 do
				DrawCircle(ts.target.x, ts.target.y, ts.target.z, 40 + j*1.5, 0x00FF00)
			end
		end
	end
	for i=1, heroManager.iCount do
		local enemydraw = heroManager:GetHero(i)
		if ValidTarget(enemydraw) then
			if ShenConfig.drawcircles then
				if killable[i] == 1 then
					for j=0, 20 do
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0x0000FF)
					end
				elseif killable[i] == 2 then
					for j=0, 10 do
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
					end
				elseif killable[i] == 3 then
					for j=0, 10 do
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + j*1.5, 0xFF0000)
					end
				elseif killable[i] == 4 then
					for j=0, 10 do
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + j*1.5, 0xFF0000)
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 140 + j*1.5, 0xFF0000)
					end
				end
			end
			if ShenConfig.drawtext and waittxt[i] == 1 and killable[i] ~= 0 then
				PrintFloatText(enemydraw,0,floattext[killable[i]])
			end
		end
		if waittxt[i] == 1 then waittxt[i] = 30
		else waittxt[i] = waittxt[i]-1 end
	end
	SC__OnDraw()
end
function OnWndMsg(msg,key)
	SC__OnWndMsg(msg,key)
end
function OnSendChat(msg)
	TargetSelector__OnSendChat(msg)
	ts:OnSendChat(msg, "pri")
end