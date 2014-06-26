--[[
	Quinn Combo 1.0 (Beta)
		by eXtragoZ
		
	Features:
		- Full combo: (Attack) -> Items -> Q -> E (if not already marked) -> (Attack) -> E (if was marked before) -> (Attack)
		- The attacks you need to make them manually or using AutoCarry
		- Supports: Deathfire Grasp, Liandry's Torment, Blackfire Torch, Bilgewater Cutlass, Hextech Gunblade, Blade of the Ruined King, Sheen, Trinity, Lich Bane, Iceborn Gauntlet, Shard of True Ice and Randuin's Omen
		- Target configuration
		- Press shift to configure
]]
if myHero.charName ~= "Quinn" then return end
--[[		Config		]]     
local HK = 32 --spacebar
--[[            Code            ]]
local range = 0
-- Active
local lastAttack = 0
local Quinn_W_vulnerable = nil
local Quinn_W_tar = nil
local AttackDelay = 0
local AttackDelayLatency = 0
local timingAttack = 0
-- draw
-- ts
local ts
local distancetstarget = 0
--
local ignite = nil
local DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LBSlot, IGSlot, LTSlot, BTSlot, STISlot, ROSlot, BRKSlot = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local QREADY, WREADY, EREADY, RREADY, DFGREADY, HXGREADY, BWCREADY, STIREADY, ROREADY, BRKREADY, IREADY = false, false, false, false, false, false, false, false, false, false, false

-- OrbWalking

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

-- End

function OnLoad()
--	range = myHero.range + GetDistance(myHero.minBBox)
	range = 700 + 25
	QCConfig = scriptConfig("Quinn Combo 1.0", "katarinacombo")
	QCConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, HK)
	QCConfig:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
	QCConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	QCConfig:permaShow("scriptActive")
	ts = TargetSelector(TARGET_LOW_HP_PRIORITY,range,DAMAGE_PHYSICAL)
	ts.name = "Quinn"
	QCConfig:addTS(ts)
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
	PrintChat(" >> Quinn Combo 1.0 loaded!")
end
function OnTick()
	ts:update()
	AttackDelay = (( 1000 * ( -0.435 + (0.625/0.668)) ) / (myHero.attackSpeed/(1/0.668)))
	AttackDelayLatency = AttackDelay-GetLatency()*2
	timingAttack = 1000/(myHero.attackSpeed*0.668)-GetLatency()
	DFGSlot, HXGSlot, BWCSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144)
	SheenSlot, TrinitySlot, LBSlot = GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
	IGSlot, LTSlot, BTSlot = GetInventorySlotItem(3025), GetInventorySlotItem(3151), GetInventorySlotItem(3188)
	STISlot, ROSlot, BRKSlot = GetInventorySlotItem(3092),GetInventorySlotItem(3143),GetInventorySlotItem(3153)
	QREADY = myHero:CanUseSpell(_Q) == READY
	WREADY = myHero:CanUseSpell(_W) == READY
	EREADY = myHero:CanUseSpell(_E) == READY
	RREADY = myHero:CanUseSpell(_R) == READY
	DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
	BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
	STIREADY = (STISlot ~= nil and myHero:CanUseSpell(STISlot) == READY)
	ROREADY = (ROSlot ~= nil and myHero:CanUseSpell(ROSlot) == READY)
	BRKREADY = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	if ts.target ~= nil then distancetstarget = GetDistance(ts.target) end
	if QCConfig.scriptActive and ts.target ~= nil then
		OrbWalk()
		if GetTickCount() < lastAttack+timingAttack*.5 and GetTickCount() > lastAttack+AttackDelayLatency then
			if DFGREADY then CastSpell(DFGSlot, ts.target) end
			if HXGREADY then CastSpell(HXGSlot, ts.target) end
			if BWCREADY then CastSpell(BWCSlot, ts.target) end
			if BRKREADY then CastSpell(BRKSlot, ts.target) end
			if STIREADY and distancetstarget<=380 then CastSpell(STISlot, myHero) end
			if ROREADY and distancetstarget<=500 then CastSpell(ROSlot) end
			if QREADY and QCConfig.useq then CastSpell(_Q, ts.target.x, ts.target.z) end
			if EREADY and not (Quinn_W_vulnerable ~= nil and GetDistance(ts.target,Quinn_W_vulnerable) < 40 ) and not (Quinn_W_tar ~= nil and GetDistance(ts.target,Quinn_W_tar) < 40 ) then
				CastSpell(_E, ts.target)
				myHero:MoveTo(ts.target.x,ts.target.z)
			end
		end
	end
end
function OnProcessSpell(unit, spell)
	if unit.isMe and spell.name:find("Quinn") and (spell.name:find("Attack") or spell.name:find("WEnhanced")) then
		lastAttack = GetTickCount() - GetLatency()/2
		lastWindUpTime = spell.windUpTime*1000
		lastAttackCD = spell.animationTime*1000
	end
end
function OnCreateObj(object)
	if object.name == "Quinn_W_tar.troy" then Quinn_W_tar = object end
	if object.name == "Quinn_W_vulnerable.troy" then Quinn_W_vulnerable = object end
	if object.name == "Quinn_W_mis.troy" then
		Quinn_W_vulnerable = nil
		Quinn_W_tar = nil
	end
end
function OnDeleteObj(object)
	if object.name == "Quinn_W_tar.troy" then Quinn_W_tar = nil end
	if object.name == "Quinn_W_vulnerable.troy" then Quinn_W_vulnerable = nil end
end
function OnDraw()
	if QCConfig.drawcircles and not myHero.dead then
		DrawCircle(myHero.x, myHero.y, myHero.z, range, 0x992D3D)
	end
end
function OnSendChat(msg)
	ts:OnSendChat(msg, "pri")
end
-- function OnSendPacket(packet)
	-- if packet.header == 0x71 then
		-- packet.pos = 1
		-- sourceNetworkId = packet:DecodeF()
		-- typemove = packet:Decode1()
		-- if sourceNetworkId == myHero.networkID and typemove == 3 then
			-- lastAttack = GetTickCount()+GetLatency()*2
		-- end
	-- end
-- end