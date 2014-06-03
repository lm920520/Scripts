    local ts
    local DFGSlot, HXGSlot, BWCSlot, YGSlot, BoRKSlot, QSSlot, MSSlot, RHSlot, MKSlot, OmenSlot, SESlot, SRSlot, SoTDSlot, TSSlot, ZHSlot = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
    local DFGREADY, HXGREADY, BWCREADY, YGREADY, BoRKREADY, QSREADY, MSREADY, RHREADY, MKREADY, OmenREADY, SEREADY, SRREADY, SoTDREADY, TSREADY, ZHREADY = false, false, false, false, false, false, false, false, false, fasle, false, false, false, false, false
    local dfgrange = 750
    local hxgrange = 750 
    local bwcrange = 500
    local range = 750
		local tsrange = 750

function OnLoad()
  PrintChat(">> ItemActive 1.2 Loaded!")
  PrintChat(">> SpaceBar is Activator.")
	PrintChat(">> C Button turns DFG On/Off.")
	PrintChat(">> Script made by SilentMan")
    IAConfig = scriptConfig("Auto Item", "AutoItems")
    IAConfig:addParam("dfg", "dfg first", SCRIPT_PARAM_ONKEYTOGGLE, false, 67) -- C is Toggle--
    IAConfig:addParam("AllItems", "Active All", SCRIPT_PARAM_ONKEYDOWN, false, 32) --spacebar ftw--
    IAConfig:addParam("drawranges", "Draw Active Ranges", SCRIPT_PARAM_ONOFF, true)
    
    
ts = TargetSelector(TARGET_LOW_HP,750,DAMAGE_MAGIC)
ts.name = myHero.name
end


    function OnTick()
            ts:update()
            DFGSlot, HXGSlot, BWCSlot, YGSlot, BoRKSlot, QSSlot, MSSlot, RHSlot, MKSlot, OmenSlot, SESlot, SRSlot, SoTDSlot, TSSlot, ZHSlot, BTSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3142), GetInventorySlotItem(3153), GetInventorySlotItem(3140),
            GetInventorySlotItem(3139), GetInventorySlotItem(3074),
            GetInventorySlotItem(3222), GetInventorySlotItem(3143), GetInventorySlotItem(3040), GetInventorySlotItem(3069), GetInventorySlotItem(3131), GetInventorySlotItem(3023), GetInventorySlotItem(3157), GetInventorySlotItem(3188)
            
            DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
            HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
            BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
            YGSREADY = (YGSSlot ~= nil and myHero:CanUseSpell(YGSlot) == READY)
            BoRKREADY = (BoRKSlot ~= nil and myHero:CanUseSpell(BoRKSlot) == READY)
            QSREADY = (QSSlot ~= nil and myHero:CanUseSpell(QSSlot) == READY)
            MSREADY = (MSSlot ~= nil and myHero:CanUseSpell(MSSlot) == READY)
            RHREADY = (RHSlot ~= nil and myHero:CanUseSpell(RHSlot) == READY)
            MKREADY = (MKSlot ~= nil and myHero:CanUseSpell(MKSlot) == READY)
            OmenREADY = (OmenSlot ~= nil and myHero:CanUseSpell(OmenSlot) == READY)
            SEREADY = (SESlot ~= nil and myHero:CanUseSpell(SESlot) == READY)
            SRREADY = (SRSlot ~= nil and myHero:CanUseSpell(SRSlot) == READY)
            SoTDREADY = (SoTDSlot ~= nil and myHero:CanUseSpell(SoTDSlot) == READY)
            TSREADY = (TSSlot ~= nil and myHero:CanUseSpell(TSSlot) == READY)
            ZHREADY = (ZHSlot ~= nil and myHero:CanUseSpell(ZHSlot) == READY)
            BTREADY = (BTSlot ~= nil and myHero:CanUseSpell(BTSLOT) == READY)
 if not myHero.dead then
    if IAConfig.AllItems then
      if ZHREADY and myHero.health <= myHero.maxHealth*0.25 then CastSpell(ZHSlot) end
      if SEREADY and myHero.health <= myHero.maxHealth*0.25 then CastSpell(SESlot) end
      if OmenREADY then CastSpell(OmenSlot) end
      if SoTDREADY then CastSpell(SoTD) end
      if QSREADY and myHero.isCharmed or myHero.isAsleep or myHero.isTaunted or myHero.isFeared or myHero.canMove == false then CastSpell(QSSlot) end
      if MSREADY and myHero.isCharmed or myHero.isAsleep or myHero.isTaunted or myHero.isFeared or myHero.canMove == false then CastSpell(MSSlot) end
      if MKREADY and myHero.isCharmed or myHero.isAsleep or myHero.isTaunted or myHero.isFeared or myHero.canMove == false then CastSpell(MKSlot) end
      if RHREADY then CastSpell(RHSlot) end
      if SRREADY then CastSpell(SRSlot) end
      if TSREADY then CastSpell(TSSlot) end
			end
			if IAConfig.AllItems and ts.target then
      if IAConfig.dfg == true and DFGREADY then CastSpell(DFGSlot, ts.target) end
      if HXGREADY then CastSpell(HXGSlot, ts.target) end
      if BWCREADY then CastSpell(BWCSlot, ts.target) end
      if BoRKREADY then CastSpell(BoRKSlot, ts.target) end
      if BTREADY then CastSpell(BTSlot, ts.target) end

 end
 end
end


 

--[[function CountEnemyHeroInRange(range)
 --   local enemyInRange = 0
  --  for i = 1, heroManager.iCount, 1 do
 --       local hero = heroManager:getHero(i)
 --       if ValidTarget(hero, range) then
  --          enemyInRange = enemyInRange + 1
 --       end
--    end
 --   return enemyInRange
end]]--

function OnDraw()
  if not myHero.dead and IAConfig.drawranges == true then
    DrawCircle(player.x, player.y, player.z, 450, 0x00FF00)
    DrawCircle(player.x, player.y, player.z, 750, 0x00FF00)
  end
end