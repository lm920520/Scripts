--[[ iBunny by Apple - Getting Riven ready for bunny style rampage 

Special thanks to Jbman for the large amount of help.]]--

if myHero.charName ~= "Riven" then return end

require "spellDmg"

--[[ Config ]]--
local HK1 = 32 -- Spacebar - PewPew! Hotkey
local HK2 = 88 -- X - Stun Combo HotKey
local HK3 = 84 -- T - Q-Spam
local DevVersion = false

--[[ Constants ]]--
local QRange = 260
local QRadius = 112.5
local WRange = 125
local ERange = 325
local RRange = 900
local AARange = 125
local BRKid, DFGid, EXECid, YOGHid, RANOid, BWCid, HXGid = 3153, 3128, 3123, 3142, 3143, 3144, 3146
local BRKSlot, DFGSlot, EXECSlot, YOGHSlot, RANOSlot, BWCSlot, HXGSlot = nil, nil, nil, nil, nil, nil, nil

--[[ Script Variables ]]--
local ts = TargetSelector(TARGET_LOW_HP,ERange)
local lastQ
local QCount = 0
local lastHasUlt
local pCount = 0
local lastPassive
local lastdirection = 0
local lastBasicAttack = 0
local swingDelay = 150
local swing = 0 
local lastSpellCast = 0
local qCast = 0

function OnLoad()
	acConfig = scriptConfig("iBunny", "rivenhelper")
	acConfig:addParam("HasUlt", "Ultimate", SCRIPT_PARAM_ONOFF, false)
	acConfig:addParam("scriptActive", "PewPew!", SCRIPT_PARAM_ONKEYDOWN, false, HK1)
	acConfig:addParam("stunComboActive", "Stun Combo!", SCRIPT_PARAM_ONKEYDOWN, false, HK2)
	acConfig:addParam("qspam", "Q-Spam!", SCRIPT_PARAM_ONKEYDOWN, false, HK3)
	acConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	acConfig:addParam("AutoUlt", "AutoUlt on killable targets?", SCRIPT_PARAM_ONOFF, true)
	acConfig:addParam("AutoAA", "No right click to AA?", SCRIPT_PARAM_ONOFF, true)
	acConfig:addParam("AlwaysStun", "Always stun when an enemy is within range?", SCRIPT_PARAM_ONOFF, false)
	acConfig:addParam("FirstUlt", "Start casting ult early?", SCRIPT_PARAM_ONOFF, true)
	acConfig:addParam("ultpercentage", "When to start casting ult early?", SCRIPT_PARAM_SLICE, 5, 0, 25, 1)
	acConfig:addParam("Weaving", "Q-AA-Q Weaving?", SCRIPT_PARAM_ONOFF, true)
	acConfig:permaShow("scriptActive")
	acConfig:permaShow("stunComboActive")
	if DevVersion then
		acConfig:permaShow("HasPassive")
		acConfig:permaShow("HasUlt")
	end
	acConfig:permaShow("qspam")
	ts.name = "Riven"
	acConfig:addTS(ts)
end

function OnTick()
	ts:update()
	if QCount ~= nil and lastQ ~= nil and lastQ < (GetTickCount() - 4000) then
		QCount = 0
	end	
	if lastHasUlt ~= nil and lastHasUlt < (GetTickCount() - 15000) then
		acConfig.HasUlt = false
	end
	if swing and GetTickCount() > (lastBasicAttack + (1000/myHero.attackSpeed)) then
		swing = false
	end
	if acConfig.HasUlt then
		WRange = 135
		AARange = 200
		if QCount <= 1 then
			QRadius = 162.5
		elseif QCount == 2 then
			QRadius = 200
		end
	elseif not acConfig.HasUlt then
		AARange = 125
		WRange = 125
		if QCount <= 1 then
			QRadius = 112.5
		elseif QCount == 2 then
			QRadius = 150
		end
	end
	if TargetHaveBuff("rivenwindslashready") then
		acConfig.HasUlt = true
		lastHasUlt = GetTickCount()
		if DevVersion then
			PrintChat("Riven Ultimate Ready!")
		end
	end
	if acConfig.AutoUlt then TerminatorVisionScanningForKillableTargetsWithUltimate() end
	if acConfig.scriptActive then PewPew() end
	if acConfig.qspam then SpamQ() end
	if acConfig.stunComboActive then StunCombo() end
	if acConfig.AlwaysStun then StunCheck() end
	DFGSlot = GetInventorySlotItem(DFGid)
	EXECSlot = GetInventorySlotItem(EXECid)
	YOGHSlot = GetInventorySlotItem(YOGHid)
	RANOSlot = GetInventorySlotItem(RANOid)
	BWCSlot = GetInventorySlotItem(BWCid)
	HXGSlot = GetInventorySlotItem(HXGid)
	BRKSlot = GetInventorySlotItem(BRKid)
end

function PewPew()
	if TargetValid(ts.target) then
		if myHero:CanUseSpell(_E) == READY and GetDistance(ts.target) < ERange and GetDistance(ts.target) > WRange then
			CastSpell(_E, ts.target.x, ts.target.z)
		end
		if myHero:CanUseSpell(_W) == READY and GetDistance(ts.target) < WRange and not (ts.target.isFeared or ts.target.isTaunted or ts.target.isCharmed) then
			CastSpell(_W)
		end
		if acConfig.Weaving then
			if not swing then
				if AutoAA and GetDistance(ts.target) < AARange+200 then
					myHero:Attack(ts.target)
				end
				if GetDistance(ts.target) < (QRange+QRadius) and not qCast then
					if GetDistance(ts.target) < QRange then
						CastSpell(_Q,ts.target.x,ts.target.z)
					else
						EnemyPos = Vector(ts.target.x,ts.target.z)
						HeroPos = Vector(myHero.x,myHero.z)
						QPos = HeroPos + ( HeroPos - EnemyPos ):normalized()
						QPos2 = QPos * ( -1 * (1-(QRange/GetDistance(ts.target)) )) 
						CastSpell(_Q, QPos2.x, QPos2.z)
					end
					qCast = true
				end
			else
				if GetDistance(ts.target) < (QRange+QRadius) and (GetTickCount() - lastBasicAttack > swingDelay) and not qCast then
					if GetDistance(ts.target) < QRange then
						CastSpell(_Q,ts.target.x,ts.target.z)
					else
						EnemyPos = Vector(ts.target.x,ts.target.z)
						HeroPos = Vector(myHero.x,myHero.z)
						QPos = HeroPos + ( HeroPos - EnemyPos ):normalized()
						QPos2 = QPos * ( -1 * (1-(QRange/GetDistance(ts.target)) )) 
						CastSpell(_Q, QPos2.x, QPos2.z)
					end
					qCast = true
					swing = false
				end
			end
		elseif GetDistance(ts.target) < QRange then
			CastSpell(_Q, ts.target.x, ts.target.z)
		elseif GetDistance(ts.target) < (QRadius+QRange) then
			EnemyPos = Vector(ts.target.x,ts.target.z)
			HeroPos = Vector(myHero.x,myHero.z)
			QPos = HeroPos + ( HeroPos - EnemyPos ):normalized()
			QPos2 = QPos * ( -1 * (1-(QRange/GetDistance(ts.target)) )) 
			CastSpell(_Q, QPos2.x, QPos2.z)
		end
		if acConfig.HasUlt and GetDistance(ts.target) < QRange then
			if iReady(DFGSlot) then CastSpell(DFGSlot, ts.target) end
			if iReady(EXECSlot) then CastSpell(EXECSlot, ts.target) end
			if iReady(YOGHSlot) then CastSpell(YOGHSlot) end
			if iReady(RANOSlot) then CastSpell(RANOSlot, ts.target) end
			if iReady(BWCSlot) then CastSpell(BWCSlot, ts.target) end
			if iReady(HXGSlot) then CastSpell(HXGSlot, ts.target) end
			if iReady(BRKSlot) then CastSpell(BRKSlot, ts.target) end
		end
	end
end

function StunCheck()
	if not myHero.dead and myHero:CanUseSpell(_W) == READY then
		for i=1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if enemy.team ~= myHero.team and enemy ~= nil then
				if GetDistance(enemy) < WRange then
					CastSpell(_W)
				end 
			end
		end
	end
end

function StunCombo()
	if TargetValid(ts.target) then
		if myHero:CanUseSpell(_E) == READY and myHero:CanUseSpell(_W) == READY and GetDistance(ts.target) < ERange and GetDistance(ts.target) > WRange then
			CastSpell(_E, ts.target.x, ts.target.z)
			lastPassive = GetTickCount()
			if GetDistance(ts.target) < WRange then
				CastSpell(_W)
			end
		end
	end
end

function TerminatorVisionScanningForKillableTargetsWithUltimate()
	if myHero:GetSpellData(_R).level ~= 0 and myHero:CanUseSpell(_R) == READY then
		for i=1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if enemy.team ~= myHero.team and enemy ~= nil then
				local RDamage = getDmg("R",enemy,myHero)
					if TargetValid(enemy) then
					if RDamage > enemy.health and GetDistance(enemy) < RRange then
						if acConfig.HasUlt then
							CastSpell(_R, enemy.x, enemy.z)
							acConfig.HasUlt = false
						else
							CastSpell(_R)
							if not enemy.dead then
								CastSpell(_R, enemy.x, enemy.z)
								acConfig.HasUlt = false
							end
						end
					elseif (RDamage+enemy.maxHealth*(acConfig.ultpercentage/100)) > enemy.health and GetDistance(enemy) < RRange then
						if not acConfig.HasUlt and acConfig.FirstUlt then
							CastSpell(_R)
						end
					end
				end
			end
		end
	end
end

function SpamQ()
	if not myHero.dead then
		if IsKeyDown(HK3) then  
			if GetTickCount()-lastdirection >= 500 then
				local absposxy = math.min(math.abs(mousePos.x-myHero.x),math.abs(mousePos.y-myHero.y))
				myHero:MoveTo(myHero.x+(mousePos.x-myHero.x)*100/absposxy,myHero.z+(mousePos.z-myHero.z)*100/absposxy)
				lastdirection = GetTickCount()
			elseif GetTickCount()-lastdirection >= 100 then
				myHero:MoveTo(mousePos.x,mousePos.z)
				CastSpell(_Q, mousePos.x,mousePos.z)  
				CastSpell(SPELL_1, mousePos.x,mousePos.z)
				CastSpell(_Q, mousePos.x,mousePos.z)
				CastSpell(SPELL_1, mousePos.x,mousePos.z)
			end
		elseif IsKeyDown(HK3) then  
			if GetTickCount()-lastdirection >= 500 then
				local absposxy = math.min(math.abs(mousePos.x-myHero.x),math.abs(mousePos.y-myHero.y))
				myHero:MoveTo(myHero.x+(mousePos.x-myHero.x)*100/absposxy,myHero.z+(mousePos.z-myHero.z)*100/absposxy)
				lastdirection = GetTickCount()
			elseif GetTickCount()-lastdirection >= 100 then
				myHero:MoveTo(mousePos.x,mousePos.z)
				CastSpell(_Q, mousePos.x,mousePos.z)  
				CastSpell(SPELL_1, mousePos.x,mousePos.z)
				CastSpell(_Q, mousePos.x,mousePos.z)
				CastSpell(SPELL_1, mousePos.x,mousePos.z)
			end
		elseif IsKeyDown(HK3) then  
			if GetTickCount()-lastdirection >= 500 then
				local absposxy = math.min(math.abs(mousePos.x-myHero.x),math.abs(mousePos.y-myHero.y))
				myHero:MoveTo(myHero.x+(mousePos.x-myHero.x)*100/absposxy,myHero.z+(mousePos.z-myHero.z)*100/absposxy)
				lastdirection = GetTickCount()
			elseif GetTickCount()-lastdirection >= 100 then
				myHero:MoveTo(mousePos.x,mousePos.z)
				CastSpell(_Q, mousePos.x,mousePos.z)  
				CastSpell(SPELL_1, mousePos.x,mousePos.z)
				CastSpell(_Q, mousePos.x,mousePos.z)
				CastSpell(SPELL_1, mousePos.x,mousePos.z)
			end 
		end
	end
end

function TargetValid(target)
	if target ~= nil and target.dead == false and target.team == TEAM_ENEMY and target.visible == true then
		return true
	else
		return false
	end
end

function iReady(itemslot)
	if itemslot ~= nil and myHero:CanUseSpell(itemslot) then
		return true
	else
		return false
	end
end

function OnDraw()
	if acConfig.drawcircles and not myHero.dead then
		DrawCircle(myHero.x,myHero.y,myHero.z, QRange, 0xFF80FF00)
		if ts.target ~= nil then
			DrawText("Targetting: " .. ts.target.charName, 18, 100, 100, 0xFFFF0000)
			DrawCircle(ts.target.x, ts.target.y, ts.target.z, 100, 0xFF80FF00)
		end
		if QPos2 ~= nil and DevVersion then
			DrawCircle(QPos2.x, QPos2.y, QPos2.z, 100, 0xFFFF0000)
		end
	end
	SC__OnDraw()
end

function OnProcessSpell(unit, spell)
	if unit.isMe and spell.name:find("Attack") ~= nil then
		lastBasicAttack = GetTickCount()
		swing = true
		qCast = false
	end	
end

function OnWndMsg(msg,key)
	SC__OnWndMsg(msg,key)
end