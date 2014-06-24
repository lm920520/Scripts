--[[
 
        Free BlitzCrank With VPrediction by JamesCarl
       
        			v1.0 - 	Initial Release
        			
				v1.1 - 	Add Combo - W>Q>E  
					Add AutoIgnite If killable
				
				v1.2 - 	Add AutoUpdate
				v1.3 - 	Fix Bugs
				v1.4 - 	Fix Ranges
				To Do: 	Add Selected Target
					Add Option to use in Combo
					Add Grab Lantern (for Duo Friend.. for fun
--]]

--[[		Auto Update		]]
local sversion = "1.4"
local AUTOUPDATE = false --You can set this false if you didn't want to autoupdate --
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/jamescarl15/BolStudio/master/JamesCarl BlitzCrank".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."JamesCarl Blitzcrank.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>JamesCarl BlitzCrank:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/jamescarl15/BolStudio/master/version/JamesCarlBlitzCrank.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(sversion) < ServerVersion then
				AutoupdaterMsg("New version available"..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..sversion.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end

local REQUIRED_LIBS = 
	{
		["VPrediction"] = "https://raw.github.com/Hellsing/BoL/master/common/VPrediction.lua",
		["SOW"] = "https://raw.github.com/Hellsing/BoL/master/common/SOW.lua",
	}		
local DOWNLOADING_LIBS = false
local DOWNLOAD_COUNT = 0
local SELF_NAME = GetCurrentEnv() and GetCurrentEnv().FILE_NAME or ""

for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
	if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
		require(DOWNLOAD_LIB_NAME)
	else
		DOWNLOADING_LIBS = true
		DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1

		print("<font color=\"#00FF00\">JamesCarl BlitzCrank:</font><font color=\"#FFDFBF\"> Not all required libraries are installed. Downloading: <b><u><font color=\"#73B9FF\">"..DOWNLOAD_LIB_NAME.."</font></u></b> now! Please don't press [F9]!</font>")
		print("Download started")
		DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
		print("Download finished")
	end
end

function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<font color=\"#00FF00\">JamesCarl BlitzCrank:</font><font color=\"#FFDFBF\"> Required libraries downloaded successfully, please reload (double [F9]).</font>")
	end
end
if DOWNLOADING_LIBS then return end

--- script ---

if myHero.charName ~= "Blitzcrank" then return end
     
require 'VPrediction'
require 'SOW'

local ts
local Recalling
local VP = nil

function OnLoad()
    VP = VPrediction()
            -- Target Selector
    ts = TargetSelector(TARGET_LESS_CAST, 1050)
                   
    Menu = scriptConfig("JamesCarl's BlitzCrank", "Blitzcrank")
    Orbwalker = SOW(VP)
    Menu:addTS(ts)
    ts.name = "Focus"
		   
		Menu:addSubMenu("["..myHero.charName.." - Orbwalker]", "SOWorb")
    Orbwalker:LoadToMenu(Menu.SOWorb)
		
		Menu:addSubMenu("["..myHero.charName.." - BlitzCombo]", "BlitzCombo")
		Menu.BlitzCombo:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		
		Menu:addSubMenu("["..myHero.charName.." - BlitzGrab]", "BlitzGrab")
		Menu.BlitzGrab:addParam("UseQ", "Use RocketGrab", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
		Menu.BlitzGrab:addParam("UseQ2", "Use Q Stunned/Dashed Enemys", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("H"))
		
		Menu:addParam("Version", "Version", SCRIPT_PARAM_INFO, sversion)
		
		Menu:addSubMenu("["..myHero.charName.." - UltiOption]", "UltiOption")
		Menu.UltiOption:addParam("KsR", "Killsteal on Ulti", SCRIPT_PARAM_ONOFF, true)
		Menu.UltiOption:addParam("SilenceR", "Use R to Silence Enemies", SCRIPT_PARAM_ONOFF, true)
		
		Menu:addSubMenu("["..myHero.charName.." - Drawings]", "drawings")
		Menu.drawings:addParam("DCircleAA", "DrawCircle Attack Range", SCRIPT_PARAM_ONOFF, true)
		Menu.drawings:addParam("DCircleQ", "DrawCircle Q Range", SCRIPT_PARAM_ONOFF, true)
		Menu.drawings:addParam("DCircleR", "DrawCircle R Range", SCRIPT_PARAM_ONOFF, true)
		
		Menu:addSubMenu("["..myHero.charName.." - Others]", "Others")
		Menu.Others:addParam("AutoLevel", "Use AutoLevel", SCRIPT_PARAM_ONOFF, true)
		Menu.Others:addParam("AutoIgnite", "Use Ignite if Killable", SCRIPT_PARAM_ONOFF, true)
		
		if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
				
		PrintChat("<font color = \"#33CCCC\">Free Blitzcrank v1.4 With VPrediction by</font> <font color = \"#fff8e7\">JamesCarl</font>")
end

local qrange, qwidth, qspeed, qdelay = 1000, 120, 1800, .25	
local rrange = 590
local aarange = 200
local abilitySequence = {1,3,2,1,1,4,1,3,1,2,4,3,3,2,2,4,3,2}

function OnTick()
		if myHero.dead then return end
		ts:update()
		Checks()
		if Menu.UltiOption.KsR then BlitzKillSteal() end
		if Menu.UltiOption.SilenceR then BlitzSilencer() end
		if Menu.BlitzCombo.Combo then Combo() end
		if Menu.Others.AutoLevel then AutoLevel() end
		if Menu.Others.AutoIgnite then AutoIgnite() end
		if Menu.BlitzGrab.UseQ then UseQ() end
		if Menu.BlitzGrab.UseQ2 then UseQ2() end
end

function UseQ()
	if ts.target ~= nil and ValidTarget(ts.target, qrange) and Menu.BlitzGrab.UseQ then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, qrange, qwidth, qspeed, qdelay, myHero, true)
		if HitChance >= 2  and GetDistance(ts.target) <= qrange and myHero:CanUseSpell(_Q) == READY then 
			CastSpell(_Q, CastPosition.x, CastPosition.z)
end
end
end

function UseQ2()
	if ts.target ~= nil and ValidTarget(ts.target, qrange) and Menu.BlitzGrab.UseQ then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, qrange, qwidth, qspeed, qdelay, myHero, true)
		if HitChance >= 3  and GetDistance(ts.target) <= qrange and myHero:CanUseSpell(_Q) == READY then 
			CastSpell(_Q, CastPosition.x, CastPosition.z)
end
end
end

function BlitzKillSteal()
	   if Menu.UltiOption.KsR and ts.target and RREADY then
          if RREADY and GetDistance(ts.target) < rrange and getDmg("R",ts.target,myHero) > ts.target.health then CastSpell(_R,ts.target) end
end  
end

-- sorry burn --
function BlitzSilencer()
        if Menu.UltiOption.SilenceR and unit ~= nil and unit.valid and unit.team == TEAM_ENEMY and CanUseSpell(_R) == READY and GetDistance(unit) <= rrange then
                if spell.name=="KatarinaR" or spell.name=="GalioIdolOfDurand" or spell.name=="Crowstorm" or spell.name=="DrainChannel"
                or spell.name=="AbsoluteZero" or spell.name=="ShenStandUnited" or spell.name=="UrgotSwap2" or spell.name=="AlZaharNetherGrasp"
                or spell.name=="FallenOne" or spell.name=="Pantheon_GrandSkyfall_Jump" or spell.name=="CaitlynAceintheHole"
                or spell.name=="MissFortuneBulletTime" or spell.name=="InfiniteDuress" or spell.name=="Teleport" or spell.name=="Meditate" then
                        CastSpell(_R, unit)
end
end
end

function Combo()
	if ts.target ~= nil and ValidTarget(ts.target, qrange) and Menu.BlitzCombo.Combo then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, qrange, qwidth, qspeed, qdelay, myHero, true)
		if HitChance >= 2  and GetDistance(ts.target) <= qrange and myHero:CanUseSpell(_Q) == READY then 
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	              if (WREADY or EREADY) and (GetDistance(ts.target) < aarange) then
                        CastSpell(_W)
                        CastSpell(_E)
end
end
end



function Checks()
        QREADY = (myHero:CanUseSpell(_Q) == READY)
        WREADY = (myHero:CanUseSpell(_W) == READY)
        EREADY = (myHero:CanUseSpell(_E) == READY)
        RREADY = (myHero:CanUseSpell(_R) == READY)
        IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)				
end

function OnDraw()
	if Menu.drawings.DCircleAA then DrawCircle(myHero.x, myHero.y, myHero.z, aarange, 0x111111) end
	if Menu.drawings.DCircleQ then DrawCircle(myHero.x, myHero.y, myHero.z, qrange, 0x111111) end
	if Menu.drawings.DCircleR then DrawCircle(myHero.x, myHero.y, myHero.z, rrange, 0x111111) end
end

function OnCreateObj(obj)
	if obj ~= nil then
		if obj.name:find("TeleportHome.troy") then
			Recalling = true
end 
end
end

function OnDeleteObj(obj)
	if obj ~= nil then
		if obj.name:find("TeleportHome.troy") then
			Recalling = false
end
end
end

-- isFacing by Feez--
function isFacing(source, ourtarget, lineLength)
	local sourceVector = Vector(source.visionPos.x, source.visionPos.z)
	local sourcePos = Vector(source.x, source.z)
	sourceVector = (sourceVector-sourcePos):normalized()
	sourceVector = sourcePos + (sourceVector*(GetDistance(ourtarget, source)))
	return GetDistanceSqr(ourtarget, {x = sourceVector.x, z = sourceVector.y}) <= (lineLength and lineLength^2 or 90000)
end

-- Thanks Burn!! --
function AutoLevel()
        if Menu.Others.AutoLevel then --auto level up
                if myHero:GetSpellData(_Q).level + myHero:GetSpellData(_W).level + myHero:GetSpellData(_E).level + myHero:GetSpellData(_R).level < myHero.level then
                        local spellSlot = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
                        local level = { 0, 0, 0, 0 }
                        for i = 1, myHero.level, 1 do
                                level[abilitySequence[i]] = level[abilitySequence[i]] + 1
                        end
                        for i, v in ipairs({ myHero:GetSpellData(_Q).level, myHero:GetSpellData(_W).level, myHero:GetSpellData(_E).level, myHero:GetSpellData(_R).level }) do
                                if v < level[i] then LevelSpell(spellSlot[i]) end
end
end 
end
end
	
function AutoIgnite()
	        if Menu.Others.AutoIgnite then    
                if IREADY then
                        local ignitedmg = 0    
                        for j = 1, heroManager.iCount, 1 do
                                local enemyhero = heroManager:getHero(j)
                                if ValidTarget(enemyhero,600) then
                                        ignitedmg = 50 + 20 * myHero.level
                                        if enemyhero.health <= ignitedmg then
                                                        CastSpell(ignite, enemyhero)
end
end
end     
end
end
end
