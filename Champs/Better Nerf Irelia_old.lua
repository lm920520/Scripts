if myHero.charName ~= "Irelia" then return end
require 'VPrediction'
require 'SOW'
local version = "1.05"
local Author = "si7ziTV"
local TESTVERSION = false
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/si7ziTV/BoL/master/Scripts/Better Nerf Irelia.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."Better Nerf Irelia.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
 
function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>Better Nerf Irelia:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
local ServerData = GetWebResult(UPDATE_HOST, "/si7ziTV/BoL/master/Scripts/versions/Better Nerf Irelia.lua.version")
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
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

local REQUIRED_LIBS = {
		["SOW"] = "https://bitbucket.org/honda7/bol/raw/master/Common/SOW.lua",
	}

local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0
local SELF_NAME = GetCurrentEnv() and GetCurrentEnv().FILE_NAME or ""

function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<b>[Irelia]: Required libraries downloaded successfully, please reload (double F9).</b>")
	end
end

for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
	if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
		require(DOWNLOAD_LIB_NAME)
	else
		DOWNLOADING_LIBS = true
		DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1
		DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
	end
end

if DOWNLOADING_LIBS then return end

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--[other Stuff]--
local menu
local ts
local EnemyMinionManager = nil
local JungleMinionManager = nil
local ignite = nil
local IREADY = false

--[[Spell data]]--
local QReady, WReady, EReady, RReady = false, false, false, false

--[[Spell Range]]--
local AArange = 125
local Qrange = 650
local Wrange = 125
local Erange = 325
local Rrange = 1200

--[[Spell Damage]]--
local Qdamage = {20, 50, 80, 110, 140}
local Edamage = {80, 130, 180, 230, 280}
local Rdamage = {320, 480, 640}

--[[Spell Mana]]--
local Qmana = {60, 65, 70, 75, 80}
local Wmana = {40, 40, 40, 40, 40}
local Emana = {50, 55, 60, 65, 70}
local Rmana = {100, 100, 100} 

--[[Spell Scaling]]--
local Qscaling = 1
local Rscaling = 0.6

function OnLoad()
	VP = VPrediction()
	iSOW = SOW(VP)
	_Menu()
	_Init()
		PrintChat("<font color=\"#FE642E\"><b>" ..">>  Better nerf Irelia</b> by si7ziTV has been loaded")
		Loaded = true
end

function _Init()
	
	--[Minion Manager]--
	EnemyMinionManager = minionManager(MINION_ENEMY, Qrange, myHero, MINION_SORT_MAXHEALTH_DEC)
	JungleMinionManager = minionManager(MINION_JUNGLE, Qrange, myHero, MINION_SORT_MAXHEALTH_DEC)
	
	--[Target Selector]--
	ts = TargetSelector(TARGET_LOW_HP,650,DAMAGE_PHYSICAL) -- (mode, range, damageType)
	ts.name = "Irelia"
	
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
        ignite = SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
        ignite = SUMMONER_2
    end
	
	--[Evadeee Integration]--	
		if _G.Evadeee_Loaded then
		_G.Evadeee_Enabled = true
	end
end

--[ingame Menu]--
function _Menu()
	menu = scriptConfig("Irelia: Main Menu", "Better Nerf Irelia")
		
		--[Version, Author]--
		menu:addParam("Version", "Version", SCRIPT_PARAM_INFO, version)
		menu:addParam("Author", "Author", SCRIPT_PARAM_INFO, Author)
	
			-- Orbwalkstuff --
			menu:addSubMenu("Irelia: Orbwalk", "Orbwalk")
				iSOW:LoadToMenu(menu.Orbwalk)
			
			--[Menu: Combo]--
			menu:addSubMenu("Irelia: Combo", "combo")
				menu.combo:addParam("combokey","Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
				menu.combo:addParam("useQ","Use (Q)", SCRIPT_PARAM_ONOFF, true)
				menu.combo:addParam("useW","Use (W)", SCRIPT_PARAM_ONOFF, true)
				menu.combo:addParam("useE","Use (E)", SCRIPT_PARAM_ONOFF, false)
				menu.combo:addParam("useEstun", "Use (E) only if it stuns", SCRIPT_PARAM_ONOFF, true)
				menu.combo:addParam("useR","Use (R)", SCRIPT_PARAM_ONOFF, false)
				menu.combo:addParam("useitems","Use Items", SCRIPT_PARAM_ONOFF, true)
				--menu.combo:addParam("useQ2", "Use Q to Gapclose", SCRIPT_PARAM_ONOFF, true)
				--menu.combo:addParam("setgrange", "Set GapClosing Range", SCRIPT_PARAM_SLICE, 1300, 0, 1950)
			
			--[Menu: Harass]--
			menu:addSubMenu("Irelia: Harass", "harass")
				menu.harass:addParam("harasskey","Harras Key", SCRIPT_PARAM_ONKEYDOWN, false, 67)
				menu.harass:addParam("useQ","Use (Q)", SCRIPT_PARAM_ONOFF, true)
				menu.harass:addParam("useW","Use (W)", SCRIPT_PARAM_ONOFF, true)
				menu.harass:addParam("useE","Use (E)", SCRIPT_PARAM_ONOFF, false)
				menu.harass:addParam("useEstun", "Use (E) only if it stuns", SCRIPT_PARAM_ONOFF, true)
			
			--[Menu: Laneclear]--
			menu:addSubMenu("Irelia: Laneclear", "lclear")
				menu.lclear:addParam("clear", "Clear that Wave!", SCRIPT_PARAM_ONKEYDOWN, false, 86)
				menu.lclear:addParam("useQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
				menu.lclear:addParam("useW", "Use (W)", SCRIPT_PARAM_ONOFF, false)
				menu.lclear:addParam("useR", "Use (R)", SCRIPT_PARAM_ONOFF, false)
				menu.lclear:addParam("useitems", "Use Items", SCRIPT_PARAM_ONOFF, true)
			
			--[Menu: Jungleclear]--
			menu:addSubMenu("Irelia: Jungle clear", "jclear")
				menu.jclear:addParam("clear", "Clear that Camp!", SCRIPT_PARAM_ONKEYDOWN, false, 86)
				menu.jclear:addParam("useQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
				menu.jclear:addParam("useW", "Use (W)", SCRIPT_PARAM_ONOFF, true)
				menu.jclear:addParam("useE", "Use (E)", SCRIPT_PARAM_ONOFF, true)
				menu.jclear:addParam("useR", "Use (R)", SCRIPT_PARAM_ONOFF, false)
				menu.jclear:addParam("useitems", "Use Items", SCRIPT_PARAM_ONOFF, false)
				--menu.jclear:addParam("lasthitQ", "Lasthit Junglecreeps using (Q)", SCRIPT_PARAM_ONKEYDOWN, false, 71)
				

			--[Menu: Killsteal]--
			menu:addSubMenu("Irelia: Killsteal", "killsteal")
				menu.killsteal:addParam("killstealQ", "Use Smart Killsteal (Q)", SCRIPT_PARAM_ONOFF, true)
				--menu.killsteal:addParam("killstealR", "Cast (R) if killable", SCRIPT_PARAM_ONOFF, true)
				menu.killsteal:addParam("ignite", "Use Auto Ignite", SCRIPT_PARAM_ONOFF, true)
				--menu.killsteal:addParam("items", "Use Items", SCRIPT_PARAM_ONOFF, true)

			--[Menu: Misc]--
			menu:addSubMenu("Irelia: Misc", "misc")
				menu.misc:addSubMenu("Mana Management", "manamanage")
					menu.misc.manamanage:addParam("minmanafarm", "Minimum Mana to Farm", SCRIPT_PARAM_SLICE, 35, 0, 100)
					menu.misc.manamanage:addParam("minmanaharass", "Minimum Mana to Harass", SCRIPT_PARAM_SLICE, 25, 0, 100)
				--menu.misc:addParam("flee", "Flee", SCRIPT_PARAM_ONKEYDOWN, false, 84)
				menu.misc:addParam("evadeeeintegration", "Use Evadeee Integration (on Toggle)", SCRIPT_PARAM_ONOFF, true)

			--[Menu: Drawings]--
			menu:addSubMenu("Irelia: Drawings", "drawings")
				--menu.drawings:addSubMenu("Combo", "combo")
					--menu.drawings.combo:addParam("drawQway", "Draw Way Calculation Enemy using (Q)", SCRIPT_PARAM_ONOFF, true)
				menu.drawings:addSubMenu("Laneclear", "lclear")
					menu.drawings.lclear:addParam("Qdraw", "Draw Minions can be killed using (Q)", SCRIPT_PARAM_ONOFF, true)
				menu.drawings:addSubMenu("Jungleclear", "jclear")
					--menu.drawings.jclear:addParam("Qdraw", "Draw Junglecreeps can be killed using (Q)", SCRIPT_PARAM_ONOFF, true)
				menu.drawings:addSubMenu("Killsteal", "killsteal")
					menu.drawings.killsteal:addParam("Qdraw", "Draw Enemys can be killed using (Q)", SCRIPT_PARAM_ONOFF, true)
					--menu.drawings.killsteal:addParam("Rdraw", "Draw Enemys can be killed using (R)", SCRIPT_PARAM_ONOFF, true)
					
				--menu.drawings:addSubMenu("Flee", "flee")
					--menu.drawings.flee:addParam("drawQway", "Draw Way Calculation Minion using (Q)", SCRIPT_PARAM_ONOFF, true)
				menu.drawings:addSubMenu("Spells", "spells")
					menu.drawings.spells:addParam("drawAA", "Draw AA", SCRIPT_PARAM_ONOFF, true)
					menu.drawings.spells:addParam("drawQ", "Draw (Q)", SCRIPT_PARAM_ONOFF, true)
					menu.drawings.spells:addParam("drawE", "Draw (E)", SCRIPT_PARAM_ONOFF, false)
					menu.drawings.spells:addParam("drawR", "Draw (R)", SCRIPT_PARAM_ONOFF, false)
					menu.drawings.spells:addParam("drawadvanced", "Use Advanced Drawings", SCRIPT_PARAM_ONOFF, true)
				menu.drawings:addParam("antilag", "use Anti-Lag Circles", SCRIPT_PARAM_ONOFF, true)
				
				--[permaShow]--
				menu.combo:permaShow("combokey")
				menu.harass:permaShow("harasskey")
				menu.lclear:permaShow("clear")
				--menu.misc:permaShow("flee")
	end

function OnTick()
	if Loaded then
		ts:update()
		EnemyMinionManager:update()
		JungleMinionManager:update()
			
			--[Items]--
			ROready = (ROSlot   ~= nil and myHero:CanUseSpell(ROSlot)   == READY)
			TMready = (TMSlot   ~= nil and myHero:CanUseSpell(TMSlot)   == READY)
			HDAready = (HDASlot   ~= nil and myHero:CanUseSpell(HDASlot)   == READY)
			BWready = (BWSlot   ~= nil and myHero:CanUseSpell(BWSlot)   == READY)
			BRKready = (BRKSlot   ~= nil and myHero:CanUseSpell(BRKSlot)   == READY)
			
			--[Ignite]--
			IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
			
			--[Spells]--
			Qready = (myHero:CanUseSpell(_Q) == READY)
			Wready = (myHero:CanUseSpell(_W) == READY)
			Eready = (myHero:CanUseSpell(_E) == READY)
			Rready = (myHero:CanUseSpell(_R) == READY)
	
	if myHero.dead then return end
	
		if menu.combo.combokey then
			_combo()
		end
	
		if menu.harass.harasskey then
			_harass()
		end
	
		if menu.lclear.clear then
			_lclear()
		end
	
		if menu.jclear.clear then
			_jclear()
		end
	
		if menu.killsteal.killstealQ then
			_killstealQ()
		end
	
		if menu.killsteal.killstealR then
			_killstealR()
		end
	
		if menu.killsteal.ignite then
			_ignite()
		end
	
		_itemauto()
	
		if menu.misc.evadeeeintegration then
			_EvadeeeIntegration()
		end

	end
end

--[Combo]--
function _combo()
	ts:update()
	local Enemies = GetEnemyHeroes
	local target = ts.target
	
	if menu.combo.combokey and ts.target ~= nil then
		_itemslots()
			_itemslots2()
				if Qready and GetDistance(ts.target) < Qrange then
					CastSpell(_Q, target)
				end
						if Wready and GetDistance(ts.target) < Wrange then
							CastSpell(_W)
						end
								if Eready and 
								GetDistance(ts.target) < Erange and 
								menu.combo.useEstun and
								(myHero.health * 100 /myHero.maxHealth) < (ts.target.health * 100 /ts.target.maxHealth) then
									CastSpell(_E, target) 
								elseif Eready 
								and menu.combo.useE and 
								GetDistance(ts.target) < Erange and 
								menu.combo.useE then
									CastSpell(_E, target)
								end
										if Rready and 
										menu.combo.useR and 
										(ts.target) then
											CastSpell(_R, target.x, target.z)
					end
				end
			end
			
--[Harras]--
function _harass()
	ts:update()
	local target = ts.target
	if menu.harass.harasskey and _ManaFarm() and ts.target ~= nil then
		_itemslots()
			_itemslots2()
				if Qready and menu.harass.useQ and GetDistance(ts.target) < Qrange then
					CastSpell(_Q, target)
				end
						if Wready and menu.harass.useW and GetDistance(ts.target) < Wrange then
							CastSpell(_W)
						end
								if Eready and 
								GetDistance(ts.target) < Erange and 
								menu.harass.useEstun and
								(myHero.health * 100 /myHero.maxHealth) < (ts.target.health * 100 /ts.target.maxHealth) then
									CastSpell(_E, target) 
								elseif Eready 
								and menu.harass.useE and 
								GetDistance(ts.target) < Erange and 
								menu.combo.useE then
									CastSpell(_E, target)
			end
		end
	end

--[Laneclear]--
function _lclear()
  EnemyMinionManager:update()
		local Minions = EnemyMinionManager.objects[1]
			if Minions and GetDistance(Minions) < 160 and menu.lclear.clear and _ManaFarm() then
				CastSpell(_W)
			end
			_itemslots3()
		for i, minion in pairs(EnemyMinionManager.objects) do
			if minion ~= nil and 
			minion.valid and 
			minion.team ~= myHero.team and not 
			minion.dead and 
			minion.visible and 
			minion.health < (getDmg("Q",minion,myHero)+getDmg("AD",minion,myHero)) and
			menu.lclear.clear and 
			menu.lclear.useQ and 
			_ManaFarm() then
				CastSpell(_Q, minion)
			end
			if Rready and 
			menu.lclear.clear and
			menu.lclear.useR then
				CastSpell(_R, Minions.x, Minions.z)
			end
	end
end

--[Jungleclear]--
function _jclear()
  JungleMinionManager:update()
		local Minions = JungleMinionManager.objects[1]
			if Minions and GetDistance(Minions) < 160 and menu.jclear.clear and _ManaFarm() then
				CastSpell(_W)
			end
		_itemslots4()
		for i, minion in pairs(JungleMinionManager.objects) do
			if minion ~= nil and 
			minion.valid and 
			Minions and GetDistance(Minions) < Qrange and
			menu.jclear.clear and
			menu.jclear.useQ and 
			_ManaFarm() then
				CastSpell(_Q, minion)
			end
			if Eready and
			menu.jclear.clear and
			menu.jclear.useE then
				CastSpell(_E, minion)
			if Rready and 
			menu.jclear.clear and
			menu.jclear.useR then
				CastSpell(_R, Minions.x, Minions.z)
			end
		end
	end
end

--[Killsteal]--
function _killstealQ()
	local Enemies = GetEnemyHeroes()
		for i, enemy in pairs(Enemies) do
				if ValidTarget(enemy, Qrange) and not enemy.dead and GetDistance(enemy) < Qrange then
				if (getDmg("Q",enemy,myHero)+getDmg("AD",enemy,myHero)) > enemy.health and 							menu.killsteal.killstealQ then 
				CastSpell(_Q, ts.target)
			end
		end
	end
end

function _killstealR()
	local Enemies = GetEnemyHeroes()
end

function _ignite()
  if IREADY then
        local ignitedmg = 0
        for j = 1, heroManager.iCount, 1 do
            local enemyhero = heroManager:getHero(j)
            if ValidTarget(enemyhero, 600) then
                ignitedmg = 50 + 20 * myHero.level
                if enemyhero.health <= ignitedmg then
                    CastSpell(ignite, enemyhero)
											end
										end
                end
            end
        end

--[Mana Management]--
function _ManaHarras()
  if myHero.mana >= myHero.maxMana * (menu.misc.manamanage.minmanaharras / 100) then
    return true
  else
    return false
  end
end

function _ManaFarm()
  if myHero.mana >= myHero.maxMana * (menu.misc.manamanage.minmanafarm / 100) then
    return true
  else
    return false
  end
end

--[Evadeee Integration]--
function _EvadeeeIntegration()
	local minion = EnemyMinionManager.objects[1]
		if minion then
		if _G.Evadeee_impossibleToEvade and menu.misc.evadeeeintegration then
				CastSpell(_Q, minion)
		end
	end
 end

function _gapcloseminionenemy()
EnemyMinions:update()
	ts:update()
	local target = ts.target
for i, minion in pairs(EnemyMinionManager.objects) do
    if Target ~= nil and minion ~= nil then 
        if GetDistance(minion,Target) < GetDistance(minion,myHero) then 
            if minion.health < (getDmg("Q",minion,myHero)+getDmg("AD",minion,myHero)) then 
                return minion
            end 
        end 
    end 
end 
end 

--[Items]--
function _itemauto()
BRKSlot = GetInventorySlotItem(3153)
BWSlot = GetInventorySlotItem(3144)
ROSlot = GetInventorySlotItem(3143)
TMSlot = GetInventorySlotItem(3077)
HDASlot = GetInventorySlotItem(3074)

end

function _itemslots()
	if menu.combo.useitems and ts.target ~= nil and not ts.target.dead then
		if GetDistance(ts.target) <= Qrange then
			if BRKready then CastSpell(BRKSlot, ts.target) 
				end
			if BWready then CastSpell(BWSlot, ts.target) 
				end
			end
		end
	end

function _itemslots2()
	if menu.combo.useitems and ts.target ~= nil and not ts.target.dead then
		if GetDistance(ts.target) <= 200 then
			if TMready then CastSpell(TMSlot, ts.target) 
				end
			if ROready then CastSpell(ROSlot, ts.target) 
				end
			if HDAready then CastSpell(HDASlot, ts.target)
				end
			end
		end
	end

function _itemslots3()
	EnemyMinionManager:update()
		local Minions = EnemyMinionManager.objects[1]
			for i, minion in pairs(EnemyMinionManager.objects) do
				if Minions and GetDistance(Minions) < 200 and
				menu.lclear.useitems then
					if TMready then CastSpell(TMSlot, minion) 
						end
					if HDAready then CastSpell(HDASlot, minion)
				end
			end
		end
	end	

function _itemslots4()
	JungleMinionManager:update()
		local Minions = JungleMinionManager.objects[1]
			for i, minion in pairs(JungleMinionManager.objects) do
				if Minions and GetDistance(Minions) < 200 and
				menu.jclear.useitems then
					if TMready then CastSpell(TMSlot, minion) 
						end
					if HDAready then CastSpell(HDASlot, minion)
				end
			end
		end
	end	
		
	--[OnDraw]]-- 
 function OnDraw()
	if myHero.dead then return end
			_killstealQ_information()
			_draw_minion_killableQ()
			_draw_ranges()
			_draw_ranges_advanced()
			_draw_ranges_lagfree()
			_draw_ranges_lagfree_advanced()
end

function _killstealQ_information()
	if Qready then
		local Enemies = GetEnemyHeroes()
		for i, enemy in pairs(Enemies) do
			if ValidTarget(enemy, 2000) and not enemy.dead and GetDistance(enemy) < 3000 then
				if (getDmg("Q",enemy,myHero)+getDmg("AD",enemy,myHero)) > enemy.health and
				(menu.drawings.killsteal) then
				DrawText3D("Press Q to kill!", enemy.x, enemy.y, enemy.z, 15, RGB(255, 150, 0), 0)
        DrawCircle3D(enemy.x, enemy.y, enemy.z, 130, 1, RGB(255, 150, 0))
        DrawCircle3D(enemy.x, enemy.y, enemy.z, 150, 1, RGB(255, 150, 0))
        DrawCircle3D(enemy.x, enemy.y, enemy.z, 170, 1, RGB(255, 150, 0))
				end
			end
		end
	end
end

function _draw_minion_killableQ()
	EnemyMinionManager:update()
			if not menu.drawings.lclear then return end
				if Qready then
					_draw_minion_visible() 
					else _draw_minion_transparence()
	end
end

function _draw_ranges()
		if (menu.drawings.antilag) then return end
				if (menu.drawings.spells.drawAA) then 																	 --AA
						DrawCircle(myHero.x, myHero.y, myHero.z, 125, 0xFFFFFF) end
				if (menu.drawings.spells.drawQ and Qready) then --Q
						DrawCircle(myHero.x, myHero.y, myHero.z, 650, 0xFFFFFF) end
				if (menu.drawings.spells.drawE and Eready) then --E
						DrawCircle(myHero.x, myHero.y, myHero.z, 325, 0xFFFFFF) end
				if (menu.drawings.spells.drawR and Rready) then --R
						DrawCircle(myHero.x, myHero.y, myHero.z, 1000, 0xFFFFFF) end
end

function _draw_ranges_advanced()
		if (menu.drawings.antilag) then return end
				if (menu.drawings.spells.drawQ) and (menu.drawings.spells.drawadvanced) then --Q
						DrawCircle(myHero.x, myHero.y, myHero.z, 650, 0x5C5C5C) end
				if (menu.drawings.spells.drawE) and (menu.drawings.spells.drawadvanced) then --E
						DrawCircle(myHero.x, myHero.y, myHero.z, 325, 0x5C5C5C) end
				if (menu.drawings.spells.drawR) and (menu.drawings.spells.drawadvanced) then --R
						DrawCircle(myHero.x, myHero.y, myHero.z, 1000, 0x5C5C5C) end
end

function _draw_ranges_lagfree()
		if not (menu.drawings.antilag) then return end
				if (menu.drawings.spells.drawAA) then
						DrawCircle3D(myHero.x, myHero.y, myHero.z, 115, 1,  ARGB(255, 255, 255, 255)) end
				if (menu.drawings.spells.drawQ and Qready) then
						DrawCircle3D(myHero.x, myHero.y, myHero.z, 600, 1,  ARGB(255, 255, 255, 255)) end
				if (menu.drawings.spells.drawE and Eready) then
						DrawCircle3D(myHero.x, myHero.y, myHero.z, 300, 1,  ARGB(255, 255, 255, 255)) end
				if (menu.drawings.spells.drawR and Rready) then
						DrawCircle3D(myHero.x, myHero.y, myHero.z, 925, 1,  ARGB(255, 255, 255, 255)) end
end

function _draw_ranges_lagfree_advanced()
		if not (menu.drawings.antilag) then return end	
				if (menu.drawings.spells.drawQ) and (menu.drawings.spells.drawadvanced) then
						DrawCircle3D(myHero.x, myHero.y, myHero.z, 600, 1,  ARGB(80, 255, 255, 255)) end
				if (menu.drawings.spells.drawE) and (menu.drawings.spells.drawadvanced) then
						DrawCircle3D(myHero.x, myHero.y, myHero.z, 300, 1,  ARGB(80, 255, 255, 255)) end
				if (menu.drawings.spells.drawR) and (menu.drawings.spells.drawadvanced) then
						DrawCircle3D(myHero.x, myHero.y, myHero.z, 925, 1,  ARGB(80, 255, 255, 255)) end
end

function _draw_minion_visible()
			for i, minion in pairs(EnemyMinionManager.objects) do
				if minion ~= nil and 
					minion.health < (getDmg("Q",minion,myHero)+getDmg("AD",minion,myHero)) then
						DrawCircle3D(minion.x, minion.y, minion.z, 50, 2,  ARGB(255, 155, 255, 0))
		end
	end
end

function _draw_minion_transparence()
			for i, minion in pairs(EnemyMinionManager.objects) do
				if minion ~= nil and 
					minion.health < (getDmg("Q",minion,myHero)+getDmg("AD",minion,myHero)) then
						DrawCircle3D(minion.x, minion.y, minion.z, 50, 2,  ARGB(75, 155, 255, 0))
		end
	end
end
