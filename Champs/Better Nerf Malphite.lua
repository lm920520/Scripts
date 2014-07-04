--[Autoupdate Configuration]--
local AUTOUPDATE = true	--change true to false, to disbale Autoupdate

--[[Key Configuration]]--
local ComboKey = 32
local HarassKey = string.byte("C")
local LastHitKey = string.byte("X")
local LastHitKeyToggle = string.byte("Z")
local LaneClearKey = string.byte("V")
local JungleClearKey = string.byte("V")
local FleeKey = string.byte("T")

-----------------------------------------------------------------------------------------------

if myHero.charName ~= "Malphite" then return end
require 'VPrediction'
require 'SOW'

local SCRIPT_NAME = "[Better Nerf] Malphite"
local version = "1.02"
local Author = "si7ziTV"
local TESTVERSION = false
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/si7ziTV/BoL/master/Scripts/Better Nerf Malphite.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."Better Nerf Malphite.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
 
function AutoupdaterMsg(msg) print("<font color=\"#FE2E2E\"><b>[Better Nerf] Malphite:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
local ServerData = GetWebResult(UPDATE_HOST, "/si7ziTV/BoL/master/Scripts/versions/Better Nerf Malphite.lua.version")
if ServerData then
ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
if ServerVersion then
if tonumber(version) < ServerVersion then
AutoupdaterMsg("New version available"..ServerVersion)
AutoupdaterMsg("Updating, please don't press F9")
DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
else
AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
end
end
else
AutoupdaterMsg("Error downloading version info")
end
end

-----------------------------------------------------------------------------------------------

--[[Spell Data]]--
local Qready = false
local Wready = false
local Eready = false
local Rready = false

--[Minion Manager]--
local EnemyMinionManager = nil
local JungleMinionManager = nil

--[MMA & SAC Information]--
local starttick = 0
local checkedMMASAC = false
local is_MMA = false
local is_REVAMP = false
local is_REBORN = false
local is_SAC = false

--[Spell Information]--
local Qready = false
local Wready = false
local Eready = false
local Rready = false
---
local AArange = myHero.range + GetDistance(myHero.minBBox)
local Qrange , Qname = 625 , "Seismic Shard"
local Wrange , Wname = 0 , "Brutal Strikes"
local Erange , Ename = 400 , "Ground Slam"
local Rrange , Rname = 1000 , "Unstoppable Force"

--[Dangerous Spells Interrupt List]--
local ToInterrupt = {}
local InterruptSpells = {

	{ charName = "FiddleSticks", 	spellName = "Crowstorm"},
    { charName = "MissFortune", 	spellName = "MissFortuneBulletTime"},
    { charName = "Nunu", 			spellName = "AbsoluteZero"},
	{ charName = "Caitlyn", 		spellName = "CaitlynAceintheHole"},
	{ charName = "Katarina", 		spellName = "KatarinaR"},
	{ charName = "Karthus", 		spellName = "FallenOne"},
	{ charName = "Malzahar",        spellName = "AlZaharNetherGrasp"},
	{ charName = "Galio",           spellName = "GalioIdolOfDurand"},
	{ charName = "Darius",          spellName = "DariusExecute"},
	{ charName = "MonkeyKing",      spellName = "MonkeyKingSpinToWin"},
	{ charName = "Vi",    			spellName = "ViR"},
	{ charName = "Shen",			spellName = "ShenStandUnited"},
	{ charName = "Urgot",			spellName = "UrgotSwap2"},
	{ charName = "Pantheon",		spellName = "Pantheon_GrandSkyfall_Jump"},
	{ charName = "Lucian",			spellName = "LucianR"},
	{ charName = "Warwick",			spellName = "InfiniteDuress"},
	{ charName = "Xerath",			spellName = "XerathLocusOfPower2"},
	{ charName = "Velkoz",			spellName = "VelkozR"},
	{ charName = "Skarner",			spellName = "SkarnerImpale"},
						 }

-----------------------------------------------------------------------------------------------

function OnLoad()
	Init()
	Menu()
	printMessage("is Loaded successfully. Happy Fragging!")
	Loaded = true
end

function Init()	
	--[Load Libs]--
	VP = VPrediction()
	iSOW = SOW(VP)
	--[Load MinionManager]--
	EnemyMinionManager = minionManager(MINION_ENEMY,  Rrange, myHero, MINION_SORT_MAXHEALTH_DEC)
	JungleMinionManager = minionManager(MINION_JUNGLE, Rrange, myHero, MINION_SORT_MAXHEALTH_DEC)
	--[Load TargetSelector]--
	ts = TargetSelector(TARGET_LESS_CAST,Rrange,DAMAGE_MAGICAL)
end

function printMessage(msg)
	if VIP_USER then
		print("<font color=\"#FE2E2E\"><b>"..SCRIPT_NAME..":</b></font> <font color=\"#FBEFEF\">VIP Version "..msg.."</font>")
	else
		print("<font color=\"#FE2E2E\"><b>"..SCRIPT_NAME..":</b></font> <font color=\"#FBEFEF\">Free User Version "..msg.."</font>")
	end
end

-----------------------------------------------------------------------------------------------

function Menu()
	menu = scriptConfig(""..SCRIPT_NAME.." "..version.."", "Malphite")
		
		menu:addSubMenu("Combo", "combo")
			menu.combo:addParam("useQ", "Use Q in Combo", SCRIPT_PARAM_ONOFF, true)
			menu.combo:addParam("useW", "Use W in Combo", SCRIPT_PARAM_ONOFF, true)
			menu.combo:addParam("useE", "Use E in Combo", SCRIPT_PARAM_ONOFF, true)
			menu.combo:addParam("useR", "Use R in Combo", SCRIPT_PARAM_ONOFF, true)
			--[[menu.combo:addParam("line", "----------------------------", SCRIPT_PARAM_INFO, "")
			menu.combo:addParam("minenemy", "min Enemys to use R", SCRIPT_PARAM_SLICE, 3, 1, 5)
			menu.combo:addParam("minally", "min Allys to use R", SCRIPT_PARAM_SLICE, 2, 1, 5)--]]
			menu.combo:addParam("line", "", SCRIPT_PARAM_INFO, "")
			menu.combo:addParam("useItems", "Use Items in Combo", SCRIPT_PARAM_ONOFF, true)
		
		menu:addSubMenu("Harass", "harass")
			menu.harass:addParam("useQ", "Use Q in Harass", SCRIPT_PARAM_ONOFF, true)
			menu.harass:addParam("useE", "Use E in Harass", SCRIPT_PARAM_ONOFF, true)
			menu.harass:addParam("line", "", SCRIPT_PARAM_INFO, "")
			menu.harass:addParam("mana", "Dont harass if Mana < X %", SCRIPT_PARAM_SLICE, 30, 0, 100)
		
		menu:addSubMenu("Farm", "farm")
			menu.farm:addSubMenu("LastHit", "lasthit")
				menu.farm.lasthit:addParam("useQ", "Use Q to LastHit", SCRIPT_PARAM_ONOFF, true)
				menu.farm.lasthit:addParam("useE", "Use E to LastHit", SCRIPT_PARAM_ONOFF, true)
				menu.farm.lasthit:addParam("line", "", SCRIPT_PARAM_INFO, "")
				menu.farm.lasthit:addParam("toggle", "Toggle LastHit Farm", SCRIPT_PARAM_ONKEYTOGGLE, false, LastHitKeyToggle)
				--menu.farm.lasthit:addParam("Eslice", "min minions to use E", SCRIPT_PARAM_SLICE, 2, 1, 5)
			menu.farm:addSubMenu("Laneclear", "lclear")
				menu.farm.lclear:addParam("useQ", "Use Q to Laneclear", SCRIPT_PARAM_ONOFF, true)
				menu.farm.lclear:addParam("useW", "Use W to Laneclear", SCRIPT_PARAM_ONOFF, true)
				menu.farm.lclear:addParam("useE", "Use E to Laneclear", SCRIPT_PARAM_ONOFF, true)
				--menu.farm.lclear:addParam("Eslice", "min minions to use E", SCRIPT_PARAM_SLICE, 2, 1, 5)
			menu.farm:addSubMenu("Jungleclear", "jclear")
				menu.farm.jclear:addParam("useQ", "Use Q to Jungleclear", SCRIPT_PARAM_ONOFF, true)
				menu.farm.jclear:addParam("useW", "Use W to Jungleclear", SCRIPT_PARAM_ONOFF, true)
				menu.farm.jclear:addParam("useE", "Use E to Jungleclear", SCRIPT_PARAM_ONOFF, true)
				--menu.farm.jclear:addParam("Eslice", "min minions to use E", SCRIPT_PARAM_SLICE, 2, 1, 5)
			menu.farm:addParam("line", "", SCRIPT_PARAM_INFO, "")
			menu.farm:addParam("mana", "Dont farm if Mana < X %", SCRIPT_PARAM_SLICE, 30, 0, 100)
		
		menu:addSubMenu("Killsteal", "ks")
			menu.ks:addParam("useQ", "use Q to Killsteal", SCRIPT_PARAM_ONOFF, true)
			menu.ks:addParam("useE", "use E to Killsteal", SCRIPT_PARAM_ONOFF, true)
			menu.ks:addParam("useR", "use R to Killsteal", SCRIPT_PARAM_ONOFF, false)
			menu.ks:addParam("line", "", SCRIPT_PARAM_INFO, "")
			menu.ks:addParam("useItems", "use Items to Killsteal", SCRIPT_PARAM_ONOFF, true)
		
		menu:addSubMenu("Flee", "flee")
			menu.flee:addParam("move", "Move to Mouse", SCRIPT_PARAM_ONOFF, true)
			menu.flee:addParam("useQ", "Use Q to gain MovementSpeed", SCRIPT_PARAM_ONOFF, true)

		menu:addSubMenu('Interruptions', 'inter')
			menu.inter:addParam("inter1", "Interrupt skills with Ultimate.", SCRIPT_PARAM_ONOFF, false)
			menu.inter:addParam("inter2", "------------------------------", SCRIPT_PARAM_INFO, "")
			-- for i, enemy in ipairs(GetEnemyHeroes()) do
				-- for _, champ in pairs(InterruptSpells) do
					-- if enemy.charName == champ.charName then
						-- table.insert(ToInterrupt, {charName = champ.charName, spellName = champ.spellName})
					-- end
				-- end
			-- end
			-- if #ToInterrupt > 0 then
				-- for _, Inter in pairs(ToInterrupt) do
					-- menu.inter:addParam(Inter.spellName, "Stop "..Inter.charName.." "..Inter.spellName, SCRIPT_PARAM_ONOFF, true)
				-- end
			-- else
				-- menu.inter:addParam("inter3", "No supported skills to interupt.", SCRIPT_PARAM_INFO, "")
			-- end
			for i, enemy in ipairs(GetEnemyHeroes()) do
				for _, champ in pairs(InterruptSpells) do
					if enemy.charName == champ.charName then
						table.insert(ToInterrupt, {charName = champ.charName, spellName = champ.spellName})
					end
				end
			end
			if #ToInterrupt > 0 then
				for _, Inter in pairs(ToInterrupt) do
					menu.inter:addParam(Inter.spellName, "Stop "..Inter.charName.." "..Inter.spellName, SCRIPT_PARAM_ONOFF, true)
				end
			else
				menu.inter:addParam("inter3", "No supported skills to interupt.", SCRIPT_PARAM_INFO, "")
			end
		
		menu:addSubMenu("Extra", "extra")
			if VIP_USER then
			menu.extra:addSubMenu("Packet Cast", "packet")
				menu.extra.packet:addParam("useQ", "use Packet Cast Q", SCRIPT_PARAM_ONOFF, false)
				menu.extra.packet:addParam("useW", "use Packet Cast W", SCRIPT_PARAM_ONOFF, false)
				menu.extra.packet:addParam("useE", "use Packet Cast E", SCRIPT_PARAM_ONOFF, false)
			end
			menu.extra:addSubMenu("permaShow Configuration", "permaShow")
				menu.extra.permaShow:addParam("combo", "ComboKey", SCRIPT_PARAM_ONOFF, false)
				menu.extra.permaShow:addParam("lasthit", "LastHitKey", SCRIPT_PARAM_ONOFF, false)
				menu.extra.permaShow:addParam("lasthittoggle", "LastHitKey on Toggle", SCRIPT_PARAM_ONOFF, false)
				menu.extra.permaShow:addParam("harass", "HarassKey", SCRIPT_PARAM_ONOFF, false)
				menu.extra.permaShow:addParam("lclear", "LaneClearKey", SCRIPT_PARAM_ONOFF, false)
				menu.extra.permaShow:addParam("jclear", "JungleClearKey", SCRIPT_PARAM_ONOFF, false)
				menu.extra.permaShow:addParam("flee", "FleeKey", SCRIPT_PARAM_ONOFF, false)

		menu:addSubMenu("Orbwalk", "Orbwalk")
				menu.Orbwalk:addParam("standartts", "Use Standart TargetSelector", SCRIPT_PARAM_ONOFF, true)
				menu.Orbwalk:addTS(ts)
				menu.Orbwalk:addParam("line", "", SCRIPT_PARAM_INFO, "")
				iSOW:LoadToMenu(menu.Orbwalk)

		menu:addSubMenu("Drawings", "draw")
			menu.draw:addSubMenu("AA Range", "AA")
				menu.draw.AA:addParam("draw", "Draw Circle", SCRIPT_PARAM_ONOFF, true)
				menu.draw.AA:addParam("color", "Circle Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
				menu.draw.AA:addParam("line", "", SCRIPT_PARAM_INFO, "")
				menu.draw.AA:addParam("lfc", "Use Low FPS Circle", SCRIPT_PARAM_ONOFF, true)
				menu.draw.AA:addParam("width", "Circle Width", SCRIPT_PARAM_SLICE, 1, 1, 5)
				menu.draw.AA:addParam("quality", "Circle Quality", SCRIPT_PARAM_SLICE, 0, 0, 360)
			menu.draw:addSubMenu("Q Range", "Q")
				menu.draw.Q:addParam("draw", "Draw Circle", SCRIPT_PARAM_ONOFF, true)
				menu.draw.Q:addParam("color", "Circle Color", SCRIPT_PARAM_COLOR, {255, 100, 0, 180})
				menu.draw.Q:addParam("line", "", SCRIPT_PARAM_INFO, "")
				menu.draw.Q:addParam("ac", "Use After Combo Circle", SCRIPT_PARAM_ONOFF, true)
				menu.draw.Q:addParam("colorac", "Circle Color After Combo", SCRIPT_PARAM_COLOR, {120, 139, 91, 182})
				menu.draw.Q:addParam("line", "", SCRIPT_PARAM_INFO, "")
				menu.draw.Q:addParam("lfc", "Use Low FPS Circle", SCRIPT_PARAM_ONOFF, false)
				menu.draw.Q:addParam("width", "Circle Width", SCRIPT_PARAM_SLICE, 1, 1, 5)
				menu.draw.Q:addParam("quality", "Circle Quality", SCRIPT_PARAM_SLICE, 135, 0, 360)
			menu.draw:addSubMenu("E Range", "E")
				menu.draw.E:addParam("draw", "Draw Circle", SCRIPT_PARAM_ONOFF, false)
				menu.draw.E:addParam("color", "Circle Color", SCRIPT_PARAM_COLOR, {255, 100, 0, 180})
				menu.draw.E:addParam("line", "", SCRIPT_PARAM_INFO, "")
				menu.draw.E:addParam("ac", "Use After Combo Circle", SCRIPT_PARAM_ONOFF, true)
				menu.draw.E:addParam("colorac", "Circle Color After Combo", SCRIPT_PARAM_COLOR, {120, 139, 91, 182})
				menu.draw.E:addParam("line", "", SCRIPT_PARAM_INFO, "")
				menu.draw.E:addParam("lfc", "Use Low FPS Circle", SCRIPT_PARAM_ONOFF, true)
				menu.draw.E:addParam("width", "Circle Width", SCRIPT_PARAM_SLICE, 1, 1, 5)
				menu.draw.E:addParam("quality", "Circle Quality", SCRIPT_PARAM_SLICE, 135, 0, 360)
			menu.draw:addSubMenu("R Range", "R")
				menu.draw.R:addParam("draw", "Draw Circle", SCRIPT_PARAM_ONOFF, false)
				menu.draw.R:addParam("color", "Circle Color", SCRIPT_PARAM_COLOR, {255, 180, 0, 0})
				menu.draw.R:addParam("line", "", SCRIPT_PARAM_INFO, "")
				menu.draw.R:addParam("ac", "Use After Combo Circle", SCRIPT_PARAM_ONOFF, true)
				menu.draw.R:addParam("colorac", "Circle Color After Combo", SCRIPT_PARAM_COLOR, {120, 80, 0, 0})
				menu.draw.R:addParam("line", "", SCRIPT_PARAM_INFO, "")
				menu.draw.R:addParam("lfc", "Use Low FPS Circle", SCRIPT_PARAM_ONOFF, true)
				menu.draw.R:addParam("width", "Circle Width", SCRIPT_PARAM_SLICE, 3, 1, 5)
				menu.draw.R:addParam("quality", "Circle Quality", SCRIPT_PARAM_SLICE, 135, 0, 360)
			menu.draw:addSubMenu("", "info")
			menu.draw:addSubMenu("Killsteal", "ks")
				menu.draw.ks:addParam("drawQ", "Draw Q Killsteal", SCRIPT_PARAM_ONOFF, true)
				menu.draw.ks:addParam("drawE", "Draw E Killsteal", SCRIPT_PARAM_ONOFF, true)
				menu.draw.ks:addParam("drawR", "Draw R Killsteal", SCRIPT_PARAM_ONOFF, true)
			menu.draw:addSubMenu("Farm", "farm")
				menu.draw.farm:addParam("draw", "Draw Circle if Minion killable", SCRIPT_PARAM_LIST, 2, { "Never", "OnKeyDown", "Always" }) 
				menu.draw.farm:addParam("color", "Circle Color", SCRIPT_PARAM_COLOR, {255, 230, 230, 230})
				menu.draw.farm:addParam("line", "", SCRIPT_PARAM_INFO, "")
				menu.draw.farm:addParam("info", "Set SAME keys like your Farm Settings!", SCRIPT_PARAM_INFO, "")
				menu.draw.farm:addParam("key1", "Freeze", SCRIPT_PARAM_ONKEYDOWN, false, LastHitKey)
				menu.draw.farm:addParam("key2", "Mixed Mode", SCRIPT_PARAM_ONKEYDOWN, false, HarassKey)
				menu.draw.farm:addParam("key3", "Laneclear", SCRIPT_PARAM_ONKEYDOWN, false, LaneClearKey)
				menu.draw.farm:addParam("key4", "Jungleclear", SCRIPT_PARAM_ONKEYDOWN, false, JungleClearKey)
			menu.draw:addParam("line", "----------------------------------------------------", SCRIPT_PARAM_INFO, "")
			menu.draw:addParam("drawpreddmg", "Draw Predicted Damage", SCRIPT_PARAM_ONOFF, true)

		menu:addParam("line", "", SCRIPT_PARAM_INFO, "")
		menu:addParam("line", "-----------[[Configuration Keys]]------------", SCRIPT_PARAM_INFO, "")
		menu:addParam("ComboKey", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, ComboKey)
		menu:addParam("LastHitKey", "LastHit", SCRIPT_PARAM_ONKEYDOWN, false, LastHitKey)
		menu:addParam("HarassKey", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, HarassKey)
		menu:addParam("LaneClearKey", "Laneclear", SCRIPT_PARAM_ONKEYDOWN, false, LaneClearKey)
		menu:addParam("JungleClearKey", "Jungleclear", SCRIPT_PARAM_ONKEYDOWN, false, JungleClearKey)
		menu:addParam("FleeKey", "Flee", SCRIPT_PARAM_ONKEYDOWN, false, FleeKey)
		menu:addParam("line", "----------------------------------------------------", SCRIPT_PARAM_INFO, "")
		menu:addParam("line", "", SCRIPT_PARAM_INFO, "")
		menu:addParam("Version", "Version", SCRIPT_PARAM_INFO, version)
		menu:addParam("Author", "Author", SCRIPT_PARAM_INFO, Author)

	if menu.extra.permaShow.combo then
		menu:permaShow("ComboKey")
	end
	if menu.extra.permaShow.lasthit then
		menu:permaShow("LastHitKey")
	end
	if menu.extra.permaShow.lasthittoggle then
		menu.farm.lasthit:permaShow("toggle")
	end
	if menu.extra.permaShow.harass then
		menu:permaShow("HarassKey")
	end
	if menu.extra.permaShow.lclear then
		menu:permaShow("LaneClearKey")
	end
	if menu.extra.permaShow.jclear then
		menu:permaShow("JungleClearKey")
	end
	if menu.extra.permaShow.flee then
		menu:permaShow("FleeKey")
	end
end

-----------------------------------------------------------------------------------------------

function OnTick()
	if myHero.dead then return end
	if Loaded then
		ts:update()
		EnemyMinionManager:update()
		JungleMinionManager:update()
		target = ts.target
		Target = getTarget()
		orbwalkcheck()
		readycheck()
		if menu.ComboKey then
			combo()
		end
		if not LowManaHarass() then
			if menu.HarassKey then
				harass()
			end
		end
		if not LowManaFarm() then
			if menu.LastHitKey then
			farm()
			end
			if menu.LaneClearKey then
				laneclear()
			end
			if menu.JungleClearKey then
				jungleclear()
			end
		end
		if menu.FleeKey then
			flee()
		end
		if menu.ks.useQ then
			killsteal_Q()
		end
		if menu.ks.useE then
			killsteal_E()
		end
		if menu.ks.useR then
			killsteal_R()
		end
	end
end

-----------------------------

function readycheck()
  --Spell Check
	Qready = (myHero:CanUseSpell(_Q) == READY)
	Wready = (myHero:CanUseSpell(_W) == READY)
	Eready = (myHero:CanUseSpell(_E) == READY)
	Rready = (myHero:CanUseSpell(_R) == READY)
  --Get Item Slots
  	BFTSlot = GetInventorySlotItem(3188) --Black Fire Torch
  	DFGSlot = GetInventorySlotItem(3128) --Deathfire Grasp
  	ROSlot = GetInventorySlotItem(3143) --Randuins Omen
  --Item Check
	BFTready = (BFTSlot ~= nil and myHero:CanUseSpell(BFTSlot) == READY)
	DFGready = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	ROready = (ROSlot   ~= nil and myHero:CanUseSpell(ROSlot)   == READY)
end

-----------------------------
--Credits to bilbao--
function orbwalkcheck()
	if checkedMMASAC then return end
	if not (starttick + 5000 < GetTickCount()) then return end
	checkedMMASAC = true
    if _G.MMA_Loaded then
     	print(' >>[Better Nerf] Malphite: MMA found. MMA support loaded.')
		is_MMA = true
	end	
	if _G.AutoCarry then
		print(' >>[Better Nerf] Malphite: SAC found. SAC support loaded.')
		is_SAC = true
	end	
	if is_MMA then
		menu.Orbwalk:addSubMenu("Marksman's Mighty Assistant", "mma")
		menu.Orbwalk.mma:addParam("mmastatus", "Use MMA Target Selector", SCRIPT_PARAM_ONOFF, false)
		menu.Orbwalk:addParam("line", "", SCRIPT_PARAM_INFO, "")				
	end
	if is_SAC then
		menu.Orbwalk:addSubMenu("Sida's Auto Carry", "sac")
		menu.Orbwalk.sac:addParam("sacstatus", "Use SAC Target Selector", SCRIPT_PARAM_ONOFF, false)
		menu.Orbwalk:addParam("line", "", SCRIPT_PARAM_INFO, "")
	end
end
function getTarget()
	if not checkedMMASAC then return end
	if is_MMA and is_SAC then
		if menu.Orbwalk.mma.mmastatus then
			menu.Orbwalk.sac.sacstatus = false
			menu.Orbwalk.standartts = false
		elseif menu.Orbwalk.sac.sacstatus then
			menu.Orbwalk.mma.mmastatus = false
			menu.Orbwalk.standartts = false
		elseif	menu.Orbwalk.standartts then
			menu.Orbwalk.mma.mmastatus = false
			menu.Orbwalk.sac.sacstatus = false
		end
	end	
	if not is_MMA and is_SAC then
		if menu.Orbwalk.sac.sacstatus then
			menu.Orbwalk.standartts = false
		else
			menu.Orbwalk.standartts = true
		end	
	end
	if is_MMA and not is_SAC then
		if menu.Orbwalk.mma.mmastatus then
			menu.Orbwalk.standartts = false
		else
			menu.Orbwalk.standartts = true
		end	
	end
	if not is_MMA and not is_SAC then
		menu.Orbwalk.standartts = true	
	end	
	if _G.MMA_Target and _G.MMA_Target.type == myHero.type then
		return _G.MMA_Target 
	end
    if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then
		return _G.AutoCarry.Attack_Crosshair.target		
	end
    return ts.target	
end

-----------------------------

function combo()
	if ts.target ~= nil and not ts.target.dead then
		if GetDistance(ts.target) <= 750 and target.visible then
			if BFTready then
				CastSpell(BFTSlot, target) 
			end
			if DFGready then
				CastSpell(DFGSlot, target)
			end
		end
		if GetDistance(ts.target) <= 350 and target.visible then
			if ROready then
				CastSpell(ROSlot)
			end
		end
	end
	if Rready then
		if menu.combo.useR then
			if ValidTarget(target, Rrange) and target.visible then
				CastSpell(_R, target.x, target.z)
			end
		end
	end
	if Eready then
		if menu.combo.useE then
			if ValidTarget(target, Erange) and target.visible then
				if VIP_USER then
					if menu.extra.packet.useE then
						Packet("S_CAST", {spellId = _E}):send()
					else
						CastSpell(_E)
					end
				else
					CastSpell(_E)
				end
			end
		end
	end
	if Qready then
		if menu.combo.useQ then
			if ValidTarget(target, Qrange) and target.visible then
				if VIP_USER then
					if menu.extra.packet.useQ then
						Packet("S_CAST", {spellId = _Q, targetNetworkId = target.networkID}):send()
					else
						CastSpell(_Q, target)
					end
				else
					CastSpell(_Q, target)
				end
			end
		end
	end
	if Wready then
		if menu.combo.useW then
			if ValidTarget(target, 350) and target.visible then
				if VIP_USER then
					if menu.extra.packet.useW then
						Packet("S_CAST", {spellId = _W}):send()
					else
						CastSpell(_W)
					end
				else
					CastSpell(_W)
				end
			end
		end
	end
end
function harass()
	if Eready then
		if menu.harass.useE then
			if ValidTarget(target, Erange) and target.visible then
				if VIP_USER then
					if menu.extra.packet.useE then
						Packet("S_CAST", {spellId = _E}):send()
					else
						CastSpell(_E)
					end
				else
					CastSpell(_E)
				end
			end
		end
	end
	if Qready then
		if menu.harass.useQ then
			if ValidTarget(target, Qrange) and target.visible then
				if VIP_USER then
					if menu.extra.packet.useQ then
						Packet("S_CAST", {spellId = _Q, targetNetworkId = target.networkID}):send()
					else
						CastSpell(_Q, target)
					end
				else
					CastSpell(_Q, target)
				end
			end
		end
	end
end
function farm()
	local Minions = EnemyMinionManager.objects[1]
	for i, minion in pairs(EnemyMinionManager.objects) do
		if minion ~= nil and not minion.dead and minion.valid and minion.team ~= myHero.team and minion.visible then
			if GetDistance(Minions) > AArange then
				if Qready and menu.farm.lasthit.useQ then
					if GetDistance(Minions) < Qrange then
						if minion.health < getDmg("Q",minion,myHero) then
							if VIP_USER then
								if menu.extra.packet.useQ then
									Packet("S_CAST", {spellId = _Q, targetNetworkId = minion.networkID}):send()
								else
									CastSpell(_Q, minion)
								end
							else
								CastSpell(_Q, minion)
							end
						end
					end
				end
				if Eready and menu.farm.lasthit.useE then
					if GetDistance(Minions) < Erange then
						if minion.health < getDmg("E",minion,myHero) then
							if VIP_USER then
								if menu.extra.packet.useE then
									Packet("S_CAST", {spellId = _E}):send()
								else
									CastSpell(_E)
								end
							else
								CastSpell(_E)
							end
						end
					end
				end
			end
		end
	end
end
function laneclear()
	local Minions = EnemyMinionManager.objects[1]
	for i, minion in pairs(EnemyMinionManager.objects) do
		if minion ~= nil and not minion.dead and minion.valid and minion.team ~= myHero.team and minion.visible then
			if Wready and menu.farm.lclear.useW then
				if GetDistance(Minions) < AArange then
					if VIP_USER then
						if menu.extra.packet.useW then
							Packet("S_CAST", {spellId = _W}):send()
						else
							CastSpell(_W)
						end
					else
						CastSpell(_W)
					end
				end
			end
			if Qready and menu.farm.lclear.useQ then
				if GetDistance(Minions) < Qrange then
					if minion.health < getDmg("Q",minion,myHero) then
						if VIP_USER then
							if menu.extra.packet.useQ then
								Packet("S_CAST", {spellId = _Q, targetNetworkId = minion.networkID}):send()
							else
								CastSpell(_Q, minion)
							end
						else
							CastSpell(_Q, minion)
						end
					end
				end
			end
			if Eready and menu.farm.lclear.useE then
				if GetDistance(Minions) < Erange then
					if minion.health < getDmg("E",minion,myHero) then
						if VIP_USER then
							if menu.extra.packet.useE then
								Packet("S_CAST", {spellId = _E}):send()
							else
								CastSpell(_E)
							end
						else
							CastSpell(_E)
						end
					end
				end
			end
		end
	end
end
function jungleclear()
	local Minions = JungleMinionManager.objects[1]
	for i, minion in pairs(JungleMinionManager.objects) do
		if minion ~= nil and not minion.dead and minion.valid and minion.team ~= myHero.team and minion.visible then
			if Wready and menu.farm.jclear.useW then
				if GetDistance(Minions) < AArange then
					if VIP_USER then
						if menu.extra.packet.useW then
							Packet("S_CAST", {spellId = _W}):send()
						else
							CastSpell(_W)
						end
					else
						CastSpell(_W)
					end
				end
			end
			if Qready and menu.farm.jclear.useQ then
				if GetDistance(Minions) < Qrange then
					if VIP_USER then
						if menu.extra.packet.useQ then
							Packet("S_CAST", {spellId = _Q, targetNetworkId = minion.networkID}):send()
						else
							CastSpell(_Q, minion)
						end
					else
						CastSpell(_Q, minion)
					end
				end
			end
			if Eready and menu.farm.jclear.useE then
				if GetDistance(Minions) < Erange then
					if VIP_USER then
						if menu.extra.packet.useE then
							Packet("S_CAST", {spellId = _E}):send()
						else
							CastSpell(_E)
						end
					else
						CastSpell(_E)
					end
				end
			end
		end
	end
end
function flee()
	if menu.flee.move then
		myHero:MoveTo(mousePos.x, mousePos.z)
	end
	for i, minion in pairs(EnemyMinionManager.objects) do
  		if minion ~= nil and ValidTarget(minion, Qrange) and target.visible and Qready then
  			CastSpell(_Q, minion)
  		end
  	end
  	for i, minion in pairs(JungleMinionManager.objects) do
  		if minion ~= nil and ValidTarget(minion, Qrange) and target.visible and Qready then
  			CastSpell(_Q, minion)
  		end
  	end
  	for i, target in pairs(GetEnemyHeroes()) do
  		if target ~= nil and ValidTarget(target, 350) and target.visible and ROready then
			CastSpell(ROSlot)
		end
  		if target ~= nil and ValidTarget(target, Qrange) and target.visible and Qready then
  			CastSpell(_Q, target)
  		end
  	end
end

-----------------------------

function LowManaHarass()
    if myHero.mana < (myHero.maxMana * ( menu.harass.mana / 100)) then
        return true
    else
        return false
    end
end

function LowManaFarm()
    if myHero.mana < (myHero.maxMana * ( menu.farm.mana / 100)) then
        return true
    else
        return false
    end
end

-----------------------------

function killsteal_Q()
	local Enemies = GetEnemyHeroes()
	for i, enemy in pairs(Enemies) do
		if not enemy.dead and GetDistance(enemy) < Qrange then
			if getDmg("Q",enemy,myHero) > enemy.health and not enemy.dead then
				if VIP_USER then
					if menu.extra.packet.useE then
						Packet("S_CAST", {spellId = _Q, targetNetworkId = ts.target.networkID}):send()
					else
						CastSpell(_Q, target)
					end
				else
					CastSpell(_Q, target)
				end
			end
		end
	end
end
function killsteal_E()
	local Enemies = GetEnemyHeroes()
	for i, enemy in pairs(Enemies) do
		if not enemy.dead and GetDistance(enemy) < Erange then
			if getDmg("E",enemy,myHero) > enemy.health and not enemy.dead then
				if VIP_USER then
					if menu.extra.packet.useE then
						Packet("S_CAST", {spellId = _E}):send()
					else
						CastSpell(_E)
					end
				else
					CastSpell(_E)
				end
			end
		end
	end
end
function killsteal_R()
	local Enemies = GetEnemyHeroes()
	for i, enemy in pairs(Enemies) do
		if not enemy.dead and GetDistance(enemy) < Rrange then
			if getDmg("R",enemy,myHero) > enemy.health and not enemy.dead then
				CastSpell(_R, ts.target.x, ts.target.z)
			end
		end
	end
end

-----------------------------------------------------------------------------------------------

function OnProcessSpell(unit, spell)
	if menu.inter.inter1 and Rready then
		if #ToInterrupt > 0 then
			for _, Inter in pairs(ToInterrupt) do
				if spell.name == Inter.spellName and unit.team ~= myHero.team then
					if menu.inter[Inter.spellName] and ValidTarget(unit, Rrange) then
						CastSpell(_R, unit.visionPos.x, unit.visionPos.z)
					end
				end
			end
		end
	end
end

-----------------------------------------------------------------------------------------------

function OnDraw()
	if myHero.dead then return end
	if menu.draw.AA.draw then
		drawAA()
	end
	if menu.draw.Q.draw then
		drawQ()
	end
	if menu.draw.E.draw then
		drawE()
	end
	if menu.draw.R.draw then
		drawR()
	end
	if menu.draw.farm.draw == 2 then
		if menu.draw.farm.key1 or menu.draw.farm.key2 or menu.draw.farm.key3 or menu.draw.farm.key4 then
			drawLastHit()
		end
	elseif menu.draw.farm.draw == 3 then
		drawLastHit()
	end
	drawkillsteal()
	if menu.draw.drawpreddmg then
		drawpreddmg()
	end
end
function drawAA()
	if menu.draw.AA.lfc then
		DrawCircleAA(myHero.x, myHero.y, myHero.z, AArange, ARGB(menu.draw.AA.color[1],menu.draw.AA.color[2],menu.draw.AA.color[3],menu.draw.AA.color[4]))
	else
		DrawCircle(myHero.x, myHero.y, myHero.z, AArange, ARGB(menu.draw.AA.color[1],menu.draw.AA.color[2],menu.draw.AA.color[3],menu.draw.AA.color[4]))
	end
end
function drawQ()
	if menu.draw.Q.lfc then
		if Qready then
			DrawCircleQ(myHero.x, myHero.y, myHero.z, Qrange, ARGB(menu.draw.Q.color[1],menu.draw.Q.color[2],menu.draw.Q.color[3],menu.draw.Q.color[4]))
		end
		if not Qready and menu.draw.Q.ac then
			DrawCircleQ(myHero.x, myHero.y, myHero.z, Qrange, ARGB(menu.draw.Q.colorac[1],menu.draw.Q.colorac[2],menu.draw.Q.colorac[3],menu.draw.Q.colorac[4]))
		end
	else
		if Qready then
			DrawCircle(myHero.x, myHero.y, myHero.z, Qrange, ARGB(menu.draw.Q.color[1],menu.draw.Q.color[2],menu.draw.Q.color[3],menu.draw.Q.color[4]))
		end
		if not Qready and menu.draw.Q.ac then
			DrawCircle(myHero.x, myHero.y, myHero.z, Qrange, ARGB(menu.draw.Q.colorac[1],menu.draw.Q.colorac[2],menu.draw.Q.colorac[3],menu.draw.Q.colorac[4]))
		end
	end
end
function drawW()
	if menu.draw.W.lfc then
		if Wready then
			DrawCircleW(myHero.x, myHero.y, myHero.z, Wrange, ARGB(menu.draw.W.color[1],menu.draw.W.color[2],menu.draw.W.color[3],menu.draw.W.color[4]))
		end
		if not Wready and menu.draw.W.ac then
			DrawCircleW(myHero.x, myHero.y, myHero.z, Wrange, ARGB(menu.draw.W.colorac[1],menu.draw.W.colorac[2],menu.draw.W.colorac[3],menu.draw.W.colorac[4]))
		end
	else
		if Wready then
			DrawCircle(myHero.x, myHero.y, myHero.z, Wrange, ARGB(menu.draw.W.color[1],menu.draw.W.color[2],menu.draw.W.color[3],menu.draw.W.color[4]))
		end
		if not Wready and menu.draw.W.ac then
			DrawCircle(myHero.x, myHero.y, myHero.z, Wrange, ARGB(menu.draw.W.colorac[1],menu.draw.W.colorac[2],menu.draw.W.colorac[3],menu.draw.W.colorac[4]))
		end
	end
end
function drawE()
	if menu.draw.E.lfc then
		if Eready then
			DrawCircleE(myHero.x, myHero.y, myHero.z, Erange, ARGB(menu.draw.E.color[1],menu.draw.E.color[2],menu.draw.E.color[3],menu.draw.E.color[4]))
		end
		if not Eready and menu.draw.E.ac then
			DrawCircleE(myHero.x, myHero.y, myHero.z, Erange, ARGB(menu.draw.E.colorac[1],menu.draw.E.colorac[2],menu.draw.E.colorac[3],menu.draw.E.colorac[4]))
		end
	else
		if Eready then
			DrawCircle(myHero.x, myHero.y, myHero.z, Erange, ARGB(menu.draw.E.color[1],menu.draw.E.color[2],menu.draw.E.color[3],menu.draw.E.color[4]))
		end
		if not Eready and menu.draw.E.ac then
			DrawCircle(myHero.x, myHero.y, myHero.z, Erange, ARGB(menu.draw.E.colorac[1],menu.draw.E.colorac[2],menu.draw.E.colorac[3],menu.draw.E.colorac[4]))
		end
	end
end
function drawR()
	if menu.draw.R.lfc then
		if Rready then
			DrawCircleR(myHero.x, myHero.y, myHero.z, Rrange, ARGB(menu.draw.R.color[1],menu.draw.R.color[2],menu.draw.R.color[3],menu.draw.R.color[4]))
		end
		if not Rready and menu.draw.R.ac then
			DrawCircleR(myHero.x, myHero.y, myHero.z, Rrange, ARGB(menu.draw.R.colorac[1],menu.draw.R.colorac[2],menu.draw.R.colorac[3],menu.draw.R.colorac[4]))
		end
	else
		if Rready then
			DrawCircle(myHero.x, myHero.y, myHero.z, Rrange, ARGB(menu.draw.R.color[1],menu.draw.R.color[2],menu.draw.R.color[3],menu.draw.R.color[4]))
		end
		if not Rready and menu.draw.R.ac then
			DrawCircle(myHero.x, myHero.y, myHero.z, Rrange, ARGB(menu.draw.R.colorac[1],menu.draw.R.colorac[2],menu.draw.R.colorac[3],menu.draw.R.colorac[4]))
		end
	end
end
function drawLastHit()
	EnemyMinionManager:update()
	for i, minion in pairs(EnemyMinionManager.objects) do
		if minion ~= nil and minion.health < getDmg("AD",minion,myHero) then
			DrawCircleLastHit(minion.x, minion.y, minion.z, 65, ARGB(menu.draw.farm.color[1],menu.draw.farm.color[2],menu.draw.farm.color[3],menu.draw.farm.color[4]))	
		end
	end
end
function drawkillsteal()
	local Enemies = GetEnemyHeroes()
	if menu.draw.ks.drawQ then
		if Qready then
			for i, enemy in pairs(Enemies) do
				if ValidTarget(enemy, 2000) and not enemy.dead and GetDistance(enemy) < 3000 then
					if getDmg("Q",enemy,myHero) > enemy.health then
						DrawText3D("Press Q to kill!", enemy.x, enemy.y, enemy.z, 15, RGB(255, 150, 0), 0)
				        DrawCircle3D(enemy.x, enemy.y, enemy.z, 130, 1, RGB(255, 150, 0))
				        DrawCircle3D(enemy.x, enemy.y, enemy.z, 150, 1, RGB(255, 150, 0))
				        DrawCircle3D(enemy.x, enemy.y, enemy.z, 170, 1, RGB(255, 150, 0))
					end
				end
			end
		end
	end
	if menu.draw.ks.drawE then
		if Eready then
			for i, enemy in pairs(Enemies) do
				if ValidTarget(enemy, 2000) and not enemy.dead and GetDistance(enemy) < 3000 then
					if getDmg("E",enemy,myHero) > enemy.health then
						DrawText3D("Press E to kill!", enemy.x, enemy.y, enemy.z, 15, RGB(255, 150, 0), 0)
				        DrawCircle3D(enemy.x, enemy.y, enemy.z, 130, 1, RGB(255, 150, 0))
				        DrawCircle3D(enemy.x, enemy.y, enemy.z, 150, 1, RGB(255, 150, 0))
				        DrawCircle3D(enemy.x, enemy.y, enemy.z, 170, 1, RGB(255, 150, 0))
					end
				end
			end
		end
	end
	if menu.draw.ks.drawR then
		if Rready then
			for i, enemy in pairs(Enemies) do
				if ValidTarget(enemy, 2000) and not enemy.dead and GetDistance(enemy) < 3000 then
					if getDmg("R",enemy,myHero) > enemy.health then
						DrawText3D("Press R to kill!", enemy.x, enemy.y, enemy.z, 15, RGB(255, 150, 0), 0)
				        DrawCircle3D(enemy.x, enemy.y, enemy.z, 130, 1, RGB(255, 150, 0))
				        DrawCircle3D(enemy.x, enemy.y, enemy.z, 150, 1, RGB(255, 150, 0))
				        DrawCircle3D(enemy.x, enemy.y, enemy.z, 170, 1, RGB(255, 150, 0))
					end
				end
			end
		end
	end
end

function drawpreddmg()
	local currLine = 1
	for i, enemy in ipairs(GetEnemyHeroes()) do		
		if enemy~=nil and not enemy.dead and enemy.visible and ValidTarget(enemy) then		
			if Qready and not Eready and not Rready then
				DrawLineHPBar(dmgAA(enemy) + dmgQ(enemy), currLine, "Q "..dmgAA(enemy) + dmgQ(enemy) , enemy)
				currLine = currLine + 1
			end	
			if Eready and not Qready and not Rready then
				DrawLineHPBar(dmgE(enemy), currLine, "E "..dmgE(enemy) , enemy)
				currLine = currLine + 1
			end			
			if Qready and Eready and not Rready then
				DrawLineHPBar(dmgQ(enemy) + dmgE(enemy) + dmgAA(enemy), currLine, "Q+E: "..dmgQ(enemy) + dmgE(enemy) + dmgAA(enemy), enemy)
				currLine = currLine + 1
			end
			if Qready and Eready and Rready then
				DrawLineHPBar(dmgQ(enemy) + dmgE(enemy) + dmgR(enemy) + dmgAA(enemy), currLine, "Q+E+R: "..dmgQ(enemy) + dmgE(enemy) + dmgR(enemy) + dmgAA(enemy), enemy)
				currLine = currLine + 1
			end
		end
	end
end	
function dmgAA(target)
	local ADDmg = getDmg("AD", target, myHero)
	return math.round(ADDmg)
end
function dmgQ(target)
  local QDmg = getDmg("Q", target, myHero)
  return math.round(QDmg)
end
function dmgE(target)
	local EDmg = getDmg("E", target, myHero)
	return math.round(EDmg)
end
function dmgR(target)
	local RDmg = getDmg("R", target, myHero)
	return math.round(RDmg)
end


--------------------------[[Credits to barasia, vadash and viseversa]]-------------------------

--[[LFC Circle AA]]
function DrawCircleNextLvlAA(x, y, z, radius, width, color, chordlength)
	radius = radius or 300
	quality = math.max(8,math.floor(menu.draw.AA.quality/math.deg((math.asin((chordlength/(2*radius)))))))
	quality = 2 * math.pi / quality
	radius = radius*.92
	local points = {}
	for theta = 0, 2 * math.pi + quality, quality do
		local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
		points[#points + 1] = D3DXVECTOR2(c.x, c.y)
	end
	DrawLines2(points, width or 1, color or 4294967295)
end
function DrawCircleAA(x, y, z, radius, color)
	local vPos1 = Vector(x, y, z)
	local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
	local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
	local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
	if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y })  then
		DrawCircleNextLvlAA(x, y, z, radius, menu.draw.AA.width, color, 75)	
	end
end
--[[LFC Circle Q]]
function DrawCircleNextLvlQ(x, y, z, radius, width, color, chordlength)
	radius = radius or 300
	quality = math.max(8,math.floor(menu.draw.Q.quality/math.deg((math.asin((chordlength/(2*radius)))))))
	quality = 2 * math.pi / quality
	radius = radius*.92
	local points = {}
	for theta = 0, 2 * math.pi + quality, quality do
		local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
		points[#points + 1] = D3DXVECTOR2(c.x, c.y)
	end
	DrawLines2(points, width or 1, color or 4294967295)
end
function DrawCircleQ(x, y, z, radius, color)
	local vPos1 = Vector(x, y, z)
	local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
	local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
	local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
	if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y })  then
		DrawCircleNextLvlQ(x, y, z, radius, menu.draw.Q.width, color, 75)	
	end
end
--[[LFC Circle W]]
function DrawCircleNextLvlW(x, y, z, radius, width, color, chordlength)
	radius = radius or 300
	quality = math.max(8,math.floor(menu.draw.W.quality/math.deg((math.asin((chordlength/(2*radius)))))))
	quality = 2 * math.pi / quality
	radius = radius*.92
	local points = {}
	for theta = 0, 2 * math.pi + quality, quality do
		local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
		points[#points + 1] = D3DXVECTOR2(c.x, c.y)
	end
	DrawLines2(points, width or 1, color or 4294967295)
end
function DrawCircleW(x, y, z, radius, color)
	local vPos1 = Vector(x, y, z)
	local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
	local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
	local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
	if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y })  then
		DrawCircleNextLvlW(x, y, z, radius, menu.draw.W.width, color, 75)	
	end
end
--[[LFC Circle E]]
function DrawCircleNextLvlE(x, y, z, radius, width, color, chordlength)
	radius = radius or 300
	quality = math.max(8,math.floor(menu.draw.E.quality/math.deg((math.asin((chordlength/(2*radius)))))))
	quality = 2 * math.pi / quality
	radius = radius*.92
	local points = {}
	for theta = 0, 2 * math.pi + quality, quality do
		local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
		points[#points + 1] = D3DXVECTOR2(c.x, c.y)
	end
	DrawLines2(points, width or 1, color or 4294967295)
end
function DrawCircleE(x, y, z, radius, color)
	local vPos1 = Vector(x, y, z)
	local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
	local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
	local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
	if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y })  then
		DrawCircleNextLvlE(x, y, z, radius, menu.draw.E.width, color, 75)	
	end
end
--[[LFC Circle R]]
function DrawCircleNextLvlR(x, y, z, radius, width, color, chordlength)
	radius = radius or 300
	quality = math.max(8,math.floor(menu.draw.R.quality/math.deg((math.asin((chordlength/(2*radius)))))))
	quality = 2 * math.pi / quality
	radius = radius*.92
	local points = {}
	for theta = 0, 2 * math.pi + quality, quality do
		local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
		points[#points + 1] = D3DXVECTOR2(c.x, c.y)
	end
	DrawLines2(points, width or 1, color or 4294967295)
end
function DrawCircleR(x, y, z, radius, color)
	local vPos1 = Vector(x, y, z)
	local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
	local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
	local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
	if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y })  then
		DrawCircleNextLvlR(x, y, z, radius, menu.draw.R.width, color, 75)	
	end
end
--[[LFC Circle LastHit]]
function DrawCircleNextLvlLastHit(x, y, z, radius, width, color, chordlength)
	radius = radius or 300
	quality = math.max(8,math.floor(0/math.deg((math.asin((chordlength/(2*radius)))))))
	quality = 2 * math.pi / quality
	radius = radius*.92
	local points = {}
	for theta = 0, 2 * math.pi + quality, quality do
		local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
		points[#points + 1] = D3DXVECTOR2(c.x, c.y)
	end
	DrawLines2(points, width or 1, color or 4294967295)
end
function DrawCircleLastHit(x, y, z, radius, color)
	local vPos1 = Vector(x, y, z)
	local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
	local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
	local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
	if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y })  then
		DrawCircleNextLvlLastHit(x, y, z, radius, 4, color, 75)	
	end
end

-------------------------------------[[Credits to Ziikah]]-------------------------------------

function GetHPBarPos(enemy)
	enemy.barData = {PercentageOffset = {x = -0.05, y = 0}}
	local barPos = GetUnitHPBarPos(enemy)
	local barPosOffset = GetUnitHPBarOffset(enemy)
	local barOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
	local barPosPercentageOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
	local BarPosOffsetX = -50
	local BarPosOffsetY = 46
	local CorrectionY = 39
	local StartHpPos = 31
	barPos.x = math.floor(barPos.x + (barPosOffset.x - 0.5 + barPosPercentageOffset.x) * BarPosOffsetX + StartHpPos)
	barPos.y = math.floor(barPos.y + (barPosOffset.y - 0.5 + barPosPercentageOffset.y) * BarPosOffsetY + CorrectionY)
	local StartPos = Vector(barPos.x , barPos.y, 0)
	local EndPos = Vector(barPos.x + 108 , barPos.y , 0)
	return Vector(StartPos.x, StartPos.y, 0), Vector(EndPos.x, EndPos.y, 0)
end
function DrawLineHPBar(damage, line, text, unit)
	local thedmg = 0
	if damage >= unit.maxHealth then
		thedmg = unit.maxHealth-1
	else
		thedmg=damage
	end
	local StartPos, EndPos = GetHPBarPos(unit)
	local Real_X = StartPos.x+24
	local Offs_X = (Real_X + ((unit.health-thedmg)/unit.maxHealth) * (EndPos.x - StartPos.x - 2))
	if Offs_X < Real_X then Offs_X = Real_X end	
	local mytrans = 350 - math.round(255*((unit.health-thedmg)/unit.maxHealth)) ---   255 * 0.5
	if mytrans >= 255 then mytrans=254 end
	local my_bluepart = math.round(400*((unit.health-thedmg)/unit.maxHealth))
	if my_bluepart >= 255 then my_bluepart=254 end

	DrawLine(Offs_X-150, StartPos.y-(30+(line*15)), Offs_X-150, StartPos.y-2, 2, ARGB(mytrans, 255,my_bluepart,0))
	DrawText(tostring(text),15,Offs_X-148,StartPos.y-(30+(line*15)),ARGB(mytrans, 255,my_bluepart,0))
end
