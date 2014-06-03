--[[

		Ziggs Mega Bouncing Charge V1.1
		
		Features:
		SBTW = DFG -> E -> AA -> Q -> AA -> W -> AA -> R
		Auto kill with Q, this is very risky because of minions (they can block it).
		Draws circles around you and the target.

--]]

if myHero.charName ~= "Ziggs" then return end

----------------------
----   Settings   ----
----------------------
local qRange = 850
local wRange = 1000
local eRange = 900
local rRange = 5300
local range = 575

local player = GetMyHero()
local ts
local tick = nil
local predict = nil
local swingDelay = 0.15
local swing = 0
local lastBasicAttack = 0
local travelDuration = nil
local DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = nil, nil, nil, nil, nil, nil  

---Keys---
local comboKey = 32

function OnLoad()
	ZConfig = scriptConfig("Ziggs Mega Bouncing Charge BETA", "ziggscombo")
	ZConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, comboKey) -- Spacebar
	ZConfig:addParam("autoCombo", "Auto Kill", SCRIPT_PARAM_ONOFF, true)
	ZConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	ZConfig:permaShow("scriptActive")
	ts = TargetSelector(TARGET_LOW_HP,eRange,DAMAGE_PHYSICAL,false)
	ts.name = "Ziggs"
	ZConfig:addTS(ts)	
	PrintChat(" >> Ziggs Mega Bouncing Charge BETA for you, xkjtx!")
end

function OnDraw()
	ts:update()
    if player.dead then return end
    
	if ZConfig.drawcircles then
	    DrawCircle(player.x, player.y, player.z, qRange, 0xFF80FF00)
		if ts.target ~= nil then
			DrawText("Targetting: " .. ts.target.charName, 18, 100, 100, 0xFFFF0000)
			DrawCircle(ts.target.x,ts.target.y,ts.target.z, 100, 0xFF80FF00)
			DrawCircle(ts.target.x,ts.target.y,ts.target.z,150,0xFF0000)
		end
	end
end

function OnProcessSpell(unit, spell)
    if unit.isMe and spell and string.find(string.lower(spell.name),"attack" ) then
        swing = 1
        lastBasicAttack = os.clock()
	end
end

function spellsReady()
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
end

function calcDmg()
	ts:update()
	spellsReady()
	if ts.target ~= nil then
		local qDamage = getDmg("Q",ts.target,myHero)
		local eDamage = getDmg("E",ts.target,myHero)
		local wDamage = getDmg("W",ts.target,myHero)
		local rDamage = getDmg("R",ts.target,myHero)
		local AD = getDmg("AD", ts.target,myHero)
		
		local totalDmg = 0		
		if QREADY then totalDmg = totalDmg + qDamage end
		if EREADY then totalDmg = totalDmg + eDamage end
		if WREADY then totalDmg = totalDmg + wDamage end
		if RREADY then totalDmg = totalDmg + rDamage end
		totalDmg = totalDmg + AD
		
		if ts.target.health <= totalDmg then
			PrintFloatText(ts.target,0, "Finish hem")
		else
			PrintFloatText(ts.target,0, tostring(math.floor((ts.target.health - totalDmg)+0.5)))
		end
	end
end

function WhereIsMyTarget(target)
	ts:update()
	if target ~= nil and target.visible then
		travelDuration = (100 + GetDistance(myHero, target)/1.2)
	end
	ts.SetPrediction(travelDuration)
	predict = ts.nextPosition
end

function OnTick()
	ts:update()
	DFGSlot = GetInventorySlotItem(3128)
    spellsReady()

	if tick == nil or GetTickCount()-tick >= 200 then
		tick = GetTickCount()
		calcDmg()
	end
	
	if swing == 1 and os.clock() > lastBasicAttack + 0.5 then
        swing = 0
    end
	
	if player.dead then return end
	if ZConfig.scriptActive and ts.target ~= nil then
		if DFGREADY and ValidTarget(ts.target, 750) then 
			CastSpell(DFGSlot, ts.target) 
		end
		if swing == 0 and GetDistance(ts.target) < range then
			myHero:Attack(ts.target)
		end
		if EREADY and swing == 1 then 
			if os.clock() - lastBasicAttack > swingDelay and ValidTarget(ts.target,qRange) then
				WhereIsMyTarget(ts.target)
				CastSpell(_E, nextPosition.x, nextPosition.z) 
				swing = 0
			end
		end		
		if QREADY and swing == 1 then
			if os.clock() - lastBasicAttack > swingDelay and ValidTarget(ts.target,qRange) then
				WhereIsMyTarget(ts.target)
				CastSpell(_Q, nextPosition.x, nextPosition.z)
				swing = 0
			end
		end
		if WREADY and swing == 1 then 
			if os.clock() - lastBasicAttack > swingDelay and ValidTarget(ts.target,qRange) then
				WhereIsMyTarget(ts.target)
				CastSpell(_W, nextPosition.x, nextPosition.z) 
			end
		end
		if RREADY and swing == 1 and GetDistance(ts.target) < rRange then
			if os.clock() - lastBasicAttack > swingDelay and ValidTarget(ts.target,rRange) then
				WhereIsMyTarget(ts.target)
				CastSpell(_R, nextPosition.x, nextPosition.z)
				swing = 0
			end
		end

	end
	
	if ZConfig.autoCombo and ts.target ~= nil then
	local killDmg = getDmg("Q",ts.target,myHero)
		if ts.target.health <= killDmg then
		WhereIsMyTarget(ts.target)
			if QREADY then CastSpell(_Q, nextPosition.x, nextPosition.z) end
		end
	end
end

function OnWndMsg(msg, key)
end

function OnSendChat(msg)
end