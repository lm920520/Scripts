--[[
	Jayce the Rapist Beta by jbman
	based on eXtragoZ scripts
  Thanks to llama for his velocity calculation and Manciuszz for implementing it for Jayce
	
	-Supports Deathfire Grasp, Bilgewater Cutlass, Hextech Gunblade, Sheen, Trinity, Lich Bane, Blade of thr Ruined King, Sword of the Devine, Tiamat, Ravenous Hydra and Ignite
	-Target configuration, Press shift to configure
	-Option to auto ignite when enemy is killable
	
	
]]

--[[	Code	]]

if myHero.charName ~= "Jayce" then return end
local CannonQ = false
local Qtime = 0
local MMtimer = 0
local wcountdown = 0
local ecountdown = 0
local AAmove = true
local KBPOS = nil
local cancelMovt = false
local EHowFarAway = 0
local range = 1625
local erange = 400
local speed = 1600 --2100
local delay = 0.285 --0.550
local smoothness = 50
local AArange = 0
local hitPosition = nil
local EnemyPos = nil
local HeroPos = nil
local GatePos = nil
local EGatePos = nil
local CanE = true
local lastRW = 0
local ignite = nil
local ts
local tp
local tpVIP
local lastBasicAttack = 0
local swing = 0
local lastdirection = 0
local aahit = false

local targetSelected = true
local YMGBSlot, TMATSlot, SotDSlot, DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot, ROSlot, ENTSlot, LOCKSlot = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local QREADY, WREADY, EREADY, RREADY, YMGBREADY, TMATREADY, SotDREADY, DFGREADY, HXGREADY, BWCREADY, ROREADY, ENTREADY, LOCKREADY = false, false, false, false, false, false, false, false, false, false, false, false, false
  
function OnLoad()
  
	JayceConfig = scriptConfig("Jayce The Rapist 2.0b", "jaycetherapist")
	JayceConfig:addParam("ESCAPE", "Escape", SCRIPT_PARAM_ONKEYDOWN, false, 192) -- ~/`	
	JayceConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 88) -- X	
	JayceConfig:addParam("BURST", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 67) -- C	
	JayceConfig:addParam("EASY", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 90) -- Z	
	JayceConfig:addParam("FREEQE", "FreeQE", SCRIPT_PARAM_ONKEYDOWN, false, 84) -- T	
  JayceConfig:addParam("eBuffer", "Gate distance",SCRIPT_PARAM_SLICE, 100, 1, 500, 2)  
  JayceConfig:addParam("drawprediction", "Draw Prediction", SCRIPT_PARAM_ONOFF, false)  
  JayceConfig:addParam("VIP", "VIP TP", SCRIPT_PARAM_ONOFF, true)
  JayceConfig:addParam("AutoMM", "Auto Muramana", SCRIPT_PARAM_ONOFF, true) 
	JayceConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	JayceConfig:addParam("drawtext", "Draw Text", SCRIPT_PARAM_ONOFF, true)
	JayceConfig:addParam("autoignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)  
  ts = TargetSelector(TARGET_LESS_CAST_PRIORITY,range+150,DAMAGE_PHYSICAL)
  tpVIP = TargetPredictionVIP(range, speed, delay)
  tp = TargetPrediction(range, speed/1000, delay*1000, smoothness)
  ts.name = "Jayce"
	JayceConfig:addTS(ts)
	PrintChat(">> Jayce The Rapist 2.0b loaded!") 
end  

function OnProcessSpell(unit, spell) -- JayceAccelerationGate
  if unit.isMe and spell and (spell.name:find("jayceaccelerationgate") ~= nil) then
    GatePos = nil
    hitPosition = nil
    cancelMovt = false
  end
  if unit.isMe and spell and (spell.name:find("JayceThunderingBlow") ~= nil) then
    KBPOS = nil
  end
  if unit.isMe and spell and (spell.name:find("jayceshockblast") ~= nil) then
    CannonQ = true
    Qtime = os.clock()
    if myHero:GetSpellData(_R).name == "jaycestancegth" and myHero:CanUseSpell(_E) == READY and VIP_USER == false and JayceConfig.scriptActive or JayceConfig.BURST or JayceConfig.FREEQE then
      myHero:HoldPosition()
    end
    if myHero:GetSpellData(_R).name == "jaycestancegth" and myHero:CanUseSpell(_E) == READY and VIP_USER and JayceConfig.scriptActive or JayceConfig.BURST or JayceConfig.FREEQE then
      cancelMovt = true
    end
  end
  if unit.isMe and spell and (spell.name:find("jaycepassive") ~= nil or spell.name:find("Attack") ~= nil or spell.name:find("Attack") ~= nil) then swing = 1 lastBasicAttack = os.clock() end --PrintChat("Hit")   
  if unit.isMe and spell and (spell.name:find("jaycehypercharge") ~= nil) then CanE = False lastRW = os.clock() end --PrintChat("Hit")   
end  
  
function OnCreateObj(obj)
  if ts.target and obj and (obj.name:find("Jayce_Hex_Buff_Ready.troy") ~= nil) and GetDistance(obj) < 175 then
    CanE = false
  end  
  if ts.target and  obj and (obj.name:find("Jayce_Range_Basic_Mis.troy") ~= nil) and GetDistance(obj) < 175 then
    aahit = true
  end    
  if ts.target and obj and (obj.name:find("globalhit_bloodslash") ~= nil) and GetDistance(obj) > 1 and GetDistance(obj,ts.target) < 150 then
    aahit = true
  end
  if ts.target and obj and (obj.name:find("Jayce_Charged_Hit") ~= nil) and GetDistance(obj) > 1 and GetDistance(obj,ts.target) < 150 then
    aahit = true      
  end
  if CannonQ and obj and (obj.name:find("JayceOrbLightning.troy") ~= nil) and GetDistance(obj) < 500 then
    --PrintChat("ORB")
    if JayceConfig.FREEQE or JayceConfig.scriptActive or JayceConfig.BURST then
      CastSpell(_E,obj.x,obj.z)
    end
  end
end
  
function OnDeleteObj(obj)
  if ts.target and obj and (obj.name:find("Jayce_Hex_Buff_Ready.troy") ~= nil) and GetDistance(obj) < 175 then   
    CanE = true
  end  
end

function Items()
  YMGBSlot, TMATSlot, SotDSlot, DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot, ROSlot, ENTSlot, LOCKSlot = GetInventorySlotItem(3142), (GetInventorySlotItem(3077) or GetInventorySlotItem(3074)) , GetInventorySlotItem(3131), GetInventorySlotItem(3128), GetInventorySlotItem(3146), (GetInventorySlotItem(3144)or GetInventorySlotItem(3153)), GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100), GetInventorySlotItem(3143), GetInventorySlotItem(3184), GetInventorySlotItem(3190)
	
  DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
  HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
  BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
  TMATREADY = (TMATSlot ~= nil and myHero:CanUseSpell(TMATSlot) == READY)
  SotDREADY = (SotDSlot ~= nil and myHero:CanUseSpell(SotDSlot) == READY)
  YMGBREADY = (SotDSlot ~= nil and myHero:CanUseSpell(YMGBSlot) == READY)
  ROREADY = (ROSlot ~= nil and myHero:CanUseSpell(ROSlot) == READY)
  ENTREADY = (ENTSlot ~= nil and myHero:CanUseSpell(ENTSlot) == READY) -- , ENTSlot = GetInventorySlotItem(3184),
  LOCKREADY = (LOCKSlot ~= nil and myHero:CanUseSpell(LOCKSlot) == READY)
  if ts.target ~= nil then
    if DFGREADY then CastSpell(DFGSlot, ts.target) end
    if HXGREADY then CastSpell(HXGSlot, ts.target) end
    if BWCREADY and GetDistance(ts.target) <= 501 and ts.target.type == "obj_AI_Hero" then CastSpell(BWCSlot, ts.target) end      
    if ROREADY and GetDistance(ts.target) <= 485 and ts.target.type == "obj_AI_Hero" then CastSpell(ROSlot) end
    if LOCKREADY and GetDistance(ts.target) <= 485 and ts.target.type == "obj_AI_Hero" then CastSpell(LOCKSlot) end
    if swing == 1 then
      if YMGBREADY then -- YMGB
        if ts.target.type == "obj_AI_Hero" and GetDistance(ts.target) < 400 then
          CastSpell(YMGBSlot)
        end
      end
      if SotDREADY then
        if ts.target.type == "obj_AI_Hero" and GetDistance(ts.target) < 400 then
          CastSpell(SotDSlot)
        end
      end
      if ENTREADY then -- YMGB
        if ts.target.type == "obj_AI_Hero" and GetDistance(ts.target) < 400 then
          CastSpell(ENTSlot)
        end
      end
      if TMATREADY and GetDistance(ts.target) < 375 and aahit == true then -- If Q is ready and you have Tiamat/Hydra you will use the active after an AA
        CastSpell(TMATSlot)
        aahit = false
        swing = 0      
      end
    end
  end
end

function QEcheck()
  if (myHero:GetSpellData(_R).name == "jaycestancegth" and myHero:CanUseSpell(_Q) ~= COOLDOWN and myHero:CanUseSpell(_E) ~= COOLDOWN and ((player:GetSpellData(_Q).level == 1 and myHero.mana > 99) or 
    (player:GetSpellData(_Q).level == 2 and myHero.mana > 104) or 
    (player:GetSpellData(_Q).level == 3 and myHero.mana > 109) or 
    (player:GetSpellData(_Q).level == 4 and myHero.mana > 114) or 
    (player:GetSpellData(_Q).level == 5 and myHero.mana > 119))) then
    return true
  else
    return false
  end    
end

function orbWalk()
	if ts.target ~= nil then
		if AAmove == true then                   
      player:MoveTo(ts.target.x, ts.target.z)
      --PrintChat("ORB!")
      aahit = false           
      swing = 0
		end
    myHero:Attack(ts.target)        
  elseif ts.target == nil then
    swing = 0
    aahit = false
  end
end

function OnSendPacket(packet)  
  if packet.header == 0x71 then
    --PrintChat("Moving!")
    packet.pos = 5    
    if cancelMovt == true then
      --PrintChat("HALT!")
      packet:Block()
      packet:Block()
      packet:Block()
    end
  end
end

function GateUpdate()
  if myHero:GetSpellData(_R).name == "jaycestancegth" and myHero:CanUseSpell(_E) == READY then
    MPos = Vector(mousePos.x, mousePos.y, mousePos.z)
    HeroPos = Vector(myHero.x, myHero.y, myHero.z)
    GatePos = HeroPos + ( HeroPos - MPos )*(-EHowFarAway/GetDistance(mousePos))    
  end
end

--ONTICK
--ONTICK
--ONTICK
--ONTICK
--ONTICK
--ONTICK
--ONTICK
--ONTICK
--ONTICK
--ONTICK
--ONTICK
--ONTICK
--ONTICK
--ONTICK
--ONTICK
--ONTICK
--ONTICK
--ONTICK
--ONTICK
--ONTICK

function OnTick()
  
  EHowFarAway = JayceConfig.eBuffer
  AArange = ((myHero.range + (GetDistance(myHero.minBBox, myHero.maxBBox)/2))*1.1)
	if myHero.dead then
		return
	end
  QEcheck()
  
  if QEcheck() == true then
   -- PrintChat("QE!")
	end
  
  if myHero:GetSpellData(_R).name == "jaycestancegth" and myHero:CanUseSpell(_E) == READY then --(JayceConfig.scriptActive or JayceConfig.BURST or JayceConfig.ESCAPE or JayceConfig.FREEQE) then
    GateUpdate()
    QEcheck()
  end
  
  if myHero:GetSpellData(_R).name == "jaycestancegth" then
    if myHero:CanUseSpell(_E) == READY then
      if myHero:CanUseSpell(_Q) == READY then
        range = 1650        
      elseif myHero:CanUseSpell(_Q) ~= READY then
        range = 650
      end
    elseif myHero:CanUseSpell(_E) ~= READY then
      if myHero:CanUseSpell(_Q) == READY then
        range = 1050
      elseif myHero:CanUseSpell(_Q) ~= READY then
        range = 650
      end
    end
  elseif myHero:GetSpellData(_R).name == "JayceStanceHtG" then
    if myHero:CanUseSpell(_Q) == READY then
      range = 750        
    elseif myHero:CanUseSpell(_Q) ~= READY then
      range = 550
    end
  end
  
  if CannonQ and os.clock() > Qtime + 0.5 then
    cancelMovt = false
    hitPosition = nil
    GatePos = nil
    CannonQ = false
    --PrintChat("CanE!")
  end  

  ts:update()
  if myHero:GetSpellData(_R).name == "jaycestancegth" and myHero:CanUseSpell(_E) == READY then
    MPos = Vector(mousePos.x, mousePos.y, mousePos.z)
    HeroPos = Vector(myHero.x, myHero.y, myHero.z)
    GatePos = HeroPos + ( HeroPos - MPos )*(-EHowFarAway/GetDistance(mousePos))
    if ts.target and ValidTarget(ts.target) and GetDistance(ts.target) < range+150 and ts.target.dead == false then      
      if VIP_USER then
        hitPosition = tpVIP:GetPrediction(ts.target)      
      elseif VIP_USER == false then
        hitPosition = tp:GetPrediction(ts.target)
      end     
    end
  end
  
  if ts.target == nil or (ts.target and hitPosition and ts.target == dead)  then
    KBPOS = nil
    hitPosition = nil
  end
  
  
  if (myHero:GetSpellData(_R).name == "jaycestancegth" and (myHero:CanUseSpell(_E) == COOLDOWN and myHero:CanUseSpell(_Q) == COOLDOWN)) or myHero:GetSpellData(_R).name ~= "jaycestancegth" then  
    hitPosition = nil
  end
  
  if CanE == false and os.clock() > lastRW + 4 then
    --PrintChat("CanE!")
		--CanE = true    
  end
  
  if swing == 1 and os.clock() > lastBasicAttack + 0.7 then
		swing = 0
    if aahit == true then
      aahit = false
    end
	end
  
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
  IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
  
	HAMMER = (myHero:GetSpellData(_R).name == "JayceStanceHtG")
	CANNON = (myHero:GetSpellData(_R).name == "jaycestancegth") 
  
  if JayceConfig.STANCE then
		if RREADY then
			CastSpell(_R)
		end	
	end
  
  --[[ MuramanaIsActive() Return true / false
  MuramanaOn() Set Muramana On if possible
  MuramanaOff() Set Muramana Off if possible
  MuramanaToggle(range, extCondition)]]
  
  if JayceConfig.AutoMM then
    if MuramanaIsActive() == false then 
      if HAMMER and ts.target ~= nil and GetDistance(ts.target) < 450 then
        MuramanaOn()
        MMtimer = os.clock()
      end
      if CANNON and ts.target ~= nil and GetDistance(ts.target) < AArange+50 then
        MuramanaOn()
        MMtimer = os.clock()
      end
    end
    if MuramanaIsActive() == true then 
      if HAMMER and ts.target ~= nil and GetDistance(ts.target) > 451 then
        MuramanaOff()
      end      
      if CANNON and ts.target ~= nil and GetDistance(ts.target) > AArange+51 then
        MuramanaOff()
      end
      if os.clock() > MMtimer + 5 and ts.target == nil then
        MuramanaOff()
      end
    end
  end

  if JayceConfig.FREEQE then
		if HAMMER then
			CastSpell(_R)
    end    
    if CANNON and QEcheck() == true and QREADY and EREADY then
      CastSpell(_Q, mousePos.x, mousePos.z)        
    end
	end

-- ESCAPE
	if JayceConfig.ESCAPE then
    if HAMMER then			
      CastSpell(_R)				
    elseif CANNON then
      if GetTickCount()-lastdirection >= 500 then
        local absposxy = math.min(math.abs(mousePos.x-myHero.x),math.abs(mousePos.y-myHero.y))
        myHero:MoveTo(myHero.x+(mousePos.x-myHero.x)*100/absposxy,myHero.z+(mousePos.z-myHero.z)*100/absposxy)
        lastdirection = GetTickCount()
      elseif GetTickCount()-lastdirection >= 100 then        
        myHero:MoveTo(mousePos.x,mousePos.z)
        if myHero:CanUseSpell(_E) == READY then          
          EscapePos = Vector(mousePos.x, mousePos.y, mousePos.z)
          HeroPos = Vector(myHero.x, myHero.y, myHero.z)
          GatePos = HeroPos + ( HeroPos - EscapePos )*(-EHowFarAway/GetDistance(mousePos))
          CastSpell(_E, GatePos.x, GatePos.z)						
        end        
      end		
    end
  end
  
  if JayceConfig.scriptActive and ts.target then
    if CANNON then
      if HAMMER == false then
        --QEcheck()
        Items()
        if hitPosition and QEcheck() == true and QREADY and EREADY then           
          CastSpell(_Q, hitPosition.x, hitPosition.z)           
        end
        if QREADY == false and EREADY == false then
          GatePos = nil          
          myHero:Attack(ts.target)
        end      
        if swing == 1 then
          if QREADY == false and EREADY == false and aahit == true then
            orbWalk()
          end
        end
      end
    end   
    if HAMMER then    
      if CANNON == false then        
        Items()      
        if QREADY and GetDistance(ts.target) < 750 then
          myHero:Attack(ts.target) 
          CastSpell(_Q, ts.target)
        end
        if swing == 0 then
          if GetDistance(ts.target) < AArange+150 then 
            myHero:Attack(ts.target) 
          end     
        elseif swing == 1 then          
          if QREADY == false and TMATREADY == false and aahit == true then
            orbWalk()           
          end        
        end
      end
    end
  end

  if JayceConfig.BURST and ts.target then
    if CANNON then
      if HAMMER == false then
        --QEcheck()
        Items()
        if hitPosition and QEcheck() == true and QREADY and EREADY then           
          CastSpell(_Q, hitPosition.x, hitPosition.z)           
        end
        if QREADY == false and EREADY == false then
          GatePos = nil    
          if GetDistance(ts.target) < AArange then
            myHero:Attack(ts.target)
            if swing == 1 and aahit == true then
              CastSpell(_W)
              myHero:Attack(ts.target)      
              CastSpell(_R)
            end
          elseif (GetDistance(ts.target) < range and GetDistance(ts.target) > AArange) then
            CastSpell(_W)
            myHero:Attack(ts.target)      
            CastSpell(_R)
          end
        end
        if QREADY == false and EREADY == false then          
          myHero:Attack(ts.target)       
        end
      end
    end    
    if HAMMER then      
      if CANNON == false then      
         Items()      
        if QREADY and GetDistance(ts.target) < 750 then
          myHero:Attack(ts.target)
          CastSpell(_W)  
          CastSpell(_Q, ts.target)        
        end    
        if swing == 0 then
          if EREADY and GetDistance(ts.target) < 450 and CanE == true then
            if EREADY and (GetDistance(ts.target) < erange and GetDistance(ts.target) > AArange-50) then            
              CastSpell(_E, ts.target)
            end            
          end          
          if GetDistance(ts.target) < AArange + 125 then
            myHero:Attack(ts.target)
          end
        end
        if swing == 1 then 
          if EREADY and aahit == true and CanE == true then
            CastSpell(_E, ts.target)
          end
          if QREADY == false and TMATREADY == false and aahit == true and CanE == false then
            orbWalk()
          end
          if QREADY == false and TMATREADY == false and EREADY == false and aahit == true then
            orbWalk()
          end          
        end
      end
    end
  end	
	
	if JayceConfig.EASY and ts.target then
    if HAMMER then    
      if CANNON == false then       
        Items()      
        if swing == 0 then
          if GetDistance(ts.target) < AArange+150 then
            myHero:Attack(ts.target)
          end
          if EREADY and GetDistance(ts.target) < 450 then
            if EREADY and (GetDistance(ts.target) < erange and GetDistance(ts.target) > AArange-50) then            
              CastSpell(_E, ts.target)
            end            
          end
        elseif swing == 1 then
          if EREADY and aahit == true then
            CastSpell(_E, ts.target)
          end
          if QREADY == false and TMATREADY == false and EREADY == false and aahit == true then
            orbWalk()
          end        
        end
      end
    end
    if CANNON then
      if HAMMER == false then    
        Items()
        if swing == 0 then
          if GetDistance(ts.target) < AArange + 200 then 
            myHero:Attack(ts.target)
          end
        elseif swing == 1 then
          if aahit == true then
            CastSpell(_W)
            myHero:Attack(ts.target)
            swing = 0
            aahit = false
          end          
          if WREADY == false and TMATREADY == false and aahit == true then
            orbWalk()     
          end        
        end
      end
    end
  end
-- Poop
end

function OnDraw()
	if myHero.dead == false then    
    if JayceConfig.drawcircles and CANNON then
      --DrawCircle(myHero.x, myHero.y, myHero.z, AArange, 0x992D3D)
			if EREADY and QREADY then DrawCircle(myHero.x, myHero.y, myHero.z, range, 0x992D3D) end
      if WREADY then DrawCircle(myHero.x, myHero.y, myHero.z, AArange, 0x992D3D)  -- 0x992D3D
      elseif WREADY == false then DrawCircle(myHero.x, myHero.y, myHero.z, AArange, 0x992D3D) end
	elseif JayceConfig.drawcircles and HAMMER then
			if QREADY then DrawCircle(myHero.x, myHero.y, myHero.z, 750, 0x992D3D) end
			if EREADY then DrawCircle(myHero.x, myHero.y, myHero.z, erange, 0x992D3D) 
      elseif EREADY == false then DrawCircle(myHero.x, myHero.y, myHero.z, AArange, 0x992D3D)end
		end
		if ts.target ~= nil then			
			DrawCircle(ts.target.x, ts.target.y, ts.target.z, (GetDistance(ts.target.minBBox, ts.target.maxBBox)/2), 0x00FF00)
		end
	end
  if ts.target ~= nil and hitPosition ~= nil and JayceConfig.drawprediction then
		DrawCircle(hitPosition.x, hitPosition.y, hitPosition.z, 100, 0xFFFFFF) -- hitPosition
	end
end

function OnSendChat(msg)
	ts:OnSendChat(msg, "pri")
end