--[[
SetSailMissFortune
]]--

-- Hero check
if GetMyHero().charName ~= "MissFortune" then 
return 
end

local version = 0.08
local AUTOUPDATE = true
local SCRIPT_NAME = "SetSailMissFortune"
local ultiCasting = false

--LIB
local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"

if FileExist(SOURCELIB_PATH) then
	require("SourceLib")
else
	DOWNLOADING_SOURCELIB = true
	DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() print("Required libraries downloaded successfully, please reload") end)
end

if DOWNLOADING_SOURCELIB then print("Downloading required libraries, please wait...") return end

if AUTOUPDATE then
	SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/bolgungho/Bol/master/"..SCRIPT_NAME..".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/bolgungho/Bol/master/version/"..SCRIPT_NAME..".version"):CheckUpdate()
end

local RequireI = Require("SourceLib")
	RequireI:Add("vPrediction", "https://raw.github.com/Hellsing/BoL/master/common/VPrediction.lua")
	RequireI:Add("SOW", "https://raw.github.com/Hellsing/BoL/master/common/SOW.lua")
	RequireI:Check()

if RequireI.downloadNeeded == true then return end
--END LIB

-- Spell
local Qrange, Qwidth, Qspeed, Qdelay = 650, 1, 1400, 0.29
local Wrange, Wwidth, Wspeed, Wdelay = 650, 100, 1400, 0.5
local Erange, Ewidth, Espeed, Edelay = 800, 300, 500, 0.65
local Rrange, Rwidth, Rspeed, Rdelay = 1400, 400, 780, 2.5
		  

function OnLoad()
	_LoadLib()
    
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
        castigo = SUMMONER_1
		PrintChat("<font color=\"#FF1155\"><b>Set Sail! (Version:"..version.." Loaded) </b></font><font color=\"#FFFFFF\">by Gungho Alvin </font>")
    elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
        castigo = SUMMONER_2
		PrintChat("<font color=\"#FF1155\"><b>Set Sail! (Version:"..version.." Loaded) </b></font><font color=\"#FFFFFF\">by Gungho Alvin </font>")
    end
end

-- Drawing
function OnDraw()
   if MFMenu.Drawing.DrawAA then
      if MFMenu.Drawing.lowfpscircle then
	     -- Lag free circle
         DrawCircle3D(myHero.x, myHero.y, myHero.z, SOWi:MyRange() + 100, 1, TARGB({200, 150, 0, 200}), 100)
	  else
         -- Draw AA hero range
         DrawCircle(myHero.x, myHero.y, myHero.z, SOWi:MyRange() + 100, 0x993399)
	  end
   end
end

function OnTick()
	if MFMenu.Combo.comboR then
		_CheckUlt()
	end	
	if MFMenu.Extra.AutoLev then
		_AutoLevel()
	end	
	if MFMenu.Combo.combokey then
		_Combo() 
	end   
	if MFMenu.Harass.harasskey then
		_Harass() 
	end
	if MFMenu.Harass.harasskey2 then
		_Harass() 
	end
  
end


-- Load lib
function _LoadLib()
    VP = VPrediction(true)
    STS = SimpleTS(STS_LESS_CAST_PHYSICAL)
    SOWi = SOW(VP, STS)
	
	_LoadMenu()
end

-- Load menu
function _LoadMenu()
    MFMenu = scriptConfig("Set Sail Miss Fortune "..version, "Set Sail Miss Fortune "..version)
	
    MFMenu:addSubMenu("Target selector", "STS")
    STS:AddToMenu(MFMenu.STS)
	
	MFMenu:addSubMenu("Drawing", "Drawing")
	MFMenu.Drawing:addParam("lowfpscircle", "Lag free draw", SCRIPT_PARAM_ONOFF, true)
	MFMenu.Drawing:addParam("DrawAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
	
	
	MFMenu:addSubMenu("Orbwalker", "Orbwalker")
	SOWi:LoadToMenu(MFMenu.Orbwalker)
    SOWi:RegisterAfterAttackCallback(AfterAttack)
	
	MFMenu:addSubMenu("Combo", "Combo")
	MFMenu.Combo:addParam("IGNITE", "Use Ignite when killable", SCRIPT_PARAM_ONOFF, true)
	MFMenu.Combo:addParam("combokey", "Combo key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MFMenu.Combo:addParam("comboQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	MFMenu.Combo:addParam("ManacheckCQ", "Mana manager Q", SCRIPT_PARAM_SLICE, 10, 1, 100)
	MFMenu.Combo:addParam("comboW", "Use W", SCRIPT_PARAM_ONOFF, true)
	MFMenu.Combo:addParam("ManacheckCW", "Mana manager W", SCRIPT_PARAM_SLICE, 10, 1, 100)
	MFMenu.Combo:addParam("comboE", "Use E when Enemy farther than AA/Q range", SCRIPT_PARAM_ONOFF, true)
	MFMenu.Combo:addParam("ManacheckCE", "Mana manager E", SCRIPT_PARAM_SLICE, 30, 1, 100)
	MFMenu.Combo:addParam("comboRinfo","Use R when enemy killable and farther than AA/Q range",SCRIPT_PARAM_INFO,"")
	MFMenu.Combo:addParam("comboR", "   |===========================>", SCRIPT_PARAM_ONOFF, true)
	
		
	MFMenu:addSubMenu("Harass", "Harass")
	MFMenu.Harass:addParam("harasskey", "Harass (Mixed mode)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	MFMenu.Harass:addParam("harasskey2", "Harass (Laneclear mode)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	MFMenu.Harass:addParam("harassQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	MFMenu.Harass:addParam("Manacheck", "Mana manager", SCRIPT_PARAM_SLICE, 50, 1, 100)
		
	MFMenu:addSubMenu("Extra", "Extra")
	MFMenu.Extra:addParam("AutoLev", "Auto level skill(Q,E,Q,W=>RQWE)", SCRIPT_PARAM_ONOFF, true)
	
end

--Check MF ULT
function _CheckUlt()
    if TargetHaveBuff("missfortunebulletsound", myHero) then
         ultiCasting = true
		 MFMenu.Orbwalker.Enabled = false
    else
         ultiCasting = false
		 MFMenu.Orbwalker.Enabled = true
    end
end

function _Combo()
    -- Cast Q
    local target = STS:GetTarget(Qrange)
    if MFMenu.Combo.comboQ and myHero:CanUseSpell(_Q) == READY and target ~= nil and (myHero.mana / myHero.maxMana * 100) >= MFMenu.Combo.ManacheckCQ then
	   if GetDistance(target) <= Qrange and myHero:CanUseSpell(_Q) == READY then
	      CastSpell(_Q, target)
       end
    end	
	-- Cast W
	local target = STS:GetTarget(Wrange)
	if MFMenu.Combo.comboW and myHero:CanUseSpell(_W) == READY and target ~= nil and (myHero.mana / myHero.maxMana * 100) >= MFMenu.Combo.ManacheckCW then
	   if GetDistance(target) < Wrange and myHero:CanUseSpell(_W) == READY then
	      CastSpell(_W)
       end
    end	
	-- Cast E
	local target = STS:GetTarget(Erange)
	if MFMenu.Combo.comboE and myHero:CanUseSpell(_E) == READY and target ~= nil and (myHero.mana / myHero.maxMana * 100) >= MFMenu.Combo.ManacheckCE then
	local CastPosition = VP:GetLineCastPosition(target, Edelay, Ewidth, Erange, Espeed, myHero, true)
	   if GetDistance(target) <= Erange and GetDistance(target) > 650 and myHero:CanUseSpell(_E) == READY then
	      CastSpell(_E, CastPosition.x, CastPosition.z)
       end
    end	
	-- Cast R
	local target = STS:GetTarget(Rrange)
	if myHero:CanUseSpell(_R) == READY then
		if MFMenu.Combo.comboR and target ~= nil then
			local CastPosition = VP:GetLineCastPosition(target, Rdelay, Rwidth, Rrange, Rspeed, myHero, true)
			if GetDistance(target) < Rrange - 200 and GetDistance(target) > 700 and myHero:CanUseSpell(_R) == READY and getDmg("R", target, myHero)*8 > target.health then
				MFMenu.Orbwalker.Enabled = false
				CastSpell(_R, CastPosition.x, CastPosition.z)
				MFMenu.Orbwalker.Enabled = false
			end
		end
	end	
	-- Cast ignite
    local target = STS:GetTarget(600)
    if MFMenu.Combo.IGNITE and target ~= nil then
	   if GetDistance(target) <= 600 and getDmg("IGNITE", target, myHero) > target.health and myHero:CanUseSpell(_Q) ~= READY then
	      CastSpell(castigo, target)
       end
    end
end

-- Harass
function _Harass()
    -- Cast Q
    local target = STS:GetTarget(Qrange)
    if MFMenu.Harass.harassQ and myHero:CanUseSpell(_Q) == READY and target ~= nil and (myHero.mana / myHero.maxMana * 100) >= MFMenu.Harass.Manacheck then
	   if GetDistance(target) <= Qrange and myHero:CanUseSpell(_Q) == READY then
	      CastSpell(_Q, target)
       end
   end	
end

-- Auto level spell
function _AutoLevel()
   Sequence = { 1,3,1,2,1,4,1,2,1,2,4,2,2,3,3,4,3,3 }
   autoLevelSetSequence(Sequence)
end
