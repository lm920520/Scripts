-- #################################################################################################
-- ##                                                                                             ##
-- ##                     Glory Ryze Script                                                       ##
-- ##                                Version 3.8 final                                            ##
-- ##                                         based of Ultimate Ryze by bnsfg                     ##
-- ##                                                                                             ##
-- ##                            Completely Rewritten by Wursti                                   ##
-- ##                                                                                             ##
-- #################################################################################################

-- #################################################################################################
-- ##                               Main Features & Changelog                                     ##
-- #################################################################################################
-- ## 2.0 - First Rewritten Release                                                               ##
-- ## 2.1 - New Long Combo                                                                        ##
-- ##     - Cage fleeing Enemies                                                                  ##
-- ## 2.2 - New Harass (Auto Q Enemy in Range)                                                    ##
-- ##     - Combo Switcher (Burst > Long                                                          ##
-- ## 2.3 - Auto AA Farm                                                                          ##
-- ## 2.4 - Fixed Bugs + Siege and Super Minion W and Q Farm if Q Framing Enabled                 ##
-- ## 2.41- Fixed Critical Typo                                                                   ##
-- ## 2.42- AA Farm was Toggle should be Hotkey so fixed as Hotkey                                ##
-- ## 2.43- Fixed Bug that Siege Minion caused Auto Q stop working for smaller Minions            ##
-- ## 2.44- Mouse Follow Toggle                                                                   ##
-- ## 2.5 - Auto Cage if Enemy under Tower Harass (Many Thx at vadash)                            ##
-- ## 2.6 - W Cage Only Nearest Champion  (Thx at Trus for findClosestEnemy)                      ##
-- ## 2.7 - Improved OnDraw (Show Killable-Text even with Circles Disabled)                       ##
-- ##     - New Menu "Ryze Combo Config" En- and Disable all PermaShow Info (Need Reload F9)      ##
-- ## 3.0 - Power Farmer:                                                                         ##
-- ##     - Combo Jungle Creeps if no Target is around (Thx at AutoSmite by eXtragoZ)             ##
-- ##       Q - R(if Activated in Settings) - Q - W - Q - E - Q and so on...                      ##
-- ##     - Fixed a possible Bug in Long Combo                                                    ##
-- ##     - Redesigned Settings Menu for some Cleanup                                             ##
-- ## 3.1 - New Item Support (DFG,HXG,BWC) and Ignite Support (Thx at Burn)                       ##
-- ## 3.2 - Improved Tower Caging (Cage if Enemy casts against you in Tower Range -> No flee)     ##
-- ## 3.3 - New Steal Objectives Mode                                                             ##
-- ## 3.4 - Multiple Changes at Combos                                                            ##
-- ## 3.5 - Jungle Creeps Combo now a Hotkey                                                      ##
-- ##     - Added small Camps to Combo                                                            ##
-- ##     - New Follow Cursor Modes:                                                              ##
-- ##                                - Follow Cursor if Combo Key pressed                         ##
-- ##                                - Follow Cursor if Spell is Casted                           ##
-- ## 3.6 - Auto Muramana Toggle :)                                                               ##
-- ## 3.61- Bugfixed!                                                                             ##
-- ## 3.7 - I hope this Relese fixed the non Save of Settings                                     ##
-- ## 3.71- Use Ultimate in Jungle Combo is a Key Toggle again (L by default)                     ##
-- #################################################################################################

-- #################################################################################################
-- ## TODO:                                                                                       ##
-- #################################################################################################

-- #################################################################################################
-- ## Please Send me your Feedback so I can improve this Script further :)                        ##
-- #################################################################################################


if GetMyHero().charName ~= "Ryze" then return end

qRange = 600
wRange = 600
eRange = 600 -- Real range is 600
rRange = 200 -- Range of your ulti AOE
AARange = 550
JungleRange = 1000
turretRange = 950
local waittxt = {}
local calculationenemy = 1
local tick = nil
killable = {}
turrets = {}
qcasted = true
waitDelay = 50
nextTick = 0
CageTurret = nil
Switch = false
targeting = false
local ignite = nil
local DFGSlot, HXGSlot, BWCSlot = nil, nil, nil
local DFGREADY, HXGREADY, BWCREADY, IREADY = false, false, false, false
local floattext = {"Cooldown!","Murder him!"}

function OnLoad()
	lastcast = _R
	RyzeConfig = scriptConfig("Ryze Combo", "Ryze_Config")
	RyzeConfigConfig = scriptConfig("Ryze Combo Visual Config", "Ryze_Config_Config")
	RyzeSettings = scriptConfig("Ryze Combo Settings", "Ryze_Settings")
	RyzeConfig:addParam("BurstActive", "Burst Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	RyzeConfig:addParam("LongActive", "Long Combo", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	RyzeConfig:addParam("Ignite", "Ignite if Killable", SCRIPT_PARAM_ONKEYTOGGLE, true, 79)
	RyzeConfig:addParam("JungleActive", "Jungle Creeps Combo", SCRIPT_PARAM_ONKEYDOWN, false, 66)
	RyzeConfig:addParam("useUlti", "Use ultimate in combos", SCRIPT_PARAM_ONOFF, true)
	RyzeConfig:addParam("useUltiJungle", "Use ultimate in Jungle combos", SCRIPT_PARAM_ONKEYDOWN, true, 76)
	RyzeConfig:addParam("useMura", "Auto use Muramana if Champs around", SCRIPT_PARAM_ONOFF, true)
	RyzeSettings:addParam("minMuraMana", "Min Mana Muramana", SCRIPT_PARAM_SLICE, 25, 0, 100, 2)
	RyzeConfig:addParam("cageW", "Cage Enemy unter Tower Harass", SCRIPT_PARAM_ONKEYTOGGLE, true, 85)
	RyzeConfig:addParam("autoQFarm", "Auto Q Farm", SCRIPT_PARAM_ONKEYTOGGLE, false, 84)
	RyzeConfig:addParam("PowerFarm", "Power Farm", SCRIPT_PARAM_ONKEYTOGGLE, false, 73)
	RyzeConfig:addParam("autoAAFarm", "Auto AA Farm", SCRIPT_PARAM_ONKEYDOWN, false, 220)
	RyzeSettings:addParam("autoAAFollow", "Auto AA Follow Cursor Toggle", SCRIPT_PARAM_ONOFF, true)
	RyzeSettings:addParam("autoMouseFollow", "Go to Cursor at Spell Cast", SCRIPT_PARAM_ONOFF, false)
	RyzeSettings:addParam("autoComboFollow", "Auto Follow Cursor if Combo Key pressed", SCRIPT_PARAM_ONOFF, true)
	RyzeConfig:addParam("autoQToggle", "Auto Q Harass (Toggle)", SCRIPT_PARAM_ONKEYTOGGLE, false, 90)
	RyzeConfig:addParam("autoQHarass", "Auto Q Harass (Hotkey)", SCRIPT_PARAM_ONKEYDOWN, false, 65)
	RyzeSettings:addParam("qMinMana", "Auto Q Farm min mana %",  SCRIPT_PARAM_SLICE, 50, 0, 100, 2)
	RyzeSettings:addParam("qMinManaHarass", "Auto Q Harass min mana %", SCRIPT_PARAM_SLICE, 50, 0, 100, 2)
	RyzeSettings:addParam("PowerMinMana", "Power Farm min mana %", SCRIPT_PARAM_SLICE, 50, 0, 100, 2)
	RyzeConfig:addParam("CageHunter", "Cage nearest Enemy Champion", SCRIPT_PARAM_ONKEYDOWN, false, 67)
	RyzeSettings:addParam("whunt", "First cage with W range", SCRIPT_PARAM_SLICE, 550, 0, 625, 0)
	RyzeSettings:addParam("wflee", "First cage in Long Combo if fleeing", SCRIPT_PARAM_SLICE, 550, 0, 625, 0)
	RyzeSettings:addParam("winsta", "Cage without waiting on Q if fleeing", SCRIPT_PARAM_ONKEYTOGGLE, true, 77)
	RyzeSettings:addParam("ComboSwitch", "Switch Combo", 	SCRIPT_PARAM_ONKEYTOGGLE, true, 78)
	RyzeSettings:addParam("minCDRnew", "CDR % to switch Combo", SCRIPT_PARAM_SLICE, 35, 0, 40, 0)
	RyzeConfigConfig:addParam("BurstActiveshow", "Show: Burst Combo", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("LongActiveshow", "Show: Long Combo", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("useUltishow", "Show: Use ultimate in combos", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("cageWshow", "Show: Cage Enemy unter Tower Harass", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("CageHuntershow", "Show: Cage nearest Enemy Champion", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("winstashow", "Show: Cage without waiting on Q if fleeing", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("autoQFarmshow", "Show: Auto Q Farm", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("PowerFarmshow", "Show: Power Farm", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("autoAAFarmshow", "Show: autoAAFarm", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("autoQToggleshow", "Show: Auto Q Harass (Toggle)", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("autoQHarassshow", "Show: Auto Q Harass (Hotkey)", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("ComboSwitchshow", "Show: Switch Combo", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	if RyzeConfigConfig.BurstActiveshow then RyzeConfig:permaShow("BurstActive") end
	if RyzeConfigConfig.LongActiveshow then RyzeConfig:permaShow("LongActive") end
	if RyzeConfigConfig.useUltishow then RyzeConfig:permaShow("useUlti") end
	if RyzeConfigConfig.cageWshow then RyzeConfig:permaShow("cageW") end
	if RyzeConfigConfig.CageHuntershow then RyzeConfig:permaShow("CageHunter") end
	if RyzeConfigConfig.winstashow then RyzeSettings:permaShow("winsta") end
	if RyzeConfigConfig.autoQFarmshow then RyzeConfig:permaShow("autoQFarm") end
	if RyzeConfigConfig.PowerFarmshow then RyzeConfig:permaShow("PowerFarm") end
	if RyzeConfigConfig.autoAAFarmshow then RyzeConfig:permaShow("autoAAFarm") end
	if RyzeConfigConfig.autoQToggleshow then RyzeConfig:permaShow("autoQToggle") end
	if RyzeConfigConfig.autoQHarassshow then RyzeConfig:permaShow("autoQHarass") end
	if RyzeConfigConfig.ComboSwitchshow then RyzeSettings:permaShow("ComboSwitch") end
	ts = TargetSelector(TARGET_PRIORITY,qRange,DAMAGE_MAGIC,false)
	ts.name = "Ryze"
	ASLoadMinions()
	RyzeConfig:addTS(ts)
	for i=1, heroManager.iCount do waittxt[i] = i*3 end
	enemyMinions = minionManager(MINION_ENEMY, qRange, player, MINION_SORT_HEALTH_ASC)
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
		ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
		ignite = SUMMONER_2 
	end
	for i = 1, objManager.maxObjects do
		local object = objManager:getObject(i)
		if object ~= nil and object.type == "obj_AI_Turret" then
			local turretName = object.name
			turrets[turretName] = 
			{
				object = object,
				team = object.team,
				range = turretRange,
				x = object.x,
				y = object.y,
				z = object.z,
				active = false,
			}
		end
	end
end


function doSpell(ts, spell, range)
	if ts.target ~= nil and GetMyHero():CanUseSpell(spell) == READY and GetDistance(ts.target)<=range then
		CastSpell(spell, ts.target)
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

function OnDraw()
	if myHero.dead then return end  
	if RyzeConfig.LongActive then DrawCircle(myHero.x, myHero.y, myHero.z, RyzeSettings.wflee, 0xFFFF0000) end
	if RyzeConfigConfig.drawcircles and not myHero.dead then
		if QREADY then DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x19A712)
		else DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x992D3D) end
		if WREADY then DrawCircle(myHero.x, myHero.y, myHero.z, wRange, 0x19A712)
		else DrawCircle(myHero.x, myHero.y, myHero.z, wRange, 0x992D3D) end
		if EREADY then DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0x19A712)
		else DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0x992D3D) end
	end
	for i=1, heroManager.iCount do
		local enemydraw = heroManager:GetHero(i)
		if ValidTarget(enemydraw) then
			if RyzeConfigConfig.drawcircles then
				if killable[i] == 1 then
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80, 0x0000FF)
				elseif killable[i] == 2 then
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80, 0xFF0000)
				end
				if waittxt[i] == 1 and killable[i] ~= 0 then
				end
				if waittxt[i] == 1 then 
					waittxt[i] = 30
				else waittxt[i] = waittxt[i]-1
				end
			end
		end
	end
	if RyzeConfigConfig.drawcircles and ValidTarget(ts.target) then
		DrawCircle(ts.target.x, ts.target.y, ts.target.z, 100, 0xFF80FF00)
	end
	if MonsterTarget ~= nil and ValidTarget(MonsterTarget) then
		if RyzeConfigConfig.drawcircles then DrawCircle(MonsterTarget.x, MonsterTarget.y, MonsterTarget.z, 100, 0xFF80FF00) end
		if MonsterKillable == true and RyzeConfigConfig.drawcircles then
			DrawCircle(MonsterTarget.x, MonsterTarget.y, MonsterTarget.z, 150, 0xFF0000)
			DrawCircle(MonsterTarget.x, MonsterTarget.y, MonsterTarget.z, 160, 0xFF0000)
			DrawCircle(MonsterTarget.x, MonsterTarget.y, MonsterTarget.z, 170, 0xFF0000)
		end
	end
end


function RyzeDmg()
	local enemy = heroManager:GetHero(calculationenemy)
	if ValidTarget(enemy) then
		local qdamage = getDmg("Q",enemy,myHero) --Normal
		local wdamage = getDmg("W",enemy,myHero)
		local edamage = getDmg("E",enemy,myHero)
		local hitdamage = getDmg("AD",enemy,myHero)
		local dfgdamage = (DFGSlot and getDmg("DFG",enemy,myHero) or 0)
		local hxgdamage = (HXGSlot and getDmg("HXG",enemy,myHero) or 0)
		local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)
		local brkdamage = (BRKREADY and getDmg("RUINEDKING",enemy,myHero,2) or 0)
		local ignitedamage = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
		local onhitdmg = (SheenSlot and getDmg("SHEEN",enemy,myHero) or 0)+(TrinitySlot and getDmg("TRINITY",enemy,myHero) or 0)+(LBSlot and getDmg("LICHBANE",enemy,myHero) or 0)+(IcebornSlot and getDmg("ICEBORN",enemy,myHero) or 0)
		local onspelldamage = (LTSlot and getDmg("LIANDRYS",enemy,myHero) or 0)+(BTSlot and getDmg("BLACKFIRE",enemy,myHero) or 0)
		local combo1 = qdamage + qdamage + wdamage + edamage + onhitdmg + onspelldamage
		local combo2 = 0
		if myHero:CanUseSpell(_Q) == READY then
			combo2 = qdamage + combo2
		end
		if myHero:CanUseSpell(_E) == READY then
			combo2 = edamage + combo2
		end
		if myHero:CanUseSpell(_W) then
			combo2 = wdamage + combo2
		end
		if myHero:CanUseSpell(_Q) and myHero:CanUseSpell(_E) and myHero:CanUseSpell(_W) == READY then
			combo2 = qdamage + combo2
		end
		if myHero:CanUseSpell(_Q) or myHero:CanUseSpell(_E) or myHero:CanUseSpell(_W) == READY then
			combo2 = combo2 + onhitdmg + onspelldamage
		end
		if DFGREADY then
			combo1 = combo1 + dfgdamage
			combo2 = combo2 + dfgdamage
		end
		if HXGREADY then               
			combo1 = combo1 + hxgdamage*(DFGREADY and 1.2 or 1)
			combo2 = combo2 + hxgdamage*(DFGREADY and 1.2 or 1)
		end
		if BWCREADY then
			combo1 = combo1 + bwcdamage*(DFGREADY and 1.2 or 1)
			combo2 = combo2 + bwcdamage*(DFGREADY and 1.2 or 1)
		end
		if BRKREADY then
			combo1 = combo1 + brkdamage
			combo2 = combo2 + brkdamage
		end
		if IREADY then
			combo1 = combo1 + ignitedamage
			combo2 = combo2 + ignitedamage
		end
		if combo2 >= enemy.health then killable[calculationenemy] = 2
		elseif combo1 >= enemy.health then killable[calculationenemy] = 1
		else killable[calculationenemy] = 0
		end
	end
	if calculationenemy == 1 then
		calculationenemy = heroManager.iCount
	else
		calculationenemy = calculationenemy-1
	end
end

function OnTick()
checkTurretState()
ts:update()
enemyMinions:update()
if tick == nil or GetTickCount()-tick >= 100 then
	tick = GetTickCount()
	RyzeDmg()
	RyzeItem()
end
if math.abs(myHero.cdr*100) >= RyzeSettings.minCDRnew and RyzeSettings.ComboSwitch then
	Switch = true
else
	Switch = false
end
CageTurret = findClosestTurret()
if myHero:GetDistance(CageTurret.object) <= 1250 and CageTurret.team == player.team then
	InTurretRange = true
else
	InTurretRange = false
end
if not myHero.dead then
	if RyzeConfig.useMura then
		MuramanaToggle(1000, ((player.mana / player.maxMana) > (RyzeSettings.minMuraMana / 100)))
	end
	if RyzeConfig.BurstActive and ValidTarget(ts.target) and Switch == false then
		if DFGREADY then
			CastSpell(DFGSlot, ts.target)
		end
		if HXGREADY then
			CastSpell(HXGSlot, ts.target)
		end
		if BWCREADY then
			CastSpell(BWCSlot, ts.target)
		end
		if myHero:CanUseSpell(_Q) == READY then
				doSpell(ts, _Q, qRange)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			elseif myHero:CanUseSpell(_W) == READY then
				doSpell(ts, _W, eRange)
			elseif myHero:CanUseSpell(_E) == READY then
				doSpell(ts, _E, wRange)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			elseif RyzeConfig.useUlti and myHero:CanUseSpell(_R) == READY then
				CastSpell(_R)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			elseif myHero:CanUseSpell(_Q) == READY then
				doSpell(ts, _Q, qRange)
        end
	elseif (RyzeConfig.LongActive or (Switch and RyzeConfig.BurstActive)) and ValidTarget(ts.target) then
		if DFGREADY then
			CastSpell(DFGSlot, ts.target)
		end
		if HXGREADY then
			CastSpell(HXGSlot, ts.target)
		end
		if BWCREADY then
			CastSpell(BWCSlot, ts.target)
		end
		if myHero:CanUseSpell(_Q) == READY and myHero:GetDistance(ts.target) <= RyzeSettings.whunt then
			doSpell(ts, _Q, qRange)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			qcasted = true
			if RyzeConfig.useUlti and myHero:CanUseSpell(_R) == READY and qcasted == true and myHero:CanUseSpell(_Q) == COOLDOWN then
				CastSpell(_R)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
				qcasted = false
			end
		elseif myHero:CanUseSpell(_W) == READY and myHero:GetDistance(ts.target) > RyzeSettings.whunt then
			doSpell(ts, _W, wRange)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			qcasted = false
			if myHero:CanUseSpell(_Q) == READY then
				doSpell(ts, _Q, qRange)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
				qcasted = true
			end
		elseif myHero:CanUseSpell(_Q) == READY then
			doSpell(ts, _Q, qRange)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			qcasted = true
		elseif RyzeConfig.useUlti and myHero:CanUseSpell(_R) == READY and qcasted == true and myHero:CanUseSpell(_Q) == COOLDOWN then
			CastSpell(_R)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			qcasted = false
		elseif myHero:CanUseSpell(_W) == READY and ((qcasted == true and myHero:CanUseSpell(_Q) == COOLDOWN and myHero:GetDistance(ts.target) >= RyzeSettings.wflee) or (RyzeSettings.winsta == true and myHero:GetDistance(ts.target) >= RyzeSettings.wflee)) then
			doSpell(ts, _W, wRange)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			qcasted = false
		elseif myHero:CanUseSpell(_E) == READY and qcasted == true and myHero:CanUseSpell(_Q) == COOLDOWN then
			doSpell(ts, _E, wRange)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			qcasted = false
		elseif myHero:CanUseSpell(_W) == READY and qcasted == true and myHero:CanUseSpell(_Q) == COOLDOWN then
			doSpell(ts, _W, wRange)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			qcasted = false
		end
	elseif RyzeConfig.JungleActive then
		closest = findClosestEnemy()
		if ValidTarget(closest) then
			if myHero:GetDistance(closest) > JungleRange then
				SaveJungle = true 
			end
		elseif closest == nil then
			SaveJungle = true 
		else
			SaveJungle = false
		end
		if ValidTarget(MonsterTarget) then 
			if myHero:GetDistance(MonsterTarget) > eRange then
				MiniMonster = false
				CheckMonster(Vilemaw)
				CheckMonster(Nashor)
				CheckMonster(Dragon)
				CheckMonster(Golem1)
				CheckMonster(Golem2)
				CheckMonster(Lizard1)
				CheckMonster(Lizard2)
			end
		else
			MiniMonster = false
			CheckMonster(Vilemaw)
			CheckMonster(Nashor)
			CheckMonster(Dragon)
			CheckMonster(Golem1)
			CheckMonster(Golem2)
			CheckMonster(Lizard1)
			CheckMonster(Lizard2)
		end
		if SaveJungle == true and MiniMonster == false and targeting == true then
			if myHero:CanUseSpell(_Q) == READY and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=qRange then
				CastSpell(_Q, MonsterTarget)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
				qcasted = true
			elseif RyzeConfig.useUltiJungle and myHero:CanUseSpell(_R) == READY and qcasted == true and myHero:CanUseSpell(_Q) == COOLDOWN and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=qRange then
				CastSpell(_R)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
				qcasted = false
			elseif myHero:CanUseSpell(_E) == READY and qcasted == true and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=eRange then
				CastSpell(_E, MonsterTarget)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
				qcasted = false
			elseif myHero:CanUseSpell(_W) == READY and qcasted == true and myHero:CanUseSpell(_Q) == COOLDOWN and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=wRange then
				CastSpell(_W, MonsterTarget)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
				qcasted = false
			end
		if ValidTarget(MonsterTarget) then
			if ((MonsterDMG("Q",_Q,MonsterTarget,qRange) + MonsterDMG("W",_W,MonsterTarget,wRange)) >= MonsterTarget.health) then
				MonsterKillable = true
				if myHero:CanUseSpell(_Q) == READY and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=qRange then
					CastSpell(_Q, MonsterTarget)
				end
				if myHero:CanUseSpell(_W) == READY and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=wRange then
					CastSpell(_W, MonsterTarget)
				end
				if myHero:CanUseSpell(_E) == READY and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=eRange then
					CastSpell(_E, MonsterTarget)
				end
			else
				MonsterKillable = false
			end
		end
		end
		if SaveJungle == true and (not ValidTarget(MonsterTarget) or (MiniMonster == true and targeting == true)) then
			MiniMonster = true
			CheckMonster(Wolf1)
			CheckMonster(Wolf2)
			CheckMonster(Golem1)
			CheckMonster(Golem2)
			CheckMonster(Wraith1)
			CheckMonster(Wraith2)
			if myHero:CanUseSpell(_R) == READY and RyzeConfig.useUltiJungle and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=eRange then
				CastSpell(_R)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			elseif myHero:CanUseSpell(_E) == READY and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=eRange then
				CastSpell(_E, MonsterTarget)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			elseif myHero:CanUseSpell(_Q) == READY and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=qRange then
				CastSpell(_Q, MonsterTarget)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			elseif myHero:CanUseSpell(_W) == READY and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=wRange then
				CastSpell(_W, MonsterTarget)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			end
		end
	elseif RyzeConfig.autoQFarm and RyzeSettings.qMinMana<=((myHero.mana/myHero.maxMana)*100) and RyzeConfig.BurstActive == false and RyzeConfig.LongActive == false and RyzeConfig.autoQHarass == false and RyzeConfig.autoQToggle == false then
		MinionSelect = {}
		for index, minion in pairs(enemyMinions.objects) do
			local myQ = getDmg("Q",minion,myHero)
			local myW = getDmg("W",minion,myHero)
			if (minion.maxHealth >= 700+27*math.floor(GetGameTimer()/180000)) then
				local ProMinion = minion
				if myHero:CanUseSpell(_Q) == READY and myHero:GetDistance(ProMinion) ~= nil and myHero:GetDistance(ProMinion) <= qRange and ProMinion.health ~= nil and ProMinion.health <= player:CalcDamage(ProMinion, myQ) and ProMinion.visible ~= nil and ProMinion.visible == true and  RyzeConfig.BurstActive == false and RyzeConfig.LongActive == false then
					CastSpell(_Q, ProMinion)
				elseif myHero:CanUseSpell(_W) == READY and myHero:GetDistance(ProMinion) ~= nil and myHero:GetDistance(ProMinion) <= wRange and ProMinion.health ~= nil and ProMinion.health <= player:CalcDamage(ProMinion, myW) and ProMinion.visible ~= nil and ProMinion.visible == true and  RyzeConfig.BurstActive == false and RyzeConfig.LongActive == false then
					CastSpell(_W, ProMinion)
				end
			end
			if myHero:CanUseSpell(_Q) == READY and myHero:GetDistance(minion) ~= nil and myHero:GetDistance(minion) <= qRange and minion.health ~= nil and minion.health <= player:CalcDamage(minion, myQ) and minion.visible ~= nil and minion.visible == true and  RyzeConfig.BurstActive == false and RyzeConfig.LongActive == false then
				CastSpell(_Q, minion)
			end
		end
	elseif RyzeConfig.PowerFarm and RyzeSettings.PowerMinMana<=((myHero.mana/myHero.maxMana)*100) and RyzeConfig.BurstActive == false and RyzeConfig.LongActive == false and RyzeConfig.autoQHarass == false and RyzeConfig.autoQToggle == false then
		MinionSelect = {}
		for index, minion in pairs(enemyMinions.objects) do
			local myQ = getDmg("Q",minion,myHero)
			local myW = getDmg("W",minion,myHero)
			local myE = getDmg("E",minion,myHero)
			if etarget ~= minion and wtarget ~= minion and myHero:CanUseSpell(_Q) == READY and myHero:GetDistance(minion) ~= nil and myHero:GetDistance(minion) <= qRange and minion.health ~= nil and minion.health <= player:CalcDamage(minion, myQ) and minion.visible ~= nil and minion.visible == true and  RyzeConfig.BurstActive == false and RyzeConfig.LongActive == false then
				CastSpell(_Q, minion)
				qtarget = minion
			end
			if etarget ~= minion and qtarget ~= minion and myHero:CanUseSpell(_W) == READY and myHero:GetDistance(minion) ~= nil and myHero:GetDistance(minion) <= wRange and minion.health ~= nil and minion.health <= player:CalcDamage(minion, myW) and minion.visible ~= nil and minion.visible == true and  RyzeConfig.BurstActive == false and RyzeConfig.LongActive == false then
				CastSpell(_W, minion)
				wtarget = minion
			end
			if qtarget ~= minion and wtarget ~= minion and myHero:CanUseSpell(_E) == READY and myHero:GetDistance(minion) ~= nil and myHero:GetDistance(minion) <= eRange and minion.health ~= nil and minion.health <= player:CalcDamage(minion, myE) and minion.visible ~= nil and minion.visible == true and  RyzeConfig.BurstActive == false and RyzeConfig.LongActive == false then
				CastSpell(_E, minion)
				etarget = minion
			end
		end
	end
	if RyzeConfig.autoAAFarm and GetTickCount() > nextTick then
		if RyzeSettings.autoAAFollow then
			player:MoveTo(mousePos.x, mousePos.z)
		end
		for index, minion in pairs(enemyMinions.objects) do
			local myAA = getDmg("AD",minion,myHero)
			if myHero:GetDistance(minion) ~= nil and  myHero:GetDistance(minion) <= AARange and minion.health ~= nil and minion.health <= myAA and minion.visible ~= nil and minion.visible == true then
				player:Attack(minion)
			end
		 nextTick = GetTickCount() + waitDelay
		end
	end
	if (RyzeConfig.autoQHarass or RyzeConfig.autoQToggle) and RyzeSettings.qMinManaHarass<=((myHero.mana/myHero.maxMana)*100) and RyzeConfig.BurstActive == false and RyzeConfig.LongActive == false and ValidTarget(ts.target) then
		if myHero:CanUseSpell(_Q) == READY then
			doSpell(ts, _Q, qRange)
		end
	end
	if RyzeConfig.CageHunter and myHero:CanUseSpell(_W) == READY then
		closest = findClosestEnemy()
		if ValidTarget(closest) then
			if myHero:GetDistance(closest) < wRange and ValidTarget(closest) then
				CastSpell(_W, closest)
			end
		end
	end
	if RyzeConfig.Ignite then       
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
	if RyzeSettings.autoComboFollow and (RyzeConfig.BurstActive == true or RyzeConfig.LongActive == true) then
		player:MoveTo(mousePos.x, mousePos.z)
	end
end
end

function OnProcessSpell(unit, spell)
--[[	if (spell.name:find("ChaosTurret") and myHero.team == TEAM_RED) or (spell.name:find("OrderTurret") and myHero.team == TEAM_BLUE) and RyzeConfig.cageW then
		for i=1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if ValidTarget(enemy) then
				if GetDistance(spell.endPos, enemy)<80 and GetDistance(enemy)<=wRange and myHero:CanUseSpell(_W) == READY then
					CastSpell(_W, enemy)
				end
			end
		end            
	end
-- ]]
if InTurretRange == true then
	if unit.team == TEAM_ENEMY and GetDistance(unit) < wRange and GetDistance(spell.endPos, myHero)<10 then
		for i=1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if ValidTarget(enemy) then
				if enemy.name == unit.name then
					if GetDistance(enemy)<=wRange and myHero:CanUseSpell(_W) == READY then
						if enemy:GetDistance(CageTurret.object) < 800 then
							CastSpell(_W, enemy)
						end
					end
				end
			end
		end
	end
end
end

function findClosestTurret()
local closestTurret = nil
local currentTurret = nil
for name, turret in pairs(turrets) do
	if turret.object.valid ~= false then 
		currentTurret = turret
	end
	if turret.team == myHero.team then
		if closestTurret == nil then
			closestTurret = currentTurret
		elseif GetDistance(currentTurret) < GetDistance(closestTurret) then
			closestTurret = currentTurret
		end
	end
end
return closestTurret
end


function OnCreateObj(obj)
	if obj ~= nil and obj.type == "obj_AI_Minion" and obj.name ~= nil then
		if obj.name == "TT_Spiderboss7.1.1" then Vilemaw = obj
		elseif obj.name == "Worm12.1.1" then Nashor = obj
		elseif obj.name == "Dragon6.1.1" then Dragon = obj
		elseif obj.name == "AncientGolem1.1.1" then Golem1 = obj
		elseif obj.name == "AncientGolem7.1.1" then Golem2 = obj
		elseif obj.name == "LizardElder4.1.1" then Lizard1 = obj
		elseif obj.name == "LizardElder10.1.1" then Lizard2 = obj
		elseif obj.name == "GiantWolf2.1.3" then Wolf1 = obj 
		elseif obj.name == "GiantWolf8.1.3" then Wolf2 = obj
		elseif obj.name == "Wraith3.1.3" then Wraith1 = obj
		elseif obj.name == "Wraith9.1.3" then Wraith2 = obj
		elseif obj.name == "Golem5.1.2" then Golem1 = obj
		elseif obj.name == "Golem11.1.2" then Golem2 = obj
		end
	end
end

function OnDeleteObj(object)
	if object ~= nil and object.type == "obj_AI_Turret" then
		for name, turret in pairs(turrets) do
			if name == object.name then
				turrets[name] = nil
				return
			end
		end
	end
end

function ASLoadMinions()
	for i = 1, objManager.maxObjects do
		local obj = objManager:getObject(i)
		if obj ~= nil and obj.type == "obj_AI_Minion" and obj.name ~= nil then
			if obj.name == "TT_Spiderboss7.1.1" then Vilemaw = obj
			elseif obj.name == "Worm12.1.1" then Nashor = obj
			elseif obj.name == "Dragon6.1.1" then Dragon = obj
			elseif obj.name == "AncientGolem1.1.1" then Golem1 = obj
			elseif obj.name == "AncientGolem7.1.1" then Golem2 = obj
			elseif obj.name == "LizardElder4.1.1" then Lizard1 = obj
			elseif obj.name == "LizardElder10.1.1" then Lizard2 = obj 
			elseif obj.name == "GiantWolf2.1.3" then Wolf1 = obj 
			elseif obj.name == "GiantWolf8.1.3" then Wolf2 = obj
			elseif obj.name == "Wraith3.1.3" then Wraith1 = obj
			elseif obj.name == "Wraith9.1.3" then Wraith2 = obj
			elseif obj.name == "Golem5.1.2" then Golem1 = obj
			elseif obj.name == "Golem11.1.2" then Golem2 = obj
			end
		end
	end
end


function CheckMonster(minion)
if minion ~= nil and ValidTarget(minion) then
	if myHero:GetDistance(minion) < eRange then
		MonsterTarget = minion
		targeting = true
	elseif not ValidTarget(MonsterTarget) then
		targeting = false
	end
end
end

function MonsterDMG(dmgspell,spell,monster,range)
	if monster ~= nil and GetMyHero():CanUseSpell(spell) == READY and GetDistance(monster)<=range then
		return getDmg(dmgspell,monster,myHero)
	else
		return 0
	end
end

function RyzeItem()
DFGSlot, HXGSlot, BWCSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144)
SheenSlot, TrinitySlot, LBSlot = GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
IGSlot, LTSlot, BTSlot = GetInventorySlotItem(3025), GetInventorySlotItem(3151), GetInventorySlotItem(3188)
STISlot, ROSlot, BRKSlot = GetInventorySlotItem(3092),GetInventorySlotItem(3143),GetInventorySlotItem(3153)
QREADY = (myHero:CanUseSpell(_Q) == READY)
WREADY = (myHero:CanUseSpell(_W) == READY)
EREADY = (myHero:CanUseSpell(_E) == READY)
RREADY = (myHero:CanUseSpell(_R) == READY)
DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
STIREADY = (STISlot ~= nil and myHero:CanUseSpell(STISlot) == READY)
ROREADY = (ROSlot ~= nil and myHero:CanUseSpell(ROSlot) == READY)
BRKREADY = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
end

function checkTurretState()
	for name, turret in pairs(turrets) do
		if turret.object.valid == false then
			turrets[name] = nil
		end
	end
end