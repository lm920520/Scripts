--[[ MADE BY WOMBOCOMBO
      WILL ONLY DO COMBO IF ENEMEY IS KILLABLE 
		  WILL KS 
			HAS AUTO IGNITE
			AUTO FARMS IF NOT HOLDING SPACE BAR
			SUPPORTS DFG, HXG - AND ADDED CALCULATIONS OF THE NEW ITEMS--]]

local rangeQ = 250 -- Q
local rangeW = 750 -- W
local rangeE = 700 -- E
local rangeR = 650 -- R

local wDelay = 50

local ulted = false
local defensive = false
local tick = nil

local ts 
local disableFarm = false

if myHero.charName ~= "Talon" then return end

local waittxt = {}
local calculationenemy = 1
local floattext = {"Skills are not available","Combo Killer","Killable","Murder him!"}
local killable = {}





local ignite = nil
local DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot, TMTSlot, RAHSlot, RNDSlot, STDSlot = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local QREADY, WREADY, EREADY, RREADY, DFGREADY, HXGREADY, BWCREADY, IREADY, TMTREADY, RAHREADY, RNDREADY, STDREADY, BRKREADY = false, false, false, false, false, false, false, false, false, false, false, false, false


function OnLoad()
	enemyMinions = minionManager(MINION_ENEMY, 600, player, MINION_SORT_HEALTH_ASC)

	ts = TargetSelector(TARGET_LOW_HP,1300,DAMAGE_MAGIC)
	ts.name = "Talon"

	Config = scriptConfig("Talon WomboCombo 1.2", "Taloncombo")
	Config:addParam("farm", "Farm", SCRIPT_PARAM_ONKEYTOGGLE, false, 90)
	Config:addParam("teamFight", "TeamFight", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Config:addParam("ks", "KS", SCRIPT_PARAM_ONKEYTOGGLE, true, 75)
	Config:addParam("autoIgnite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("stunText", "Stun Counter", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("drawtext", "Draw Text", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("drawprediction", "Draw Prediction", SCRIPT_PARAM_ONOFF, false)
	Config:permaShow("farm")
	Config:permaShow("teamFight")
	Config:permaShow("ks")
	Config:addTS(ts)
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2
	else ignite = nil
  end
	for i=1, heroManager.iCount do waittxt[i] = i*3 end
end
	
function OnTick()
	ts:update()
	enemyMinions:update()
	DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot, BRKSlot, TMTSlot, RAHSlot, RNDSlot, STDSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100), GetInventorySlotItem(3153), GetInventorySlotItem(3077), GetInventorySlotItem(3074), GetInventorySlotItem(3143), GetInventorySlotItem(3131)
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
	BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
	BRKREADY = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
	TMTREADY = (TMTSlot ~= nil and myHero:CanUseSpell(TMTSlot) == READY)
	RAHREADY = (RAHSlot ~= nil and myHero:CanUseSpell(RAHSlot) == READY)
	RNDREADY = (RNDSlot ~= nil and myHero:CanUseSpell(RNDSlot) == READY)
	STDREADY = (STDSlot ~= nil and myHero:CanUseSpell(STDSlot) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	dmgCalculation()
	target()
	teamFight()
	igniteCheck()
	skillState()
	farmCheck()
	if tick == nil or GetTickCount()-tick >= 200 then
		tick = GetTickCount()
	end	
	
end -- End of OnTick function	
function skillState() 
	
	
	local rData = myHero:GetSpellData(_R)
	if rData.name == "talonshadowassaulttoggle" then ulted = true end
	if rData.name == "TalonShadowAssault" then ulted = false end
	
end
function target()
	local enemies = CountEnemyHeroInRange(1300)
	if ts.target and enemies >1 then
		for i = 1, heroManager.iCount, 1 do
    local enemy = heroManager:getHero(i)
			if enemy.maxHealth<ts.target.maxHealth then
				enemy = ts.target
			end
		end
		defensive = true
	end
	if ts.target and enemies ==1 then
		defensive = false
	end
end

function farmCheck()
	if Config.teamFight == false then disableFarm = false end
	if Config.farm and disableFarm == false then
			for index, minion in pairs(enemyMinions.objects) do
				if WREADY and GetDistance(minion, myHero) <= rangeW then
				local wdamage = getDmg("W",minion, myHero)
					if wdamage>minion.health then
						CastSpell(_W, minion)
					end
				end	
			end
	end
end

function teamFight()
	if Config.teamFight then
		disableFarm = true
		if DFGREADY then CastSpell(DFGSlot, ts.target) end
		if HXGREADY then CastSpell(HXGSlot, ts.target) end
		if BWCREADY then CastSpell(BWCSlot, ts.target) end
		if BRKREADY then CastSpell(BRKSlot, ts.target) end
		if TMTREADY and GetDistance(ts.target) < 275 then CastSpell(TMTSlot) end
		if RAHREADY and GetDistance(ts.target) < 275 then CastSpell(RAHSlot) end
		if RNDREADY and GetDistance(ts.target) < 275 then CastSpell(RNDSlot) end
		if ValidTarget(ts.target, rangeE) then
			CastSpell(_E, ts.target)
		end
		if ValidTarget(ts.target, rangeQ) then
			if WREADY then myHero:Attack(ts.target) end
		end
		if ValidTarget(ts.target, rangeW) then
			WPos = GetPredictionPos(ts.target, wDelay)
			if WPos ~= nil then
				CastSpell(_W, WPos.x, WPos.z)
			end
		end
		if ValidTarget(ts.target, rangeQ) then
			if QREADY then myHero:Attack(ts.target) end
		end
		if ValidTarget(ts.target, rangeQ) then
			CastSpell(_Q)
		end
		if ValidTarget(ts.target, rangeQ) then
			if RREADY then myHero:Attack(ts.target) end
		end
		if defensive == true then
			if ValidTarget(ts.target, rangeR) then
				if RREADY and ulted == false then CastSpell(_R) PrintChat("once")end
			end
		end
		if defensive == false then
			if ValidTarget(ts.target, rangeR) then
				if RREADY then CastSpell(_R) end
			end
		end
	end
end-- End of function teamFight()
		

function igniteCheck()
	if Config.autoIgnite == true then
		local ignitedmg = 0            
		if IREADY then
			for i = 1, heroManager.iCount, 1 do
			local enemyhero = heroManager:getHero(i)
				if ValidTarget(enemyhero) then
					ignitedmg = 50 + 20 * myHero.level
					if enemyhero ~= nil and enemyhero.team ~= myHero.team and not enemyhero.dead and enemyhero.visible and GetDistance(enemyhero) < 600 and enemyhero.health <= ignitedmg then
						CastSpell(ignite, enemyhero)
					end
				end
			end
		end               
	end         
end






function dmgCalculation()
	for i=1, heroManager.iCount do
	local enemy = heroManager:GetHero(i)
		if ValidTarget(enemy) then
			local dfgdamage, hxgdamage, bwcdamage, ignitedamage, Sheendamage, Trinitydamage, LichBanedamage  = 0, 0, 0, 0, 0, 0, 0
			local pdamage = getDmg("P",enemy,myHero)
			local qdamage = getDmg("Q",enemy,myHero)
			local edamage = getDmg("E",enemy,myHero)
			local rdamage = getDmg("R",enemy,myHero)
			local wdamage = getDmg("W",enemy,myHero)
			local hitdamage = getDmg("AD",enemy,myHero)
			local dfgdamage = (DFGSlot and getDmg("DFG",enemy,myHero) or 0)
			local hxgdamage = (HXGSlot and getDmg("HXG",enemy,myHero) or 0)
			local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)
			local ignitedamage = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
			local onhitdmg = (SheenSlot and getDmg("SHEEN",enemy,myHero) or 0)+(TrinitySlot and getDmg("TRINITY",enemy,myHero) or 0)+(LichBaneSlot and getDmg("LICHBANE",enemy,myHero) or 0)+(IcebornSlot and getDmg("ICEBORN",enemy,myHero) or 0)                                          local onspelldamage = (LiandrysSlot and getDmg("LIANDRYS",enemy,myHero) or 0)+(BlackfireSlot and getDmg("BLACKFIRE",enemy,myHero) or 0)
			local combo1 = onspelldamage + pdamage + onhitdmg + hitdamage --0 cd
			local combo2 = onspelldamage + pdamage + onhitdmg + hitdamage
			local combo3 = 0
			local combo4 = 0
			if QREADY then
				combo1 = combo1 + qdamage
				combo2 = combo2 + qdamage
				combo3 = combo3 + qdamage
				combo4 = combo4 + qdamage
			end
			if EREADY then
				combo1 = combo1 + edamage
				combo2 = combo2 + edamage
				combo3 = combo3 + edamage
				combo4 = combo4 + edamage
			end
			if WREADY then
				combo1 = combo1 + wdamage
				combo2 = combo2 + wdamage
				combo3 = combo3 + wdamage
				combo4 = combo4 + wdamage
			end
			if RREADY then
				combo1 = combo1 + rdamage
				combo2 = combo2 + rdamage
				combo3 = combo3 + rdamage
				combo4 = combo4 + rdamage
			end
			if HXGREADY then              
				combo1 = combo1 + hxgdamage    
				combo2 = combo2 + hxgdamage
				combo3 = combo3 + hxgdamage
				combo4 = combo4 + hxgdamage
			end
			if BWCREADY then
				combo1 = combo1 + bwcdamage
				combo2 = combo2 + bwcdamage
				combo3 = combo3 + bwcdamage
				combo4 = combo4 + bwcdamage
			end
			if DFGREADY then        
				combo1 = combo1 + dfgdamage            
				combo2 = combo2 + dfgdamage
				combo3 = combo3 + dfgdamage
				combo4 = combo4 + dfgdamage
			end                                                
			if IREADY then
				combo1 = combo1 + ignitedamage
				combo2 = combo2 + ignitedamage
				combo3 = combo3 + ignitedamage
				combo4 = combo4 + ignitedamage
			end 
			
			if combo4 >= enemy.health then
							killable[i] = 4	
			elseif combo3 >= enemy.health then
							killable[i] = 3						
			elseif combo2 >= enemy.health then
							killable[i] = 2	
			elseif combo1 >= enemy.health then
							killable[i] = 1	
			else
							killable[i] = 0
			end 
			
		end
	end -- end of for loop

end -- end of dmgCalculation() function

function OnDraw()
	if Config.drawcircles and not myHero.dead then
		DrawCircle(myHero.x, myHero.y, myHero.z, rangeE, 0x099B2299)
	end
	if ValidTarget(ts.target) then
   DrawText("Targetting: " .. ts.target.charName, 18, 650, 25, 0xFFFF0000)
   DrawCircle(ts.target.x, ts.target.y, ts.target.z, 100, 0x099B2299)
  end
	for i=1, heroManager.iCount do
	local enemydraw = heroManager:GetHero(i)
		if ValidTarget(enemydraw) then
			if killable[i] == 1 then
					DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 100, 0xFFFFFF00)
				end
			if killable[i] == 2 then
				
				DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 100, 0x099B2299)
				
			end
			if killable[i] ==3  then
				for j=0, 10 do
					DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 100+j*0.8, 0x099B2299)
				end
			end
			if killable[i] ==4  then
				for j=0, 10 do
					DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 100+j*0.8, 0x099B2299)
					
				end
			end
			if waittxt[i] == 1 and killable[i] ~= 0 then
				PrintFloatText(enemydraw,0,floattext[killable[i]])
			end
		end
		if waittxt[i] == 1 then waittxt[i] = 30
		else waittxt[i] = waittxt[i]-1 end
	end
	
	
	
end
	
function OnWndMsg(msg,key)
	
	
end

function OnSendChat(msg)
	
	ts:OnSendChat(msg, "pri")
end
PrintChat(" >> Talon WomboCombo 1.2 loaded!")