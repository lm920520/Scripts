--[[ MADE BY WOMBOCOMBO
      WILL ONLY DO COMBO IF ENEMEY IS KILLABLE 
		  WILL KS 
			HAS AUTO IGNITE
			AUTO FARMS IF NOT HOLDING SPACE BAR
			SUPPORTS DFG, HXG - AND ADDED CALCULATIONS OF THE NEW ITEMS--]]
local rangeQ = 900 -- Q
local rangeW = 800 -- W
local rangeE = 650 -- E
local range = 700 -- R
local qDelay = 650
local UltStarted = false
local disableFarm = false


local tick = nil
local ts 
local farmKey = 90 -- z

if myHero.charName ~= "Malzahar" then return end

local waittxt = {}
local calculationenemy = 1
local floattext = {"Skills are not available","Able to fight","Killable","Murder him!"}
local killable = {}

local ignite = nil
local DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot, TWSSlot, LiandrysSlot = nil, nil, nil, nil, nil, nil, nil, nil
local QREADY, WREADY, EREADY, RREADY, DFGREADY, HXGREADY, BWCREADY, IREADY, TWSREADY, LIAREADY = false, false, false, false, false, false, false, false, false, false


function OnLoad()

	enemyMinions = minionManager(MINION_ENEMY, 600, player, MINION_SORT_HEALTH_ASC)
	ts = TargetSelector(TARGET_LOW_HP,range,DAMAGE_MAGIC)
	ts.name = "Malzahar"

	Config = scriptConfig("Malzahar WomboCombo 1.0", "Malzaharcombo")
	Config:addParam("farm", "Farm", SCRIPT_PARAM_ONOFF, false)
	Config:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	Config:addParam("teamFight", "TeamFight", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Config:addParam("autoIgnite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("drawtext", "Draw Text", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("drawprediction", "Draw Prediction", SCRIPT_PARAM_ONOFF, false)
	Config:permaShow("farm")
	Config:permaShow("harass")
	Config:permaShow("teamFight")
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
	
	DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot, TWSSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100), GetInventorySlotItem(3023)
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
	BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	TWSREADY = (TWSSlot ~= nil and myHero:CanUseSpell(TWSSlot) == READY)
	LIAREADY = (LiandrysSlot ~= nil and myHero:CanUseSpell(LiandrysSlot) == READY)
	teamFight()
	igniteCheck()
	dmgCalculation()
	farmCheck()
	harass()
	
	if tick == nil or GetTickCount()-tick >= 200 then
		tick = GetTickCount()
	end	
	
end -- End of OnTick function	
function harass()
	if Config.harass then
		disableFarm = true
		if ValidTarget(ts.target) then
			if EREADY and GetDistance(ts.target)<=rangeE then CastSpell(_E, ts.target) end
		end -- End ValidTarget
	end
end


function teamFight()
	if Config.teamFight then
		disableFarm = true
		if ValidTarget(ts.target) then
			QPos = GetPredictionPos(ts.target, qDelay)
			if QPos ~= nil then
				if QREADY and UltStarted == false and GetDistance(ts.target)<=rangeQ then CastSpell(_Q, QPos.x, QPos.z) end
			end
			if EREADY and QREADY == false and UltStarted == false and GetDistance(ts.target)<=rangeE then CastSpell(_E, ts.target)
				if DFGREADY and UltStarted == false then CastSpell(DFGSlot, ts.target) end
				if HXGREADY and UltStarted == false then CastSpell(HXGSlot, ts.target) end
				if BWCREADY and UltStarted == false then CastSpell(BWCSlot, ts.target) end
				if TWSREADY and UltStarted == false then CastSpell(TWSSlot, ts.target) end
			end
			WPos = GetPredictionPos(ts.target, 0)
			if WPos ~= nil then
				if WREADY and EREADY == false and UltStarted == false and GetDistance(ts.target)<=rangeW then CastSpell(_W, WPos.x, WPos.z) end
			end
			if RREADY and WREADY == false and DFGREADY == false and UltStarted == false and GetDistance(ts.target)<=range then CastSpell(_R, ts.target) end		
		end -- End ValidTarget
	end
end
function farmCheck()
	if Config.harass == false and Config.teamFight == false then disableFarm = false end
	if Config.farm and disableFarm == false then
		for index, minion in pairs(enemyMinions.objects) do
			if EREADY and GetDistance(minion, myHero) <= rangeE then
			local edamage = getDmg("E",minion, myHero)
				if edamage>minion.health then
					CastSpell(_E, minion)
				end
			end	
		end
	end
end -- end of farmCheck()	

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
function OnCreateObj(obj)	
		if obj~= nil and obj.name:find("AlZaharNetherGrasp_tar.troy") then
			UltStarted = true
	end	
end
function OnDeleteObj(obj)
	if obj~= nil and obj.name:find("AlZaharNetherGrasp_tar.troy") then
			UltStarted = false
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
				ks = true
			elseif combo3 >= enemy.health then
							killable[i] = 3
							ks = true
			elseif combo2 >= enemy.health then
							killable[i] = 2
							ks = false
							doCombo = true
			elseif combo1 >= enemy.health then
							killable[i] = 1
							doCombo = true
			else
							killable[i] = 0
							doCombo = false
			end 
			
		end
	end -- end of for loop

end -- end of dmgCalculation() function

function OnDraw()
	if Config.drawcircles and not myHero.dead then
		DrawCircle(myHero.x, myHero.y, myHero.z, rangeQ, 0x099B2299)
		DrawCircle(myHero.x, myHero.y, myHero.z, range, 0x099B2299)
	end
	if ValidTarget(ts.target) then
   DrawText("Targetting: " .. ts.target.charName, 18, 100, 100, 0xFFFF0000)
   DrawCircle(ts.target.x, ts.target.y, ts.target.z, 100, 0x099B2299)
  end
	for i=1, heroManager.iCount do
	local enemydraw = heroManager:GetHero(i)
		if ValidTarget(enemydraw) then
			if killable[i] == 1 then
					DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 100, 0xFFFFFF00)
				end
			if killable[i] == 2 then
				
				DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 100, 0xFFFFFF00)
				
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
	
	if key == farmKey then
		if msg == KEY_DOWN then
			if Config.farm then
				Config.farm = false
			else
				Config.farm = true
			end
		end
	end
	
	
end

function OnSendChat(msg)
	
	ts:OnSendChat(msg, "pri")
end
PrintChat(" >> Malzahar WomboCombo 1.0 loaded!")