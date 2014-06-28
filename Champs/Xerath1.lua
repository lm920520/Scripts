--[[ MADE BY WOMBOCOMBO
      WILL ONLY DO COMBO IF ENEMEY IS KILLABLE 
		  WILL KS 
			HAS AUTO IGNITE
			AUTO FARMS IF NOT HOLDING SPACE BAR
			SUPPORTS DFG, HXG - AND ADDED CALCULATIONS OF THE NEW ITEMS--]]
local rangeQ = 1050 -- Q 1750 when W is down
local rangeW = 1750 -- W
local rangeE = 650 -- E 950 when W is down
local rangeR = 900 -- R 1600 when W is down
local wDown = false
local eParticle = false
local qDelay = 600
local rDelay = 250
local rHit = false
local tick = nil
local rCount = 0
local danger = false
local ts 
local ks = false

if myHero.charName ~= "Xerath" then return end

local waittxt = {}
local calculationenemy = 1
local floattext = {"Skills are not available","Able to fight","Killable","Murder him!"}
local killable = {}





local ignite = nil
local DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = nil, nil, nil, nil, nil, nil
local QREADY, WREADY, EREADY, RREADY, DFGREADY, HXGREADY, BWCREADY, IREADY = false, false, false, false, false, false, false, false


function OnLoad()

	rCount = 0
	
	ts = TargetSelector(TARGET_LOW_HP,rangeW,DAMAGE_MAGIC)
	ts.name = "Xerath"

	Config = scriptConfig("Xerath WomboCombo 1.0", "Xerathcombo")
	Config:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	Config:addParam("teamFight", "TeamFight", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Config:addParam("autoIgnite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("drawtext", "Draw Text", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("drawprediction", "Draw Prediction", SCRIPT_PARAM_ONOFF, false)
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
	DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
	BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	--KS()
	harass()
	teamFight()
	igniteCheck()
	dmgCalculation()
	--farmCheck()
	if wDown == true then 
		
		rangeQ = 1750 
		rangeE = 950
		rangeR = 1600
	else 
		rangeQ = 1050 
		rangeE = 650
		rangeR = 1100
	end
	
	if tick == nil or GetTickCount()-tick >= 200 then
		tick = GetTickCount()
	end	
	
end -- End of OnTick function	

--[[function KS()
	if ValidTarget(ts.target, 800) and ks == true then
		danger = true
		if wDown == true then
			CastSpell(_W)
		end
		Config.harass = false
		Config.teamFight = false
		QPos = GetPredictionPos(ts.target, qDelay)
		if DFGREADY then CastSpell(DFGSlot, ts.target) end
		if HXGREADY then CastSpell(HXGSlot, ts.target) end
		if BWCREADY then CastSpell(BWCSlot, ts.target) end
		if EREADY and GetDistance(ts.target)<=rangeE then CastSpell(_E, ts.target) end
		if QPos ~= nil then
			if QREADY and EREADY == false and GetDistance(ts.target)<=rangeQ then CastSpell(_Q, QPos.x, QPos.z) end
		end
		if rCount == 0 and QREADY == false and EREADY == false and RREADY == false then
			if wDown == true then
				CastSpell(_W)
			end
		end
	end
	if ValidTarget(ts.target, 950) and ks == true and danger == false then
		Config.harass = false
		Config.teamFight = false
		QPos = GetPredictionPos(ts.target, qDelay)
		if DFGREADY then CastSpell(DFGSlot, ts.target) end
		if HXGREADY then CastSpell(HXGSlot, ts.target) end
		if BWCREADY then CastSpell(BWCSlot, ts.target) end
		if WREADY and QREADY and wDown == false and GetDistance(ts.target)<=rangeW then CastSpell(_W, ts.target) end
		if EREADY and GetDistance(ts.target)<=rangeE then CastSpell(_E, ts.target) end
		if QPos ~= nil then
			if QREADY and EREADY == false and GetDistance(ts.target)<=rangeQ then CastSpell(_Q, QPos.x, QPos.z) end
		end
		if rCount == 0 and QREADY == false and EREADY == false and RREADY == false then
			if wDown == true then
				CastSpell(_W)
			end
		end
	end
	if ValidTarget(ts.target) and ks == true and danger == false then
		Config.harass = false
		Config.teamFight = false
		QPos = GetPredictionPos(ts.target, qDelay)
		if WREADY and QREADY and wDown == false and GetDistance(ts.target)<=rangeW then CastSpell(_W, ts.target) end
		if QPos ~= nil then
			if QREADY and GetDistance(ts.target)<=rangeQ then CastSpell(_Q, QPos.x, QPos.z) end
		end
		if rCount == 0 and QREADY == false and EREADY == false and RREADY == false then
			if wDown == true then
				CastSpell(_W)
			end
		end
	end
	if not ValidTarget(ts.target)  then
			if wDown == true then
				CastSpell(_W)
			end
	end
end]]

function harass()
	if Config.harass then
		rangeW = 1750
		if ValidTarget(ts.target, 1050) then
			danger = true
				if wDown == true then
					CastSpell(_W)
				end
				QPos = GetPredictionPos(ts.target, qDelay)
				if QPos ~= nil then
					if QREADY and GetDistance(ts.target)<=rangeQ then CastSpell(_Q, QPos.x, QPos.z) end
			end
		else
			danger = false
		end
		if ValidTarget(ts.target) and danger == false then
			QPos = GetPredictionPos(ts.target, qDelay)
			if WREADY and QREADY and wDown == false and GetDistance(ts.target)<=rangeW then CastSpell(_W, ts.target) end
			if QPos ~= nil then
				if QREADY and GetDistance(ts.target)<=rangeQ then CastSpell(_Q, QPos.x, QPos.z) end
				if QREADY == false then
					if wDown == true then
						CastSpell(_W)
					end
				end
			end
		end
		if not ValidTarget(ts.target)  then
			if wDown == true then
				CastSpell(_W)
			end
		end
	end
end

function teamFight()
	if Config.teamFight then
	if EREADY then rangeW = 950 elseif EREADY == false then rangeW = 1750 end
		if ValidTarget(ts.target, 800) then
			danger = true
				if wDown == true then
					CastSpell(_W)
				end
			QPos = GetPredictionPos(ts.target, qDelay)	
			RPos = GetPredictionPos(ts.target, rDelay)
			if DFGREADY then CastSpell(DFGSlot, ts.target) end
			if HXGREADY then CastSpell(HXGSlot, ts.target) end
			if BWCREADY then CastSpell(BWCSlot, ts.target) end
			if EREADY and GetDistance(ts.target)<=rangeE then CastSpell(_E, ts.target) end
			if QPos ~= nil then
				if QREADY and rHit == true and GetDistance(ts.target)<=rangeQ then CastSpell(_Q, QPos.x, QPos.z) rHit = false end				
			end
			if RPos ~= nil then
				if RREADY and eParticle == true and rHit == false and GetDistance(ts.target)<=rangeR then CastSpell(_R, RPos.x, RPos.z) rHit = true end
				if RREADY and EREADY == false and GetDistance(ts.target)<=rangeR then CastSpell(_R, RPos.x, RPos.z) end
			end
			if QPos ~= nil then
				if QREADY and RREADY == false and EREADY == false and GetDistance(ts.target)<=rangeQ then CastSpell(_Q, QPos.x, QPos.z) end
			end
		else
			danger = false
		end
		if ValidTarget(ts.target, 950) and danger == false then
			QPos = GetPredictionPos(ts.target, qDelay)	
			RPos = GetPredictionPos(ts.target, rDelay)
			if DFGREADY then CastSpell(DFGSlot, ts.target) end
			if HXGREADY then CastSpell(HXGSlot, ts.target) end
			if BWCREADY then CastSpell(BWCSlot, ts.target) end
			if WREADY and QREADY and wDown == false and GetDistance(ts.target)<=rangeW then CastSpell(_W, ts.target) end
			if wDown == false then rCount = 0 end
			if EREADY and GetDistance(ts.target)<=rangeE then CastSpell(_E, ts.target) end
			if QPos ~= nil then
				if QREADY and rHit == true and GetDistance(ts.target)<=rangeQ then CastSpell(_Q, QPos.x, QPos.z) rHit = false end				
			end
			if RPos ~= nil then
				if RREADY and eParticle == true and rHit == false and GetDistance(ts.target)<=rangeR then CastSpell(_R, RPos.x, RPos.z) rHit = true end
				if RREADY and EREADY == false and GetDistance(ts.target)<=rangeR then CastSpell(_R, RPos.x, RPos.z) end
			end
			if QPos ~= nil then
				if QREADY and RREADY == false and EREADY == false and GetDistance(ts.target)<=rangeQ then CastSpell(_Q, QPos.x, QPos.z) end
			end
			if rCount == 3 then
				if wDown == true then
					CastSpell(_W)
				end
			end
			if rCount == 0 and QREADY == false and EREADY == false and RREADY == false then
				if wDown == true then
					CastSpell(_W)
				end
			end
		end -- End ValidTarget(ts.target)
		if ValidTarget(ts.target) and danger == false then
			rangeW = 1750
			QPos = GetPredictionPos(ts.target, qDelay)
			if WREADY and QREADY and wDown == false and GetDistance(ts.target)<=rangeW then CastSpell(_W, ts.target) end
			if QPos ~= nil then
				if QREADY and GetDistance(ts.target)<=rangeQ then CastSpell(_Q, QPos.x, QPos.z) end
				if QREADY == false then
					if wDown == true then
						CastSpell(_W)
					end
				end
			end
		end -- End ValidTarget(ts.target)
		if not ValidTarget(ts.target)  then
			if wDown == true then
				CastSpell(_W)
			end
		end
	end
end
		

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
	if obj.name:find("Xerath_LocusOfPower_beam.troy") then
		if GetDistance(obj, myHero)<=70 then
			wDown = true
		end
	end
	if obj.name:find("Xerath_Bolt_hit_tar.troy") then
		eParticle = true
		
	end
	if obj.name:find("Xerath_Barrage_tar.troy") then
		
		rCount = rCount + 1
	end
end

function OnDeleteObj(obj)
	if obj.name:find("Xerath_LocusOfPower_beam.troy") then
		wDown = false
	end
	if obj.name:find("Xerath_Bolt_hit_tar.troy") then
		eParticle = false
		
	end
	if obj.name:find("Xerath_Barrage_tar.troy") then
		
		
	end
	
end	-- end of OnDeleteObj(obj)




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
				combo1 = combo1 + rdamage*3
				combo2 = combo2 + rdamage*3
				combo3 = combo3 + rdamage*3
				combo4 = combo4 + rdamage*3
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
							ks = false
			elseif combo2 >= enemy.health then
							killable[i] = 2
							ks = false
			elseif combo1 >= enemy.health then
							killable[i] = 1	
							ks = false
			else
							killable[i] = 0				
							ks = false
			end 
			
		end
	end -- end of for loop

end -- end of dmgCalculation() function

function OnDraw()
	if Config.drawcircles and not myHero.dead then
		DrawCircle(myHero.x, myHero.y, myHero.z, rangeQ, 0x099B2299)
		--DrawCircle(myHero.x, myHero.y, myHero.z, 1750, 0x099B2299)
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
	
	
	
end

function OnSendChat(msg)
	
	ts:OnSendChat(msg, "pri")
end
PrintChat(" >> Xerath WomboCombo 1.0 loaded!")