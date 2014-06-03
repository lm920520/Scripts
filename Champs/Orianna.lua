

local rangeQ = 825 -- Q
local rangeW = 250 -- W
local rangeE = 1100 -- E
local rangeR = 400 -- R
local qDelay = 600

local tick = nil


local ts 


if myHero.charName ~= "Orianna" then return end

local waittxt = {}
local calculationenemy = 1
local floattext = {"Skills are not available","Able to fight","Killable","Murder him!"}
local killable = {}

local fountain = false
local doomBallobj = nil
local doomBallOut = false
local doomBall = nil
local ballBinded = false
local ballBind = nil
local ballBindedAlly = false
local ballBindAllyobj = nil
local ballBindAlly = nil
local qHit = nil
local wHit = nil
local qhit = false
local whit = false
local sT = 0
local s = 0

local shieldKey = 90 -- z
local teamFightKey = 32 -- spacebar
local harassKey = 88 -- x



local ignite = nil
local DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = nil, nil, nil, nil, nil, nil
local QREADY, WREADY, EREADY, RREADY, DFGREADY, HXGREADY, BWCREADY, IREADY = false, false, false, false, false, false, false, false


function OnLoad()

	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerBarrier") then sbarrier = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerBarrier") then sbarrier = SUMMONER_2 end
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerHeal") then sheal = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerHeal") then sheal = SUMMONER_2 end
	
	player = GetMyHero()
	ball = player
	doomBall = nil

	ts = TargetSelector(TARGET_LOW_HP,rangeE,DAMAGE_MAGIC)
	ts.name = "Orianna"

	Config = scriptConfig("Orianna WomboCombo 2.7.1", "Oriannacombo")
	
	
	Config:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	Config:addParam("teamFight", "TeamFight", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Config:addParam("autoIgnite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)

	
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
	teamFight()
	harass()
	igniteCheck()
	dmgCalculation()
	BuffCheck()
	if myHero.dead then
		ball = player
		doomBall = nil
	end
	
	if tick == nil or GetTickCount()-tick >= 200 then
		tick = GetTickCount()
	end	
	
end -- End of OnTick function	

function BuffCheck()
	for i = 1, myHero.buffCount do
	local buff = myHero:getBuff(i)
		if buff.name ~= nil then
			if buff.name == "orianaghostself" then 
				 sT = buff.startT
				 if sT>s then
					s = sT
				ball = player
				doomBall = nil
					--PrintChat("bal is on me")
				 end
			end
		end
	end -- end of for loop
	
end

function harass()
	if Config.harass then
		if ValidTarget(ts.target, rangeQ) then
			QPos = GetPredictionPos(ts.target, qDelay)
			if QPos ~= nil then
				if QREADY and GetDistance(ts.target)<=rangeQ then CastSpell(_Q, QPos.x, QPos.z) end
			end
			if doomBall ~=nil then
				if WREADY and GetDistance(doomBall, ts.target)<=rangeW then CastSpell(_W) end
			end
			if doomBall == nil then
				if GetDistance(myHero, ts.target)<rangeW then
					CastSpell(_W)
				end
			end
		end
	end
end

function teamFight()
	if Config.teamFight then
		if DFGREADY then CastSpell(DFGSlot, ts.target) end
		if HXGREADY then CastSpell(HXGSlot, ts.target) end
		if BWCREADY then CastSpell(BWCSlot, ts.target) end
		if ValidTarget(ts.target, rangeQ) then
			QPos = GetPredictionPos(ts.target, qDelay)
			if QPos ~= nil then
				if QREADY and GetDistance(ts.target)<=rangeQ then CastSpell(_Q, QPos.x, QPos.z) end
			end
		end
		if ValidTarget(ts.target, rangeQ) then
			if doomBall ~=nil then
				if WREADY and GetDistance(doomBall, ts.target)<=rangeW then CastSpell(_W) end
			end
			if doomBall == nil then
				if GetDistance(myHero, ts.target)<rangeW then
					CastSpell(_W)
				end
			end
			if whit == true then
				EREADY = false
				if RREADY and WREADY == false then CastSpell(_R) end	
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
	if obj ~= nil then
		--[[	if obj.name:find("oriana_ball_glow_green") then
				ball = obj
			end ]]
		if ValidTarget(ts.target) then
			if obj.name:find("OrianaIzuna_tar") then
				qHit = obj
				if GetDistance(ts.target, qHit)<=100 then
					 qhit = true 
				end
			end	
			if obj.name:find("OrianaDissonance_ball_green.troy") then
				wHit = obj
				if GetDistance(ts.target, wHit)<=250 then
					whit = true 
				end
			end
		end
		if obj.name:find("TheDoomBall") then
			doomBallobj = obj
			doomBall = doomBallobj
			ball = doomBall
		end
		if obj.name:find("Oriana_Ghost_mis") then
			ball = player
			doomBall = nil
			doomBallobj = nil
		end
	end
end

function OnDeleteObj(obj)
	if obj ~= nil then
			if obj.name:find("OrianaIzuna_tar") then
							qhit = false
							qHit = nil
			end
			if obj.name:find("OrianaDissonance_ball_green.troy") then
							whit = false
							wHit = nil
			end
			if obj.name:find("TheDoomBall") then
				doomBallobj = nil
			end
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
			if EREADY then
				DrawCircle(myHero.x, myHero.y, myHero.z, rangeE, 0x099B2299)
			else
				DrawCircle(myHero.x, myHero.y, myHero.z, rangeQ, 0x099B2299)
			end
			for j=0, 10 do
				DrawCircle(ball.x, ball.y, ball.z, 100+j*0.5, 0x099B2299)	
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
		

end
	
function OnWndMsg(msg,key)
	
end

function OnSendChat(msg)
	
	ts:OnSendChat(msg, "pri")
end
PrintChat(" >> Orianna WomboCombo 2.7.1 loaded!")