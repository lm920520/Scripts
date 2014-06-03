--[[	Vaynity by bencrabcore. 
		Original Script by Hex.
		Some codes from Glory Ryze by Wursti (Trus for findClosestEnemy)

		Description: The script's job is to keep you alive as long as possible in a clash while dealing the most possible damage. It's goal also is to reduce player work load down to just your positioning. You won't even have to touch the skill, condemn, as the script would automate all of its usage for you.

		Changelog
		
		Changelog 1.1: Added Killsteals with E, Auto Tumble when on Rambo Mode, Updated targetting with the target selector.
		Changelog 1.2: Added Entropy, Youmuu's Ghostblade, Health Potion and Mana Potion activation when on Rambo Mode. Updated ranges to correct values. Auto Tumble on Rambo Mode now only casts Tumble when Enemy is 175 distance away or less then only fires when you're 250 distance away.
		Changelog 1.3: Code optimazion for better engaging. Should now work better with Manciuszz' autocarry. Auto Killsteal now with Q and items.
		Changelog 1.4: Added an option for option for Tumble when on Rambo Mode. 0 for no tumble. 1 for auto tumble when out of cd. 2 for auto tumble only when enemy is within 200 distance. Added auto condemn when clashing.
		Changelog 1.5: Removed auto attacking from Rambo mode so that it won't mess up with Auto Carry. Added auto attack when casting condemn to squeeze in a bolt. Added BRK use when you are 85% in health or enemy hero is 500 distance away so that the active could be used well. Added BRK as killsteal function, uses active when enemy is 10% in health to account for armor. Added stun distance range for Auto Stun to the Wall.
		Changelog 1.6: Updated her condemn range from 450 to 550.
		Changelog a.a: Since the advent of Sida's Auto Carry Revamped, some features were unnecessary thus I removed them. Hope this makes the script lighter.
		Changelog a.b: Updated her condemn range from 450 to 550.
		]]--

if myHero.charName ~= "Vayne" then return end
require "MapPosition"

--[[	Variables Call	]]--

local ignite = nil
local BRKSlot, DFGSlot, HXGSlot, BWCSlot, TMTSlot, RAHSlot, RNDSlot, SOTDSlot, EntropySlot, YGSlot, HealthSlot, ManaSlot = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local QREADY, WREADY, EREADY, RREADY, BRKREADY, DFGREADY, HXGREADY, BWCREADY, TMTREADY, RAHREADY, RNDREADY, SOTDREADY, EntropyREADY, YGREADY, HEALTHREADY, MANAREADY = false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false
local ts
local tick = nil
local AArange = 550 --[[	Auto attack range of Vayne	]]--
local Qrange = 250 --[[	Tumble distance	]]--

--[[	Ranges of Skills and Buffers	]]--
local Erange = 575 --[[	The range of your condemn. Max distance is 450.  ]]--
local tumblebufferrange = 200 --[[	When an enemy hero enters this range on rambo mode, Vayne will automatically tumble to your mouse.	]]--
local tumbleattacknowrange = 250 --[[	After vayne tumbles to your mouse, it will check if enemy hero is 250 distance away. If yes, attack.	]]--

--[[	Do not edit after this line	]]--
--[[	Auto-Stun Function	]]--
function AgainstWall(Target)
	TargetPos = Vector(Target.x, Target.y, Target.z)
	MyPos = Vector(myHero.x, myHero.y, myHero.z)
	StunPos = TargetPos+(TargetPos-MyPos)*((VayneParameters.stunDistance/GetDistance(Target)))
  if StunPos ~= nil and mapPosition:intersectsWall(Point(StunPos.x, StunPos.z)) then
		return true
	end
end

--[[	Unit Check Function	]]--
function ValidCheck(Unit)
	if Unit ~= nil and Unit.type == "obj_AI_Hero" and not Unit.dead and myHero.team ~= Unit.team and Unit.visible then
		return true
	end
end

--[[	Knockback Function	]]--
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

--[[	OnTick Function	]]--
function OnTick()
--[[	Variables	]]--
	ts:update()
	BRKSlot, DFGSlot, HXGSlot, BWCSlot, TMTSlot, RAHSlot, RNDSlot, SOTDSlot, EntropySlot, YGSlot, HealthSlot, ManaSlot = GetInventorySlotItem(3153), GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3077), GetInventorySlotItem(3074),  GetInventorySlotItem(3143), GetInventorySlotItem(3131), GetInventorySlotItem(3184), GetInventorySlotItem(3142), GetInventorySlotItem(2003), GetInventorySlotItem(2004)
	DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
	BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
	BRKREADY = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
	TMTREADY = (TMTSlot ~= nil and myHero:CanUseSpell(TMTSlot) == READY)
	RAHREADY = (RAHSlot ~= nil and myHero:CanUseSpell(RAHSlot) == READY)
	RNDREADY = (RNDSlot ~= nil and myHero:CanUseSpell(RNDSlot) == READY)
	EntropyREADY = (EntropySlot ~= nil and myHero:CanUseSpell(EntropySlot) == READY)
	YGREADY = (YGSlot ~= nil and myHero:CanUseSpell(YGSlot) == READY)
	HEALTHREADY = (HEALTHSlot ~= nil and myHero:CanUseSpell(HEALTHSlot) == READY)
	MANAREADY = (MANASlot ~= nil and myHero:CanUseSpell(MANASlot) == READY)
	SOTDREADY = (SOTDSlot ~= nil and myHero:CanUseSpell(SOTDSlot) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)

	--[[	Auto Stun to Wall	]]--
	if myHero:GetSpellData(_E).level > 0 then
		StunPos = nil
			if ValidCheck(ts.target) and GetDistance(ts.target) <= 1000 then
				if VayneConfig.autoStun and EREADY and AgainstWall(ts.target) then
					if GetDistance(ts.target) <= Erange then
						CastSpell(_E, ts.target)
						if ValidCheck(ts.Target) and GetDistance(ts.target) <= AARange then myHero:Attack(ts.target) 
						else end
					end
				end
			end
		end


	--[[	Engage	]]--
	 if VayneConfig.engage then
		  --[[	Items	]]--
	  if DFGREADY then CastSpell(DFGSlot, ts.target) end
	  if HXGREADY then CastSpell(HXGSlot, ts.target) end
	  if BWCREADY then CastSpell(BWCSlot, ts.target) end
	  if BRKREADY and player.health/player.maxHealth <= VayneParameters.BRKUSE then CastSpell(BRKSlot, ts.target) end
	  if SOTDREADY then CastSpell(SOTDSlot) end
	  if EntropyREADY then CastSpell(EntropySlot) end
	  if YGREADY then CastSpell(YGSlot) end
	  if HEALTHREADY then CastSpell(HEALTHSlot) end
	  if MANAREADY then CastSpell(MANASlot) end
	  if TMTREADY and GetDistance(ts.target) < 275 then CastSpell(TMTSlot) end
	  if RAHREADY and GetDistance(ts.target) < 275 then CastSpell(RAHSlot) end
	  if RNDREADY and GetDistance(ts.target) < 275 then CastSpell(RNDSlot) end
	  if VayneParameters.engageult then 
		if RREADY then CastSpell(_R) end
	  end
		  --[[	Attack	]]--
		if QREADY then
			if VayneParameters.engagemode == 2 and ValidCheck(ts.Target) and GetDistance(ts.target) <= tumblebufferrange then
				CastSpell(_Q, mousePos.x,mousePos.z)
			elseif VayneParameters.engagemode == 1 then
				CastSpell(_Q, mousePos.x,mousePos.z)
			else
				if ValidCheck(ts.Target) and GetDistance(ts.target) <= AARange then myHero:Attack(ts.target) 
				else end
			end
		elseif ValidCheck(ts.Target) and GetDistance(ts.target) <= AARange then myHero:Attack(ts.target)
		else end
	 end

	--[[	Knockback	]]--
	if myHero:GetSpellData(_E).level > 0 then
		for i=1, heroManager.iCount do
			Target = heroManager:getHero(i)
			closest = findClosestEnemy()
			if ValidCheck(closest) and GetDistance(closest) <= Erange then
				if VayneConfig.knockback and EREADY then
						CastSpell(_E, closest)
						if ValidCheck(ts.Target) and GetDistance(ts.target) <= AARange then myHero:Attack(ts.target) 
						else end
				end
			elseif ValidCheck(closest) and GetDistance(closest) <= Erange and VayneConfig.engageknockback and EREADY and tumblebufferrange then
			CastSpell(_E, closest)
				if ValidCheck(ts.Target) and GetDistance(ts.target) <= AARange then myHero:Attack(ts.target) 
				else end
			else end
		end
	end

	

	--[[	Killsteal	]]--

	if VayneConfig.killsteal then	
				for i=1, heroManager.iCount do
                local target = heroManager:GetHero(i)
                local eDmg = getDmg("E",target,myHero)
				local qDmg = getDmg("Q",target,myHero)
                if target ~= nil and target.visible == true and player.team ~= target.team and target.dead == false then
					if eDmg > target.health then
                        if EREADY and player:GetDistance(target) <= 450 then
                                if HXGREADY then CastSpell(HXGSlot, target) end
								if BWCREADY then CastSpell(BWCSlot, target) end
								if BRKREADY then CastSpell(BRKSlot, target) end
								CastSpell(_E,target)
								if ValidCheck(ts.Target) and GetDistance(ts.target) <= AARange then myHero:Attack(ts.target) 
								else end
                        end
					elseif qDmg > target.health then 
                        if QREADY and player:GetDistance(target) <= 700 then
								if HXGREADY then CastSpell(HXGSlot, target) end
								if BWCREADY then CastSpell(BWCSlot, target) end
								if BRKREADY then CastSpell(BRKSlot, target) end
                                CastSpell(_Q,target)
								myHero:Attack(target)
                        end
					elseif target.health < (target.maxHealth*(10/100)) then
								if HXGREADY then CastSpell(HXGSlot, target) end
								if BWCREADY then CastSpell(BWCSlot, target) end
								if BRKREADY then CastSpell(BRKSlot, target) end
					end
                end
                end
	end

	--[[	Auto Ignite	]]--
	if VayneConfig.autoignite and ts.target ~= nil then    
		if IREADY then
			local ignitedmg = 0    
			for i = 1, heroManager.iCount, 1 do
				local enemyhero = heroManager:getHero(i)
				if ValidTarget(enemyhero,600) then
					ignitedmg = 50 + 20 * myHero.level
					if enemyhero.health <= ignitedmg then
						CastSpell(ignite, enemyhero)
					end
				end
			end
		end
	end


	--[[	End of OnTick Function	]]--
end


function getHitBoxRadius(target)
    return GetDistance(target.minBBox, target.maxBBox)/2
end
 --[[	On Draw Function	]]--
function OnDraw()
    if myHero.dead then return end
 	--[[	Auto-Stun Circle	]]--
    if VayneConfig.autoStun then
        if hero ~= nil then
            if myHero:CanUseSpell(_E) == READY then
                if StunPos ~= nil then
                    if VayneDraw.stunCircle then
                        DrawArrows(TargetPos, StunPos, 80, RGBA(255,255,255,0))
                    else
                        DrawCircle(StunPos.x, StunPos.y, StunPos.z, getHitBoxRadius(hero), 0xFFFF00)
                    end
                end
            end
        end
    end
 
end



function OnLoad()
	VayneConfig = scriptConfig("Vaynity's Attendant", "Vaynity")
	VayneConfig:addParam("autoStun", "Hands Up to the Wall", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("Z"))
	VayneConfig:addParam("knockback", "OSHIT! OSHIT!", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	VayneConfig:addParam("engage", "Rambo Mode", SCRIPT_PARAM_ONKEYDOWN, true,32)
	VayneConfig:addParam("engageknockback", "Clash Auto Condemn", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("M"))
	VayneConfig:addParam("autoignite", "Ignite when Killable", SCRIPT_PARAM_ONOFF, true)
	VayneConfig:addParam("killsteal", "Killsteal", SCRIPT_PARAM_ONOFF, true)
	VayneConfig:permaShow("autoStun")
	VayneConfig:permaShow("autoignite")
	VayneConfig:permaShow("killsteal")
	VayneConfig:permaShow("engageknockback")
	
	VayneParameters = scriptConfig("Vaynity's Parameters", "VayneParameters")
	VayneParameters:addParam("engageult", "Ult when Engaging", SCRIPT_PARAM_ONOFF, true)
	VayneParameters:addParam("engagemode", "Tumble Engage Mode", SCRIPT_PARAM_SLICE, 2, 0, 2, 0)	
	VayneParameters:addParam("stunDistance", "Stun Distance", SCRIPT_PARAM_SLICE, 470, 0, 470, 0)
	VayneParameters:addParam("BRKUse", "BRK Health Use", SCRIPT_PARAM_SLICE, .85, 0, 1, 2)
	
	VayneDraw = scriptConfig("Vaynity's Draw", "VayneDraw")
	VayneDraw:addParam("stunCircle", "Guide me, Master", SCRIPT_PARAM_ONOFF, true)

	mapPosition = MapPosition()
		if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2
		end

	ts = TargetSelector(TARGET_LOW_HP,800,DAMAGE_PHYSICAL,false)
	ts.name = "Vayne"
	VayneConfig:addTS(ts)
	PrintChat("Vaynity Script")
end