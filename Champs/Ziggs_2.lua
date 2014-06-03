--[[
	Ziggs  Combo 1.0 by WomboCombo
		
		It requires AllClass and Spell Damage Library

	-Full combo: items -> Q-> E -> R
	-Supports Deathfire Grasp, Bilgewater Cutlass, Hextech Gunblade, Sheen, Trinity, Lich Bane and Ignite
	-Informs where will use the combo / default off
	-Mark killable target with a combo
	-Target configuration
	-Press shift to configure
]]
if myHero.charName ~= "Ziggs" then return end
require "AllClass"
--[[            Code            ]]
local range = 5300
local range2 = 850
local tick = nil
local doCombo = false
local doUlt = false
-- Active
-- draw
local waittxt = {}
local calculationenemy = 1
local floattext = {"Skills are not available","Able to fight","Killable","Murder him!"}
local killable = {}
-- ts
local ts
--
local ignite = nil
local DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = nil, nil, nil, nil, nil, nil
local QREADY, WREADY, EREADY, RREADY, DFGREADY, HXGREADY, BWCREADY, IREADY = false, false, false, false, false, false, false, false
 
function OnLoad()
	MCConfig = scriptConfig("Ziggs WomboCombo 1.0", "Ziggscombo")
	MCConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MCConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	MCConfig:addParam("drawtext", "Draw Text", SCRIPT_PARAM_ONOFF, true)
	MCConfig:addParam("drawprediction", "Draw Prediction", SCRIPT_PARAM_ONOFF, false)
	MCConfig:addParam("useUlt", "Use Ult", SCRIPT_PARAM_ONOFF, false)
	MCConfig:permaShow("scriptActive")

	ts = TargetSelector(TARGET_LOW_HP,range,DAMAGE_MAGIC)
	ts.name = "Ziggs"
	MCConfig:addTS(ts)
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
	for i=1, heroManager.iCount do waittxt[i] = i*3 end
end

function OnTick()
	ts:update()
	Prediction__OnTick()
	DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
	BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	if tick == nil or GetTickCount()-tick >= 200 then
		tick = GetTickCount()
		MCDmgCalculation()
	end
		if MCConfig.scriptActive then
			if ts.target then
				if DFGREADY then CastSpell(DFGSlot, ts.target) end
				if HXGREADY then CastSpell(HXGSlot, ts.target) end
				if BWCREADY then CastSpell(BWCSlot, ts.target) end
				if not MCConfig.manual then
					if QREADY and GetDistance(ts.nextPosition)<=850 then CastSpell(_Q, ts.target) end
					if doCombo == true then
					if EREADY and GetDistance(ts.nextPosition)<=900 then CastSpell(_E, ts.nextPosition.x, ts.nextPosition.z) end				
			  end
		  end
	  end
	end
	if ts.target ~= nil then
	if doUlt == true then
		if MCConfig.useUlt and RREADY and GetDistance(ts.nextPosition)<=5300 then CastSpell(_R, ts.target) end
		end
	end
end
function MCDmgCalculation()
	local enemy = heroManager:GetHero(calculationenemy)
	if ValidTarget(enemy) then
		local dfgdamage, hxgdamage, bwcdamage, ignitedamage, Sheendamage, Trinitydamage, LichBanedamage  = 0, 0, 0, 0, 0, 0, 0
		local pdamage = getDmg("P",enemy,myHero)
		local qdamage = getDmg("Q",enemy,myHero)
		local wdamage = getDmg("W",enemy,myHero) 
		local edamage = getDmg("E",enemy,myHero)
		local rdamage = getDmg("R",enemy,myHero)
		local hitdamage = getDmg("AD",enemy,myHero)
		local dfgdamage = (DFGSlot and getDmg("DFG",enemy,myHero) or 0)
		local hxgdamage = (HXGSlot and getDmg("HXG",enemy,myHero) or 0)
		local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)
		local ignitedamage = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
		local Sheendamage = (SheenSlot and getDmg("SHEEN",enemy,myHero) or 0)
		local Trinitydamage = (TrinitySlot and getDmg("TRINITY",enemy,myHero) or 0)
		local LichBanedamage = (LichBaneSlot and getDmg("LICHBANE",enemy,myHero) or 0)
		local combo1 = hitdamage + qdamage + wdamage + edamage + rdamage + Sheendamage + Trinitydamage + LichBanedamage --0 cd
		local combo2 = hitdamage + Sheendamage + Trinitydamage + LichBanedamage
		local combo3 = hitdamage + Sheendamage + Trinitydamage + LichBanedamage
		local combo4 = 0
		
		if QREADY then
			combo2 = combo2 + qdamage
			combo3 = combo3 + qdamage
			--combo4 = combo4 + qdamage
		end
		if WREADY then
			combo2 = combo2 + wdamage
			combo3 = combo3 + wdamage
		end
		if EREADY then
			combo2 = combo2 + edamage
			combo3 = combo3 + edamage
			--combo4 = combo4 + edamage
		end
		if RREADY then
			combo2 = combo2 + rdamage
			combo3 = combo3 + rdamage
			combo4 = combo4 + rdamage
		end
		if DFGREADY then        
			combo1 = combo1 + dfgdamage            
			combo2 = combo2 + dfgdamage
			combo3 = combo3 + dfgdamage
			--combo4 = combo4 + dfgdamage
		end
		if HXGREADY then               
			combo1 = combo1 + hxgdamage    
			combo2 = combo2 + hxgdamage
			combo3 = combo3 + hxgdamage
			--combo4 = combo4 + hxgdamage
		end
		if BWCREADY then
			combo1 = combo1 + bwcdamage
			combo2 = combo2 + bwcdamage
			combo3 = combo3 + bwcdamage
			combo4 = combo4 + bwcdamage
		end
		if IREADY then
			combo1 = combo1 + ignitedamage 
			combo2 = combo2 + ignitedamage
			combo3 = combo3 + ignitedamage
		end
		if combo4 >= enemy.health then killable[calculationenemy] = 4 doUlt = true
		elseif combo3 >= enemy.health then killable[calculationenemy] = 3 doUlt = false
		elseif combo2 >= enemy.health then killable[calculationenemy] = 2 doUlt = false
		elseif combo1 >= enemy.health then killable[calculationenemy] = 1  doCombo = true doUlt = false
		else killable[calculationenemy] = 0 doCombo = false doUlt = false end
	end
	if calculationenemy == 1 then calculationenemy = heroManager.iCount
	else calculationenemy = calculationenemy-1 end
end

function OnDraw()
	if MCConfig.drawcircles and not myHero.dead then
		DrawCircle(myHero.x, myHero.y, myHero.z, range, 0x19A712)
		DrawCircle(myHero.x, myHero.y, myHero.z, range2, 0x19A712)
		if ts.target ~= nil then
			for j=0, 10 do
				DrawCircle(ts.target.x, ts.target.y, ts.target.z, 40 + j*1.5, 0x00FF00)
			end
		end
	end
	if ts.target ~= nil and MCConfig.drawprediction then
		DrawCircle(ts.nextPosition.x, ts.target.y, ts.nextPosition.z, 200, 0x0000FF)
	end
	for i=1, heroManager.iCount do
		local enemydraw = heroManager:GetHero(i)
		if ValidTarget(enemydraw) then
			if MCConfig.drawcircles then
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
			if MCConfig.drawtext and waittxt[i] == 1 and killable[i] ~= 0 then
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
PrintChat(" >> Ziggs WomboCombo 1.0 loaded!")