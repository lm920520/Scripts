if myHero.charName ~= "Darius" then return end

local PACKET_MOVE = 2
local PACKET_ATTACK = 3
local PACKET_ATTACK_CLOSEST_TARGET = 7

function SendPacketCastSpell(SpellID, ToX, ToZ, Target)
	if ToX == 0 then
		ToX = Target.x
	end
	if ToZ == 0 then
		ToZ = Target.z
	end
	local TargetID = 0 
	if Target ~= nil then
		TargetID = Target.networkID
	end
	local Packet = CLoLPacket(153) 
	Packet.dwArg1 = 1
	Packet.dwArg2 = 0
	Packet:EncodeF(myHero.networkID) -- HeroID
	Packet:Encode1(SpellID) -- SpellID
	Packet:EncodeF(ToX) -- ToX
	Packet:EncodeF(ToZ) -- ToZ
	Packet:EncodeF(myHero.x) -- FromX
	Packet:EncodeF(myHero.z) -- FormZ
	Packet:EncodeF(TargetID) -- TargetID
	SendPacket(Packet)
end

function SendPacketMove(Type, PosX, PosY, TargetID)
	local Packet = CLoLPacket(113) -- 
	Packet.dwArg1 = 1
	Packet.dwArg2 = 0
	Packet:EncodeF(myHero.networkID)
	Packet:Encode1(Type) -- Move Type
	Packet:EncodeF(PosX) -- To X
	Packet:EncodeF(PosY) -- To Z
	Packet:EncodeF(TargetID or 0) -- Target network id
	Packet:EncodeF(0)
	Packet:EncodeF(0)
	Packet:EncodeF(0)
	Packet:Encode1(0)
	SendPacket(Packet)
end

--[[

	Globals

]]--

local AARange = 125
local ExtraDmg = 1.0
local MyHeroLevel = 0

local MainTarget = nil
local EnemyTable = {}

local EnemyTurrets = {}

local HemoTable = {
[0] = "darius_Base_hemo_counter_01.troy",
[1] = "darius_Base_hemo_counter_02.troy",
[3] = "darius_Base_hemo_counter_03.troy",
[4] = "darius_Base_hemo_counter_04.troy",
[5] = "darius_Base_hemo_counter_05.troy"
}

local ProtectingSpells = {

}

local ColorTable = {
	Black = ARGB(0x00,0x00,0x00,0x00),
	Silver = ARGB(0x00,0xC0,0xC0,0xC0),
	Gray = ARGB(0x00,0x80,0x80,0x80),
	White = ARGB(0xFF,0xFF,0xFF,0xFF),
	Maroon = ARGB(0x00,0x80,0x00,0x00),
	Red = ARGB(0x00,0xFF,0x00,0x00),
	Purple = ARGB(0x00,0x80,0x00,0x80),
	Pink = ARGB(0x00,0xFF,0x00,0xFF),
	Green = ARGB(0x00,0x00,0x80,0x00),
	Lime = ARGB(0x00,0x00,0xFF,0x00),
	Olive = ARGB(0x00,0x80,0x80,0x00),
	Yellow = ARGB(0x00,0xFF,0xFF,0x00),
	Navy = ARGB(0x00,0x00,0x00,0x80),
	Blue = ARGB(0x00,0x00,0x00,0xFF),
	Teal = ARGB(0x00,0x00,0x80,0x80),
	Aqua = ARGB(0x00,0x00,0xFF,0xFF)
}

local function Get2dDistance(P1, P2)
	if P1 ~= nil and P2 ~= nil then
		return math.sqrt( (P1.x-P2.x)*(P1.x-P2.x) + (P1.z-P2.z)*(P1.z-P2.z) )
	end
	return math.huge
end


--[[

	Spells

]]--

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


class 'SpellQ'

function SpellQ:__init()
	self.BaseRange = 425
	self.Range = 425
	self.Ready = false
	self.MinRange = 270
	self.ManaCost = 40
	self.ID = _Q
end

function SpellQ:Cast(Target)
	if self.Ready then
		if VIP_USER then
			if Target ~= nil and Get2dDistance(myHero, Target) <= self.Range then
				SendPacketCastSpell(self.ID, myHero.x, myHero.z)
			end
		else
			if Target ~= nil and Get2dDistance(myHero, Target) <= self.Range then
				CastSpell(self.ID)
			end
		end
	end
end

function SpellQ:Harass(Target, Perfect)
	if self.Ready then
		if Target ~= nil then
			if Perfect then
				local DistanceToTarget = Get2dDistance(myHero, Target)
				if VIP_USER then
					if Target ~= nil and DistanceToTarget <= self.Range and DistanceToTarget >= self.MinRange then
						SendPacketCastSpell(self.ID, Target.x, Target.z)
					end
				else
					if Target ~= nil and Get2dDistance(myHero, Target) <= self.Range then
						CastSpell(self.ID)
					end
				end
			else	
				if VIP_USER then
					if Target ~= nil and Get2dDistance(myHero, Target) <= self.Range then
						SendPacketCastSpell(self.ID, Target.x, Target.z)
					end
				else
					if Target ~= nil and Get2dDistance(myHero, Target) <= self.Range then
						CastSpell(self.ID)
					end
				end
			end
		end
	end
end

function SpellQ:DmgToTarget(Target)
	if Target ~= nil and Get2dDistance(myHero, Target) >= self.MinRange then
		return (player:CalcDamage(Target, 35*(player:GetSpellData(self.ID).level-1)+70+(.7*player.addDamage))*1.5)*ExtraDmg
	else
		return (player:CalcDamage(Target, 35*(player:GetSpellData(self.ID).level-1)+70+(.7*player.addDamage)))*ExtraDmg
	end
end

function SpellQ:Draw(Color)
	if Color == nil then
		Color = ColorTable.Aqua
	end
	DrawCircle2(myHero.x, myHero.y, myHero.z, self.Range, Color)
end

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

class 'SpellW'

function SpellW:__init()
	self.BaseRange = 145
	self.Range = 145
	self.Ready = false
	self.ManaCost = 30
	self.ID = _W
end

function SpellW:Cast(Target)
	if self.Ready then
	if VIP_USER then
		if Target ~= nil and Get2dDistance(myHero, Target) <= self.Range then
			SendPacketCastSpell(self.ID, Target.x, Target.z)
		end
	else
		if Target ~= nil and Get2dDistance(myHero, Target) <= self.Range then
			CastSpell(self.ID)
		end
	end
	end
end

function SpellW:SetMana()
	self.ManaCost = 30 + 5*(player:GetSpellData(self.ID).level-1)
end

function SpellW:DmgToTarget(Target)
	return (player:CalcDamage(Target, 0.2*(player:GetSpellData(self.ID).level-1)*player.damage + player.damage)*ExtraDmg)
end

function SpellW:Draw(Color)
	if Color == nil then
		Color = ColorTable.Aqua
	end
	DrawCircle2(myHero.x, myHero.y, myHero.z, self.Range, Color)
end


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


class 'SpellE'

function SpellE:__init()
	self.BaseRange = 540
	self.Range = 540
	self.Ready = false
	self.ManaCost = 45
	self.ID = _E
end

function SpellE:Cast(Target)
	if self.Ready then
		if VIP_USER then
			if Target ~= nil and Get2dDistance(myHero, Target) <= self.Range then
				CastSpell(self.ID, Target.x, Target.z)
			end
		else
			if Target ~= nil and Get2dDistance(myHero, Target) <= self.Range then
				CastSpell(self.ID, Target.x, Target.z)
			end
		end
	end
end

function SpellE:DmgToTarget(Target)
	return  0
end

function SpellE:Draw(Color)
	if Color == nil then
		Color = ColorTable.Aqua
	end
	DrawCircle2(myHero.x, myHero.y, myHero.z, self.Range, Color)
end


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


class 'SpellR'

function SpellR:__init()
	self.BaseRange = 460
	self.Range = 460
	self.Ready = false
	self.ManaCost = 100
	self.ID = _R
end

function SpellR:Cast(Target)
	if self.Ready then
		if VIP_USER then
			if Target ~= nil and Get2dDistance(myHero, Target) <= self.Range then
				SendPacketCastSpell(self.ID, Target.x, Target.z, Target)
			end
		else
			CastSpell(self.ID, Target)
		end
	end
end

function SpellR:DmgToTarget(Target)
	return ((160 + 90*(player:GetSpellData(self.ID).level-1)+(.75*player.addDamage)) * (1.0 + Target.HemoStacks * 0.2))*ExtraDmg
end

function SpellR:Draw(Color)
	if Color == nil then
		Color = ColorTable.Aqua
	end
	DrawCircle2(myHero.x, myHero.y, myHero.z, self.Range, Color)
end


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


class 'SpellIgnite'

function SpellIgnite:__init()
	self.Name = "SummonerDot"
	self.BaseRange = 600
	self.Range = 600
	self.Ready = false
	self.ID = nil
end

function SpellIgnite:Cast(Target)
	if self.Ready then
		if Get2dDistance(Target, myHero) <= self.Range then
			if VIP_USER then
				SendPacketCastSpell(self.ID, Target.x, Target.z, Target)
			else
				CastSpell(self.ID, Target)
			end
		end
	end
end

function SpellIgnite:DmgToTarget(Target)
	return (50 + 20 * myHero.level)
end

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


--[[
	
	Functions

]]--

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

function Draw3DBox(Object, Linesize, Linecolor)
	Linesize = Linesize or 1
	Linecolor = Linecolor or ARGB(255, 255, 255, 0)
	if Object and Object.minBBox then
	
		local x1, y1, z1 = get2DFrom3D(Object.minBBox.x, Object.minBBox.y, Object.minBBox.z)
		local x2, y2, z2 = get2DFrom3D(Object.maxBBox.x, Object.minBBox.y, Object.minBBox.z)
		local x3, y3, z3 = get2DFrom3D(Object.minBBox.x, Object.maxBBox.y, Object.maxBBox.z)
		local x4, y4, z4 = get2DFrom3D(Object.maxBBox.x, Object.maxBBox.y, Object.maxBBox.z)
		
		DrawLine(x1, y1, x2, y2, Linesize, Linecolor)
		DrawLine(x2, y2, x4, y4, Linesize, Linecolor)
		DrawLine(x3, y3, x1, y1, Linesize, Linecolor)
		DrawLine(x4, y4, x3, y3, Linesize, Linecolor)
	end
end

function MenuColorToARGB(MenuColor)
	return ARGB(MenuColor[1], MenuColor[2], MenuColor[3], MenuColor[4])
end


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


function GetObjectCenter(Object)
	if Object ~= nil and Object.minBBox then
		local x1, y1, z1 = get2DFrom3D(Object.minBBox.x, Object.minBBox.y, Object.minBBox.z)
		local x2, y2, z2 = get2DFrom3D(Object.maxBBox.x, Object.maxBBox.y, Object.maxBBox.z)
		
		local CenterX = (x1 + x2)/2 
		local CenterY = (y1 + y2)/2
			
		return CenterX, CenterY
		
	else
		return 0, 0, 0
	end
end


function DrawStacks(Hero)
	local x, y, z =  GetObjectCenter(Hero)
	DrawText(tostring(Hero.HemoStacks), 20, x, y, ColorTable.White)
end 


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


function OnLevelUp()
	if myHero.level > MyHeroLevel then
		if DariusMenu.Spells.AutoLevelUlti and myHero.level == 6 or myHero.level == 11 or myHero.level == 16 then
			LevelSpell(_R)
		end
		W:SetMana()
		MyHeroLevel = myHero.level
	end
end


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


function SpellStateUpdate()
	if myHero:CanUseSpell(_Q) then Q.Ready = true else Q.Ready = false end
	if myHero:CanUseSpell(_W) then W.Ready = true else W.Ready = false end
	if myHero:CanUseSpell(_E) then E.Ready = true else E.Ready = false end
	if myHero:CanUseSpell(_R) then R.Ready = true else R.Ready = false end
	if myHero:CanUseSpell(Ignite.ID) then Ignite.Ready = true else Ignite.Ready = false end
	
	Q.Range = Q.BaseRange - DariusMenu.Spells.DecreaseQRange
	E.Range = E.BaseRange - DariusMenu.Spells.DecreaseERange
	
end


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


function DoCombo(Target)
	if Target ~= nil then
		Q:Cast(Target)
		W:Cast(Target)
		E:Cast(Target)
		
		if Target and Get2dDistance(Target, myHero) <= (AARange + 100) and DariusMenu.Combo.UseAA then
			player:Attack(Target)
		elseif DariusMenu.Combo.MoveToMouse then
			player:MoveTo(mousePos.x, mousePos.z)
		end
	
	elseif DariusMenu.Combo.MoveToMouse then
		player:MoveTo(mousePos.x, mousePos.z)
	end

end


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


function DoHarass(Target)
	if Target ~= nil and not Target.dead then
		if DariusMenu.Spells.QCheckVisible then
			if myHero.mana/myHero.maxMana >= DariusMenu.Harass.ManaCheck and Target.visible then
				if DariusMenu.Harass.UsePerfectHarass then
					Q:Harass(Target, true)
				else
					Q:Harass(Target, false)
				end
			end
		else
			if myHero.mana/myHero.maxMana >= DariusMenu.Harass.ManaCheck then
				if DariusMenu.Harass.UsePerfectHarass then
					Q:Harass(Target, true)
				else
					Q:Harass(Target, false)
				end
			end		
		end
	end
end


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


function KillSteal()
	for i, Enemy in pairs(EnemyTable) do
		
		--if Enemy.HemoStacks > 0 and GetTickCount() > Enemy.HemoTmr + 5000 then
		--	Enemy.HemoStacks = 0
		--end
		
		if Get2dDistance(myHero, Enemy) <= 1200 and not Enemy.dead then
			if DariusMenu.Spells.AutoQKs then
				if Q.Ready and  Q:DmgToTarget(Enemy) > Enemy.health then
					Q:Cast(Enemy)
				end
			end
			if DariusMenu.Spells.AutoDunk1 or DariusMenu.Spells.AutoDunk2 then
				if R.Ready and (R:DmgToTarget(Enemy)- DariusMenu.Spells.DecreaseDunkDmg) > Enemy.health and not Enemy.Protected then
					R:Cast(Enemy)
				end
			end
			if DariusMenu.Misc.AutoIgnite then
				if Ignite.Ready and (Ignite:DmgToTarget(Enemy) - DariusMenu.Misc.DecreaseIgniteDmg) > Enemy.health then
					Ignite:Cast(Enemy)
				end
			end
		end
	end
end


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


function TurretsUpdate()
	for i, Turret in pairs(EnemyTurrets) do
        if Turret.valid == false or Turret.dead or Turret.health == 0 then
			table.remove(EnemyTurrets, Turret)
		end
	end
end


function IsHeroUnderTower(Hero)
	for i, Turret in pairs(EnemyTurrets) do
		if Turret ~= nil and Turret.health > 0 then
			if Get2dDistance(Hero, Turret) <= 1300 then
				return true
			end
		end
	end
	return false
end


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------



--[[

	Main

]]--

function OnLoad()
	
	DariusMenu = scriptConfig("Darius", "Darius")
	DariusMenu:addParam("ComboKey", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	DariusMenu:addParam("Harass1Key", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
	DariusMenu:addParam("Harass2Key", "Harass (TOGGLE)",  SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("C"))
	
	DariusMenu:permaShow("ComboKey")
	DariusMenu:permaShow("Harass1Key")
	DariusMenu:permaShow("Harass2Key")
	
	DariusMenu:addSubMenu("Combo", "Combo")
		DariusMenu.Combo:addParam("UseItems", "Use Items", SCRIPT_PARAM_ONOFF , true)
		DariusMenu.Combo:addParam("UseAA", "Use auto attacks", SCRIPT_PARAM_ONOFF , true)
		DariusMenu.Combo:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF , true)
		DariusMenu.Combo:addParam("UseW", "Use W", SCRIPT_PARAM_ONOFF , true)
		DariusMenu.Combo:addParam("UseE", "Use E", SCRIPT_PARAM_ONOFF , true)
		DariusMenu.Combo:addParam("MoveToMouse", "Move To Mouse", SCRIPT_PARAM_ONOFF , true)
	
	DariusMenu:addSubMenu("Harass", "Harass")
		DariusMenu.Harass:addParam("UsePerfectHarass", "Perfect Harass", SCRIPT_PARAM_ONOFF , true)
		DariusMenu.Harass:addParam("ManaCheck", "Don't harass under mana %", SCRIPT_PARAM_SLICE, 0, 0, 100)
		DariusMenu.Harass:addParam("TowerCheck", "Don't harass under towers", SCRIPT_PARAM_ONOFF , true)
	
	DariusMenu:addSubMenu("Spells", "Spells")
		DariusMenu.Spells:addParam("AutoLevelUlti", "Auto add Dunk", SCRIPT_PARAM_ONOFF , true)
		DariusMenu.Spells:addParam("DecreaseDunkDmg", "Decrease Dunk Dmg for: ", SCRIPT_PARAM_SLICE, 30, 0, 150)
		DariusMenu.Spells:addParam("AutoDunk1", "Auto Dunk", SCRIPT_PARAM_ONOFF , true)
		DariusMenu.Spells:addParam("AutoDunk2", "Auto Dunk (TOGGLE)",  SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("X"))
		DariusMenu.Spells:permaShow("AutoDunk1")
		DariusMenu.Spells:permaShow("AutoDunk2")
		DariusMenu.Spells:addParam("FreeSpace", " ", SCRIPT_PARAM_INFO, " ")
		DariusMenu.Spells:addParam("DecreaseERange", "Decrease E Range for: ", SCRIPT_PARAM_SLICE, 20, 0, 50)
		DariusMenu.Spells:addParam("DecreaseQRange", "Decrease Q Range for: ", SCRIPT_PARAM_SLICE, 20, 0, 50)
		DariusMenu.Spells:addParam("AutoQKs", "Auto kill steal with Q", SCRIPT_PARAM_ONOFF , true)
		DariusMenu.Spells:addParam("FreeSpace", " ", SCRIPT_PARAM_INFO, " ")
		DariusMenu.Spells:addParam("QCheckVisible", "Cast Q only on visible targets", SCRIPT_PARAM_ONOFF , false)
		
	DariusMenu:addSubMenu("Misc", "Misc")
		DariusMenu.Misc:addParam("AutoIgnite", "Auto Ignite", SCRIPT_PARAM_ONOFF , true)
		DariusMenu.Misc:addParam("DecreaseIgniteDmg", "Decrease Ignite Dmg for: ", SCRIPT_PARAM_SLICE, 30, 0, 150)
		DariusMenu.Misc:addParam("FreeSpace", " ", SCRIPT_PARAM_INFO, " ")
		DariusMenu.Misc:addParam("HealthCheckPotions", "Use health potions at health %", SCRIPT_PARAM_SLICE, 50, 0, 100)
		DariusMenu.Misc:addParam("ManaCheckPotions", "Use mana potions at mana %", SCRIPT_PARAM_SLICE, 50, 0, 100)
		
	DariusMenu:addSubMenu("Draw", "Draw")
		DariusMenu.Draw:addParam("DrawQRange", "Draw Spell Q Range", SCRIPT_PARAM_ONOFF , true)
		DariusMenu.Draw:addParam("QCircleColor", "Spell Q Circle Color", SCRIPT_PARAM_COLOR, {255,0,255,0})
		DariusMenu.Draw:addParam("FreeSpace", " ", SCRIPT_PARAM_INFO, " ")
		DariusMenu.Draw:addParam("DrawWRange", "Draw Spell W Range", SCRIPT_PARAM_ONOFF , false)
		DariusMenu.Draw:addParam("WCircleColor", "Spell W Circle Color", SCRIPT_PARAM_COLOR, {255,0,255,0})
		DariusMenu.Draw:addParam("FreeSpace", " ", SCRIPT_PARAM_INFO, " ")
		DariusMenu.Draw:addParam("DrawERange", "Draw Spell E Range", SCRIPT_PARAM_ONOFF , true)
		DariusMenu.Draw:addParam("ECircleColor", "Spell E Circle Color", SCRIPT_PARAM_COLOR, {255,0,255,0})
		DariusMenu.Draw:addParam("FreeSpace", " ", SCRIPT_PARAM_INFO, " ")
		DariusMenu.Draw:addParam("DrawRRange", "Draw Spell R Range", SCRIPT_PARAM_ONOFF , true)
		DariusMenu.Draw:addParam("RCircleColor", "Spell R Circle Color", SCRIPT_PARAM_COLOR, {255,0,255,0})
		DariusMenu.Draw:addParam("FreeSpace", " ", SCRIPT_PARAM_INFO, " ")
		DariusMenu.Draw:addParam("FreeSpace", " ", SCRIPT_PARAM_INFO, " ")
		DariusMenu.Draw:addParam("DrawFocus", "Draw Focus", SCRIPT_PARAM_ONOFF , true)
		DariusMenu.Draw:addParam("FocusColor", "Spell Focus", SCRIPT_PARAM_COLOR, {255,255,0,0})
	
	for i=0, heroManager.iCount, 1 do
		Hero = heroManager:GetHero(i)
		if Hero.team ~= myHero.team then
			Hero.Protected = false
			Hero.HemoStacks = 0
			Hero.HemoTmr = 0 
			table.insert(EnemyTable, Hero)
		end
	end
	
	for i = 0, objManager.maxObjects do
		local Obj = objManager:getObject(i)
		if Obj ~= nil and (Obj.type == "obj_AI_Turret") then
			if Obj.team ~= myHero.team then
				table.insert(EnemyTurrets, Obj)
			end
		end
	end
	
	Q = SpellQ()
	W = SpellW()
	E = SpellE()
	R = SpellR()
	Ignite = SpellIgnite()
	
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
		Ignite.ID = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
		Ignite.ID = SUMMONER_2
	end 

	
	Ts = TargetSelector(TARGET_LOW_HP, E.Range,DAMAGE_PHYSICAL)
    Ts.name = Darius
    DariusMenu:addTS(Ts)
	
end


function OnTick()
	Ts:update()
	MainTarget = Ts.target
	SpellStateUpdate()
	KillSteal()	
	OnLevelUp()
	
	if DariusMenu.ComboKey then
		DoCombo(MainTarget)
	end
	
	if not DariusMenu.ComboKey and (DariusMenu.Harass1Key or DariusMenu.Harass2Key) then
		if DariusMenu.Harass.TowerCheck then
			if not IsHeroUnderTower(myHero) then
				DoHarass(MainTarget)
			end
		else
			DoHarass(MainTarget)
		end
	end
	
end

function OnDraw()
	if not myHero.dead then
		if DariusMenu.Draw.DrawQRange then
			Q:Draw(MenuColorToARGB(DariusMenu.Draw.QCircleColor))
		end
		if DariusMenu.Draw.DrawWRange then
			W:Draw(MenuColorToARGB(DariusMenu.Draw.WCircleColor))
		end
		if DariusMenu.Draw.DrawERange then
			E:Draw(MenuColorToARGB(DariusMenu.Draw.ECircleColor))
		end
		if DariusMenu.Draw.DrawRRange then
			R:Draw(MenuColorToARGB(DariusMenu.Draw.RCircleColor))
		end
		if DariusMenu.Draw.DrawFocus and MainTarget ~= nil and MainTarget.visible and not MainTarget.dead then
			Draw3DBox(MainTarget, 1, MenuColorToARGB(DariusMenu.Draw.FocusColor))
		end
		
		for i, Enemy in pairs(EnemyTable) do
			if Enemy ~= nil and not Enemy.dead and Get2dDistance(Enemy, myHero) <= 2000  and Enemy.visible then
				DrawStacks(Enemy)
			end
		end
	end
end

--[[
	104 STH WITH CHAT


function OnRecvPacket(P)
	if P.header ~= 106 and P.header ~= 96 and P.header ~= 146 and P.header ~= 117 and P.header ~= 43 and P.header ~= 195 and P.header ~= 51 and P.header ~= 109 and P.header ~= 254 and P.header ~= 26
		and P.header ~= 89 and P.header ~= 173 and P.header ~= 190 and P.header ~= 37 and P.header ~= 105 and P.header ~= 28 and P.header ~= 122 and P.header ~= 182 and P.header ~= 79 and P.header ~= 16 
		and P.header ~= 157 and P.header ~= 180 and P.header ~= 192 and P.header ~= 155 and P.header ~= 134 and P.header ~= 185 and P.header ~= 12 and P.header ~= 62 and P.header ~= 55 and P.header ~= 121 
		and P.header ~= 80 and P.header ~= 31 and P.header ~= 50 and P.header ~= 126 and P.header ~= 23 and P.header ~= 215 and P.header ~= 132 and P.header ~= 21 and P.header ~= 147 and P.header ~= 58
		and P.header ~= 67 and P.header ~= 110 and P.header ~= 35 and P.header ~= 52 and P.header ~= 58 and P.header ~= 67 and P.header ~= 40 and P.header ~= 46 and P.header ~= 102 and P.header ~= 103
		and P.header ~= 40  and P.header ~= 158 and P.header ~= 239 and P.header ~= 107 and P.header ~= 104 and P.header ~= 150 and P.header ~= 11
	then
		PrintChat(tostring(P.header))
	end
end

]]--



function OnCreateObj(Obj)
    if string.find(Obj.name,"darius_Base_hemo_counter_") then
        for i, Enemy in pairs(EnemyTable) do
            if Enemy ~= nil and not Enemy.dead and  GetDistance(Enemy, Obj) <= 80 then
				for j, Hemo in pairs(HemoTable) do
					if Obj.name == Hemo then
						Enemy.HemoStacks = j
						Enemy.HemoTmr = GetTickCount()
					end
				end
            end
        end
    end
end

function OnDeleteObj(obj)


end


--[[
function OnGainBuff(Unit, Buff)
	for i, Enemy in pairs(EnemyTable) do
		if Unit.charName == Enemy.charName then
			if Buff.name == "dariushemo" then
				Enemy.HemoStacks = 1
			end
		end
	end
end
function OnLoseBuff(Unit, Buff)
	for i, Enemy in pairs(EnemyTable) do
		if Unit.charName == Enemy.charName then
			if Buff.name == "dariushemo" then
				Enemy.HemoStacks = 0
			end
		end
	end
end
function OnUpdateBuff(Unit, Buff)
	for i, Enemy in pairs(EnemyTable) do
		if Unit.charName == Enemy.charName and Buff ~= nil and Buff.stack ~= nil then
			if Buff.name == "dariushemo" then
				Enemy.HemoStacks = Buff.stack
			end
		end
	end
end
]]--
