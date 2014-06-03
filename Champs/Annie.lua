--[[
	-Full combo: Items -> Q -> W -> E -> R
	-Supports Deathfire Grasp, Bilgewater Cutlass, Hextech Gunblade, Sheen, Trinity, Lich Bane, Ignite, Iceborn, Liandrys and Blackfire
	-Target configuration, Press shift to configure
	
	By burn, based on Trus sbtw annie script
]]
if myHero.charName ~= "Annie" then return end
local LIB_PATH = debug.getinfo(1).source:sub(debug.getinfo(1).source:find(".*\\")):sub(2).."Common/"
local AllClassFile = LIB_PATH.."AllClass.lua"
local spellDmgFile = LIB_PATH.."spellDmg.lua"
if file_exists(AllClassFile) then require "AllClass" end
if file_exists(spellDmgFile) then require "spellDmg" end
mecMethod = 2 --> 2 will hit our target and maybe other people, 1 will hit a  lot of people and maybe also our target (not guarantee this last)
scriptActive = false
stunReadyFlag = false
existTibbers = false
ultiRange = 600         
ultiRadius = 230  
range = 620
killable = {}
local calculationenemy = 1
local waittxt = {}
local ts
local ignite = nil
local player = GetMyHero()
function OnLoad()
	PrintChat(">> Annie Combo v1.0 loaded!")
    if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2
    else ignite = nil
    end
	AnnieConfig = scriptConfig("Annie Combo", "anniecombo")
	AnnieConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	AnnieConfig:addParam("harass", "Harass Enemy", SCRIPT_PARAM_ONKEYDOWN, false, 65) --a
	AnnieConfig:addParam("autofarmQ", "Auto farm Q", SCRIPT_PARAM_ONKEYTOGGLE, false, 67)
	AnnieConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	AnnieConfig:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
	AnnieConfig:permaShow("harass")
	AnnieConfig:permaShow("autofarmQ")
	ts = TargetSelector(TARGET_LOW_HP,range+30,DAMAGE_MAGIC,false)
	ts.name = "Annie"
	AnnieConfig:addTS(ts)
end

function OnTick()
	ts:update()
	--if existTibbers then
        --PrintChat("Tibers ALIVE!")
    --end   
	--if existTibbers == false then
        --PrintChat("NO tibers!")
    --end   
	DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
	IcebornSlot, LiandrysSlot, BlackfireSlot = GetInventorySlotItem(3025), GetInventorySlotItem(3151), GetInventorySlotItem(3188)	
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
	BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	DmgCalculation()
	if AnnieConfig.autofarmQ and QREADY then
		local myQ = math.floor((myHero:GetSpellData(_Q).level-1)*40 + 85 + myHero.ap * .7)
		for k = 1, objManager.maxObjects do
		local minionObjectI = objManager:GetObject(k)
			if minionObjectI ~= nil and string.find(minionObjectI.name,"Minion_") == 1 and minionObjectI.team ~= myHero.team and minionObjectI.dead == false then
				if myHero:GetDistance(minionObjectI) <= range and minionObjectI.health <= myHero:CalcMagicDamage(minionObjectI, myQ)then	
					CastSpell(_Q, minionObjectI)
				end
			end
		end		
	end
	if AnnieConfig.harass and ts.target then
		if QREADY and GetDistance(ts.target) <= range then CastSpell(_Q, ts.target) end
		if WREADY and GetDistance(ts.target) < range then CastSpell(_W, ts.target.x, ts.target.z) end
	end
	if AnnieConfig.scriptActive and ts.target then
		if DFGREADY then CastSpell(DFGSlot, ts.target) end
		if HXGREADY then CastSpell(HXGSlot, ts.target) end
		if BWCREADY then CastSpell(BWCSlot, ts.target) end
		if stunReadyFlag then
			if player:CanUseSpell(_R) == READY and myHero:GetDistance(ts.target) < 650 then
                if mecMethod == 1 then
                    spellPos = FindGroupCenterFromNearestEnemies(ultiRadius,ultiRange)
                elseif mecMethod == 2 then
                    spellPos = FindGroupCenterNearTarget(ts.target,ultiRadius,ultiRange)
                end
                if spellPos ~= nil then
                    CastSpell(_R, spellPos.center.x, spellPos.center.z)
                else
                    CastSpell(_R, ts.target.x, ts.target.z)
                end
            end
		end    
		if QREADY and GetDistance(ts.target) <= range then CastSpell(_Q, ts.target) end  
		if stunReadyFlag then
			if player:CanUseSpell(_R) == READY and myHero:GetDistance(ts.target) < 650 then
                if mecMethod == 1 then
                    spellPos = FindGroupCenterFromNearestEnemies(ultiRadius,ultiRange)
                elseif mecMethod == 2 then
                    spellPos = FindGroupCenterNearTarget(ts.target,ultiRadius,ultiRange)
                end
                if spellPos ~= nil then
                    CastSpell(_R, spellPos.center.x, spellPos.center.z)
                else
                    CastSpell(_R, ts.target.x, ts.target.z)
                end
            end
		end  
		if WREADY and GetDistance(ts.target) < range then CastSpell(_W, ts.target.x, ts.target.z) end
		if EREADY and AnnieConfig.useE and not stunReadyFlag then CastSpell(_E) end	
		if player:CanUseSpell(_R) == READY and myHero:GetDistance(ts.target) < 650 then
                if mecMethod == 1 then
                    spellPos = FindGroupCenterFromNearestEnemies(ultiRadius,ultiRange)
                elseif mecMethod == 2 then
                    spellPos = FindGroupCenterNearTarget(ts.target,ultiRadius,ultiRange)
                end
                if spellPos ~= nil then
                    CastSpell(_R, spellPos.center.x, spellPos.center.z)
                else
                    CastSpell(_R, ts.target.x, ts.target.z)
					end
         end
		 
		if myHero:GetDistance(ts.target) < 650 and existTibbers then
		CastSpell(_R,ts.target)
		end
		 
	end
end

function OnCreateObj(object)
	if object.name == "StunReady.troy" then stunReadyFlag = true end
	if object.name == "BearFire_foot.troy" then existTibbers = true end
end

function OnDeleteObj(object)
	if object.name == "StunReady.troy" then stunReadyFlag = false end
	if object.name == "BearFire_foot.troy" then existTibbers = false end	
end

function OnWndMsg(msg,key)
	SC__OnWndMsg(msg,key)
end

function OnSendChat(msg)
	TargetSelector__OnSendChat(msg)
	ts:OnSendChat(msg, "pri")
end

function DmgCalculation()
		local enemy = heroManager:GetHero(calculationenemy)
		if ValidTarget(enemy) then
			local dfgdamage, hxgdamage, bwcdamage, ignitedamage, Sheendamage, Trinitydamage, LichBanedamage  = 0, 0, 0, 0, 0, 0, 0
			local qdamage = getDmg("Q",enemy,myHero)
			local wdamage = getDmg("W",enemy,myHero)
			local rdamage = getDmg("R",enemy,myHero)
			local dfgdamage = (DFGSlot and getDmg("DFG",enemy,myHero) or 0)
			local hxgdamage = (HXGSlot and getDmg("HXG",enemy,myHero) or 0)
			local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)
			local ignitedamage = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
			local onhitdmg = (SheenSlot and getDmg("SHEEN",enemy,myHero) or 0)+(TrinitySlot and getDmg("TRINITY",enemy,myHero) or 0)+(LichBaneSlot and getDmg("LICHBANE",enemy,myHero) or 0)+(IcebornSlot and getDmg("ICEBORN",enemy,myHero) or 0)							
			local onspelldamage = (LiandrysSlot and getDmg("LIANDRYS",enemy,myHero) or 0)+(BlackfireSlot and getDmg("BLACKFIRE",enemy,myHero) or 0)
			local combo1 = onspelldamage
			local combo2 = onhitdmg + qdamage + wdamage + rdamage + dfgdamage + hxgdamage + bwcdamage + ignitedamage + onspelldamage
			if QREADY then
				combo1 = combo1 + qdamage
			end
			if WREADY then
				combo1 = combo1 + wdamage
			end
			if (RREADY and not existTibbers) then
				combo1 = combo1 + rdamage
			end		
			if HXGREADY then               
				combo1 = combo1 + hxgdamage    
			end
			if BWCREADY then
				combo1 = combo1 + bwcdamage
			end
			if DFGREADY then        
				combo1 = combo1*1.2 + dfgdamage            
			end			
			if IREADY then
				combo1 = combo1 + ignitedamage 
			end
			combo1 = combo1 + onhitdmg
			if combo1 >= enemy.health then killable[calculationenemy] = 1
			elseif combo2 >= enemy.health then killable[calculationenemy] = 2
			else killable[calculationenemy] = 0 end
		end	
		if calculationenemy == 1 then
			calculationenemy = heroManager.iCount
		else 
			calculationenemy = calculationenemy-1
		end
end

function OnDraw()
	if AnnieConfig.drawcircles and not myHero.dead then
		DrawCircle(myHero.x, myHero.y, myHero.z, range, 0x19A712)
		if ts.target ~= nil then
			for j=0, 5 do
				DrawCircle(ts.target.x, ts.target.y, ts.target.z, 40 + j*1.5, 0x00FF00)
			end
		end
		for i=1, heroManager.iCount do
			local enemydraw = heroManager:GetHero(i)
			if ValidTarget(enemydraw) then
				if killable[i] == 2 then
					for j=0, 20 do
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0x0000FF)
					end
					PrintFloatText(enemydraw,0,"Skills are not available")
				elseif killable[i] == 1 then
					for j=0, 10 do
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + j*1.5, 0xFF0000)
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 140 + j*1.5, 0xFF0000)
					end
					PrintFloatText(enemydraw,0,"Kill him!")
				end
			end
		end
	end
	SC__OnDraw()
end