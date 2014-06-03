if myHero.charName ~= "Brand" then return end

--[[
	Brand: Let'em Burn!
	by Tux
	Made with Simple Minion Marker by Kilua
--]]


local burntime = 0
local ts = TargetSelector(TARGET_LOW_HP,900,DAMAGE_MAGIC,true)
local qDelay = 250
local qSpeed = 1.61
local nextTick = 0
local waitDelay = 625
local qPred
local UseW
local DmgCalcItems =
{
Liandrys = { id = 3151, slot = nil },
Blackfire = { id = 3188, slot = nil }
}
local items = 
{ 
DFG = {id=3128, range = 750, reqTarget = true, slot = nil },
}

function OnLoad()
	BrandConfig = scriptConfig("Let'em Burn!", "BrandCombo")
	BrandConfig:addParam("Active", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	BrandConfig:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	BrandConfig:addParam("Ignite", "Ignite Killable Target", SCRIPT_PARAM_ONOFF, true)
	BrandConfig:addParam("DoubleIgnite", "Don't Double Ignite", SCRIPT_PARAM_ONOFF, true)
	BrandConfig:addParam("KS", "Auto KS", SCRIPT_PARAM_ONOFF, true)
	BrandConfig:addParam("Movement", "Move to Mouse", SCRIPT_PARAM_ONOFF, true)
	BrandConfig:addParam("DrawCircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	BrandConfig:permaShow("Active")
	BrandConfig:permaShow("Harass")
	BrandConfig:permaShow("Ignite")
	BrandConfig:permaShow("KS")
	ts.name = "Brand"
	BrandConfig:addTS(ts)
	PrintChat(">> Brand - Let'em Burn! v1.2.a loaded.")
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ign = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ign = SUMMONER_2
		else ign = nil
	end
end

function CanCast(Spell)
	return (player:CanUseSpell(Spell) == READY)
end

function IReady()
	return (player:CanUseSpell(ign) == READY)
end

function AutoIgnite()
	local iDmg = 0		
	if ign ~= nil and IReady and not myHero.dead then
		for i = 1, heroManager.iCount, 1 do
			local target = heroManager:getHero(i)
			if ValidTarget(target) then
				iDmg = 50 + 20 * myHero.level
				if target ~= nil and target.team ~= myHero.team and not target.dead and target.visible and GetDistance(target) < 600 and target.health < iDmg then
					if BrandConfig.DoubleIgnite and not TargetHaveBuff("SummonerDot", target) then
						CastSpell(ign, target)
						elseif not BrandConfig.DoubleIgnite then
							CastSpell(ign, target)
					end
				end
			end
		end
	end
end 

function AutoKS()
    for i=1, heroManager.iCount do
    target = heroManager:GetHero(i)
	eDmg = getDmg("E", target, player)
	rDmg = getDmg("R", target, player)
		if target ~= nil and not target.dead and target.team ~= player.team and target.visible and GetDistance(target) < 625 then
			if target.health < eDmg + rDmg and CanCast(_E) and CanCast(_R) then
				CastSpell(_E, target)
				CastSpell(_R, target)
			end
		end
		if target ~= nil and not target.dead and target.team ~= player.team and target.visible and GetDistance(target) < 625 then
			if target.health < eDmg and CanCast(_E) then
				CastSpell(_E, target)
			end
		end
		if target ~= nil and not target.dead and target.team ~= player.team and target.visible and GetDistance(target) < 750 then
			if target.health < rDmg and CanCast(_R) then
				CastSpell(_R, target)
			end
		end
	end
end

function getHitBoxRadius(target)
 return GetDistance(target.minBBox, target.maxBBox)/2
end

function UseItems(target)
	if target == nil then return end
		for _,item in pairs(items) do
			item.slot = GetInventorySlotItem(item.id)
			if item.slot ~= nil then
				if item.reqTarget and GetDistance(target) < item.range then
					CastSpell(item.slot, target)
				elseif not item.reqTarget then
					if (GetDistance(target) - getHitBoxRadius(myHero) - getHitBoxRadius(target)) < 50 then
						CastSpell(item.slot)
					end
				end
			end
	end
end

function OnCreateObj(object)
	if object ~= nil and string.find(object.name, "BrandFireMark") then
		for i=1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if enemy.team ~= myHero.team and GetDistance(object,enemy) < 80 then
				burntime = GetTickCount()
				burned = true
			end
		end
	end
end

function OnDeleteobject(object) 
	if object ~= nil and string.find(object.name, "BrandFireMark") then
		for i=1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if enemy.team ~= myHero.team and GetDistance(object,enemy) < 80 then
				burntime = GetTickCount()
				burned = false
			end
		end
	end
end

function OnTick()
	ts:update()
	if ts.target ~= nil then
		travelDuration = (qDelay + GetDistance(myHero, ts.target)/qSpeed)
		UseW = GetPredictionPos(ts.target, 750, enemyTeam)
		qPred = ts.nextPosition
	end
	ts:SetPrediction(travelDuration)
	if BrandConfig.Ignite and AutoIgnite() then end
	if BrandConfig.KS and AutoKS() then end
	if BrandConfig.Active then
		if CountEnemyHeroInRange(600) >= 3 then
			if ValidTarget(ts.target, 750) and CanCast(_W) then
				UseItems(ts.target)
				CastSpell(_W, UseW.x, UseW.z)
			end
				if ValidTarget(ts.target, 625) and CanCast(_E) then
					CastSpell(_E, ts.target)
				end
					if ValidTarget(ts.target, 750) and CanCast(_R) then
						CastSpell(_R, ts.target)
					end
						if ValidTarget(ts.target, 900) and CanCast(_Q) and qPred ~= nil then
							HeroPos = Vector(myHero.x,0,myHero.z)
							EnemyPos = Vector(ts.nextPosition.x,0, ts.nextPosition.z)                      
							LeadingPos = EnemyPos + ( EnemyPos - HeroPos ):normalized()*(-0.05)
							CastSpell(_Q, LeadingPos.x, LeadingPos.z)
						end
		else
			if ValidTarget(ts.target, 625) and CanCast(_E) then
				UseItems(ts.target)
				CastSpell(_E, ts.target)
			end
				if ValidTarget(ts.target, 900) and CanCast(_Q) and qPred ~= nil then
					HeroPos = Vector(myHero.x,0,myHero.z)
					EnemyPos = Vector(ts.nextPosition.x,0, ts.nextPosition.z)                      
					LeadingPos = EnemyPos + ( EnemyPos - HeroPos ):normalized()*(-0.05)
					CastSpell(_Q, LeadingPos.x, LeadingPos.z)
				end
					if ValidTarget(ts.target, 750) and CanCast(_W) then
						CastSpell(_W, UseW.x, UseW.z)
					end
						if ValidTarget(ts.target, 750) and CanCast(_R) then
							CastSpell(_R, ts.target)
						end
		end
	end
	if BrandConfig.Harass then
		if ValidTarget(ts.target, 625) and CanCast(_E) then
			CastSpell(_E, ts.target)
		end
			if ValidTarget(ts.target, 900) and CanCast(_Q) and qPred ~= nil then
				if GetTickCount() - burntime < 3600 and burned then
					HeroPos = Vector(myHero.x,0,myHero.z)
					EnemyPos = Vector(ts.nextPosition.x,0, ts.nextPosition.z)                      
					LeadingPos = EnemyPos + ( EnemyPos - HeroPos ):normalized()*(-0.05)
					CastSpell(_Q, LeadingPos.x, LeadingPos.z)
				end
			end
					if ValidTarget(ts.target, 750) and CanCast(_W) and not ts.target.canMove then
						CastSpell(_W, ts.target.x, ts.target.z)
					end
	end
	if BrandConfig.Movement and (BrandConfig.Active or BrandConfig.Harass) and ts.target == nil then myHero:MoveTo(mousePos.x, mousePos.z) 
	end
end

function BrandDamageCalc(enemy)
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
		if ValidTarget(enemy) then
			local dfgDmg, ignDmg = 0, 0
			local qDmg = getDmg("Q", enemy, myHero)
			local wDmg = getDmg("W", enemy, myHero)
			local eDmg = getDmg("E", enemy, myHero)
			local rDmg = getDmg("R", enemy, myHero)
			local hitDmg = getDmg("AD",enemy,myHero)
			local dfgDmg = (items.DFG.slot and getDmg("DFG",enemy,myHero) or 0)
			local ignDmg = (ign and getDmg("IGNITE",enemy,myHero) or 0)
			local onspellDmg = (DmgCalcItems.Liandrys.slot and getDmg("LIANDRYS",enemy,myHero) or 0)+(DmgCalcItems.Blackfire.slot and getDmg("BLACKFIRE",enemy,myHero) or 0)
			local myDamage = 0
			local maxDamage = qDmg + wDmg + eDmg + rDmg + onspellDmg + dfgDmg + ignDmg
			if CanCast(_Q) then myDamage = myDamage + qDmg end
			if CanCast(_W) then myDamage = myDamage + wDmg end
			if CanCast(_E) then myDamage = myDamage + eDmg end
			if CanCast(_R) then myDamage = myDamage + rDmg end
			if items.DFG.slot ~= nil then myDamage = myDamage + dfgDmg end
			if IReady() and BrandConfig.Ignite then myDamage = myDamage + ignDmg end
				myDamage = myDamage + onspellDmg
				myDamage = myDamage + hitDmg
			if ts.target.health <= myDamage then
				PrintFloatText(ts.target, 0, "Murder")
			elseif ts.target.health <= maxDamage then
				PrintFloatText(ts.target, 0, "Wait for cooldowns")
			else
				PrintFloatText(ts.target, 0, "You are not strong enough")
			end
		end
	end
end

function OnDraw()
	if BrandConfig.DrawCircles then
		DrawCircle(myHero.x,myHero.y,myHero.z,1050,0xFFFF0000)
		DrawCircle(myHero.x,myHero.y,myHero.z,625,0xFFFF0000)
	end
	if ts.target ~= nil then
		BrandDamageCalc(ts.target)
        for j=0, 15 do
            DrawCircle(ts.target.x, ts.target.y, ts.target.z, 40 + j*1.5, 0x00FF00)
		end
	end
end