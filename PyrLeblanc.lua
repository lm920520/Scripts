--[[Leblanc - Looks Can Be Deceiving v 1.74 by Pyryoer]]

--ChangeLog--
--V 0.2 - E accuracy tweaks, fixed bug where if RW was used manually it would jump back to cast position--
--V 0.3 - Smoothed out combos, added Q-E harass option, added orbwalk option to harass and combo--
--V 0.4 - More combo tweaks, Target Selector re-added--
--V 0.41 - Pretty sure both combos working perfectly now--
--V 0.42 - W reliability improved--
--V 0.5 - W accuracy improved, W-RW combo option added, current target drawing added, escape feature added--
--V 0.6 - W-RW combo fixed, killsteal functions added --
--V 0.7 - Experimental changes to W and E prediction --
--V 0.8 - Timers on W and RW added --
--V 0.9 - W and Q farming + Jungle Stealing added --
--V 0.91 - Collision fixed, check to make sure Q is cast first in harass --
--V 0.92 - Gapcloser combo added! Currently only in Q-RQ mode, casts W to gapclose, Q, RW, E when an enemy is killable by burst.
--V 0.93 - Fixed collision on E, added toggle for gapcloser --
--V 1.0 - Read Thread
--V 1.1 - Fixed second W cast when W is maxed
--V 1.2 - Prodiction added, W range fixed
--V 1.3 - Lag free circles added
--V 1.31 - Hopefully fixed second W cast problems for those experiencing, added automatic casting of Q or W or R when dmg> target health
--V 1.32 - Check was preventing second W in harass, fixed
--V 1.35 - W range extra fixed, added some options to secure kills, EVEN MORE checks to prevent second W casts on certain machines --
--V 1.4 - Stealing for Baron and Dragon reconfigured, W-RW completely overhauled --
--V 1.5 - More changes to W-RW, Q is cast first now unless gapclosing, farming with W improved --
--V 1.6 - More dynamic combo: automatically calculates whether RQ or RW will do more damage (almost always RQ) and casts accordingly. If there are multiple enemies that can be hit, it will use W>RW to maximize AOE damage.
--V 1.63 - All new bugs brought about by 1.6 (hopefully) fixed, more intelligent skill rotation, now casts RQ before Q if it's up, will use RE if toggled on in menu when Q is on cd and RQ is unavailable --
--V 1.7 - Tweaks to allow W to be cast from further away, Disabling Q check is recommended as a delay has been added to replace it which is quicker, TS distance decreased when skills are on cd (To not prioritize gapclose combos), checks to prevent W/RW casts into walls, delay adjuster for casting W after Q, other things--
if myHero.charName ~= "Leblanc" then return end
require "VPrediction"
require "Collision"
require "Prodiction"

local VP = nil
local Col = nil
local ForceTarget = nil

local latestVersion=nil
local updateCheck = false
local VERSION = "1.74"
local Prodict = ProdictManager.GetInstance()
local ProdictE = Prodict:AddProdictionObject(_E, eRange, eSpeed, eDelay, eWidth)

function getDownloadVersion(response)
        latestVersion = response
end

function getVersion()
        GetAsyncWebResult("dl.dropboxusercontent.com","/u/22305037/LBversion.txt",getDownloadVersion)
end 

function update()
   if updateCheck == false then
       local PATH = BOL_PATH.."Scripts\\PyrLeblanc.lua"
       local URL = "https://dl.dropboxusercontent.com/u/22305037/PyrLeblanc.lua"
       if latestVersion~=nil and latestVersion ~= VERSION then
           updateCheck = true
           PrintChat("UPDATING PyrLeblanc - "..SCRIPT_PATH:gsub("/", "\\").."PyrLeblanc.lua")
           DownloadFile(URL, PATH,function ()
            PrintChat("UPDATED - Please Reload (F9 twice)")
            end)            
        elseif latestVersion == VERSION then
            updateCheck = true
            PrintChat("PyrLeblanc is up to date")        
        end
   end
end
AddTickCallback(update)

function OnLoad()
	getVersion()
	Variables()
	LbMenuInit()
	PrintChat("<font color='#0000FF'> >> Leblanc - Looks Can Be Deceiving 1.74 Loaded! <<</font>")
	GetJungle()
	VP = VPrediction() --Load VPrediction
	Col = Collision(eRange, eSpeed, eDelay, eWidth)
end

function OnTick()
	--CloneMove()
	AutoIgnite()
	Checks()
	DamageCalc()
		--W and R timers, thanks to Silent Man http://botoflegends.com/forum/topic/13561-scriptleesinthresh-qtimer/ --
	if LbMenu.misc.drawTimer then
		if not (myHero:CanUseSpell(_W) == READY) then
			start = GetTickCount()
		end
		if wCast == true then
			elasped = GetTickCount() - start 
			cd = 2500 - elasped
			cooldown = ""..cd
			PrintFloatText(myHero, 0, cooldown)
		end
		if not (myHero:CanUseSpell(_R) == READY) then
			start2 = GetTickCount()
		end
		if rCast == true then
			elasped = GetTickCount() - start2 
			cd2 = 2500 - elasped
			cooldown2 = ""..cd2
		PrintFloatText(myHero, 0, cooldown2)
		end
	end	
	--Menu--
	ComboKey = LbMenu.combo.comboKey
	HarassKey = LbMenu.harass.harassKey
	EscapeKey = LbMenu.combo.escapeKey
	if ComboKey then FullCombo() end
	if HarassKey then HarassCombo() end
	if EscapeKey then Escape() end
	if LbMenu.ks.killsteal then Killsteal() end
	if LbMenu.ks.Ignite then AutoIgnite() end
	if LbMenu.farm.farm or LbMenu.farm.farmtoggle then Farming() end
	if LbMenu.farm.steal then JungleSteal() end
end

function Variables()
	Clone = false
	Combo1 = false
	Combo2 = false
	Combo3 = false
	Ready = false
	CanRQ = false
	rCast = false
	wCast = false
	qRange, wRange, eRange, iRange = 700, 600, 950, 600
	qReady, wReady, eReady, rReady = false, false, false, false
	wSpeed, wDelay, wWidth = math.huge, .25, 250
	eSpeed, eDelay, eWidth = 1600, .25, 95
	wPos, ePos = nil, nil
	TextList = {"Not Killable", "Easy Kill", "Combo Kill", "Low Mana", "CD"}
	KillText = {}
	colorText = ARGB(255,0,255,0)
	lastAnimation = nil
	lastAttack = 0
	lastAttackCD = 0
	lastWindUpTime = 0
	EnemyMinions = minionManager(MINION_ENEMY, 1200, myHero, MINION_SORT_MAXHEALTH_DEC)
	gapclose = false
	qDmgAvail = 0
	wDmgAvail = 0
	eDmgAvail = 0
	rDmgAvail = 0
	maxDmgAvail = 0
	-- Ripped from Skeem --
		priorityTable = {
	    AP = {
	        "Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
	        "Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
	        "Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra",
	            },
	    Support = {
	        "Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean",
	                },
	    Tank = {
	        "Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear",
	        "Warwick", "Yorick", "Zac",
	            },
	    AD_Carry = {
	        "Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
	        "Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo","Zed", 
	                },
	    Bruiser = {
	        "Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy",
	        "Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao",
	            },
        }
	     	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1500 ,DAMAGE_MAGIC)
	TargetSelector.name = "Leblanc"

	if heroManager.iCount < 10 then -- borrowed from Sidas Auto Carry, modified to 3v3
        PrintChat(" >> Too few champions to arrange priority")
	elseif heroManager.iCount == 6 and TTMAP then
		ArrangeTTPrioritys()
    else
        ArrangePrioritys()
    end

end
	
-- Menu --
function LbMenuInit()
	LbMenu = scriptConfig("Leblanc - Looks Can Be Deceiving", "Leblanc")
	
	LbMenu:addSubMenu("Leblanc - Combo Settings", "combo")
		LbMenu.combo:addParam("comboKey", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		LbMenu.combo:addParam("comboItems", "Use Items if Killable", SCRIPT_PARAM_ONOFF, true)
		LbMenu.combo:addParam("cOrbwalk", "Orbwalk During Combo", SCRIPT_PARAM_ONOFF, true)
		LbMenu.combo:addParam("escapeKey", "Escape", SCRIPT_PARAM_ONKEYDOWN, false, 83)
		LbMenu.combo:addParam("gapclose", "Use Gapcloser", SCRIPT_PARAM_ONOFF, true)
		LbMenu.combo:permaShow("comboKey")
		LbMenu.combo:permaShow("escapeKey")
		
	LbMenu:addSubMenu("Leblanc - Harass Settings", "harass")
		LbMenu.harass:addParam("harassKey", "Harass Key (X)", SCRIPT_PARAM_ONKEYDOWN, false, 88)
		LbMenu.harass:addParam("mode", "Mode: 1=Q, 2=Q-W, 3=Q-E", SCRIPT_PARAM_SLICE, 1, 1, 4, 0)
		LbMenu.harass:addParam("hOrbwalk", "Orbwalk During Harass", SCRIPT_PARAM_ONOFF, true)
		LbMenu.harass:addParam("qcheck", "Check for Q Debuff before W", SCRIPT_PARAM_ONOFF, false)
		LbMenu.harass:addParam("wait", "W delay", SCRIPT_PARAM_SLICE, 0, 0, 300, 0)
		LbMenu.harass:permaShow("harassKey")
	
	LbMenu:addSubMenu("Leblanc - Killsteal Settings", "ks")
		LbMenu.ks:addParam("killsteal", "Enable KS", SCRIPT_PARAM_ONOFF, false)
		LbMenu.ks:addParam("ignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
		LbMenu.ks:addParam("Qks", "KS with Q", SCRIPT_PARAM_ONOFF, true)
		LbMenu.ks:addParam("Wks", "KS with W", SCRIPT_PARAM_ONOFF, true)
		LbMenu.ks:addParam("Eks", "KS with E", SCRIPT_PARAM_ONOFF, true)
		--LbMenu.ks:addParam("noDash", "Don't Dash if X Nearby Champions", SCRIPT_PARAM_SLICE, 2, 1, 4, 0)
		--LbMenu.ks:permaShow("killsteal")
	LbMenu:addSubMenu("Leblanc - Farming Settings", "farm")
		LbMenu.farm:addParam("farm", "Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
		LbMenu.farm:addParam("farmtoggle", "Farm Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("T"))
		LbMenu.farm:addParam("farmQ", "Farm With Q", SCRIPT_PARAM_ONOFF, true)
		LbMenu.farm:addParam("farmW", "Farm With W", SCRIPT_PARAM_ONOFF, true)
		LbMenu.farm:addParam("steal", "Jungle Stealing", SCRIPT_PARAM_ONKEYDOWN, false, 82)
		LbMenu.farm:permaShow("farmtoggle")
		
	LbMenu:addSubMenu("Leblanc -Drawing Settings", "drawing")	
		LbMenu.drawing:addParam("mDraw", "Disable All Ranges Drawing", SCRIPT_PARAM_ONOFF, false)
		LbMenu.drawing:addParam("cDraw", "Draw target Text", SCRIPT_PARAM_ONOFF, true)
		LbMenu.drawing:addParam("qDraw", "Draw Q Range", SCRIPT_PARAM_ONOFF, false)
		LbMenu.drawing:addParam("gapclose1", "Draw Medium Gapclose Range", SCRIPT_PARAM_ONOFF, false)
		LbMenu.drawing:addParam("gapclose2", "Draw Long Gapclose Range", SCRIPT_PARAM_ONOFF, false)
		LbMenu.drawing:addParam("tDraw", "Draw Selected Target", SCRIPT_PARAM_ONOFF, true)
		LbMenu.drawing:addParam("LFC", "Lag Free Circles", SCRIPT_PARAM_ONOFF, true )
		
	LbMenu:addSubMenu("Leblanc - Miscellaneous Setings", "misc")
		LbMenu.misc:addParam("minHitchance", "Mininum Hitchance on E", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
		LbMenu.misc:addParam("drawTimer", "Draw Timer for W/RW", SCRIPT_PARAM_ONOFF, true)
		LbMenu.misc:addParam("prediction", "Prodiction/VPred toggle - on = VP, off = Pro", SCRIPT_PARAM_ONOFF, true)
		LbMenu.misc:addParam("AOE", "Use AOE combo in Teamfights", SCRIPT_PARAM_ONOFF, true)
		LbMenu.misc:addParam("AOEnum", "# of targets for AOE combo", SCRIPT_PARAM_SLICE, 2,0,5,0)
		LbMenu.misc:addParam("UseRE", "Use RE when RQ unavailable", SCRIPT_PARAM_ONOFF, false)
		LbMenu.misc:addParam("debugMode", "Debug", SCRIPT_PARAM_ONOFF, false)
		LbMenu.misc:addParam("wRangeAdj", "W range adjust", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
		LbMenu.misc:addParam("wWidthAdj", "W width adjust", SCRIPT_PARAM_SLICE, 0, 0, 250, 0)
	LbMenu:addTS(TargetSelector)

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
		end
	end
	if obj ~= nil and obj.name ~= nil then
		if obj.name == "LeblancImage.troy" then Clone = true
		end
	end
	if obj ~= nil and obj.name:find("Leblanc_displacement_blink_indicator.troy") then
			wCast = true
			--PrintChat("wFound")
	end
	
	if obj ~= nil and obj.name:find("Leblanc_displacement_blink_indicator_ult.troy") then
			rCast = true
	end
end

function OnDeleteObj(obj)
		if obj ~= nil and obj.name ~= nil then
			if obj.name == "TT_Spiderboss7.1.1" then Vilemaw = nil
			elseif obj.name == "Worm12.1.1" then Nashor = nil
			elseif obj.name == "Dragon6.1.1" then Dragon = nil
			elseif obj.name == "AncientGolem1.1.1" then Golem1 = nil
			elseif obj.name == "AncientGolem7.1.1" then Golem2 = nil
			elseif obj.name == "LizardElder4.1.1" then Lizard1 = nil
			elseif obj.name == "LizardElder10.1.1" then Lizard2 = nil 
			end
		end
	if obj ~= nil and obj.name ~= nil then
		if obj.name == "LeblancImage.troy" then Clone = false
		end
	end
	if obj ~= nil and obj.name:find("Leblanc_displacement_blink_indicator.troy") then
			wCast = false
			--PrintChat("wGone")
	end

	if obj ~= nil and obj.name:find("Leblanc_displacement_blink_indicator_ult.troy") then
			rCast = false
	end
end

function OnGainBuff(unit, buff)
	if unit.isMe and buff.name == 'LeblancSlide' then
		wCast = true
	end
	if unit.isMe and buff.name == 'LeblancSlideM' then
		rCast = true
	end
end

function OnLoseBuff(unit, buff)
	if unit.isMe and buff.name == 'LeblancSlide' then
		wCast = false
	end
	if unit.isMe and buff.name == 'LeblancSlideM' then
		rCast = false
	end
end

--Checks, also from Skeem --		
function Checks()
--OnGainBuff(unit, buff)
_G.DrawCircle = DrawCircle2
TargetSelector:update()
	tsTarget = TargetSelector.target
	if ValidTarget(tsTarget) and tsTarget.type == "obj_AI_Hero" then
		target = tsTarget
	else
		target = nil
	end
	if qReady and eReady and wReady and rReady then
		TargetSelector.range = 1500
	else
		TargetSelector.range = 1000
	end

	wRange = 600 + LbMenu.misc.wRangeAdj
	wWidth = 250 + LbMenu.misc.wWidthAdj
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
		ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
		ignite = SUMMONER_2
	end
	rstSlot, ssSlot, swSlot, vwSlot =    GetInventorySlotItem(2045),
									     GetInventorySlotItem(2049),
									     GetInventorySlotItem(2044),
									     GetInventorySlotItem(2043)
	dfgSlot, hxgSlot, bwcSlot, brkSlot = GetInventorySlotItem(3128),
										 GetInventorySlotItem(3146),
										 GetInventorySlotItem(3144),
										 GetInventorySlotItem(3153)
	bftSlot = GetInventorySlotItem(3188)
										 
	qReady = (myHero:CanUseSpell(_Q) == READY)
	if (myHero:CanUseSpell(_R) == COOLDOWN) then gapclose = false end
	wReady = ((myHero:CanUseSpell(_W) == READY) and not (myHero:GetSpellData(_W).name == "leblancslidereturn"))
	eReady = (myHero:CanUseSpell(_E) == READY)
	rReady = ((myHero:CanUseSpell(_R) == READY) and not (myHero:GetSpellData(_R).name == "leblancslidereturnm"))
	iReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	dfgReady = (dfgSlot ~= nil and myHero:CanUseSpell(dfgSlot) == READY)
	bftReady = (bftSlot ~= nil and myHero:CanUseSpell(bftSlot) == READY)
	EnemyMinions:update()
end

function CountEnemies(point, range)
	local ChampCount = 0
    for j = 1, heroManager.iCount, 1 do
        local enemyhero = heroManager:getHero(j)
        if myHero.team ~= enemyhero.team and ValidTarget(enemyhero, wRange+150) then
            if GetDistance(enemyhero, point) <= range then
                ChampCount = ChampCount + 1
            end
        end
    end            
    return ChampCount
end

-- Ability Usage --

function CastQ(target)
	if not qReady or (GetDistance(target) > qRange) then
		return false
	end
	if ValidTarget(target) then
		Packet ("S_CAST", {SpellId = _Q, targetNetworkId = target.networkID}):send()
		return true
	end
	return false
end

function CastW(target)
	if not wReady or GetDistance(target, myPos) > (wRange + wWidth) then
		return false
	end
	if not (myHero:CanUseSpell(_W) == READY) then return false end
	if wCast == false then
	local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(target, wDelay, wWidth, wRange)
		if HitChance >=1 then
				CastSpell(_W, CastPosition.x, CastPosition.z)
			return true
		end
	end
	return false
end

function AoeCastW(target)
	local AoeWpos = GetAoESpellPosition(250, target, .25)
	if AoeWpos and GetDistance(AoeWpos) <= wRange then
		if CountEnemies(AoeWpos, 250) >= LbMenu.misc.AOEnum then
			if myHero:GetSpellData(_W).name == "LeblancSlide" then CastSpell(_W, AoeWpos.x, AoeWpos.z) end
		else
			if myHero:GetSpellData(_W).name == "LeblancSlide" then CastW(target) end
		end
	end
end

function AoeCastR(target)
	local AoeRpos = GetAoESpellPosition(250, target, .25)
	if AoeRpos and GetDistance(AoeRpos) <= wRange then
		if CountEnemies(AoeRpos, 250) >= LbMenu.misc.AOEnum then
			if myHero:GetSpellData(_R).name == "LeblancSlideM" then CastSpell(_R, AoeRpos.x, AoeRpos.z) end
		else
			if myHero:GetSpellData(_R).name == "LeblancSlideM" then CastRW(target) end
		end
	end
end

function GetHitBoxRadius(target)
	return GetDistance(target, target.minBBox)
end

function CastE(target)
	if not eReady or (GetDistance(target) > eRange) then
		return false
	end
	if LbMenu.misc.prediction then
		if ValidTarget(target) then
		local Mcol1 = Col:GetMinionCollision(myHero, target)
		local Mcol2 = Col:GetMinionCollision(myHero, target)
			local CastPosition,  HitChance, HeroPosition = VP:GetLineCastPosition(target, eDelay, eWidth, eRange, eSpeed, myHero)
			if HitChance >= LbMenu.misc.minHitchance then
				if not Mcol1 and not Mcol2 then
					CastSpell(_E, CastPosition.x, CastPosition.z)
				end
			end
			return true
		end
	elseif not LbMenu.misc.prediction then
		if GetDistance(target) - GetHitBoxRadius(target)*0.5 < eRange and ValidTarget(target) then
		EPos = ProdictE:GetPrediction(target)
		local Mcol1 = Col:GetMinionCollision(myHero, target)
		local Mcol2 = Col:GetMinionCollision(myHero, target)
		if not Mcol1 and not Mcol2 then
			CastSpell(_E, EPos.x, EPos.z)
		end
		return true
		end
	end	
	return false
end

function CastRE(target)
	if not rReady or (GetDistance(target) > eRange) or not (myHero:GetSpellData(_R).name == "LeblancSoulShackleM") then
		return false
	end
	if LbMenu.misc.prediction then
		if ValidTarget(target) then
		local Mcol1 = Col:GetMinionCollision(myHero, target)
		local Mcol2 = Col:GetMinionCollision(myHero, target)
			local CastPosition,  HitChance, HeroPosition = VP:GetLineCastPosition(target, eDelay, eWidth, eRange, eSpeed, myHero)
			if HitChance >= 2 then
				if not Mcol1 and not Mcol2 then
					CastSpell(_R, CastPosition.x, CastPosition.z)
				end
			end
			return true
		end
	elseif not LbMenu.misc.prediction then
		if GetDistance(target) - GetHitBoxRadius(target)*0.5 < eRange and ValidTarget(target) then
		REPos = ProdictE:GetPrediction(target)
		local Mcol1 = Col:GetMinionCollision(myHero, target)
		local Mcol2 = Col:GetMinionCollision(myHero, target)
		if not Mcol1 and not Mcol2 then
			CastSpell(_R, REPos.x, REPos.z)
		end
		return true
		end
	end	
	return false
end

function CastR(target)
		if not rReady or not myHero:GetSpellData(_R).name == "LeblancChaosOrbM" then 
			return false
		end
		if rCast == true or (GetDistance(target) > qRange) then
			return false
		end
		if ValidTarget(target) then
			if myHero:GetSpellData(_R).name == "LeblancChaosOrbM" then	
				CastSpell(_R, target)
			end
			return true
		end
		return false
end

function CastRW(target)
		if (myHero:CanUseSpell(_R) == COOLDOWN) or not myHero:GetSpellData(_R).name == "LeblancSlideM" then 
			return false
		end
		if rCast == true or (GetDistance(target) > wRange+wWidth) then
			return false
		end
		if rCast == false and not TargetHaveBuff("LeblancSlideM", myHero) then
			local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(target, wDelay, wWidth, wRange)
			if HitChance > 1 then
				local mypos = Vector(myHero.x, 0, myHero.z)
				if GetDistance(myHero.visionPos, CastPosition) < wRange+wWidth then
					if myHero:GetSpellData(_R).name == "LeblancSlideM" then
						CastSpell(_R, CastPosition.x, CastPosition.z)
					end
				end
				return true
			end
		end
	return false
end
	
function UseI(target)
	if ValidTarget(target) then
		if dfgReady and GetDistance(target) <= 600 then CastSpell(dfgSlot, target) end
		if bftReady and GetDistance(target) <= 650 then CastSpell(bftSlot, target) end
		return true
	end
	return false
end

function AutoIgnite()
	if target then
		if target.health <= iDmg and GetDistance(target) <= 600 then
			if iReady then CastSpell(ignite, target) end
		end
	end
end

function CloneMove()
	if Clone == true then
		if GetDistance(mousePos) then
			local moveToPos = myHero+ (Vector(mousePos) - myHero):normalized()*300
			Packet("S_MOVE", {type = 9, x = moveToPos.x, y = moveToPos.z}):send()
		end
	end
end
     
-- Harass Combo --
function HarassCombo()
	if LbMenu.harass.hOrbwalk then
		if target then
			OrbWalking(target)
		else
			moveToCursor()
		end
	end
	if LbMenu.harass.mode == 1 then
		if target then
			CastQ(target)
		end
	end
	if LbMenu.harass.mode == 2 then
		local lastTick = 0
		if target then
			if qReady then
				CastQ(target)
				lastTick = GetTickCount()
				if LbMenu.misc.debugMode then PrintChat ("Qcast") end
			end
			if LbMenu.harass.qcheck then
				if TargetHaveBuff("LeblancChaosOrb", target) then
						CastW(target)
						if wCast == true then CastSpell(_W, target) end
				end
			elseif not qReady then
					if lastTick + LbMenu.harass.wait <= GetTickCount() then
						if LbMenu.misc.debugMode then PrintChat ("Timerdone") end
						CastW(target)
						if wCast == true then CastSpell(_W, target) end
						lastTick = GetTickCount()
					end
			end
		end
	end
	if LbMenu.harass.mode == 3 then
		if target then
			CastQ(target)
			CastE(target)
		end
	end
end


function rqCombo(target)
	if not ((myHero:CanUseSpell(_R) == READY) and (myHero:GetSpellData(_R).name == "LeblancChaosOrbM")) then
		CastQ(target)
		if LbMenu.misc.debugMode then PrintChat ("RQcomboQQQ") end
	end
	if myHero:GetSpellData(_R).name == "LeblancChaosOrbM" then
			CastR(target)
			if LbMenu.misc.debugMode then PrintChat ("RQcomboRRRQQQ") end
	end
	if (myHero:CanUseSpell(_R) == COOLDOWN) or (myHero:CanUseSpell(_R) == NOTLEARNED) or (TargetHaveBuff("LeblancSlideM", myHero)) or rCast == true then
			if (myHero:CanUseSpell(_Q) == COOLDOWN) or (GetDistance(target, myHero) > qRange) or myHero:CanUseSpell(_Q) == NOTLEARNED then
				CastW(target)
				if LbMenu.misc.debugMode then PrintChat ("RQcomboWWW") end
			end
	end
	if (myHero:CanUseSpell(_R) == COOLDOWN) or rCast == true or (myHero:CanUseSpell(_R) == NOTLEARNED) then
		if (myHero:CanUseSpell(_Q) == COOLDOWN) or GetDistance(target, myHero) > qRange then
			if wCast == true or (myHero:CanUseSpell(_W) == COOLDOWN) or GetDistance(target, myHero) > wRange+wWidth then
				CastE(target)
			end
		end
	end
	if LbMenu.misc.UseRE then
		if (myHero:CanUseSpell(_Q) == COOLDOWN) and (myHero:GetSpellData(_R).name == "LeblancSoulShackleM") then
				CastRE(target)
			if LbMenu.misc.debugMode then PrintChat ("RQcomboRREEE") end
		end
	end
end

function rwCombo(target)
	if qReady and not (((myHero:GetSpellData(_W).name == "leblancslidereturn") and ((myHero:GetSpellData(_R).name == "LeblancSlideM")) and not (myHero:CanUseSpell(_R) == COOLDOWN))) then
		CastQ(target)
		--if LbMenu.misc.debugMode then PrintChat("TryToQQQ") end
	end
	if rReady and wReady then
		if not qReady or GetDistance(target) > qRange then
			if wCast == false then AoeCastW(target) end
			--if LbMenu.misc.debugMode then PrintChat ("TryToW") end
		end
	end
	if ((wCast == true or not wReady) and (myHero:GetSpellData(_R).name == "LeblancSlideM")) and rCast == false then AoeCastR(target) end
	if LbMenu.misc.debugMode then PrintChat ("TryToR") end
	if not rReady or rCast == true then
		if not qReady or (GetDistance(target) > qRange) and wCast == false then AoeCastW(target) end	
		--if LbMenu.misc.debugMode then PrintChat ("TryToW2") end					
	end
	if wCast == true and qReady and not rCast==true then AoeCastR(target)
	--if LbMenu.misc.debugMode then PrintChat ("TryToR2") end
	end
	-- if (myHero:CanUseSpell(_W) == COOLDOWN) or TargetHaveBuff("LeblancSlide", myHero) then
		-- if TargetHaveBuff("LeblancSlideM", myHero) or (myHero:CanUseSpell(_R) == COOLDOWN) or (myHero:CanUseSpell(_R) == NOTLEARNED) then
			-- CastQ(target)
		-- end
	-- end
	if (myHero:CanUseSpell(_R) == COOLDOWN) or rCast == true or (myHero:CanUseSpell(_R) == NOTLEARNED) then
		if (myHero:CanUseSpell(_Q) == COOLDOWN) or GetDistance(target, myHero) > qRange then
			if wCast == true or (myHero:CanUseSpell(_W) == COOLDOWN) or GetDistance(target, myHero) > wRange+wWidth then
				CastE(target)
			end
		end
	end
end


-- SBTW Combo --
function FullCombo()
	if LbMenu.combo.cOrbwalk then
		if target then
			OrbWalking(target)
		else
			moveToCursor()
		end
	end
	local retVal =  rReady
	--print(retVal)
		if target then 
			if GetDistance(target) <= qRange then
				if LbMenu.combo.comboItems then
					if target.health <= (maxDmg) then
						UseI(target)
					end
				end
			end
			if LbMenu.combo.gapclose then
						if GetDistance(target) > qRange and GetDistance(target) > qRange+wRange-50 and GetDistance(target) < qRange+wRange+wRange-50 then
							if target.health <= qDmgTotal+eDmgInit+itemDmg then
								local DashPos = myHero + Vector(target.x - myHero.x, 0, target.z - myHero.z):normalized()*wRange
								if wCast == false and wReady then						
									if not IsWall(D3DXVECTOR3(DashPos.x, DashPos.y, DashPos.z)) then
										if LbMenu.misc.debugMode then PrintChat ("Gapclose") end
										CastSpell(_W, DashPos.x, DashPos.z)
									else 
										local wallblock = "WallBlock!!"
										PrintFloatText(myHero, 0, wallblock)
									end
								end
							end
						end
							if target.health <= (qDmgTotal+eDmgInit+itemDmg) and qReady and eReady and rReady then
								local DashPos = myHero + Vector(target.x - myHero.x, 0, target.z - myHero.z):normalized()*wRange
								if wCast == true and GetDistance(target) > qRange and GetDistance(target) <= qRange+wRange-50 then
									gapclose = true
									CastSpell(_R, DashPos.x, DashPos.z) 
								end
							end
						if GetDistance(target) > qRange and GetDistance(target) < qRange+wRange-50 then
								if target.health <= (qDmgTotal+eDmgInit+rqDmgTotal+itemDmg) and qReady and eReady and rReady and wReady then
									local DashPos = myHero + Vector(target.x - myHero.x, 0, target.z - myHero.z):normalized()*wRange
									if wCast == false and wReady then
										if not IsWall(D3DXVECTOR3(DashPos.x, DashPos.y, DashPos.z)) then
											CastSpell(_W, DashPos.x, DashPos.z) end
											gapclose = true
										else 
											local wallblock = "WallBlock!!"
											PrintFloatText(myHero, 0, wallblock)
										end
								elseif qReady or eReady then
									local DashPos = myHero + Vector(target.x - myHero.x, 0, target.z - myHero.z):normalized()*wRange
									if wCast == false and wReady then
										if not IsWall(D3DXVECTOR3(DashPos.x, DashPos.y, DashPos.z)) then
											CastSpell(_W, DashPos.x, DashPos.z)
											gapclose = true
										else 
											local wallblock = "WallBlock!!"
											PrintFloatText(myHero, 0, wallblock)
										end
									end
								end
						end
				end
						if not dfgReady or not LbMenu.combo.comboItems then
					if target.health <= ((qDmgInit) + 10) then
						CastQ(target)
					elseif target.health <= (wDmg + 10) then
							if wCast == false then CastW(target) end
					elseif target.health <= ((rqDmgInit) + 10) then
							CastR(target)
					elseif CountEnemies(myHero.visionPos, 1000) >= LbMenu.misc.AOEnum then	
							if LbMenu.misc.AOE then
								if gapclose == false then		
									rwCombo(target)
									if LbMenu.misc.debugMode then PrintChat ("Begin AOE") end
								else
									rqCombo(target)
									if LbMenu.misc.debugMode then PrintChat ("Begin RQ combo") end
								end
							else
								rqCombo(target)
								if LbMenu.misc.debugMode then PrintChat ("Begin RQ combo2") end
							end
					else
						rqCombo(target)
						if LbMenu.misc.debugMode then PrintChat ("Begin RQ combo2") end
					end
						--if LbMenu.misc.debugMode then PrintChat ("Begin RQ combo") end
					AutoIgnite(target)
				end
		end	
end

function Escape()
	if LbMenu.combo.cOrbwalk then
			moveToCursor()
	end
	if target then
		CastE(target)
	end
end

--AOE Skillshot Position 2.0, credit to Monogato: http://botoflegends.com/forum/topic/3001-aoe-skillshot-position-gotta-catch-em-all/ -- 

function GetCenter(points)
        local sum_x = 0
        local sum_z = 0
        
        for i = 1, #points do
                sum_x = sum_x + points[i].x
                sum_z = sum_z + points[i].z
        end
        
        local center = {x = sum_x / #points, y = 0, z = sum_z / #points}
        
        return center
end

function ContainsThemAll(circle, points)
        local radius_sqr = circle.radius*circle.radius
        local contains_them_all = true
        local i = 1
        
        while contains_them_all and i <= #points do
                contains_them_all = GetDistanceSqr(points[i], circle.center) <= radius_sqr
                i = i + 1
        end
        
        return contains_them_all
end

-- The first element (which is gonna be main_target) is untouchable.
function FarthestFromPositionIndex(points, position)
        local index = 2
        local actual_dist_sqr
        local max_dist_sqr = GetDistanceSqr(points[index], position)
        
        for i = 3, #points do
                actual_dist_sqr = GetDistanceSqr(points[i], position)
                if actual_dist_sqr > max_dist_sqr then
                        index = i
                        max_dist_sqr = actual_dist_sqr
                end
        end
        
        return index
end

function RemoveWorst(targets, position)
        local worst_target = FarthestFromPositionIndex(targets, position)
        
        table.remove(targets, worst_target)
        
        return targets
end

function GetInitialTargets(radius, main_target)
        local targets = {main_target}
        local diameter_sqr = 4 * radius * radius
        
        for i=1, heroManager.iCount do
                target = heroManager:GetHero(i)
                if target.networkID ~= main_target.networkID and ValidTarget(target) and GetDistanceSqr(main_target, target) < diameter_sqr then table.insert(targets, target) end
        end
        
        return targets
end

function GetPredictedInitialTargets(radius, main_target, delay)
        if VIP_USER and not vip_target_predictor then vip_target_predictor = TargetPredictionVIP(nil, nil, delay/1000) end
        local predicted_main_target = VIP_USER and vip_target_predictor:GetPrediction(main_target) or GetPredictionPos(main_target, delay)
        local predicted_targets = {predicted_main_target}
        local diameter_sqr = 4 * radius * radius
        
        for i=1, heroManager.iCount do
                target = heroManager:GetHero(i)
                if ValidTarget(target) then
                        predicted_target = VIP_USER and vip_target_predictor:GetPrediction(target) or GetPredictionPos(target, delay)
                        if target.networkID ~= main_target.networkID and GetDistanceSqr(predicted_main_target, predicted_target) < diameter_sqr then table.insert(predicted_targets, predicted_target) end
                end
        end
        
        return predicted_targets
end

-- I don't need range since main_target is gonna be close enough. You can add it if you do.
function GetAoESpellPosition(radius, main_target, delay)
        local targets = delay and GetPredictedInitialTargets(radius, main_target, delay) or GetInitialTargets(radius, main_target)
        local position = GetCenter(targets)
        local best_pos_found = true
        local circle = Circle(position, radius)
        circle.center = position
        
        if #targets > 2 then best_pos_found = ContainsThemAll(circle, targets) end
        
        while not best_pos_found do
                targets = RemoveWorst(targets, position)
                position = GetCenter(targets)
                circle.center = position
                best_pos_found = ContainsThemAll(circle, targets)
        end
        
        return position, #targets
end


--------------------------------------------------------------------------------------------------------------

--Killsteal Functions--

function Killsteal()
	if LbMenu.ks.killsteal then
		if target then
			if target.health <= ((qDmgInit) + 35) and LbMenu.ks.Qks then
				CastQ(target)
			else
				if target.health <= (wDmg + 35) and LbMenu.ks.Wks then
					if wCast == false then CastW(target) end
				else
					if target.health <= ((rqDmgInit) + 35 ) then 
						CastR(target)
					else
						if target.health <= (qDmgTotal + wDmg + 35) and LbMenu.ks.Qks and LbMenu.ks.Wks then
							CastQ(target)
							if wCast == false then CastW(target) end
						else
							if target.health <= (qDmgTotal + wDmg + (eDmgInit) + 35) and LbMenu.ks.Qks and LbMenu.ks.Wks and LbMenu.ks.Eks then
								CastQ(target)
								if wCast == false then CastW(target) end
								CastE(target)
							end
						end
					end
				end
			end
		end
	end
end
					
-- Farming --

function Farming()
	if LbMenu.farm.farm or LbMenu.farm.farmtoggle then
		if LbMenu.farm.farmW then
			FarmW()
		end
		if LbMenu.farm.farmQ then
			FarmQ()
		end
	end
end
	
-- Credits to Honda7 --

function FarmQ()
	for _, minion in pairs(EnemyMinions.objects) do
		local QminionDmg = (getDmg("Q", minion, myHero)) or 0
		if ValidTarget(minion) then
			if GetDistance(minion, myHero) < qRange then
			 	if minion.health <= QminionDmg+10 then
		 			CastSpell(_Q, minion)
			 	end
			 end
		end
	end
end

function FarmW()
	if wReady and #EnemyMinions.objects > 2 then
		local WPos = GetBestWPositionFarm()
		if WPos then
			if GetDistance(WPos) < wRange then
				if wCast == false then CastSpell(_W, WPos.x, WPos.z) end
			end
		end
	end
end

function countminionshitW(pos)
	local n = 0
	for i, minion in ipairs(EnemyMinions.objects) do
	local WminionDmg = (getDmg("W", minion, myHero)) or 0
	if GetDistance(minion, myHero) < wRange then
		if minion.health <= WminionDmg then 
			if GetDistance(minion, pos) < wWidth then
				n = n +1
			end
		end
	end
	end
	return n
end

function GetBestWPositionFarm()
	local MaxW = 2
	local MaxWPos 
	for i, minion in pairs(EnemyMinions.objects) do
		local hitW = countminionshitW(minion)
		if hitW > MaxW or MaxWPos == nil then
			MaxWPos = minion
			MaxW = hitW
		end
	end

	if MaxWPos then
		local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(MaxWPos, wDelay, wWidth, wRange)
		return Position
	else
		return nil
	end
end

-- Jungle Stealing --

function GetJungle()
	for i = 1, objManager.maxObjects do
		local obj = objManager:getObject(i)
		if obj ~= nil and obj.type == "obj_AI_Minion" and obj.name ~= nil then
			if obj.name == "TT_Spiderboss7.1.1" then Vilemaw = obj
			elseif obj.name == "Worm12.1.1" then Nashor = obj
			elseif obj.name == "Dragon6.1.1" then Dragon = obj
			elseif obj.name == "AncientGolem1.1.1" then Golem1 = obj
			elseif obj.name == "AncientGolem7.1.1" then Golem2 = obj
			elseif obj.name == "LizardElder4.1.1" then Lizard1 = obj
			elseif obj.name == "LizardElder10.1.1" then Lizard2 = obj end
		end
	end
end

function JungleSteal()
	if Nashor ~= nil then if not Nashor.valid or Nashor.dead or Nashor.health <= 0 then Nashor = nil end end
	if Dragon ~= nil then if not Dragon.valid or Dragon.dead or Dragon.health <= 0 then Dragon = nil end end
	if Golem1 ~= nil then if not Golem1.valid or Golem1.dead or Golem1.health <= 0 then Golem1 = nil end end
	if Golem2 ~= nil then if not Golem2.valid or Golem2.dead or Golem2.health <= 0 then Golem2 = nil end end
	if Lizard1 ~= nil then if not Lizard1.valid or Lizard1.dead or Lizard1.health <= 0 then Lizard1 = nil end end
	if Lizard2 ~= nil then if not Lizard2.valid or Lizard2.dead or Lizard2.health <= 0 then Lizard2 = nil end end
	
	if Nashor ~= nil and GetDistance(Nashor) < 1000 and Nashor.visible then Steal2(Nashor, true) end
	if Dragon ~= nil and GetDistance(Dragon) < 1000 and Dragon.visible then Steal2(Dragon, true) end
	if Golem1 ~= nil and GetDistance(Golem1) < 1000 and Golem1.visible then Steal(Golem1) end
	if Golem2 ~= nil and GetDistance(Golem2) < 1000 and Golem2.visible then Steal(Golem2) end
	if Lizard1 ~= nil and GetDistance(Lizard1) < 1000 and Lizard1.visible then Steal(Lizard1) end
	if Lizard2 ~= nil and GetDistance(Lizard2) < 1000 and Lizard2.visible then Steal(Lizard2) end	
end

function Steal(object, static)
	if static == nil then static = false end
	DmgOnObject = 0
	local qDmgJungle = getDmg("Q", object, myHero)
	local rqDmgJungle = getDmg ("R", object, myHero)
	local wDmgJungle = getDmg("W", object, myHero)
	if not static then
		if qReady and wReady and rReady and ((qDmgJungle*2)+(rqDmgJungle*2)+wDmgJungle) > object.health and GetDistance(object) < qRange then
			CastSpell(_Q, object)
			CastSpell(_R, object)
		elseif wReady and not rReady and rqDmgJungle+wDmgJungle > object.health and GetDistance(object) < wRange then
			CastSpell(_W, object.x, object.z)
		elseif qReady and wReady and ((qDmgJungle*2)+wDmgJungle) > object.health and GetDistance(object) < qRange  then
			CastSpell(_Q, object)
			CastSpell(_W, object.x, object.z)
		elseif qReady and qDmgJungle > object.health and GetDistance(object) < qRange then
			CastSpell(_Q, object)
		end
	end
end

function Steal2(object, static)
	if static == nil then static = false end
	DmgOnObject = 0
	local qDmgJungle = getDmg("Q", object, myHero, 3)
	local rqDmgJungle = getDmg ("R", object, myHero,1)*2
	local eDmgJungle = getDmg("E", object, myHero, 1)
	if not static then
		if qReady and wReady and rReady and eReady and ((qDmgJungle*2)+rwDmgJungle+eDmgJungle) > object.health+400 and GetDistance(object) < wRange+qRange then
			local DashPos = myHero + Vector(object.x - myHero.x, 0, object.z - myHero.z):normalized()*wRange
			if wCast == false and wReady then CastSpell(_W, DashPos.x, DashPos.z) end
			CastSpell(_Q, object)
			CastSpell(_R, object)
			CastSpell(_E, object)
			if wCast == true then CastSpell(_W, object) end
		end
	end
end
	
-- Damage Calculation --
--ALL SKEEM'S.--
function DamageCalc()
	for i=1, heroManager.iCount do
	local target = heroManager:getHero(i)
	if ValidTarget(target) then
		myMana = (myHero.mana)
		qMana = myHero:GetSpellData(_Q).mana
		wMana = myHero:GetSpellData(_W).mana
		eMana = myHero:GetSpellData(_E).mana
		qDmgInit = (getDmg("Q", target, myHero, 1)) or 0
		qDmgTotal = (getDmg("Q", target, myHero, 3)) or 0
		wDmg = (getDmg("W", target, myHero)) or 0
		eDmgInit = (getDmg("E", target, myHero, 1)) or 0
		eDmgTotal = (getDmg("E", target, myHero, 3)) or 0
		rqDmgInit = (getDmg("R", target, myHero, 1)) or 0
		rqDmgTotal = (getDmg("R", target, myHero, 1)*2) or 0
		rwDmg = (getDmg("R", target, myHero, 2)) or 0
		dfgDmg = dfgReady and (getDmg("DFG", target, myHero)) or 0
		iDmg = iReady and (getDmg("IGNITE", target, myHero)) or 0
		itemDmg = dfgDmg + iDmg
		maxDmgRQ = qDmgTotal+wDmg+eDmgTotal+rqDmgTotal+itemDmg
		maxDmgRW = qDmgTotal+wDmg+rwDmg+eDmgTotal+itemDmg
		if qReady then qDmgAvail = qDmgTotal end
		if wReady then wDmgAvail = wDmg end
		if eReady then eDmgAvail = eDmgTotal end
		if rReady then rDmgAvail = rqDmgTotal end
		maxDmgAvail = qDmgAvail+wDmgAvail+eDmgAvail+rDmgAvail
		if maxDmgRW > maxDmgRQ then
			maxDmg = maxDmgRW
		else
			maxDmg = maxDmgRQ
		end
		if target.health <= (qDmgTotal+wDmg+eDmgTotal) then
			if qReady and wReady and eReady then
				if myMana > (qMana + wMana + eMana) then
					KillText[i] = 2
					colorText = ARGB(255,255,0,0)
				else
					KillText[i] = 4
					colorText = ARGB(255,0,0,255)
				end
			else
				KillText[i] = 5
				colorText = ARGB(255,0,0,255)
			end
		elseif target.health <= (maxDmgRQ or maxDmgRW) then
			if myMana > (qMana+wMana+eMana) then
				KillText[i] = 3
				colorText = ARGB(255,255,0,0)
			else
				KillText[i] = 4
				colorText = ARGB(255,0,0,255)
			end
		elseif target.health > (maxDmg) then
			KillText[i] = 1
			colortext = ARGB(255,0,255,0)
		end
	end
end
end
		
function ArrangePrioritys()
    for i, target in pairs(GetEnemyHeroes()) do
        SetPriority(priorityTable.AD_Carry, target, 1)
        SetPriority(priorityTable.AP, target, 2)
        SetPriority(priorityTable.Support, target, 3)
        SetPriority(priorityTable.Bruiser, target, 4)
        SetPriority(priorityTable.Tank, target, 5)
    end
end

function SetPriority(table, hero, priority)
    for i=1, #table, 1 do
        if hero.charName:find(table[i]) ~= nil then
            TS_SetHeroPriority(priority, hero.charName)
        end
    end
end

function OnDraw()
	--> Ranges
		if target then
		if GetDistance(target) < qRange and target.health <= maxDmg then
			Combo1 = true
			Combo2 = false
			Combo3 = false
		end
		if GetDistance(target) > qRange and GetDistance(target) <= qRange+wRange-100 and target.health <= qDmgTotal+itemDmg+rqDmgTotal+eDmgInit then
			Combo2 = true
			Combo1 = false
			Combo3 = false
		end
		if GetDistance(target) > qRange and GetDistance(target) > qRange+wRange-100 and GetDistance(target) <= qRange+wRange+wRange-100 and target.health <= qDmgTotal+itemDmg+eDmgInit then
			Combo3 = true
			Combo1 = false
			Combo2 = false
		end
	end
	if not target then
		Combo1 = false
		Combo2 = false
		Combo3 = false
	end
	if not LbMenu.drawing.mDraw and not myHero.dead then
		if LbMenu.drawing.qDraw then
			if Combo1 == true then
				DrawCircle(myHero.x, myHero.y, myHero.z, qRange, ARGB(255, 0, 255, 255))
			else
				DrawCircle(myHero.x, myHero.y, myHero.z, qRange, ARGB(255, 255, 0, 255))
			end
		end
		if LbMenu.drawing.gapclose1 then
			if Combo2 == true then
				DrawCircle(myHero.x, myHero.y, myHero.z, qRange+wRange-100, ARGB(255, 0, 255, 255))
			else
				DrawCircle(myHero.x, myHero.y, myHero.z, qRange+wRange-100, ARGB(255, 255, 0, 255))
			end
		end
		if LbMenu.drawing.gapclose2 then
			if Combo3 == true then
				DrawCircle(myHero.x, myHero.y, myHero.z, qRange+wRange+wRange-100, ARGB(255, 0, 255, 255))
			else
				DrawCircle(myHero.x, myHero.y, myHero.z, qRange+wRange+wRange-100, ARGB(255, 255, 0, 255))
			end
		end
	end
	if LbMenu.drawing.cDraw then
		for i = 1, heroManager.iCount do
        	local Unit = heroManager:GetHero(i)
        	if ValidTarget(Unit) then
        		local barPos = WorldToScreen(D3DXVECTOR3(Unit.x, Unit.y, Unit.z)) --(Credit to Zikkah)
				local PosX = barPos.x - 35
				local PosY = barPos.y - 10        
        	 	DrawText(TextList[KillText[i]], 13, PosX, PosY, colorText)
			end
		end
    end
	if LbMenu.drawing.tDraw then
		if target then
			DrawCircle(tsTarget.x, tsTarget.y, tsTarget.z, 250, ARGB(255, 255, 0, 255))
		end
	end
			
end

--Lagfree Circles by barasia, vadash and viseversa
function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
		quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
		quality = 2 * math.pi / quality
		radius = radius*.92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width or 1, color or 4294967295)
end

function round(num) 
	if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

function DrawCircle2(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
        DrawCircleNextLvl(x, y, z, radius, 1, color, 75)	
    end
end

-- From Manciuzz's Orbwalk Script: http://pastebin.com/jufCeE0e

function OrbWalking(target)
	if TimeToAttack() and GetDistance(target) <= qRange + GetDistance(myHero.minBBox) then
		myHero:Attack(target)
    elseif heroCanMove() then
        moveToCursor()
    end
end

function TimeToAttack()
    return (GetTickCount() + GetLatency()/2 > lastAttack + lastAttackCD)
end

function heroCanMove()
	return (GetTickCount() + GetLatency()/2 > lastAttack + lastWindUpTime + 20)
end

function moveToCursor()
	if GetDistance(mousePos) then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized()*300
		myHero:MoveTo(moveToPos.x, moveToPos.z)
    end        
end

function OnProcessSpell(object, spell)
	if object == myHero then
		if spell.name:lower():find("attack") then
			lastAttack = GetTickCount() - GetLatency()/2
			lastWindUpTime = spell.windUpTime*1000
			lastAttackCD = spell.animationTime*1000
        end
    end
end

function OnAnimation(unit,animationName)
    if unit.isMe and lastAnimation ~= animationName then lastAnimation = animationName end
end

--UPDATEURL=https://bitbucket.org/christiantluciani/bol/raw/master/PyrLeblanc.lua
--HASH=DD1485F4878804A855A84E4FA1347A47