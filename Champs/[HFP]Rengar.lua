if myHero.charName ~= "Rengar" then return end
--- [[Info]] --- 
local version = betatest_dontwork_willrewrite
local AUTOUPDATE = false
local SCRIPT_NAME = "[HFP]Rengar"
--- [[Update + Libs]] ---
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
SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/HFPDarkAlex/BoL/master/"..SCRIPT_NAME..".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/HFPDarkAlex/BoL/master/versions/"..SCRIPT_NAME..".version"):CheckUpdate()
end
local RequireI = Require("SourceLib")
RequireI:Add("vPrediction", "https://raw.githubusercontent.com/AWABoL150/BoL/master/Honda7-Scripts/common/VPrediction.lua")
RequireI:Add("SOW", "https://raw.githubusercontent.com/AWABoL150/BoL/master/Honda7-Scripts/common/SOW.lua")
RequireI:Check()
if RequireI.downloadNeeded == true then return end	
local MainCombo = {_Q, _W, _E, _IGNITE, _ITEMS}

--Spell Data
local Ranges = {[_Q] = 125, [_W] = 500, [_E] = 1000, [_R] = 0}
local Widths = {[_Q] = 0, [_W] = 1, [_E] = 70, [_R] = 0}
local Delays = {[_Q] = 0.5, [_W] = 0.5,  [_E] = 0.5, [_R] = 0.5}
local Speeds = {[_Q] = math.huge, [_W] = math.huge, [_E] = 1500, [_R] = math.huge}

lastAttack, lastWindUpTime, lastAttackCD = 0, 0, 0
Fury, qCount = 0, 0

function OnLoad()
	VP = VPrediction()
	SOWi = SOW(VP)
	STS = SimpleTS(STS_PRIORITY_LESS_CAST_PHYSICAL)
	DLib = DamageLib()
	DManager = DrawManager()
	
	Q = Spell(_Q, Ranges[_Q])
	W = Spell(_W, Ranges[_W])
	E = Spell(_E, Ranges[_E])
	R = Spell(_R, Ranges[_R])

	E:SetSkillshot(VP, SKILLSHOT_LINEAR, Widths[_Q], Delays[_Q], Speeds[_Q], true)

	W:SetAOE(true)

	DLib:RegisterDamageSource(_Q, _PHYSICAL, 0, 30, _PHYSICAL, _AD, 1.1, function() return (player:CanUseSpell(_Q) == READY) end)
	DLib:RegisterDamageSource(_W, _MAGIC, 20, 30, _MAGIC, _AP, 0.8, function() return (player:CanUseSpell(_W) == READY) end)
	DLib:RegisterDamageSource(_E, _PHYSICAL, 0, 50, _PHYSICAL, _AP, 0.7, function() return (player:CanUseSpell(_E) == READY) end)

	Menu = scriptConfig("[HFP]Rengar", "Rengar")

	-- Menu:addSubMenu("Orbwalking", "Orbwalking")
		-- SOWi:LoadToMenu(Menu.Orbwalking)

	Menu:addSubMenu("Target selector", "STS")
		STS:AddToMenu(Menu.STS)

	Menu:addSubMenu("Combo", "Combo")
		Menu.Combo:addParam("UseQ", "Use Q in combo", SCRIPT_PARAM_ONOFF , true)
		Menu.Combo:addParam("UseW", "Use W in combo", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("UseE", "Use E in combo", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("UseR", "Use R ???", SCRIPT_PARAM_ONKEYTOGGLE, true,   string.byte("Z"))
		Menu.Combo:addParam("UseIgnite", "Use ignite if the target is killable", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("Enabled", "Combo!", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Menu.Combo:permaShow("UseR")

	Menu:addSubMenu("Harass", "Harass")
		Menu.Harass:addParam("UseQ", "Harass using Q", SCRIPT_PARAM_ONOFF, true)
		Menu.Harass:addParam("UseW", "Harass using W", SCRIPT_PARAM_ONOFF, false)
		Menu.Harass:addParam("UseE", "Harass using E", SCRIPT_PARAM_ONOFF, true)
		Menu.Harass:addParam("Enabled", "Harass! (hold)", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("C"))
		Menu.Harass:addParam("Enabled2", "Harass! (toggle)", SCRIPT_PARAM_ONKEYTOGGLE, false,   string.byte("Y"))
		Menu.Harass:permaShow("Enabled2")

	Menu:addSubMenu("Farm", "Farm")
		Menu.Farm:addParam("UseQ",  "Use Q", SCRIPT_PARAM_LIST, 4, { "No", "Freeze", "LaneClear", "Both" })
		Menu.Farm:addParam("UseW",  "Use W", SCRIPT_PARAM_LIST, 3, { "No", "Freeze", "LaneClear", "Both" })
		Menu.Farm:addParam("UseE",  "Use E", SCRIPT_PARAM_LIST, 3, { "No", "Freeze", "LaneClear", "Both" })
		Menu.Farm:addParam("Freeze", "Farm freezing", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("C"))
		Menu.Farm:addParam("LaneClear", "Farm LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))

	Menu:addSubMenu("JungleFarm", "JungleFarm")
		Menu.JungleFarm:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Menu.JungleFarm:addParam("UseW", "Use W", SCRIPT_PARAM_ONOFF, false)
		Menu.JungleFarm:addParam("UseE", "Use E", SCRIPT_PARAM_ONOFF, false)
		Menu.JungleFarm:addParam("Enabled", "Farm jungle!", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))

	Menu:addSubMenu("Ultimate", "Ultimate")
		Menu.Ultimate:addParam("Auto",  "Auto ultimate if ", SCRIPT_PARAM_LIST, 1, { "No", ">0 targets", ">1 targets", ">2 targets", ">3 targets", ">4 targets" })
		Menu.Ultimate:addParam("AutoAim", "Cast ultimate!", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R"))

	Menu:addSubMenu("Drawings", "Drawings")
	--Spell ranges
	for spell, range in pairs(Ranges) do
		DManager:CreateCircle(myHero, range, 1, {255, 255, 255, 255}):AddToMenu(Menu.Drawings, SpellToString(spell).." Range", true, true, true)
	end
	DManager:CreateCircle(myHero, SOWi:MyRange(), 1, {255, 255, 255, 255}):AddToMenu(Menu.Drawings, "AA Range", true, true, true)
	--Predicted damage on healthbars
	DLib:AddToMenu(Menu.Drawings, MainCombo)

	EnemyMinions = minionManager(MINION_ENEMY, Ranges[_E], myHero, MINION_SORT_MAXHEALTH_DEC)
	JungleMinions = minionManager(MINION_JUNGLE, Ranges[_E], myHero, MINION_SORT_MAXHEALTH_DEC)

	TickLimiter(AutoR, 15)
	print("<font color='#ff8000'> >> [HFP]Rengar Loaded! </font>")
end

function isPoisoned(target)
	for i = 1, target.buffCount do
		local tBuff = target:getBuff(i)
		if BuffIsValid(tBuff) and tBuff.name:find("poison") and (tBuff.endT - (math.min(GetDistance(myHero.visionPos, target.visionPos), 700)/1900 + 0.25 + GetLatency()/2000) - GetGameTimer() > 0) then
			return true
		end
	end

	return false
end

function AutoE()
	if not E:IsReady() then return end
	for n = 1, 5 do
		local target = STS:GetTarget(Ranges[_E], n)
		if target and isPoisoned(target) then
			return E:Cast(target)
		end
	end
end

function UseSpells(UseQ, UseW, UseE, UseR)
	--Q
	if UseQ then
		local Qtarget = STS:GetTarget(Ranges[_Q])
		if Qtarget then
			Q:Cast(Qtarget)
myHero:Attack(Qtarget)
		end
	end

	--W
	if UseW then
		Wtarget = STS:GetTarget(Ranges[_W])
		if Wtarget then
			W:Cast(Wtarget)
		end
	end

	--E
	if UseE then
		Etarget = STS:GetTarget(Ranges[_E])
		if Etarget then 
			E:Cast(Etarget)
		end
	end

	--R
	if UseR then
		local Rtarget = STS:GetTarget(Ranges[_R])
		if Rtarget and DLib:IsKillable(Rtarget, MainCombo) then
			R:SetAOE(true, R.width, CountObjectsNearPos(Vector(Rtarget), 500, 500, SelectUnits(GetEnemyHeroes(), function(t) return ValidTarget(t) end)))
			R:Cast(Rtarget)
			R:SetAOE(true)
		end
	end
end

function SetAttacks()
	SOWi:DisableAttacks()
	if not W:IsReady() and not E:IsReady() then
		SOWi:EnableAttacks()
	end
end

function Combo()
	OrbWalk()
	if Menu.Combo.UseIgnite and _IGNITE then
		local Ignitetarget = STS:GetTarget(600)
		if Ignitetarget and DLib:IsKillable(Ignitetarget, MainCombo) then
			CastSpell(_IGNITE, Ignitetarget)
		end
	end

	UseSpells(Menu.Combo.UseQ, Menu.Combo.UseW, Menu.Combo.UseE, Menu.Combo.UseR)
	SetAttacks()
end

function Harass()
	VP.ShotAtMaxRange = true
	UseSpells(Menu.Harass.UseQ, Menu.Harass.UseW, Menu.Harass.UseE, false)
	VP.ShotAtMaxRange = false
end

function Farm()
	EnemyMinions:update()
	local UseQ = Menu.Farm.LaneClear and (Menu.Farm.UseQ >= 3) or (Menu.Farm.UseQ == 2)
	local UseW = Menu.Farm.LaneClear and (Menu.Farm.UseW >= 3) or (Menu.Farm.UseW == 2)
	local UseE = Menu.Farm.LaneClear and (Menu.Farm.UseE >= 3) or (Menu.Farm.UseE == 2)

	if UseQ then
		if Menu.Farm.Freeze then
			for i, minion in ipairs(EnemyMinions.objects) do
				if VP:GetPredictedHealth(minion, Delays[_Q] + 0.25) - 50 < 0 then
					CastSpell(_Q, minion.visionPos.x, minion.visionPos.z)
					break
				end
			end
		end
		if Menu.Farm.LaneClear then
			local AllMinions = SelectUnits(EnemyMinions.objects, function(t) return ValidTarget(t) end)
			AllMinions = GetPredictedPositionsTable(VP, AllMinions, Delays[_Q], Widths[_Q], Ranges[_Q] + Widths[_Q], math.huge, myHero, false)
			local BestPos, BestHit = GetBestCircularFarmPosition(Ranges[_Q] + Widths[_Q], Widths[_Q], AllMinions)

			if BestPos then
				CastSpell(_Q, BestPos.x, BestPos.z)
			end
		end
	end

	if UseW then
		local CasterMinions = SelectUnits(EnemyMinions.objects, function(t) return (t.charName:lower():find("wizard") or t.charName:lower():find("caster")) and ValidTarget(t) end)
		CasterMinions = GetPredictedPositionsTable(VP, CasterMinions, Delays[_W], Widths[_W], Ranges[_W], Speeds[_W], myHero, false)

		local BestPos, BestHit = GetBestCircularFarmPosition(Ranges[_W], Widths[_W]*1.5, CasterMinions)
		if BestHit > 2 then
			CastSpell(_W, BestPos.x, BestPos.z)
			do return end
		end
	end

	if UseE then
		local PoisonedMinions = SelectUnits(EnemyMinions.objects, function(t) return ValidTarget(t) and isPoisoned(t) end)
		for i, minion in ipairs(PoisonedMinions) do
			local time = 0.25 + 1900 / GetDistance(minion.visionPos, myHero.visionPos) + 0.1
			if VP:GetPredictedHealth(minion, time) - DLib:CalcSpellDamage(minion, _E) < 0 then
				CastSpell(_E, minion)
				break
			end
		end
	end
end

function JungleFarm()
	JungleMinions:update()
	local UseQ = Menu.JungleFarm.UseQ
	local UseW = Menu.JungleFarm.UseW
	local UseE = Menu.JungleFarm.UseE
	local minion = JungleMinions.objects[1]
	
	if UseQ and ValidTarget(minion) then
		Q:Cast(minion)
	end

	if UseW and ValidTarget(minion) then
		W:Cast(minion)
	end

	if UseE then
		local PoisonedMinions = SelectUnits(JungleMinions.objects, function(t) return ValidTarget(t) and isPoisoned(t) end)
		if #PoisonedMinions > 0 then
			CastSpell(_E, PoisonedMinions[1])
		end
	end
end

function OrbWalk()
	if ValidTarget(Target) and GetDistance(Target) <= trueRange() then
		if timeToShoot() then
			myHero:Attack(Target)
		elseif heroCanMove() then
			moveToCursor()
		end
	else
		moveToCursor()
		
	end
end

function trueRange()
	
		return myHero.range + GetDistance(myHero.minBBox)
	
end

function heroCanMove()
	return (GetTickCount() + GetLatency()/2 > lastAttack + lastWindUpTime + 20)
end

function timeToShoot()
	if DisableAttacks then
		return false
	end
	return (GetTickCount() + GetLatency()/2 > lastAttack + lastAttackCD)
end

function moveToCursor()
	if GetDistance(mousePos) > 150 or lastAnimation == "Idle1" then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized()*300
		myHero:MoveTo(moveToPos.x, moveToPos.z)
	end	
end

function OnTick()
	SOWi:EnableAttacks()
	Target = STS:GetTarget(600)
	Fury = myHero.mana

	if Menu.Combo.Enabled then
		Combo()
	elseif Menu.Harass.Enabled or Menu.Harass.Enabled2 then
		Harass()
	end

	if Menu.Farm.LaneClear or Menu.Farm.Freeze then
		Farm()
	end

	if Menu.JungleFarm.Enabled then
		JungleFarm()
	end


	--R aim
	if Menu.Ultimate.AutoAim then
		local Rtarget = STS:GetTarget(Ranges[_R])
		R:Cast(Rtarget)
	end
end

function AutoR()
	if Menu.Ultimate.Auto ~= 1 then
		local Rtarget = STS:GetTarget(Ranges[_R])
		R:SetAOE(true, R.width, Menu.Ultimate.Auto - 1)
		R:Cast(Rtarget)
		R:SetAOE(true)
	end
end

function OnProcessSpell(object,spell)
--	gragasbarrelrolltoggle
	if object == myHero then
		if spell.name:lower():find("attack") then
			lastAttack = GetTickCount() - GetLatency()/2
			lastWindUpTime = spell.windUpTime*1000
			lastAttackCD = spell.animationTime*1000
		end
		
		if spell.name:find("RengarQ") then
			qCount = qCount + 1

		end
	end
end