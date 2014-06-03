        --[[
                Master Yi Combo 1.6 by burn
                updated season 3
         
                -Full combo: Items -> R -> Q -> E
                -Supports Deathfire Grasp, Bilgewater Cutlass, Hextech Gunblade, Sheen, Trinity, Lich Bane, Ignite, Iceborn, Liandrys, Blackfire, || Ravenous Hydra, EXEC, YOGH, RANO and BRK (this part only item activation)
                -Mark killable target with a combo
                -Target configuration, Press shift to configure
                -Mana managament system
                -Option to auto ignite when enemy is killable (this affect also for damage calculation)
                            -Option to Auto R-Q on killable enemy
         
                Explanation of the marks:
         
                Green circle: Marks the current target to which you will do the combo
                Blue circle: Mark a target that can be killed with a combo, if all the skills were available
                Red circle: Mark a target that can be killed using Items + 10 hits + Q x2 + ignite
                2 Red circles: Mark a target that can be killed using Items + 5 hit + Q + ignite
                3 Red circles: Mark a target that can be killed using Items (without Sheen, Trinity and Lich Bane) + Q + ignite
        ]]
        if myHero.charName ~= "MasterYi" then return end      
        --[[            Code            ]]
        local range = 600
        local tick = nil
            local WujuStyleActive = false
            local UltimateActive = false
        -- draw
        local waittxt = {}
        local calculationenemy = 1
        local floattext = {"Skills are not available","Able to fight","Killable","Murder him!"}
        local killable = {}
        -- ts
        local ts
        --
        local ignite = nil
        local WeHaveMana = false
        local DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot, YomumusGhostbladeSlot = nil, nil, nil, nil, nil, nil, nil
        local QREADY, EREADY, RREADY, DFGREADY, HXGREADY, BWCREADY, IREADY, YomumusGhostbladeReady = false, false, false, false, false, false, false, false
         
        function OnLoad()
                PrintChat(">> MasterYi Combo 1.6 loaded!")
                MYiConfig = scriptConfig("Master Yi Combo", "yicombo")
                MYiConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
                MYiConfig:addParam("drawcircles", "Draw Range", SCRIPT_PARAM_ONOFF, true)
                MYiConfig:addParam("drawenemy", "Draw Enemy Circles", SCRIPT_PARAM_ONOFF, false)
                MYiConfig:addParam("drawtext", "Draw Text", SCRIPT_PARAM_ONOFF, true)
                MYiConfig:addParam("autoignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
                MYiConfig:addParam("autoQ", "Auto Q KS on killable enemy", SCRIPT_PARAM_ONOFF, true)
                MYiConfig:permaShow("scriptActive")
                ts = TargetSelector(TARGET_LOW_HP,range+100,DAMAGE_MAGIC,false)
                ts.name = "MasterYi"
                MYiConfig:addTS(ts)
                if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
                elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
                for i=1, heroManager.iCount do waittxt[i] = i*3 end
        end
         
        function OnTick()
                ts:update()
                DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot, YomumusGhostbladeSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100), GetInventorySlotItem(3142)
                            EXECSlot = GetInventorySlotItem(3123)
                            RANOSlot = GetInventorySlotItem(3143)
                            BRKSlot = GetInventorySlotItem(3153)
                            RavenousHydraSlot = GetInventorySlotItem(3074)
                            IcebornSlot, LiandrysSlot, BlackfireSlot = GetInventorySlotItem(3025), GetInventorySlotItem(3151), GetInventorySlotItem(3188)
                            --
                QREADY = (myHero:CanUseSpell(_Q) == READY)
                EREADY = (myHero:CanUseSpell(_E) == READY)
                RREADY = (myHero:CanUseSpell(_R) == READY)
                DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
                HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
                BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
                            YomumusGhostbladeReady = (YomumusGhostbladeSlot ~= nil and myHero:CanUseSpell(YomumusGhostbladeSlot) == READY)
                            EXECReady = (EXECSlot ~= nil and myHero:CanUseSpell(EXECSlot) == READY)
                            RANOReady = (RANOSlot ~= nil and myHero:CanUseSpell(RANOSlot) == READY)
                            BRKReady = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
                            RavHydraReady = (RavenousHydraSlot ~= nil and myHero:CanUseSpell(RavenousHydraSlot) == READY)                  
                IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
                if tick == nil or GetTickCount()-tick >= 100 then
                        tick = GetTickCount()
                        YiDmgCalculation()
                end
                            if MYiConfig.autoQ and ts.target and QREADY then
                                            --mana check managament:
                        local SpellDataQ2 = myHero:GetSpellData(_Q)
                        local totalCost2 = 100 + (60+10*SpellDataQ2.level) --total cost of mana necessary to do a R+Q
                        if myHero.mana >= totalCost2 then
                                WeHaveMana2 = true
                        else
                                WeHaveMana2 = false
                        end
                                            --end mana check
                                            local qdmg = getDmg("Q",ts.target,myHero)
                        if WeHaveMana2 and QREADY and ts.target.health < qdmg then
                                if RREADY and not UltimateActive and GetDistance(ts.target) <= (range-100) then CastSpell(_R) end
                                if GetDistance(ts.target) <= (range-100) then CastSpell(_Q, ts.target) end
                        end
                                            if not WeHaveMana2 and QREADY and ts.target.health < qdmg then
                                if GetDistance(ts.target) <= (range-100) then CastSpell(_Q, ts.target) end
                        end                        
                            end
                if MYiConfig.scriptActive and ts.target then
                --mana check managament:
                        local SpellDataQ = myHero:GetSpellData(_Q)
                        local totalCost = 100 + (60+10*SpellDataQ.level) --total cost of mana necessary to do a R+Q
                        if myHero.mana >= totalCost then
                                WeHaveMana = true
                        else
                                WeHaveMana = false
                        end
                --end mana check
                        if DFGREADY then CastSpell(DFGSlot, ts.target) end
                                            if YomumusGhostbladeReady then CastSpell(YomumusGhostbladeSlot, ts.target) end
                                            if EXECReady then CastSpell(EXECSlot, ts.target) end
                                            if BRKReady then CastSpell(BRKSlot, ts.target) end
                                            if RavHydraReady then CastSpell(RavenousHydraSlot, ts.target) end
                                            if RANOReady then CastSpell(RANOSlot, ts.target) end                                   
                        if HXGREADY then CastSpell(HXGSlot, ts.target) end
                        if BWCREADY then CastSpell(BWCSlot, ts.target) end
                        if WeHaveMana then
                                if RREADY and QREADY and not UltimateActive then CastSpell(_R) end --QREADY for avoid use only ultimate if Q is on Cooldown
                                if QREADY and GetDistance(ts.target) <= range then CastSpell(_Q, ts.target) end
                        else
                                if QREADY and GetDistance(ts.target) <= range then CastSpell(_Q, ts.target) end
                        end
                        if EREADY and not WujuStyleActive then CastSpell(_E) end
                        myHero:Attack(ts.target)
                end
                if MYiConfig.autoignite then  
                        if IREADY then
                                local ignitedmg = 0    
                                for j = 1, heroManager.iCount, 1 do
                                        local enemyhero = heroManager:getHero(j)
                                        if ValidTarget(enemyhero,600) then
                                                ignitedmg = 50 + 20 * myHero.level
                                                if enemyhero.health <= ignitedmg then
                                                        CastSpell(ignite, enemyhero)
                                                end
                                        end
                                end
                        end
                end
        end
        function YiDmgCalculation()
                local enemy = heroManager:GetHero(calculationenemy)
                if ValidTarget(enemy) then
                        local dfgdamage, hxgdamage, bwcdamage, ignitedamage, Sheendamage, Trinitydamage, LichBanedamage  = 0, 0, 0, 0, 0, 0, 0
                        local qdamage = getDmg("Q",enemy,myHero)
                        local hitdamage = getDmg("AD",enemy,myHero)
                        local dfgdamage = (DFGSlot and getDmg("DFG",enemy,myHero) or 0)
                        local hxgdamage = (HXGSlot and getDmg("HXG",enemy,myHero) or 0)
                        local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)
                        local ignitedamage = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
                                            local onhitdmg = (SheenSlot and getDmg("SHEEN",enemy,myHero) or 0)+(TrinitySlot and getDmg("TRINITY",enemy,myHero) or 0)+(LichBaneSlot and getDmg("LICHBANE",enemy,myHero) or 0)+(IcebornSlot and getDmg("ICEBORN",enemy,myHero) or 0)
                        local onspelldamage = (LiandrysSlot and getDmg("LIANDRYS",enemy,myHero) or 0)+(BlackfireSlot and getDmg("BLACKFIRE",enemy,myHero) or 0)
                                            local combo1 = qdamage*2 + onspelldamage
                        local combo2 = onspelldamage
                        local combo3 = onspelldamage
                        local combo4 = onspelldamage
                        if QREADY then
                                combo2 = combo2 + qdamage*2
                                combo3 = combo3 + qdamage
                                combo4 = combo4 + qdamage
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
                                combo1 = combo1*1.2 + dfgdamage            
                                combo2 = combo2*1.2 + dfgdamage
                                combo3 = combo3*1.2 + dfgdamage
                                combo4 = combo4*1.2 + dfgdamage
                        end                                
                        if IREADY and MYiConfig.autoignite then
                                combo1 = combo1 + ignitedamage
                                combo2 = combo2 + ignitedamage
                                combo3 = combo3 + ignitedamage
                                combo4 = combo4 + ignitedamage
                        end
                        combo1 = combo1 + hitdamage*10 + onhitdmg    
                        combo2 = combo2 + hitdamage*10 + onhitdmg
                        combo3 = combo3 + hitdamage*5 + onhitdmg   
                        if combo4 >= enemy.health then killable[calculationenemy] = 4
                        elseif combo3 >= enemy.health then killable[calculationenemy] = 3
                        elseif combo2 >= enemy.health then killable[calculationenemy] = 2
                        elseif combo1 >= enemy.health then killable[calculationenemy] = 1
                        else killable[calculationenemy] = 0 end
                end
                if calculationenemy == 1 then
                        calculationenemy = heroManager.iCount
                else
                        calculationenemy = calculationenemy-1
                end
        end
        function OnDraw()
                if MYiConfig.drawcircles and not myHero.dead then
                        DrawCircle(myHero.x, myHero.y, myHero.z, range, 0x19A712)
                        if ts.target ~= nil then
                            DrawCircle(ts.target.x, ts.target.y, ts.target.z, 50, 0x00FF00)
                        end
                end
                for i=1, heroManager.iCount do
                        local enemydraw = heroManager:GetHero(i)
                        if ValidTarget(enemydraw) then
                                if MYiConfig.drawenemy then
                                        if killable[i] == 1 then
                                                DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80, 0x0000FF)
                                        elseif killable[i] == 2 then
                              
                                                DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80, 0xFF0000)
                                        elseif killable[i] == 3 then
												DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80, 0xFF0000)
												DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110, 0xFF0000)
                                        elseif killable[i] == 4 then
                                                DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80, 0xFF0000)
                                                DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110, 0xFF0000)
                                                DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 140, 0xFF0000)
                                        end
                                end
                                if MYiConfig.drawtext and waittxt[i] == 1 and killable[i] ~= 0 then
                                        PrintFloatText(enemydraw,0,floattext[killable[i]])
                                end
                        end
                        if waittxt[i] == 1 then waittxt[i] = 30
                        else waittxt[i] = waittxt[i]-1 end
                end
        end
           
            function OnCreateObj(object)
                    if object.name == "WujustyleSC_buf.troy" then WujuStyleActive = true end
                    if object.name == "Highlander_buf.troy" then UltimateActive = true end
            end
     
            function OnDeleteObj(object)
                    if object.name == "WujustyleSC_buf.troy" then WujuStyleActive = false end
                    if object.name == "Highlander_buf.troy" then UltimateActive = false end
            end
