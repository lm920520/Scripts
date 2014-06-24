if myHero.charName ~= "Riven" then return end

local version	=	"1.001"

require "VPrediction"
local myPlayer				=	GetMyHero()
local VP

--[[skills]]
local RivenBasic			=	{
	range	=	125,
	delay	=	0.13
}

local RivenTriCleave		=	{
	range	=	275,
	delay	=	0.25,
	speed	=	math.huge,
}

local RivenMartyr			=	{
	range	=	260,
	delay	=	0,
	speed	=	1500
}

local RivenFeint			=	{
	range	=	385,
	delay	=	0,
	speed	=	1450
}

local RivenFengShuiEngine	=	{
	range	=	900,
	delay	=	0.5,
	speed	=	1200
}
local skilllist				=	{_Q, _W, _E, _R}
--[[skill/items:ultimate variables]]
local aaboost, UsandoHP, UsandoRecall 	=	false, false, false
local CanUseQ							=	true
local boxbox_							=	nil
local rTick								=	0
--[[others]]
local TargetManager								=	nil
local lastAttack, lastWindUpTime, lastAttackCD 	= 0, 0, 0
local myTrueRange 								= 0
local Target 									= nil
--[[ITEMS]]--
local Items = {
			["Brtk"]   	= 	{ready = false, range = 450, SlotId = 3153, slot = nil},
			["Bc"]     	= 	{ready = false, range = 450, SlotId = 3144, slot = nil},
			["Rh"]     	= 	{ready = false, range = 400, SlotId = 3074, slot = nil},
			["Tiamat"] 	= 	{ready = false, range = 400, SlotId = 3077, slot = nil},
			["Hg"]     	= 	{ready = false, range = 700, SlotId = 3146, slot = nil},
			["Yg"]     	= 	{ready = false, range = 150, SlotId = 3142, slot = nil},
			["RO"]     	= 	{ready = false, range = 500, SlotId = 3143, slot = nil}, 
			["SD"]	   	=	{ready = false, range = 150, SlotId = 3131, slot = nil},
			["MU"]		=	{ready = false, range = 150, SlotId = 3042, slot = nil}		
			}
local HP_MANA 				= { ["Hppotion"] = {SlotId = 2003, ready = false, slot = nil}	}
local FoundItems 			= {}
--[[buffs]]
local BuffNames				= {"rivenpassiveaaboost",
								"riventricleavesoundone", 
								"riventricleavesoundtwo", 
								"riventricleavesoundthree",
								"regenerationpotion", 
								"flaskofcrystalwater", 
								"recall" }
--[[spells]]
local IgniteSpell   = 	{spellSlot = "SummonerDot", slot = nil, range = 600, ready = false}
local BarreiraSpell = 	{spellSlot = "SummonerBarrier", slot = nil, range = 0, ready = false}

function SpellName(spell)
	return myPlayer:GetSpellData(spell).name
end

function OnLoad()
	Menu()
	PrintChat("<font color=\"#6699ff\"><b>Riven, I'm not a Bunny by Jus</b></font>")
end

function Menu()
	menu 	=	scriptConfig("Riven by Jus", "rivenjus")
	menu:addParam("Version", "Version Info", SCRIPT_PARAM_INFO, version)
	--[[combo]]
	menu:addSubMenu("[Combo System]", "combo")	
	for i=1, #skilllist do
		menu.combo:addParam(tostring(skilllist[i]), "Use "..SpellName(skilllist[i]), SCRIPT_PARAM_ONOFF, true)
	end
	menu.combo:addParam("", "", SCRIPT_PARAM_INFO, "")
	menu.combo:addParam("key", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		menu.combo:addSubMenu("[Combo Settings]", "settings")		
		menu.combo.settings:addParam("boxbox", "Riven Combo Mode", SCRIPT_PARAM_LIST, 1, { "BoxBox", "Animation Canceling"})
		menu.combo:addSubMenu("[Animation Canceling Settings]", "animation")
		menu.combo.animation:addParam("info", "Only Valid if Mode Seted", SCRIPT_PARAM_INFO, "Need to set")
		menu.combo.animation:addParam("q", "Cancel Animation (Q)", SCRIPT_PARAM_ONOFF, true)
		menu.combo.animation:addParam("w", "Cancel Animation (W)", SCRIPT_PARAM_ONOFF, true)
		menu.combo.animation:addParam("e", "Cancel Animation (E)", SCRIPT_PARAM_ONOFF, true)
		menu.combo.animation:addParam("rr", "Cancel Animation (R)", SCRIPT_PARAM_ONOFF, true)
		menu.combo.settings:addParam("stun", "Auto Stun if Possible", SCRIPT_PARAM_ONOFF, true)
		menu.combo.settings:addParam("e", "Use (E) with Combo Key", SCRIPT_PARAM_ONOFF, true)
		menu.combo.settings:addParam("", "", SCRIPT_PARAM_INFO, "")
		menu.combo.settings:addParam("items", "Auto Use Inventory Items", SCRIPT_PARAM_ONOFF, true)
		menu.combo.settings:addParam("ignite", "Auto Use Ignite in Combo", SCRIPT_PARAM_ONOFF, true)
		menu.combo.settings:addParam("antiDi", "Anti Double Ignite", SCRIPT_PARAM_ONOFF, true)		
		menu.combo.settings:addParam("", "", SCRIPT_PARAM_INFO, "")
		menu.combo.settings:addParam("r", "Use (R) with Combo key", SCRIPT_PARAM_ONOFF, true)					
		menu.combo.settings:addParam("ultimate", "Ultimate Enemy with Health <", SCRIPT_PARAM_LIST, 2, {"15%", "25%", "50%", "75%"})
	--[[harass]]
	menu:addSubMenu("[Harass System]", "harass")
	menu.harass:addParam("Q", "Use "..SpellName(skilllist[1]).." (Q)", SCRIPT_PARAM_ONOFF, false)
	menu.harass:addParam("W", "Use "..SpellName(skilllist[2]).." (W)", SCRIPT_PARAM_ONOFF, true)
	menu.harass:addParam("E", "Use "..SpellName(skilllist[3]).." (E)", SCRIPT_PARAM_ONOFF, false)
	menu.harass:addParam("", "", SCRIPT_PARAM_INFO, "")
	menu.harass:addParam("key", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	--[[extra]]
	menu:addSubMenu("[Extra System]", "extra")
	menu.extra:addParam("items", "Auto Use Inventory Items", SCRIPT_PARAM_ONOFF, true)
	--menu.extra:addParam("ignite", "Auto Use Ignite", SCRIPT_PARAM_ONOFF, true)	
	menu.extra:addParam("hp", "Auto Use HP Potions", SCRIPT_PARAM_ONOFF, true)
	menu.extra:addParam("hppercent", "Use HP if my Health < %", SCRIPT_PARAM_SLICE, 60, 10, 90, -1)
	menu.extra:addParam("barrier", "Auto Barrier", SCRIPT_PARAM_ONOFF, true)
	menu.extra:addParam("barrierPercent", "Use Barrier if my Health < %", SCRIPT_PARAM_SLICE, 30, 10, 90, -1)
	menu.extra:addParam("", "", SCRIPT_PARAM_INFO, "")
	menu.extra:addParam("jump", "Jump Wall with (Q) [HOLD]", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
	menu.extra:addParam("jungleKey", "Cast Combo in Jungle", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	menu.extra:addParam("lineKey", "Cast Combo in Line Minions", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	--[[draw]]
	menu:addSubMenu("[Draw System]", "draw")	
	menu.draw:addParam("Q", "Draw (Q) range", SCRIPT_PARAM_ONOFF, false)
	menu.draw:addParam("W", "Draw (W) range", SCRIPT_PARAM_ONOFF, true)
	menu.draw:addParam("E", "Draw (E) range", SCRIPT_PARAM_ONOFF, true)
	menu.draw:addParam("R", "Draw (R) range", SCRIPT_PARAM_ONOFF, false)	
	menu.draw:addParam("", "", SCRIPT_PARAM_INFO, "")
	menu.draw:addParam("target", "Draw Target", SCRIPT_PARAM_ONOFF, true)
	--[[system]]
	menu:addSubMenu("[General System Settings]", "system")
	--menu.system:addParam("packet", "Use Packets", SCRIPT_PARAM_ONOFF, true)
	menu.system:addParam("orbwalker", "Use Orbwalk", SCRIPT_PARAM_ONOFF, true)
	--[[permashow]]
	menu:permaShow("Version")
	menu.combo:permaShow("key")
	menu.harass:permaShow("key")
	menu.extra:permaShow("")	
	menu.extra:permaShow("lineKey")
	menu.extra:permaShow("jungleKey")
	menu.extra:permaShow("jump")
	--[[target selector]]
	TargetManager		=	TargetSelector(TARGET_LOW_HP, 780, DAMAGE_PHYSICAL)
	TargetManager.name 	= 	"Riven"
	menu:addTS(TargetManager)
	VP = VPrediction()
	JungleMinions = minionManager(MINION_JUNGLE, 550, myHero, MINION_SORT_MAXHEALTH_DEC)
	MinionsInimigos = minionManager(MINION_ENEMY, 850, myHero, MINION_SORT_HEALTH_ASC)
	--[[orbwalk]]
	myTrueRange 		= myPlayer.range + GetDistance(myPlayer.minBBox)
	--[[others]]
	boxbox_				=	menu.combo.settings.boxbox
	--[[spells]]
	if myPlayer:GetSpellData(SUMMONER_1).name:find(IgniteSpell.spellSlot) then IgniteSpell.slot = SUMMONER_1
	elseif myPlayer:GetSpellData(SUMMONER_2).name:find(IgniteSpell.spellSlot) then IgniteSpell.slot = SUMMONER_2 end	
	if myPlayer:GetSpellData(SUMMONER_1).name:find(BarreiraSpell.spellSlot) then BarreiraSpell.slot = SUMMONER_1
	elseif myPlayer:GetSpellData(SUMMONER_2).name:find(BarreiraSpell.spellSlot) then BarreiraSpell.slot = SUMMONER_2 end
end

function SkillReady(skill_)
	return myPlayer:CanUseSpell(skill_) == READY
end

function UpdateTarget()
	TargetManager:update()
	if TargetManager.target ~= nil and TargetManager.target.type ~= myPlayer.type then return TargetManager.target == nil end
	return TargetManager.target
end

function CheckAABoost()
	return aaboost
end

function TryAutoAttack(myTarget)
	return CheckAABoost() and myHero:Attack(myTarget)	
end

function GetPosPredictionAndCast(hero, delay, speed, from, collision, Chance, spell_)
	local Position, HitChance    = VP:GetPredictedPos(hero, delay, speed, from, collision)
	if HitChance >= Chance then
		-- Packet('S_CAST', { spellId = spell_, toX = Position.x, toY = Position.z }):send()
		CastSpell(spell_, Position.x, Position.z)
	end
end								

function CastQ(myTarget)	
	local skillname		=	tostring(skilllist[1]) --_Q
	local useq_			=	menu.combo[skillname]	--menu.combo._Q
	local validT		=	ValidTarget(myTarget, RivenTriCleave.range)	
	if boxbox_ == 1 then
		if CheckAABoost() and ValidTarget(myTarget, myTrueRange) then
			TryAutoAttack(myTarget)
			CanUseQ = true	
		else
			if validT and player:CanUseSpell(_Q) == READY and CanUseQ then										
				GetPosPredictionAndCast(myTarget, RivenTriCleave.delay, RivenTriCleave.speed, myPlayer, false, 2, _Q)
				CanUseQ = false	
			end	
		end
	else
		if validT and player:CanUseSpell(_Q) == READY then										
			GetPosPredictionAndCast(myTarget, RivenTriCleave.delay, RivenTriCleave.speed, myPlayer, false, 2, _Q)
		end
	end		
end

function CastW(myTarget)	
	local skillname	=	tostring(skilllist[2])
	local usew_		=	menu.combo[skillname]
	local validT	=	ValidTarget(myTarget, RivenMartyr.range)
	if boxbox_ == 1 then
		if CheckAABoost() and ValidTarget(myTarget, myTrueRange) then
			TryAutoAttack(myTarget)
			CanUseQ = true				
		else
			if usew_ and validT and player:CanUseSpell(_W) == READY then			
				-- Packet('S_CAST', { spellId = skilllist[2]}):send()
				CastSpell(_W)
				CanUseQ = false			
			end
		end
	else
		if usew_ and validT and player:CanUseSpell(_W) == READY then			
			-- Packet('S_CAST', { spellId = skilllist[2]}):send()
			CastSpell(_W)
			CanUseQ = true
		end
	end
end

function CastE(myTarget)	
	local skillname		=	tostring(skilllist[3])
	local usee_			=	menu.combo[skillname]
	local validT	=	ValidTarget(myTarget, RivenFeint.range)
	if boxbox_ == 1 then
		if CheckAABoost() and ValidTarget(myTarget, myTrueRange) then
			TryAutoAttack(myTarget)	
			CanUseQ = true			
		else
			if usee_ and validT and player:CanUseSpell(_E) == READY then
				GetPosPredictionAndCast(myTarget, RivenFeint.delay, RivenFeint.speed, myPlayer, false, 2, _E)
				CanUseQ = false								
			end
		end
	else
		if usee_ and validT and player:CanUseSpell(_E) == READY then			
			GetPosPredictionAndCast(myTarget, RivenFeint.delay, RivenFeint.speed, myPlayer, false, 2, _E)
			CanUseQ = true			
		end
	end	
end

function CastR(myTarget)	
	local skillname	=	tostring(skilllist[4])
	local user_		=	menu.combo[skillname]
	local ultimate_	=	menu.combo.settings.ultimate
	local validT	=	nil
	local ultPer	=	menu.combo.settings.ultimate
	local secondR	=	false	
	if not secondR then
	validT 			= 	ValidTarget(myTarget, 200)
	else
	validT 			= 	ValidTarget(myTarget, RivenFengShuiEngine.range)
	end	
	if user_ and validT and SkillReady(skilllist[4]) and not secondR then
		CastSpell(_R)
		secondR = true
	end
	if user_ and validT and SkillReady(skilllist[4]) and secondR then
		local tHealth	=	(myTarget.health / myTarget.maxHealth * 100)
		local ultPer_	=	0
		if ultPer == 1 then ultPer_ = 15 end
		if ultPer == 2 then ultPer_ = 25 end
		if ultPer == 3 then ultPer_ = 50 end
		if ultPer == 4 then ultPer_ = 75 end		
	 	if rTick + (GetLatency() *1000) < 10 or tHealth < ultPer_  then
			GetPosPredictionAndCast(myTarget, RivenFengShuiEngine.delay, RivenFeint.speed, myPlayer, false, 2, _R)
			secondR = false
		end
	end	
end

function OnProcessSpell(object, spell)
	--[[animation cancel menu]]
	local cancelQ	=	menu.combo.animation.q
	local cancelW	=	menu.combo.animation.w
	local cancelE	=	menu.combo.animation.e
	local cancelR	=	menu.combo.animation.rr
	local items_ 	=	menu.combo.settings.items
	--[[system]]
	local orb_			=	menu.system.orbwalker
	if object == myPlayer then
		if spell.name:lower():find("attack") then			
			lastAttack = GetTickCount() - GetLatency() / 2
			lastWindUpTime = spell.windUpTime * 2000
			lastAttackCD = spell.animationTime * 2000
		end
		if spell.name == "RivenFengShuiEngine" and boxbox_ == 1 then
			rTick = os.clock() + (GetLatency() *1000)
		end	
		if boxbox_ == 2 and ValidTarget(Target) then
			if spell.name == "RivenFengShuiEngino" and cancelR then
				rTick = os.clock() + (GetLatency() *1000)
				if SkillReady(skilllist[3]) then CastSpell(_E, mousePos.x, mousePos.z) end
				if SkillReady(skilllist[2]) then CastSpell(_W, mousePox.x, mousePos.z) end
			end
			if spell.name == "RivenMartyr" and cancelW then				
				if items_ then CastCommonItem() end
			--else
				--Packet('S_MOVE', {x = spell.startPos.x, y = spell.startPos.z}):send()
			end
			if spell.name == "RivenMartyr" and cancelE then
				CastSpell(_E, mousePos.x, mousePos.z)
			end			
		end
	end
end

--[[local qtable = {"spell1a", "spell1b", "spell1c"}]]

function OrbWalk(myTarget)	 
	if myTarget ~= nil and GetDistance(myTarget) <= myTrueRange then		
		if timeToShoot() then
			myPlayer:Attack(myTarget)
		elseif heroCanMove()  then
			moveToCursor()
		end
	else		
		moveToCursor() 
	end
end

function heroCanMove()
	return ( GetTickCount() + GetLatency() / 2 > lastAttack + lastWindUpTime + 20 )
end 
 
function timeToShoot()
	return ( GetTickCount() + GetLatency() / 2 > lastAttack + lastAttackCD )
end 
 
function moveToCursor()
	if GetDistance(mousePos) > 1 or lastAnimation == "Idle1" then
		local moveToPos = myPlayer + (Vector(mousePos) - myPlayer):normalized() * 250
		myPlayer:MoveTo(moveToPos.x, moveToPos.z)
	end 
end

function OnGainBuff(unit, buff)	
	if unit.isMe then		
		for i=1, #BuffNames do
			if buff.name:lower():find(BuffNames[i]) then
				if BuffNames[i] == "rivenpassiveaaboost" 		then 	aaboost 		= true end
				if BuffNames[i] == "regenerationpotion" 		then 	UsandoHP 		= true end				
				if BuffNames[i] == "recall" 					then 	UsandoRecall 	= true end
				--if BuffNames[i] == "riventricleavesoundone" 	then 	q1 		= true end
				--if BuffNames[i] == "riventricleavesoundtwo" 	then 	q2  	= true end
				--if BuffNames[i] == "riventricleavesoundthree" then 	q3 		= true end
			end 	
		end
	end
end

function OnLoseBuff(unit, buff)	
	if unit.isMe then		
		for i=1, #BuffNames do
			if buff.name:lower():find(BuffNames[i]) then
				if BuffNames[i] == "rivenpassiveaaboost" 		then 	aaboost 		= false end
				if BuffNames[i] == "regenerationpotion" 		then 	UsandoHP 		= false end				
				if BuffNames[i] == "recall" 					then 	UsandoRecall 	= false end
				--if BuffNames[i] == "riventricleavesoundone" 	then 	q1 		= false end
				--if BuffNames[i] == "riventricleavesoundtwo" 	then 	q2  	= false end
				--if BuffNames[i] == "riventricleavesoundthree" then 	q3 		= false end 
			end	
		end
	end
end

--[[cast Spells/items]]
function CheckItems(tabela)
	for ItemIndex, Value in pairs(tabela) do
		Value.slot = GetInventorySlotItem(Value.SlotId)			
			if Value.slot ~= nil and (myPlayer:CanUseSpell(Value.slot) == READY) then				
			FoundItems[#FoundItems+1] = ItemIndex	
		end
	end
end

function CastCommonItem()
	CheckItems(Items)
	if #FoundItems ~= 0 then
		for i, Items_ in pairs(FoundItems) do
			if Target ~= nil then				
				if GetDistance(Target) <= Items[Items_].range then 
					if 	Items_ == "Brtk" or Items_ == "Bc" then
						CastSpell(Items[Items_].slot, Target)
					else					
						CastSpell(Items[Items_].slot)					
					end
				end
			end
			FoundItems[i] = nil --clear table to optimaze
		end	
	end
end

function CastSurviveItem()
	CheckItems(HP_MANA)	
	local hp_ 					= menu.extra.hp	
	local hppercent_			= menu.extra.hppercent	
	local myPlayerhp_	 		= (myPlayer.health / myPlayer.maxHealth *100)	
	local barrier_				= menu.extra.barrier
	local barrierPercent_		= menu.extra.barrierPercent	
	if #FoundItems ~= 0 then	
		for i, HP_MANA_ in pairs(FoundItems) do
			if HP_MANA_ == "Hppotion" and myPlayerhp_ <= hppercent_ and not InFountain() and not UsandoHP then
				CastSpell(HP_MANA[HP_MANA_].slot)
			end					
		FoundItems[i] = nil
		end
		if BarreiraSpell.slot ~= nil and barrier_ and myPlayerhp_ <= barrierPercent_ and not InFountain() then
			CastSpell(BarreiraSpell.slot)
		end 
	end
end

function CastIgnite(myTarget)		
	local AntiDoubleIgnite_ = menu.combo.settings.antiDi
	if IgniteSpell.slot ~= nil and ValidTarget(myTarget, IgniteSpell.range) then	
		if AntiDoubleIgnite_ and TargetHaveBuff("SummonerDot", myTarget) then return end
		if AntiDoubleIgnite_ and not TargetHaveBuff("SummonerDot", myTarget) and myPlayer:CanUseSpell(IgniteSpell.slot) == READY then			
			-- Packet('S_CAST', { spellId = IgniteSpell.slot, targetNetworkId = myTarget.networkID }):send()
			CastSpell(_IGNITE, myTarget)
		end
	end
end 

function JungleFarm()
	JungleMinions:update()	
	if CountEnemyHeroInRange(400, myHero) == 0 then	
	--local orb_			=	menu.system.orbwalker		
		for i, MinionJ in pairs(JungleMinions.objects) do
			if MinionJ ~= nil then											
			CastW(MinionJ)
			CastE(MinionJ)
			CastQ(MinionJ)					
			end
		end
		--if orb_ then OrbWalk() end
	end
end

function LineFarm()
	MinionsInimigos:update()
	for i, MinionJ in pairs(MinionsInimigos.objects) do
		if MinionJ ~= nil then				
			CastE(MinionJ)
			CastW(MinionJ)
			CastQ(MinionJ)
		end
	end
end

function JumpQ()
	if SkillReady(skilllist[1]) then
		CastSpell(skilllist[1], mousePos.x, mousePos.z)
	end
	myPlayer:MoveTo(mousePos.x, mousePos.z)
end

function OnTick()
	--[[combo]]
	local combokey_		=	menu.combo.key	
	local e_			= 	menu.combo.settings.e
	local stun_			=	menu.combo.settings.stun
	local r_			=	menu.combo.settings.r
	local ignite_ 		=	menu.combo.settings.ignite
	local items_ 		=	menu.combo.settings.items
	--[[harass]]
	local q_2			=	menu.harass.q
	local w_2			=	menu.harass.w
	local e_2			=	menu.harass.e
	local key_2			=	menu.harass.key
	--[[extra]]
	local jungleKey_	=	menu.extra.jungleKey
	local jump_			=	menu.extra.jump
	local items_2 		=	menu.extra.items
	local lineKey_		=	menu.extra.lineKey
	--[[system]]
	local orb_			=	menu.system.orbwalker
	--[[update target]]	
	Target 	=	UpdateTarget()
	--[[items usage]]	
	if items_2 then CastSurviveItem() end
	--[[combo active]]		
	if combokey_ then 
		if boxbox_ == 1 then
			if r_ then CastR(Target) end		
			if e_ then CastE(Target) end
			CastW(Target)
			CastQ(Target)
			if orb_ 	then OrbWalk(Target) end
		end	
		if boxbox_ == 2 then
			if r_ then CastR(Target) end		
			if e_ then CastE(Target) end
			CastW(Target)
			CastQ(Target)
			if orb_ 	then OrbWalk(Target) end			
		end			
		if ignite_ 	then CastIgnite(Target) end
		if items_ 	then CastCommonItem() end

	end
	if stun_ 		then CastW(Target) end
	if key_2		then
		if e_2 		then CastE(Target) end
		if w_2 		then CastW(Target) end
		if q_2 		then CastQ(Target) end		
		if orb_ 	then OrbWalk(Target) end
	end
	if jungleKey_ 	then JungleFarm() end	
	if lineKey_ 	then LineFarm() end
	if jump_ 		then JumpQ() end	
end

--[[Credits to barasia, vadash and viseversa for anti-lag circles]]--
function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
	radius = radius or 300
	quality = math.max(8,math.floor(180/math.deg((math.asin((chordlength/(2*radius)))))))
	quality = 2 * math.pi / quality
	radius = radius*.92
	local points = {}
	for theta = 0, 2 * math.pi + quality, quality do
		local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
		points[#points + 1] = D3DXVECTOR2(c.x, c.y)
	end
	DrawLines2(points, width or 1, color or 4294967295)
end

function DrawCircle2(x, y, z, radius, color)
	local vPos1 = Vector(x, y, z)
	local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
	local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
	local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
	if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y })  then
		DrawCircleNextLvl(x, y, z, radius, 1, color, 75)	
	end
end
--

function OnDraw()
	if myPlayer.dead then return end
	--[[menu variables]]	
	local drawq_			=	menu.draw.Q --RivenTriCleave
	local draww_			=	menu.draw.W --RivenMartyr
	local drawe_			=	menu.draw.E --RivenFeint
	local drawr_			=	menu.draw.R --RivenFengShuiEngine
	local drawTarget		=	menu.draw.target
	if drawq_ then 
		DrawCircle2(myPlayer.x, myPlayer.y, myPlayer.z, RivenTriCleave.range, ARGB(255, 255, 000, 000))
	end
	if draww_ then 
		DrawCircle2(myPlayer.x, myPlayer.y, myPlayer.z, RivenMartyr.range, ARGB(255, 000, 255, 000))
	end
	if drawe_ then 
		DrawCircle2(myPlayer.x, myPlayer.y, myPlayer.z, RivenFeint.range, ARGB(255, 000, 000, 255))
	end
	if drawr_ then 
		DrawCircle2(myPlayer.x, myPlayer.y, myPlayer.z, RivenFengShuiEngine.range, ARGB(255, 255, 255, 000))
	end
	if drawTarget and ValidTarget(Target) then
		for i=0, 3, 1 do
			DrawCircle2(Target.x, Target.y, Target.z, 80 + i , ARGB(255, 255, 000, 255))	
		end
	end
end



