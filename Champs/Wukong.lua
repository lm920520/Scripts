--[[
	Wukong Combo 1.41 by HeX
	
Features:
	-Basic Combo: Items-> E-> AA-> Q-> AA
	-Full Combo(With Use Ulti in combo activated): Items-> E-> AA-> Q-> R
	-Use ultimate in combo ON/OFF option in ingame menu.
	-Auto Ignite in combo ON/OFF option in ingame menu.
	-Item Support: Blade of the Ruined King, Bligewater Cutlass, Deathfire Grasp, Hextech Gunblade, Tiamat, Ravenous Hydra, Randuins Omen.
	
Explanation of the marks:
	-Green circle: Marks the current target to which you will do the combo
	-Blue circle: Killed with a combo, if all the skills were available
	-Red circle: Killed using items + 2 Hits + Q + E + R + Ignite(if available)
	-2 Red circles: Killed using items + 1 Hit + Q + E + Ignite(if available)
	-3 Red circles: Killed using Q
]]
if myHero.charName ~= "MonkeyKing" then return end

--[[   Buffers  ]]-- Change these based on personal preference.
local ebuffer = 350 --Wont use E unless they are this far away. 350 by default.
local qbuffer = 275 --Will use Q without attacking when they are this far away. 275 by default.
--[[		Code		]]--
local range = 650
local qrange = 300
local AArange = 170
local rrange = 300
local ts
local waittxt = {}
local calculationenemy = 1
local floattext = {"Skills are not available","Able to fight","Killable","Murder him!"}
local killable = {}
local lastBasicAttack = 0
local swingDelay = 0.25
local startAttackSpeed = 0.625
local swing = 0
local ignite = nil
local BRKSlot, DFGSlot, HXGSlot, BWCSlot, TMTSlot, RAHSlot, RNDSlot = nil, nil, nil, nil, nil, nil, nil
local QREADY, WREADY, EREADY, RREADY, BRKREADY, DFGREADY, HXGREADY, BWCREADY, TMTREADY, RAHREADY, RNDREADY = false, false, false, false, false, false, false, false, false, false, false

function OnLoad()
	PrintChat("<font color='#CCCCCC'> >> Wukong Combo 1.41 loaded! <<</font>")
	WCConfig = scriptConfig("Wukong Combo", "wukongcombo")
	WCConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	WCConfig:addParam("drawcirclesSelf", "Draw Circles - Self", SCRIPT_PARAM_ONOFF, true)
	WCConfig:addParam("drawcirclesEnemy", "Draw Circles - Enemy", SCRIPT_PARAM_ONOFF, true)
	WCConfig:addParam("drawText", "Draw Text - Enemy", SCRIPT_PARAM_ONOFF, true)
	WCConfig:addParam("useUlt", "Use Ultimate in Combo", SCRIPT_PARAM_ONKEYTOGGLE, false, 67)--C 
	WCConfig:addParam("autoignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
	WCConfig:permaShow("scriptActive")
	WCConfig:permaShow("useUlt")
	WCConfig:permaShow("autoignite")
	
	ts = TargetSelector(TARGET_LOW_HP, 800, DAMAGE_PHYSICAL)
	ts.name = "Wukong"
	WCConfig:addTS(ts)
	
	for i=1, heroManager.iCount do waittxt[i] = i*3 end
	
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end 
end

function OnProcessSpell(unit, spell)
	if unit.isMe and (spell.name:find("Attack") ~= nil) then
		swing = 1
		lastBasicAttack = os.clock()
	end
end

function OnTick()
	if myHero.dead then
		return
	end
	
	AttackDelay = 1/(myHero.attackSpeed*startAttackSpeed)
	if swing == 1 and os.clock() > lastBasicAttack + AttackDelay then
		swing = 0
	end
	
	if tick == nil or GetTickCount()-tick>=100 then
		tick = GetTickCount()
		WCDmgCalculation()
	end

	ts:update()
	
	BRKSlot, DFGSlot, HXGSlot, BWCSlot, TMTSlot, RAHSlot, RNDSlot = GetInventorySlotItem(3153), GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3077), GetInventorySlotItem(3074),  GetInventorySlotItem(3143)
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
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)

	if WCConfig.autoignite then    
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

	if WCConfig.scriptActive and ts.target ~= nil then
		if DFGREADY then CastSpell(DFGSlot, ts.target) end
		if HXGREADY then CastSpell(HXGSlot, ts.target) end
		if BWCREADY then CastSpell(BWCSlot, ts.target) end
		if BRKREADY then CastSpell(BRKSlot, ts.target) end
		if TMTREADY and GetDistance(ts.target) < 275 then CastSpell(TMTSlot) end
		if RAHREADY and GetDistance(ts.target) < 275 then CastSpell(RAHSlot) end
		if RNDREADY and GetDistance(ts.target) < 275 then CastSpell(RNDSlot) end
		local QDMG = getDmg("Q", ts.target, myHero)
		local EDMG = getDmg("E", ts.target, myHero)
		if swing == 0  then
      if GetDistance(ts.target) < qrange then
        myHero:Attack(ts.target)
				elseif QREADY and ts.target.health < QDMG then
					CastSpell(_Q)
					myHero:Attack(ts.target)
					swing = 0
      end
			if EREADY and GetDistance(ts.target) < range and GetDistance(ts.target) > ebuffer then  
				CastSpell(_E, ts.target)
				myHero:Attack(ts.target)
				if QREADY and WCConfig.useUlt and RREADY then
					CastSpell(_Q)
					myHero:Attack(ts.target)
					swing = 0
				end
				elseif EREADY and ts.target.health < EDMG then
					CastSpell(_E, ts.target)
      end
			if QREADY and GetDistance(ts.target) > qbuffer then
				if GetDistance(ts.target) < qrange then
					CastSpell(_Q)
					myHero:Attack(ts.target)
					swing = 0
				end
			end
			elseif swing == 1 then
			if QREADY and os.clock() - lastBasicAttack > swingDelay and GetDistance(ts.target) < qrange then
				CastSpell(_Q)
				myHero:Attack(ts.target)
				swing = 0
			end
			if RREADY and WCConfig.useUlt and GetDistance(ts.target) < rrange then
				if not QREADY then
				CastSpell(_R)
				end
			end
		end
	end
end

function WCDmgCalculation()
	local enemy = heroManager:GetHero(calculationenemy)
	if ValidTarget(enemy) then
		local ignitedamage, dfgdamage, hxgdamage, bwcdamage, brkdamage, tmtdamage, rahdamage = 0, 0, 0, 0, 0, 0, 0
		local qdamage = getDmg("Q",enemy,myHero)
		local edamage = getDmg("E",enemy,myHero)
		local rdamage = getDmg("R",enemy,myHero,1)
		local hitdamage = getDmg("AD",enemy,myHero)
		local ignitedamage = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
		local dfgdamage = (DFGSlot and getDmg("DFG",enemy,myHero) or 0)
		local hxgdamage = (HXGSlot and getDmg("HXG",enemy,myHero) or 0)
		local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)
		local brkdamage = (BRKSlot and getDmg("RUINEDKING",enemy,myHero) or 0)
		local tmtdamage = (TMTSlot and getDmg("TIAMAT",enemy,myHero) or 0)
		local rahdamage = (RAHSlot and getDmg("HYDRA",enemy,myHero) or 0)
		local combo1 = hitdamage*2 + qdamage + edamage + rdamage
		local combo2 = hitdamage*2 
		local combo3 = hitdamage*1
		local combo4 = 0
	if QREADY then
		combo2 = combo2 + qdamage
		combo3 = combo3 + qdamage
		combo4 = combo4 + qdamage
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
	if TMTREADY then
		combo1 = combo1 + tmtdamage
		combo2 = combo2 + tmtdamage
		combo3 = combo3 + tmtdamage
	end
	if RAHREADY then
		combo1 = combo1 + rahdamage
		combo2 = combo2 + rahdamage
		combo3 = combo3 + rahdamage
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
	if WCConfig.drawcirclesSelf and not myHero.dead then
		DrawCircle(myHero.x, myHero.y, myHero.z, range, 0x19A712)
	end
	
	if WCConfig.drawcirclesEnemy and ts.target ~= nil then
		for j=0, 10 do
			DrawCircle(ts.target.x, ts.target.y, ts.target.z, 40 + j*1.5, 0x00FF00)
		end
	end
	for i=1, heroManager.iCount do
		local enemydraw = heroManager:GetHero(i)
		if ValidTarget(enemydraw) then
			if WCConfig.drawcirclesEnemy then
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
			if WCConfig.drawText and waittxt[i] == 1 and killable[i] ~= 0 then
				PrintFloatText(enemydraw,0,floattext[killable[i]])
			end
		end
		if waittxt[i] == 1 then waittxt[i] = 30
			else waittxt[i] = waittxt[i]-1 
		end
	end
end