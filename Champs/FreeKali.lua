if myHero.charName ~= "Akali" then return end

require("SourceLib")

local VERSION = "1.9"
local latestVersion=nil
local updateCheck = false

local MainCombo = {_R, _Q, _E, _AA, _R, _ITEMS, _IGNITE}

function getDownloadVersion(response)
        latestVersion = response
end

function getVersion()
        GetAsyncWebResult("dl.dropboxusercontent.com","/s/hvz2qgfrcr3k2n1/FKversion.txt",getDownloadVersion)
end 

function update()
    if updateCheck == false then
        local PATH = BOL_PATH.."Scripts\\FreeKali.lua"
        local URL = "http://dl.dropboxusercontent.com/s/uqpzkfdmcigt2rd/FreeKali.lua"
        if latestVersion~=nil and latestVersion ~= VERSION then
            updateCheck = true
            PrintChat("UPDATING FreeKali - "..SCRIPT_PATH:gsub("/", "\\").."FreeKali.lua")
            DownloadFile(URL, PATH,function ()
                PrintChat("UPDATED - reload please (F9 twice)")
            end)            
        elseif latestVersion == VERSION then
            updateCheck = true
            PrintChat("Your Version of FreeKali is up to date")        
        end
    end
end
AddTickCallback(update)

function OnLoad()
	getVersion()
	Menu()
	init()
	PrintChat("<font color='#aaff34'>FreeKali</font>")
end

function Menu()
	DLib = DamageLib()
	DManager = DrawManager()

	DLib:RegisterDamageSource(_Q, _MAGIC, 35, 45, _MAGIC, _AP, 0.9, function() return (player:CanUseSpell(_Q) == READY) end)
	DLib:RegisterDamageSource(_E, _MAGIC, 5, 25, _MAGIC, _AP, 0.3, function() return (player:CanUseSpell(_E) == READY) end)
	DLib:RegisterDamageSource(_R, _MAGIC, 25, 75, _MAGIC, _AP, 0.5, function() return (player:CanUseSpell(_R) == READY) end)
	
	
	AkMen = scriptConfig("FreeKali", "FreeKali")
	AkMen:addParam("Ak", "Main Settings", SCRIPT_PARAM_INFO, "")
	AkMen:addSubMenu("Combo Settings", "CSettings")
	AkMen.CSettings:addParam("CuseIgnite","Use Ignite if killable", SCRIPT_PARAM_ONOFF, true)
	AkMen.CSettings:addParam("CuseQ","Use Q in Combo", SCRIPT_PARAM_ONOFF, true)
	AkMen.CSettings:addParam("CQblock","Block Q use if target is marked", SCRIPT_PARAM_ONOFF, true)
	AkMen.CSettings:addParam("CuseW","Use W in Combo", SCRIPT_PARAM_ONOFF, true)
	AkMen.CSettings:addParam("CuseE","Use E in Combo", SCRIPT_PARAM_ONOFF, true)
	AkMen.CSettings:addParam("CuseEonlyifQ","Only use E on Q marked targets", SCRIPT_PARAM_ONOFF, true)
	AkMen.CSettings:addParam("CuseR","Use R in Combo", SCRIPT_PARAM_ONOFF, true)
	AkMen.CSettings:addParam("CuseRchase","only use R to chase", SCRIPT_PARAM_ONOFF, true)
	AkMen.CSettings:addParam("CuseRchaseHP","if enemy is below % HP", SCRIPT_PARAM_SLICE, 100, 0, 100, 0)
	AkMen.CSettings:addParam("CuseRchaseDistance","Minimum Distance to chase", SCRIPT_PARAM_SLICE, 300, 0, 800, 0)
	AkMen.CSettings:addParam("CuseAA","AutoAttack", SCRIPT_PARAM_ONOFF, true)
	AkMen.CSettings:addParam("CprioritizeBuffAA","Prioritize AA if lich/sheen", SCRIPT_PARAM_ONOFF, true)
	AkMen.CSettings:addParam("CmMove","Move to Mouse", SCRIPT_PARAM_ONOFF, true)
	AkMen:addSubMenu("Harass Settings", "HSettings")
	AkMen.HSettings:addParam("HuseQ","Use Q in Harass", SCRIPT_PARAM_ONOFF, true)
	AkMen.HSettings:addParam("HuseE","Use E in Harass", SCRIPT_PARAM_ONOFF, true)
	AkMen.HSettings:addParam("HuseAA","AutoAttack", SCRIPT_PARAM_ONOFF, false)
	AkMen.HSettings:addParam("HmMove","Move to Mouse", SCRIPT_PARAM_ONOFF, true)
	AkMen:addSubMenu("Farm Settings", "FSettings")
	AkMen.FSettings:addParam("FuseQ","Use Q to farm", SCRIPT_PARAM_ONOFF, true)
	AkMen.FSettings:addParam("FuseE","Use E to farm", SCRIPT_PARAM_ONOFF, true)
	AkMen.FSettings:addParam("FuseAA","AutoAttack", SCRIPT_PARAM_ONOFF, true)
	AkMen.FSettings:addParam("FmMove","Move to Mouse", SCRIPT_PARAM_ONOFF, true)
	AkMen:addSubMenu("Lane Clear Settings", "LCSettings")
	AkMen.LCSettings:addParam("LCuseQ","Use Q to farm", SCRIPT_PARAM_ONOFF, true)
	AkMen.LCSettings:addParam("LCuseE","Use E to farm", SCRIPT_PARAM_ONOFF, true)
	AkMen.LCSettings:addParam("LCuseAA","AutoAttack", SCRIPT_PARAM_ONOFF, true)
	AkMen.LCSettings:addParam("LCmMove","Move to Mouse", SCRIPT_PARAM_ONOFF, true)
	AkMen:addParam("Combo","Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	AkMen:addParam("Harass","Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	AkMen:addParam("Farm","Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
	AkMen:addParam("LaneClear","LaneClear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	AkMen:addParam("Flee","Flee", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	AkMen:addSubMenu("Item Settings", "ISettings")
	AkMen.ISettings:addParam("iCombo", "Use Items in Combo", SCRIPT_PARAM_ONOFF, true)
	AkMen.ISettings:addParam("smartdfg", "Use smart DFG", SCRIPT_PARAM_ONOFF, false)
	AkMen.ISettings:addParam("null", "Use DFG if it reduces #", SCRIPT_PARAM_ONOFF, true)
	AkMen.ISettings:addParam("DFGnComboControl", "of Combos to kill to (0 is ks)", SCRIPT_PARAM_SLICE, 2, 0, 3, 0)
	AkMen:addSubMenu("Draw Settings", "DSettings")
	AkMen.DSettings:addParam("drawQ", "Draw Q radius", SCRIPT_PARAM_ONOFF, true)
	AkMen.DSettings:addParam("drawR", "Draw R radius", SCRIPT_PARAM_ONOFF, true)
	AkMen.DSettings:addParam("drawTar", "Draw red circle on target", SCRIPT_PARAM_ONOFF, true)
	AkMen.DSettings:addParam("drawKill", "Draw Killable", SCRIPT_PARAM_ONOFF, true)
	DLib:AddToMenu(AkMen.DSettings, MainCombo)
	
	AkMen:permaShow("Combo")
    AkMen:permaShow("Farm")
    AkMen:permaShow("LaneClear")
    AkMen:permaShow("Harass")
	AkMen:permaShow("Flee")
end

function checkItems()
    Omen = GetInventorySlotItem(3143)
    BilgeWaterCutlass = GetInventorySlotItem(3144)
	HexTech = GetInventorySlotItem(3146)
    OmenR = (Omen ~= nil and myHero:CanUseSpell(Omen))
	HexTechR = (HexTech ~= nil and myHero:CanUseSpell(HexTech))
    BilgeWaterCutlassR = (BilgeWaterCutlass ~= nil and myHero:CanUseSpell(BilgeWaterCutlass))
	Lich = GetInventorySlotItem(3100)
	LichR = (Lich ~= nil and myHero:CanUseSpell(Lich) == READY)
	DFG = GetInventorySlotItem(3128)
	DFGR = (DFG ~= nil and myHero:CanUseSpell(DFG) == READY)
end

function init()
	ts = TargetSelector(TARGET_NEAR_MOUSE, 1300, DAMAGE_PHYSICAL)	
	ts.name = "Akali"
	AkMen:addTS(ts)
	AttackDistance = 125
	lastAttack = 0
	enemyMinions = minionManager(MINION_ENEMY, 800, myHero)
	jungleMinions = minionManager(MINION_JUNGLE, 800, myHero)
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then 
		ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then 
		ignite = SUMMONER_2
	else 
		ignite = nil
	end
	haveBuff = false
	eHasQbuff = false
	minionAtkVal = 0
	hasQ = nil
	AAwind = 0
	AAanim = 0
end

function getAAdmg(targ)
	local Mdmg = getDmg("P", targ, myHero)
	local Admg = getDmg("AD", targ, myHero)
	local returnval = Mdmg + Admg
	return returnval
end

function OnDraw()
	if AkMen.DSettings.drawQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, 600, ARGB(214,1,33,0))
	end
	if AkMen.DSettings.drawR then
		DrawCircle(myHero.x, myHero.y, myHero.z, 800, ARGB(214,1,33,0))
	end
	if AkMen.DSettings.drawKill then
		for i=1, heroManager.iCount, 1 do
			local champ = heroManager:GetHero(i)
			if ValidTarget(champ) and champ.team ~= myHero.team then
				DrawText3D(analyzeCombat(champ), champ.x, champ.y, champ.z, 20, RGB(255, 255, 255), true)
			end
		end
	end
	if AkMen.DSettings.drawTar and Target ~= nil then 
		DrawCircle(Target.x, Target.y, Target.z, 50, ARGB(214, 214, 1,33))
	end
end

function OnTick()
	--Combo
	Qrdy = (myHero:CanUseSpell(_Q) == READY)
	Wrdy = (myHero:CanUseSpell(_W) == READY)
	Erdy = (myHero:CanUseSpell(_E) == READY)
	Rrdy = (myHero:CanUseSpell(_R) == READY)
	Irdy = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	AArdy = CanAtk()
	ts:update()
	enemyMinions:update()
	checkItems() --thanks fuggi--
	Target = ts.target
	AttackDistance = 125
	if Target ~= nil then
		hasQ = hasQbuff(Target)
	end
	if AkMen.Combo then
		Combo(Target)
	end
	if AkMen.Harass then
		Harass(Target)
	end
	if AkMen.Farm then
		Farm()
	end
	if AkMen.LaneClear then
		LaneClear()
	end
	if AkMen.Flee then
		Flee()
	end
end

function OnCreateObj(obj)
	if obj.isMe and (obj.name == "purplehands_buf.troy" or obj.name == "enrage_buf.troy") then
		haveBuff = true
	end
end

function OnDeleteObj(obj)
	if obj.isMe and (obj.name == "purplehands_buf.troy" or obj.name == "enrage_buf.troy") then
		haveBuff = false
	end
end

function OnProcessSpell(obj, spell)
	if obj.isMe and spell.name:lower():find("attack") then
		AAwind = spell.windUpTime
		AAanim = spell.animationTime
	end
end

function CanAtk()
	return os.clock() > lastAttack + AAanim + ((GetLatency()/2)*0.001)
end

function IsAtk()
    return os.clock() < lastAttack + AAwind + ((GetLatency()/2)*0.001)
end

function hasQbuff(targ)
	for i = 1, targ.buffCount, 1 do
		if targ:getBuff(i).name == "AkaliMota" then
			return true
		end
	end
	return false
end

function Flee()
	local mPos = getNearestMinion(mousePos)
	if Rrdy and mPos ~= nil and GetDistance(mPos, mousePos) < GetDistance(mousePos) then
		useR(mPos) 
	else 
		mMove() 
	end
end

function getNearestMinion(unit)

	local closestMinion = nil
	local nearestDistance = 0

		enemyMinions:update()
		jungleMinions:update()
		for index, minion in pairs(enemyMinions.objects) do
			if minion ~= nil and minion.valid and string.find(minion.name,"Minion_") == 1 and minion.team ~= player.team and minion.dead == false then
				if GetDistance(minion) <= 800 then
					if nearestDistance < GetDistance(unit, minion) then
						nearestDistance = GetDistance(minion)
						closestMinion = minion
					end
				end
			end
		end
		for index, minion in pairs(jungleMinions.objects) do
			if minion ~= nil and minion.valid and minion.dead == false then
				if GetDistance(minion) <= 800 then
                    if nearestDistance < GetDistance(unit, minion) then
						nearestDistance = GetDistance(minion)
						closestMinion = minion
					end
				end
			end
		end
		for i = 1, heroManager.iCount, 1 do
			local minion = heroManager:getHero(i)
			if ValidTarget(minion, 800) then
				if GetDistance(minion) <= 800 then
                    if nearestDistance < GetDistance(unit, minion) then
						nearestDistance = GetDistance(minion)
						closestMinion = minion
					end
				end
			end
		end
	return closestMinion
end

function Combo(targ)
	if targ ~= nil then
		if AkMen.ISettings.iCombo and DFGR and GetDistance(targ) < 500 then
			useDFG(targ)
		end
		if AkMen.ISettings.iCombo and HexTechR and GetDistance(targ) < 500 then
			CastSpell(HexTech, targ)
		end
		if AkMen.ISettings.iCombo and OmenR and GetDistance(targ) < 500 then
			CastSpell(Omen, targ)
		end
		if AkMen.ISettings.iCombo and BilgeWaterCutlassR and GetDistance(targ) < 500 then
			CastSpell(BilgeWaterCutlass, targ)
		end
		if AkMen.CSettings.CuseIgnite and Irdy and GetDistance(targ) < 600 and targ.health <= (50 + (20 * myHero.level))then
			CastSpell(ignite, targ)
		end
		if AkMen.CSettings.CuseAA and AkMen.CSettings.CprioritizeBuffAA and haveBuff then
			useAA(targ)
		end
		if AkMen.CSettings.CuseQ and Qrdy then
			if not hasQ and AkMen.CSettings.CQblock then
				useQ(targ)	
			else
				useQ(targ)
			end
		end
		if AkMen.CSettings.CuseR and Rrdy then
			if AkMen.CSettings.CuseRchase then
				if Target.health < (AkMen.CSettings.CuseRchaseHP * (Target.maxHealth / 100)) and GetDistance(Target) > AkMen.CSettings.CuseRchaseDistance then
					useR(targ)
				end
			else
				useR(targ)
			end
		end
		if AkMen.CSettings.CuseE and Erdy then
			if AkMen.CSettings.CuseEonlyifQ and hasQ then
				useE(targ)
			elseif AkMen.CSettings.CuseEonlyifQ and targ.health < getDmg("E",targ,myHero) then
				useE(targ)
			else
				useE(targ)
			end
		end
		if AkMen.CSettings.CuseW and Wrdy then
			useW(targ)
		end
		if AkMen.CSettings.CuseAA and AArdy then
			useAA(targ)
		end
		if AkMen.CSettings.CmMove and not IsAtk() then
			mMove()
		end
	elseif AkMen.CSettings.CmMove and not IsAtk() then
		mMove()
	end
end

function Harass(targ)
	if Target ~= nil then
		if AkMen.HSettings.HuseQ and Qrdy then
			if Qrdy and AttackDistance < 600 then
				AttackDistance = 600
			end
			useQ(targ)
		end
		if AkMen.HSettings.HuseE and Erdy then
			if Erdy and AttackDistance < 325 then
				AttackDistance = 325
			end
			useE(targ)
		end
		if AkMen.HSettings.HuseW and Wrdy then
			useW(targ)
		end
		if AkMen.HSettings.HuseAA and AArdy then
			useAA(targ)
		end
		if AkMen.HSettings.HmMove then
			if targ == nil then
				mMove()
			elseif GetDistance(targ, myHero) > AttackDistance then
				mMove()
			elseif not IsAtk() then
				mMove()
			end
		end
	elseif AkMen.HSettings.HmMove then
		mMove()
	end
end

function Farm()
	local tar = nil
	local Admg = 0
	local minRange = 1000
	local isEable = false
	if AkMen.FSettings.FuseAA then
		enemyMinions.range = 200
	end
	if AkMen.FSettings.FuseE then
		enemyMinions.range = 320
	end
	if AkMen.FSettings.FuseQ then
		enemyMinions.range = 600
	end
	enemyMinions:update()
	for i, minion in pairs(enemyMinions.objects) do
		if minion ~= nil then
			Admg = getAAdmg(minion)
			minRange = GetDistance(minion)
			if minion.health < Admg and minRange < 125 then
				tar = minion
				minionAtkVal = 1
				break
			elseif minion.health < getDmg("E", minion, myHero) and minRange < 315 and minRange > 125 and AkMen.FSettings.FuseE then
				tar = minion
				minionAtkVal = 2
				isEable = true
				break
			elseif  minion.health < getDmg("Q", minion, myHero) and minRange < 600 and minRange > 315 and AkMen.FSettings.FuseQ and not isEable then
				tar = minion
				minionAtkVal = 3
				break
			else
				tar = nil
			end
		end
	end
	if tar ~= nil then
		if AkMen.FSettings.FuseQ and Qrdy and not IsAtk() and minionAtkVal == 3 then
			if GetDistance(tar) < 600 then
				useQ(tar)
			end
		end
		if AkMen.FSettings.FuseE and Erdy and not IsAtk() and minionAtkVal == 2 then
			if GetDistance(tar) < 300 then
			useE(tar)
			end
		end
		if AkMen.FSettings.FuseAA and AArdy and minionAtkVal == 1 then
			useAA(tar)
		end
		if AkMen.FSettings.FmMove and not IsAtk() then
			mMove()
		end
	elseif AkMen.FSettings.FmMove then
		mMove()
	end
end

function LaneClear()
	local mosthp = 0
	local leasthp = 10000
	local tar = nil
	local Admg = 0
	enemyMinions:update()
	jungleMinions:update()
	for i, minion in pairs(enemyMinions.objects) do
		if minion ~= nil then
			if minion.health < leasthp then
				tar = minion
				leasthp = minion.health
			end
		end
	end
	for i, minion in pairs(jungleMinions.objects) do
		if minion ~= nil then
			if minion.health > mosthp then
				tar = minion
				mosthp = minion.health
			end
		end
	end
	if tar ~= nil then
		if AkMen.LCSettings.LCuseQ and Qrdy then
			useQ(tar)
		end
		if AkMen.LCSettings.LCuseE and Erdy then
			useE(tar)
		end
		if AkMen.LCSettings.LCuseAA and AArdy then
			useAA(tar)
		end
		if AkMen.LCSettings.LCmMove and not IsAtk() then
			mMove()
		end
	elseif AkMen.LCSettings.LCmMove then
		mMove()
	end
end

function useQ(targ)
	if VIP_USER and GetDistance(targ, myHero) < 600 then
		Packet("S_CAST", {spellId = _Q, targetNetworkId = targ.networkID}):send()
	else
		if GetDistance(targ, myHero) < 600 then
			CastSpell(_Q, targ)
		end
	end
end

function useE(targ)
	if VIP_USER and GetDistance(targ, myHer0) < 325 then
		 Packet("S_CAST", {spellId = _E}):send()
	else
	if GetDistance(targ, myHero) < 325 then
		CastSpell(_E)
	end
	end
end

function useR(targ)
	if VIP_USER and GetDistance(targ, myHero) < 800 then
		Packet("S_CAST", {spellId = _R, targetNetworkId = targ.networkID}):send()
	else
	if GetDistance(targ, myHero) < 800 then
		CastSpell(_R, targ)
	end
	end
end

function useW(targ)
	if VIP_USER and GetDistance(targ, myHero) < 700 then
		Packet("S_CAST", {spellId = _Q, x = targ.x, y = targ.z}):send()
	else
	if GetDistance(targ, myHero) < 700 then
		CastSpell(_W, targ)
	end
	end
end

function useAA(targ)
	if CanAtk() and GetDistance(targ, myHero) < 125 then
		lastAttack = os.clock()
		myHero:Attack(targ)
	end
end

function mMove()
	if not IsAtk() then
		MoveToMouse()
	end
end

function useDFG(targ)
	if AkMen.ISettings.smartdfg then
		local Qdmg = getDmg("Q", targ, myHero, 3)
		local Edmg = getDmg("E", targ, myHero)
		local Rdmg = getDmg("R", targ, myHero)
		local AAdmg = getDmg("AD", targ, myHero)
		local Lichdmg = (Lich and getDmg("LICHBANE", targ, myHero) or 0)
		local HexTechdmg = (HexTech and getDmg("HXG", targ, myHero) or 0)
		local Blgdmg = (BilgeWaterCutlass and getDmg("BWC", targ, myHero) or 0)
		local dfgdmg = (DFG and getDmg("DFG", targ, myHero) or 0)
		local Cdmg = Qdmg + Edmg + Rdmg + AAdmg
		
		if targ.health > Cdmg*DFGnComboControl + HexTechdmg + Blgdmg + Lichdmg and targ.health - dfgdmg < ((Cdmg*DFGnComboControl)- Cdmg) + ((HexTechdmg + Blgdmg + Lichdmg + Cdmg)*1.2) then
			CastSpell(DFG, targ)
		end
	else
		local dfgdmg = (DFG and getDmg("DFG", targ, myHero) or 0)
		if targ.health > dfgdmg then
			CastSpell(DFG, targ)
		end
	end
end

function MoveToMouse()
    local MousePos = Vector(mousePos.x, mousePos.y, mousePos.z)
    local Position = myHero + (Vector(MousePos) - myHero):normalized()*300
    myHero:MoveTo(Position.x, Position.z)
end

function analyzeCombat(targ)
	local Qdmg = getDmg("Q", targ, myHero, 3)
	local Edmg = getDmg("E", targ, myHero)
	local Rdmg = getDmg("R", targ, myHero)
	local AAdmg = getDmg("AD", targ, myHero)
	local Cdmg = Qdmg + Edmg + Rdmg + AAdmg
	local Lichdmg = (Lich and getDmg("LICHBANE", targ, myHero) or 0)
	local HexTechdmg = (HexTech and getDmg("HXG", targ, myHero) or 0)
	local Blgdmg = (BilgeWaterCutlass and getDmg("BWC", targ, myHero) or 0)
	local rTxt = ""
	
	if not LichR and not HexTechR and not BilgeWaterCutlassR then
		if (targ.health < Rdmg and Rrdy) or (targ.health < Qdmg and Qrdy) then
			rTxt = "MURDER HIM!"
		elseif targ.health < Qdmg + Edmg and Qrdy and Rrdy then
			rTxt = "Q + E"
		elseif targ.health < Cdmg and Qrdy and Erdy and Rrdy then
			rTxt = "Combo Him!"
		elseif targ.health < Cdmg*2 and Qrdy and Erdy and Rrdy then
			rTxt = "Combo x2"
		elseif targ.health < Cdmg*3 and Qrdy and Erdy and Rrdy then
			rTxt = "Combo x3"
		else
			rTxt = "Harassable"
		end
	elseif not LichR and BilgeWaterCutlassR then
		if targ.health < Rdmg and Rrdy then
			rTxt = "Ult Him!"
		elseif targ.health < Qdmg + Edmg and Qrdy and Erdy then
			rTxt = "Q + E"
		elseif targ.health < Cdmg + Blgdmg and Qrdy and Erdy and Rrdy then
			rTxt = "Combo Him!"
		elseif targ.health < Cdmg*2 + Blgdmg and Qrdy and Erdy and Rrdy then
			rTxt = "Combo x2"
		elseif targ.health < Cdmg*3 + Blgdmg and Qrdy and Erdy and Rrdy then
			rTxt = "Combo x3"
		else
			rTxt = "Harassable"
		end
	elseif not LichR and HexTechR then
		if targ.health < Rdmg and Rrdy then
			rTxt = "Ult Him!"
		elseif targ.health < Qdmg + Edmg and Qrdy and Erdy then
			rTxt = "Q + E"
		elseif targ.health < Cdmg + HexTechdmg and Qrdy and Erdy and Rrdy then
			rTxt = "Combo Him!"
		elseif targ.health < Cdmg*2 + HexTechdmg and Qrdy and Erdy and Rrdy then
			rTxt = "Combo x2"
		elseif targ.health < Cdmg*3 + HexTechdmg and Qrdy and Erdy and Rrdy then
			rTxt = "Combo x3"
		else
			rTxt = "Harassable"
		end
	elseif LichR and not HexTechR then
		if targ.health < Rdmg and Rrdy then
			rTxt = "Ult Him!"
		elseif targ.health < Qdmg + Edmg and Qrdy and Erdy then
			rTxt = "Q + E"
		elseif targ.health < Cdmg + Lichdmg and Qrdy and Erdy and Rrdy then
			rTxt = "Combo Him!"
		elseif targ.health < Cdmg*2 + Lichdmg and Qrdy and Erdy and Rrdy then
			rTxt = "Combo x2"
		elseif targ.health < Cdmg*3 + Lichdmg and Qrdy and Erdy and Rrdy then
			rTxt = "Combo x3"
		else
			rTxt = "Harassable"
		end
	elseif LichR and HexTechR then
		if targ.health < Rdmg and Rrdy then
			rTxt = "Ult Him!"
		elseif targ.health < Qdmg + Edmg and Qrdy and Erdy then
			rTxt = "Q + E"
		elseif targ.health < Cdmg + Lichdmg + HexTechdmg and Qrdy and Erdy and Rrdy then
			rTxt = "Combo Him!"
		elseif targ.health < Cdmg*2 + Lichdmg + HexTechdmg and Qrdy and Erdy and Rrdy then
			rTxt = "Combo x2"
		elseif targ.health < Cdmg*3 + Lichdmg + HexTechdmg and Qrdy and Erdy and Rrdy then
			rTxt = "Combo x3"
		else
			rTxt = "Harassable"
		end
	else
		rTxt = "Harrassable(error)"
	end
	return rTxt
end

function KSULT()
	for _, enemy in pairs(heroManager.iCount) do
		if enemy.team ~= myHero.team then
			if enemy.health < getDmg("R", enemy, myHero) and Rrdy then
				CastSpell(_R, enemy)
			end
		end
	end
end
