--[[
	Galio Combo 1.0 by burn

	-Combo: Q -> E -> W*
	-Target configuration, Press shift to configure
	-Option to autoignite killable enemy
	-Option to use R to stop enemy ultimates
	-Option to auto level up
]]
if myHero.charName ~= "Galio" then return end
local Qrange = 940
local Erange = 1180
local ultirange = 570
local ignite = nil
local QREADY, WREADY, EREADY, RREADY, IREADY = false, false, false, false, false
local abilitySequence = {1,3,1,2,1,4,1,3,1,3,4,3,3,2,2,4,2,2}
--Q prediction
local delay = 240
local speed = 1.4 --(speed increased on purpose)
local travelDuration = 0
local predic = nil
--E prediction
local ep = TargetPrediction(1180, 1.4, 240) --(speed increased on purpose)

function OnLoad()
	PrintChat(">> Galio Combo 1.5.1 loaded!")
	GalioConfig = scriptConfig("Galio", "Galiocombo")
	GalioConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	GalioConfig:addParam("silenceR", "Use R to stop enemy ultimates", SCRIPT_PARAM_ONOFF, true)		
	GalioConfig:addParam("drawcircles", "Draw our range", SCRIPT_PARAM_ONOFF, true)
	GalioConfig:addParam("useW", "Use W if enemy is near", SCRIPT_PARAM_ONOFF, true)	
	GalioConfig:addParam("autolvl", "Auto level skill sequence", SCRIPT_PARAM_ONOFF, true)		
	GalioConfig:addParam("autoignite", "Auto Ignite killable enemy", SCRIPT_PARAM_ONOFF, true)
	GalioConfig:permaShow("scriptActive")
	GalioConfig:permaShow("silenceR")
	ts = TargetSelector(TARGET_LOW_HP,Erange,DAMAGE_MAGIC,false)
	ts.name = "Galio"
	GalioConfig:addTS(ts)
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
end

function OnProcessSpell(unit, spell)
	if GalioConfig.silenceR and unit ~= nil and unit.valid and unit.team == TEAM_ENEMY and CanUseSpell(_R) == READY and GetDistance(unit) < ultirange then
		if spell.name=="KatarinaR" or spell.name=="GalioIdolOfDurand" or spell.name=="Crowstorm" or spell.name=="DrainChannel" 
		or spell.name=="AbsoluteZero" or spell.name=="ShenStandUnited" or spell.name=="UrgotSwap2" or spell.name=="AlZaharNetherGrasp" 
		or spell.name=="FallenOne" or spell.name=="Pantheon_GrandSkyfall_Jump" or spell.name=="CaitlynAceintheHole" 
		or spell.name=="MissFortuneBulletTime" or spell.name=="InfiniteDuress" or spell.name=="Teleport" then 
			CastSpell(_R, unit)
		end
	end
end
 
function OnTick()
	ts:update()
	
	if ts.target ~= nil then
		ePred = ep:GetPrediction(ts.target) --E prediction		
		travelDuration = (delay + GetDistance(myHero, ts.target)/speed)
		ts:SetPrediction(travelDuration)
		predic = ts.nextPosition --Q prediction
	end
		
	if GalioConfig.autolvl then --auto level up
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
		
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	
	if GalioConfig.autoignite then    
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
	
	if GalioConfig.scriptActive and ts.target ~= nil then
		ts:update()
		if QREADY and predic ~= nil and GetDistance(predic) <= Qrange then
			CastSpell(_Q, predic.x, predic.z)
		end
		if EREADY and ePred ~= nil and GetDistance(ePred) <= Erange then
			CastSpell(_E, ePred.x, ePred.z)
		end
		if GalioConfig.useW and WREADY and GetDistance(ts.target) <= 450 then
			CastSpell(_W, myHero)
		end
		if GetDistance(ts.target) < 165 then
			myHero:Attack(ts.target)
		end
	end
end
 
function OnDraw()
	if GalioConfig.drawcircles and not myHero.dead then
		DrawCircle(myHero.x, myHero.y, myHero.z, Qrange, 0xc2743c)
		DrawCircle(myHero.x, myHero.y, myHero.z, Erange, 0x9999FF)
		DrawCircle(myHero.x, myHero.y, myHero.z, ultirange, 0xFF6600)
		if ts.target ~= nil then
			DrawText("Targetting: " .. ts.target.charName, 15, 100, 100, 0xFFFF0000)
			DrawCircle(ts.target.x, ts.target.y, ts.target.z, 100, 0x00FF00)
		end
	end
end

function OnSendChat(msg)
	ts:OnSendChat(msg, "pri")
end