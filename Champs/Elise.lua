if myHero.charName ~= "Elise" then return end

local qrange = 625
local range = 650
local wrange = 950
local erange = 1075
local watibefureHuman = 0

local QREADY, WREADY, EREADY, RREADY = false, false, false, false
local HUMAN, SPIDER = false, false
local qManaCost, wManaCost, eManaCost = 0, 0, 0

local ts = TargetSelector(TARGET_LOW_HP_PRIORITY, 1150, DAMAGE_MAGIC, true)
local tp = TargetPrediction(erange, 1.3, 265)

function OnLoad()
	ELConfig = scriptConfig("Elise Combo", "EliseCombo")
	ELConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	ELConfig:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, 84)
	ELConfig:addParam("usee", "Use SPIDER E", SCRIPT_PARAM_ONOFF, true)
	ELConfig:addParam("StoH", "Can Spider to Human", SCRIPT_PARAM_ONOFF, true)
	
	ELConfig:permaShow("scriptActive")
	ELConfig:permaShow("harass")
	
	ts.name = "Elise"
	ELConfig:addTS(ts)
	
	PrintChat(" >> Elise Combo by HunteR")
end

function OnTick()
	if myHero.dead then
		return
	end
	
	ts:update()
	
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	
	if myHero:GetSpellData(_Q).name == "EliseHumanQ" then
		HUMAN = true
		SPIDER = false
	else
		HUMAN = false
		SPIDER = true
	end
	
	if ELConfig.scriptActive then combo("Combo") end
	if ELConfig.harass then combo("harass") end
end

function combo(typeC)
	if ts.target ~= nil then
		local distanceto = GetDistance(ts.target)
	
		if HUMAN then
			local spellQ = myHero:GetSpellData(_Q)
			local spellW = myHero:GetSpellData(_W)
			local spellE = myHero:GetSpellData(_E)
			
			qManaCost = spellQ.mana
			wManaCost = spellW.mana
			eManaCost = spellE.mana
			
			local prediction = tp:GetPrediction(ts.target)
			
			if prediction ~= nil and GetDistance(prediction) < erange and EREADY then
				CastSpell(_E, prediction.x, prediction.z)
				return
			end
			
			if not ts.target.canMove or typeC == "Combo" then
				if QREADY and distanceto < qrange then
					CastSpell(_Q, ts.target)
					
					local timeCooldown = math.ceil(os.clock() + spellQ.cd)
					if (timeCooldown > watibefureHuman) then watibefureHuman = timeCooldown end
					
					return
				end
				if WREADY and distanceto < wrange then
					CastSpell(_W, ts.target.x, ts.target.z)
					
					local timeCooldown = math.ceil(os.clock() + spellW.cd)
					if (timeCooldown > watibefureHuman) then watibefureHuman = timeCooldown end
					
					return
				end
				
				if typeC == "Combo" and RREADY and distanceto <= 700 then
					CastSpell(_R)
				end
			end
		else
			if QREADY and typeC == "Combo" then
				if distanceto < 475 then
					CastSpell(_Q, ts.target)
					if WREADY then CastSpell(_W) end
					return
				elseif distanceto < erange and EREADY and ELConfig.usee then
					local qdmg = getDmg("Q", ts.target, myHero)
					local addmg = getDmg("AD", ts.target, myHero)
					
					if (qdmg + (addmg * 2)) > ts.target.health then
						CastSpell(_E, ts.target)
						return
					end
				end
			end
			
			if ((os.clock() >= watibefureHuman and ELConfig.StoH and not QREADY and distanceto < qrange and (qManaCost + eManaCost) <= myHero.mana) or typeC == "harass") and RREADY then
				CastSpell(_R)
				return
			end
		end
		
		if typeC == "Combo" then myHero:Attack(ts.target) end
	end
end