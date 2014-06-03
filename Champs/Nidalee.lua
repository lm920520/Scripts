--[[
	Nidalee the Rapist
]]
if myHero.charName ~= "Nidalee" then return end

require "AllClass"
 
--[[		Code		]]
local mousemoving = true 
local movedelay = 0
local unitScanDelay = 0
local waitDelay = 300
local scanAdditionalRange = 500
local units = {}
local oldDelayTick = 0
local unitScanTick = 0
local holding = 0
local animPlayedTick = nil
local nextTick = 0

local AxePos = nil

local lasthiton = true

local lastdirection = 0

local range = 1400

local wrange = 1000

local AArange = 275
local lastBasicAttack = 0
local swingDelay = 0.1
local rangedSwingDelay = 0.05
local swing = 0
local tick = nil
-- Active
-- draw

local targetSelected = true	
-- ts
local ts
--
local ignite = nil
local BRKSlot, DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = nil, nil, nil, nil, nil, nil, nil
local QREADY, WREADY, EREADY, RREADY, BRKREADY, DFGREADY, HXGREADY, BWCREADY = false, false, false, false, false, false, false, false

function OnLoad()
	NIDConfig= scriptConfig("Nidalee the Rapist", "nidaleetherapist")
	NIDConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	NIDConfig:addParam("scriptActive1", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 67)	
  NIDConfig:addParam("scriptActive2", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	NIDConfig:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, 84)
  NIDConfig:addParam("DASH", "Dash", SCRIPT_PARAM_ONKEYDOWN, false, 90)
	NIDConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	NIDConfig:addParam("drawtext", "Draw Text", SCRIPT_PARAM_ONOFF, true)
	NIDConfig:addParam("drawprediction", "Draw Prediction", SCRIPT_PARAM_ONOFF, false)
	NIDConfig:addParam("autoignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
	NIDConfig:addParam("autoAAFarm", "Auto Farm", SCRIPT_PARAM_ONKEYDOWN, false, 192)
  NIDConfig:permaShow("autoAAFarm")
	ts = TargetSelector(TARGET_LOW_HP,range+250,DAMAGE_MAGIC)
	ts.name = "Nidalee"
	NIDConfig:addTS(ts)
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end	
end



	function OnProcessSpell(unit, spell)
		if unit.isMe and (spell.name:find("Attack") ~= nil) then
			swing = 1
			lastBasicAttack = os.clock()
		end
	end



function OnTick()
  
  ts:update()
	if myHero.dead then
		return
	end
  
  
    
  if myHero:GetSpellData(_Q).name == "JavelinToss" or myHero:GetSpellData(_W).name == "Bushwhack" or myHero:GetSpellData(_E).name == "PrimalSurge" then
    HUMAN = true
    COUGAR = false
	end
  
  if myHero:GetSpellData(_Q).name == "Takedown" or myHero:GetSpellData(_W).name == "Pounce" or myHero:GetSpellData(_E).name == "Swipe" then
    COUGAR = true
    HUMAN = false
	end
	
	if swing == 1 and os.clock() > lastBasicAttack + 0.5 then
		swing = 0
	end

	if ignite ~= nil and myHero:CanUseSpell(ignite) == READY then
		if IREADY then
			local ignitedmg = 0	
			for j = 1, heroManager.iCount, 1 do
				local enemyhero = heroManager:getHero(j)
				if ValidTarget(enemyhero,600) then
					ignitedmg = 50 + 20 * myHero.level
					if enemyhero.health <= (ignitedmg - 50) then
						CastSpell(ignite, enemyhero)
					end
				end
			end
		end
	end

	BRKSlot, DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = GetInventorySlotItem(3153), GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
	BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
	BRKREADY = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)


---------------------------------------------------------------- Combos Etc---------------------------------------------------------------------------------
	if ts.target == nil then
    ts:update()
  end
  
  if ts.target ~= nil then
    Prediction__OnTick()
  end

	if NIDConfig.harass and ts.target ~= nil then
    if HUMAN and not COUGAR then	
      if QREADY then
        QtravelDuration = (GetDistance(myHero, ts.nextPosition) / 1.2) + 290
        ts:SetPrediction(QtravelDuration)  
        if GetDistance(ts.target)<range and GetDistance(ts.nextPosition) < range and not GetMinionCollision(myHero,ts.nextPosition, 150) then
          CastSpell(_Q, ts.nextPosition.x, ts.nextPosition.z)
        end
      end
    end
    if COUGAR and not HUMAN then
      CastSpell(_R)
    end
	end
 

 
  if HUMAN and NIDConfig.scriptActive and ts.target ~= nil and not COUGAR then
		if DFGREADY then CastSpell(DFGSlot, ts.target) end
		if HXGREADY then CastSpell(HXGSlot, ts.target) end
		if BWCREADY then CastSpell(BWCSlot, ts.target) end
		if BRKREADY then CastSpell(BRKSlot, ts.target) end
		if QREADY then
      QtravelDuration = (GetDistance(myHero, ts.nextPosition) / 1.2) + 270
      ts:SetPrediction(QtravelDuration)  
      if HUMAN and GetDistance(ts.target) < range and GetDistance(ts.nextPosition) < range and not GetMinionCollision(myHero,ts.nextPosition, 150) then
        CastSpell(_Q, ts.nextPosition.x, ts.nextPosition.z)
      end
    end		
		if swing == 0  then
			if GetDistance(ts.target) < AArange then
        myHero:Attack(ts.target)
      end
    end
  end
  
  
  
  if COUGAR and NIDConfig.scriptActive and ts.target ~= nil and not HUMAN then			
		if DFGREADY then CastSpell(DFGSlot, ts.target) end
		if HXGREADY then CastSpell(HXGSlot, ts.target) end
		if BWCREADY then CastSpell(BWCSlot, ts.target) end
		if BRKREADY then CastSpell(BRKSlot, ts.target) end		
    if swing == 0 then
      if GetDistance(ts.target) < myHero.range + 300 then
        myHero:Attack(ts.target)
      end      
			if WREADY and GetDistance(ts.target) < myHero.range + 300 then				
				myHero:Attack(ts.target)
				if GetTickCount()-lastdirection >= 500 then
					local absposxy = math.min(math.abs(ts.target.x-myHero.x),math.abs(ts.target.y-myHero.y))
					myHero:MoveTo(myHero.x+(ts.target.x-myHero.x)*100/absposxy,myHero.z+(ts.target.z-myHero.z)*100/absposxy)
					lastdirection = GetTickCount()
        elseif GetTickCount()-lastdirection >= 100 then
					CastSpell(_W, ts.target.x,ts.target.z)
				end				
			end      
    elseif swing == 1 then
      if EREADY and GetDistance(ts.target) < myHero.range + 200 and os.clock() - lastBasicAttack > swingDelay then				
        if GetTickCount()-lastdirection >= 500 then
          local absposxy = math.min(math.abs(ts.target.x-myHero.x),math.abs(ts.target.y-myHero.y))
          myHero:MoveTo(myHero.x+(ts.target.x-myHero.x)*100/absposxy,myHero.z+(ts.target.z-myHero.z)*100/absposxy)
          lastdirection = GetTickCount()
        elseif GetTickCount()-lastdirection >= 100 then
          CastSpell(_E, ts.target.x,ts.target.z)
          swing = 0
        end
      elseif QREADY and not EREADY and os.clock() - lastBasicAttack > swingDelay then
        CastSpell(_Q)
        swing = 0			
      end
    end
  end
  
  
  
  if HUMAN and NIDConfig.scriptActive1 and ts.target ~= nil and not COUGAR then			
		if DFGREADY then CastSpell(DFGSlot, ts.target) end
		if HXGREADY then CastSpell(HXGSlot, ts.target) end
		if BWCREADY then CastSpell(BWCSlot, ts.target) end
		if BRKREADY then CastSpell(BRKSlot, ts.target) end		
		if swing == 0  then
			if GetDistance(ts.target) < AArange then
        myHero:Attack(ts.target)
      end
    elseif swing == 1 then
      if EREADY and os.clock() - lastBasicAttack > rangedSwingDelay then
				CastSpell(_E, myHero)
				swing = 0
			end		   
    end
  end
  
  
  
  if COUGAR and NIDConfig.scriptActive1 and ts.target ~= nil and not HUMAN then		
		if DFGREADY then CastSpell(DFGSlot, ts.target) end
		if HXGREADY then CastSpell(HXGSlot, ts.target) end
		if BWCREADY then CastSpell(BWCSlot, ts.target) end
		if BRKREADY then CastSpell(BRKSlot, ts.target) end		
    if swing == 0 then
      if GetDistance(ts.target) < myHero.range + 300 then
        myHero:Attack(ts.target)
      end
    elseif swing == 1 then
      if EREADY and GetDistance(ts.target) < myHero.range + 200 and os.clock() - lastBasicAttack > swingDelay then			
        if GetTickCount()-lastdirection >= 500 then
          local absposxy = math.min(math.abs(ts.target.x-myHero.x),math.abs(ts.target.y-myHero.y))
          myHero:MoveTo(myHero.x+(ts.target.x-myHero.x)*100/absposxy,myHero.z+(ts.target.z-myHero.z)*100/absposxy)
          lastdirection = GetTickCount()
        elseif GetTickCount()-lastdirection >= 100 then
          CastSpell(_E, ts.target.x,ts.target.z)
          swing = 0
        end	
      elseif QREADY and not EREADY and os.clock() - lastBasicAttack > swingDelay then
        CastSpell(_Q)
        swing = 0			
      end
    end
  end
  
  
  
  if NIDConfig.scriptActive2 then
    if COUGAR and ts.target ~= nil and not HUMAN then
      if DFGREADY then CastSpell(DFGSlot, ts.target) end
      if HXGREADY then CastSpell(HXGSlot, ts.target) end
      if BWCREADY then CastSpell(BWCSlot, ts.target) end
      if BRKREADY then CastSpell(BRKSlot, ts.target) end		
      if swing == 0 then
        if GetDistance(ts.target) < myHero.range + 300 then
          myHero:Attack(ts.target)
        end      
        if WREADY and GetDistance(ts.target) < myHero.range + 300 then				
          myHero:Attack(ts.target)
          if GetTickCount()-lastdirection >= 500 then
            local absposxy = math.min(math.abs(ts.target.x-myHero.x),math.abs(ts.target.y-myHero.y))
            myHero:MoveTo(myHero.x+(ts.target.x-myHero.x)*100/absposxy,myHero.z+(ts.target.z-myHero.z)*100/absposxy)
            lastdirection = GetTickCount()
          elseif GetTickCount()-lastdirection >= 100 then
            CastSpell(_W, ts.target.x,ts.target.z)
          end				
        end      
      elseif swing == 1 then
        if EREADY and GetDistance(ts.target) < myHero.range + 200 and os.clock() - lastBasicAttack > swingDelay then				
          if GetTickCount()-lastdirection >= 500 then
            local absposxy = math.min(math.abs(ts.target.x-myHero.x),math.abs(ts.target.y-myHero.y))
            myHero:MoveTo(myHero.x+(ts.target.x-myHero.x)*100/absposxy,myHero.z+(ts.target.z-myHero.z)*100/absposxy)
            lastdirection = GetTickCount()
          elseif GetTickCount()-lastdirection >= 100 then
            CastSpell(_E, ts.target.x,ts.target.z)
            swing = 0
          end
        elseif QREADY and not EREADY and os.clock() - lastBasicAttack > swingDelay then
          CastSpell(_Q)
          swing = 0			
        end
      end
    end
    if HUMAN and not COUGAR then
				CastSpell(_E)
        CastSpell(_R)
		end
  end
  
  
  
	if NIDConfig.DASH then
    myHero:MoveTo(mousePos.x,mousePos.z)
		if COUGAR and not HUMAN then
			if WREADY then
        if GetTickCount()-lastdirection >= 500 then
          local absposxy = math.min(math.abs(mousePos.x-myHero.x),math.abs(mousePos.y-myHero.y))
          myHero:MoveTo(myHero.x+(mousePos.x-myHero.x)*100/absposxy,myHero.z+(mousePos.z-myHero.z)*100/absposxy)
          lastdirection = GetTickCount()
        elseif GetTickCount()-lastdirection >= 100 then
          CastSpell(_W)
        end
      end
    end
		if HUMAN and not COUGAR then
				CastSpell(_R)
		end	
	end
  
  

	if NIDConfig.autoAAFarm then
		if mousemoving and GetTickCount() > nextTick then
			player:MoveTo(mousePos.x, mousePos.z)
		end
						
		local tick = GetTickCount()
		if lasthiton then
		unitScanTick = tick
			for i = 1, objManager.maxObjects, 1 do
				local object = objManager:getObject(i)
				if object ~= nil and object.team ~= player.team and object.type == "obj_AI_Minion" and string.find(object.charName,"Minion") then
					if not object.dead and GetDistance(object,player) <= (player.range + scanAdditionalRange) then
						if units[object.name] == nil then
							units[object.name] = { obj = object, markTick = 0 }
						end
					else
						units[object.name] = nil
					end
				end
			end
		end
		for i, unit in pairs(units) do
			if unit.obj == nil or unit.obj.dead or GetDistance(player,unit.obj) > (player.range + scanAdditionalRange) then
				units[i] = nil
			else
				if unit.obj.health <= (myHero:CalcDamage(unit.obj,myHero.totalDamage)) then -- 
					if lasthiton and GetTickCount() > nextTick then
						player:Attack(unit.obj) ---PrintChat("ATTACKING")
						nextTick = GetTickCount() + waitDelay	
						return
					end 
				end
			end     
		end
	end	
	
end
function OnDraw()
	if NIDConfig.drawcircles and not myHero.dead then
    if HUMAN and not COUGAR then
      DrawCircle(myHero.x, myHero.y, myHero.z, myHero.range+150, 0x992D3D)
      if QREADY then DrawCircle(myHero.x, myHero.y, myHero.z, range, 0x992D3D)end
      if WREADY then DrawCircle(myHero.x, myHero.y, myHero.z, wrange, 0xFFFFFF)end
    end
    if COUGAR and not HUMAN then
      DrawCircle(myHero.x, myHero.y, myHero.z, myHero.range+150, 0x992D3D)
      if WREADY then DrawCircle(myHero.x, myHero.y, myHero.z, myHero.range+300, 0xFFFFFF)end
    end
		if ts.target ~= nil then
			for j=0, 10 do DrawCircle(ts.target.x, ts.target.y, ts.target.z, 40 + j*1.5, 0x00FF00) end
		end
	end  
	if ts.target ~= nil and NIDConfig.drawprediction then
		DrawCircle(ts.nextPosition.x, ts.target.y, ts.nextPosition.z, 200, 0x0000FF)
	end
	SC__OnDraw()
end
function OnWndMsg(msg,key)
	SC__OnWndMsg(msg,key)
end
function OnSendChat(msg)
	TargetSelector__OnSendChat(msg)
	ts:OnSendChat(msg, "pri")
end
PrintChat(" >> Nidalee the Rapist!")