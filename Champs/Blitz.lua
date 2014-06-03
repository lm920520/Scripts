--[[
	Blitzcrank Combo 1.7 by burn

	-Full combo: Q -> W -> E
	-Target configuration, Press shift to configure
	-Option to autoignite killable enemy
	-Option to auto ks with R
	-Option to use R to stop enemy ultimates
	-Option to auto level up
]]
if myHero.charName ~= "Blitzcrank" then return end
local attackrange = 175
local qrange = 1050
local ultirange = 590
local ignite = nil
local QREADY, WREADY, EREADY, RREADY, IREADY = false, false, false, false, false
local abilitySequence = {1,3,2,1,1,4,1,3,1,2,4,3,3,2,2,4,3,2}
--Q normal prediction
local delay = 250
local speed = 1.8
local QWidth = 120
local travelDuration = 0
local predic = nil
--Q VIP prediction
local qPredict = TargetPredictionVIP(qrange, 1800, .25, QWidth)

function OnLoad()
	PrintChat(">> Blitzcrank Combo 1.7 loaded!")
	BlitzcrankConfig = scriptConfig("Blitzcrank", "blitzcrankcombo")
	BlitzcrankConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	BlitzcrankConfig:addParam("grabQ", "Grab Q", SCRIPT_PARAM_ONKEYDOWN, false, 65) --A
	BlitzcrankConfig:addParam("silenceR", "Use R to stop enemy ultimates", SCRIPT_PARAM_ONOFF, true)		
	BlitzcrankConfig:addParam("drawcircles", "Draw our range", SCRIPT_PARAM_ONOFF, true)
	BlitzcrankConfig:addParam("autolvl", "Auto level skill sequence", SCRIPT_PARAM_ONOFF, true)		
	BlitzcrankConfig:addParam("autoks", "Auto Kill Steal with R", SCRIPT_PARAM_ONOFF, false)	
	BlitzcrankConfig:addParam("autoignite", "Auto Ignite killable enemy", SCRIPT_PARAM_ONOFF, false)
	if VIP_USER == true then 
		BlitzcrankConfig:addParam("UseVIP", "Use Q VIP Prediction", SCRIPT_PARAM_ONOFF, true)
		BlitzcrankConfig:addParam("QHitChance", "Q VIP min Hit Chance", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
	end
	BlitzcrankConfig:permaShow("scriptActive")
	BlitzcrankConfig:permaShow("silenceR")	
	ts = TargetSelector(TARGET_LOW_HP,qrange,DAMAGE_MAGIC or DAMAGE_PHYSICAL)
	ts.name = "Blitzcrank"
	BlitzcrankConfig:addTS(ts)
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
	enemyMinions = minionManager(MINION_ENEMY, 1050, player)
end

function OnProcessSpell(unit, spell)
	if BlitzcrankConfig.silenceR and unit ~= nil and unit.valid and unit.team == TEAM_ENEMY and CanUseSpell(_R) == READY and GetDistance(unit) <= ultirange then
		if spell.name=="KatarinaR" or spell.name=="GalioIdolOfDurand" or spell.name=="Crowstorm" or spell.name=="DrainChannel" 
		or spell.name=="AbsoluteZero" or spell.name=="ShenStandUnited" or spell.name=="UrgotSwap2" or spell.name=="AlZaharNetherGrasp" 
		or spell.name=="FallenOne" or spell.name=="Pantheon_GrandSkyfall_Jump" or spell.name=="CaitlynAceintheHole" 
		or spell.name=="MissFortuneBulletTime" or spell.name=="InfiniteDuress" or spell.name=="Teleport" or spell.name=="Meditate" then 
			CastSpell(_R, unit)
		end
	end
end
 
function OnTick()
	ts:update()
	enemyMinions:update()
	
	if ts.target ~= nil then
		travelDuration = (delay + GetDistance(myHero, ts.target)/speed)
		ts:SetPrediction(travelDuration)
		predic = ts.nextPosition
	end
		
	if BlitzcrankConfig.autolvl then --auto level up
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
	
	if BlitzcrankConfig.autoignite then    
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
	
	if BlitzcrankConfig.autoks and ts.target and RREADY then
		if RREADY and GetDistance(ts.target) < ultirange and getDmg("R",ts.target,myHero) > ts.target.health then CastSpell(_R,ts.target) end
	end		
	
	if BlitzcrankConfig.grabQ and ts.target ~= nil and QREADY then
		if BlitzcrankConfig.UseVIP and VIP_USER == true then
			QPrediction()
		else
			if predic ~= nil and GetDistance(predic) < qrange and not minionCollision(predic, QWidth, qrange) then
				CastSpell(_Q, predic.x, predic.z)
			end
		end
	end
	
	if BlitzcrankConfig.scriptActive and ts.target ~= nil then
		ts:update()
		if BlitzcrankConfig.UseVIP and VIP_USER == true and QREADY then
			QPrediction()
		else
			if QREADY and predic ~= nil and GetDistance(predic) < qrange and not minionCollision(predic, QWidth, qrange) then
				CastSpell(_Q, predic.x, predic.z)
			end
		end		
		if (WREADY or EREADY) and (GetDistance(ts.target) < attackrange) then
			CastSpell(_W)
			CastSpell(_E)
		end
		if GetDistance(ts.target) <= attackrange then
			myHero:Attack(ts.target)
		end
	end
end

function QPrediction()
	local hitChance = qPredict:GetHitChance(ts.target)
	local pos = qPredict:GetPrediction(ts.target)
	local minionblocking = qPredict:GetCollision(ts.target)
	if hitChance > BlitzcrankConfig.QHitChance/100 and minionblocking == false then
		if pos ~= nil and GetDistance(pos) < qrange then
			CastSpell(_Q, pos.x, pos.z)
		end
	end
end
 
function OnDraw()
	if BlitzcrankConfig.drawcircles and not myHero.dead then
		DrawCircle(myHero.x, myHero.y, myHero.z, qrange, 0xc2743c)
		DrawCircle(myHero.x, myHero.y, myHero.z, ultirange+10, 0xFF6600)
		if ts.target ~= nil then
			DrawText("Targetting: " .. ts.target.charName, 15, 100, 100, 0xFFFF0000)
			DrawCircle(ts.target.x, ts.target.y, ts.target.z, 100, 0x00FF00)
		end
	end
end

function OnSendChat(msg)
	ts:OnSendChat(msg, "pri")
end

function minionCollision(predic, width, range)
	for _, minionObjectE in pairs(enemyMinions.objects) do
		if predic ~= nil and player:GetDistance(minionObjectE) < range then
			ex = player.x
			ez = player.z
			tx = predic.x
			tz = predic.z
			dx = ex - tx
			dz = ez - tz
			if dx ~= 0 then
				m = dz/dx
				c = ez - m*ex
			end
			mx = minionObjectE.x
			mz = minionObjectE.z
			distanc = (math.abs(mz - m*mx - c))/(math.sqrt(m*m+1))
			if distanc < width and math.sqrt((tx - ex)*(tx - ex) + (tz - ez)*(tz - ez)) > math.sqrt((tx - mx)*(tx - mx) + (tz - mz)*(tz - mz)) then
				return true
			end
		end
	end
	return false
end