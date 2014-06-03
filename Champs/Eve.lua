    --[[
            Evelynn Combo 1.6 by burn
            updated season 3 items
            Auto farm lag fixed and MEC requirement removed by HeX
     
            -Full combo: Items -> R -> E -> Q
            -Supports Deathfire Grasp, Bilgewater Cutlass, Hextech Gunblade, Sheen, Trinity, Lich Bane, Ignite, Iceborn, Liandrys and Blackfire
            -Mark killable target with a combo
            -Target configuration, Press shift to configure
            -Option to auto ignite when enemy is killable (this affect also for damage calculation)
            -MEC calculation for Ulti
            -C toogle auto farm
            -Harass with Q
     
            Explanation of the marks:
     
            Green circle: Marks the current target to which you will do the combo
            Blue circle: Mark a target that can be killed with a combo, if all the skills were available
            Red circle: Mark a target that can be killed using Items + 2 hit + R + E + Q x3 + ignite
            2 Red circles: Mark a target that can be killed using Items + 1 hit + R + E + Q x2 + ignite
            3 Red circles: Mark a target that can be killed using Items (without Sheen, Trinity and Lich Bane) + R + E + Q
    ]]
    if myHero.charName ~= "Evelynn" then return end
    --[[            Code            ]]
    local myObjectsTable = {}
    local range = 600
    local tick = nil
    -- draw
    local waittxt = {}
    local calculationenemy = 1
    local floattext = {"Skills are not available","Able to fight","Killable","Murder him!"}
    local killable = {}
    -- ts
    local ts
    --
    local ignite = nil
    local DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = nil, nil, nil, nil, nil, nil
    local QREADY, EREADY, RREADY, DFGREADY, HXGREADY, BWCREADY, IREADY = false, false, false, false, false, false, false
     
    function OnLoad()
            PrintChat(">> Evelynn Combo 1.6 loaded!")
            EvelynnConfig = scriptConfig("Evelynn Combo", "evelynncombo")
            EvelynnConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
            EvelynnConfig:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, 88) --x
            EvelynnConfig:addParam("autoFarm", "Auto Farm", SCRIPT_PARAM_ONKEYTOGGLE, false, 67) --c
            EvelynnConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
            EvelynnConfig:addParam("drawtext", "Draw Text", SCRIPT_PARAM_ONOFF, true)
            EvelynnConfig:addParam("autoignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, false)
            EvelynnConfig:permaShow("autoFarm")
            EvelynnConfig:permaShow("harass")
            ts = TargetSelector(TARGET_LOW_HP,range+50,DAMAGE_MAGIC)
            ts.name = "Evelynn"
            EvelynnConfig:addTS(ts)
            if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
            elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
            for i=1, heroManager.iCount do waittxt[i] = i*3 end
           
            for i = 0, objManager.maxObjects, 1 do
                    local object = objManager:GetObject(i)
                    if objectIsValid(object) then table.insert(myObjectsTable, object) end
            end
    end
     
    function objectIsValid(object)
       return object and object.valid and string.find(object.name,"Minion_") ~= nil and object.team ~= myHero.team and object.dead == false
    end
     
    function OnTick()
            ts:update()
            DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
            IcebornSlot, LiandrysSlot, BlackfireSlot = GetInventorySlotItem(3025), GetInventorySlotItem(3151), GetInventorySlotItem(3188)
            QREADY = (myHero:CanUseSpell(_Q) == READY)
            EREADY = (myHero:CanUseSpell(_E) == READY)
            RREADY = (myHero:CanUseSpell(_R) == READY)
            DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
            HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
            BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
            IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
            if tick == nil or GetTickCount()-tick > 150 then
                    tick = GetTickCount()
                    DmgCalculation()
            end
            if EvelynnConfig.harass and ts.target and myHero:GetDistance(ts.target) < 500 then
                    if QREADY then CastSpell(_Q, ts.target) end
            end    
            if EvelynnConfig.scriptActive and ts.target then
                    if DFGREADY then CastSpell(DFGSlot, ts.target) end
                    if HXGREADY then CastSpell(HXGSlot, ts.target) end
                    if BWCREADY then CastSpell(BWCSlot, ts.target) end
                    if RREADY then CastSpell(_R, ts.target) end
                    if EREADY then CastSpell(_E, ts.target) end
                    if QREADY then CastSpell(_Q, ts.target) end
            end
            if EvelynnConfig.autoFarm and QREADY then
                    local myQ = math.floor((myHero:GetSpellData(_Q).level-1)*20 + 40 + myHero.ap * .4)
                            for i,object in ipairs(myObjectsTable) do
                                    if objectIsValid(object) and object.health <= myHero:CalcDamage(object, myQ) and myHero:GetDistance(object) < 500 then
                                                    CastSpell(_Q, object)
                                            else
                                    end
                            end
            end
     
            if EvelynnConfig.autoignite then       
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
     
    function DmgCalculation()
            local enemy = heroManager:GetHero(calculationenemy)
            if ValidTarget(enemy) then
                    local dfgdamage, hxgdamage, bwcdamage, ignitedamage, Sheendamage, Trinitydamage, LichBanedamage  = 0, 0, 0, 0, 0, 0, 0
                    local qdamage = getDmg("Q",enemy,myHero)
                    local edamage = getDmg("E",enemy,myHero)
                    local rdamage = getDmg("R",enemy,myHero)
                    local hitdamage = getDmg("AD",enemy,myHero)
                    local dfgdamage = (DFGSlot and getDmg("DFG",enemy,myHero) or 0)
                    local hxgdamage = (HXGSlot and getDmg("HXG",enemy,myHero) or 0)
                    local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)
                    local ignitedamage = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
                    local onhitdmg = (SheenSlot and getDmg("SHEEN",enemy,myHero) or 0)+(TrinitySlot and getDmg("TRINITY",enemy,myHero) or 0)+(LichBaneSlot and getDmg("LICHBANE",enemy,myHero) or 0)+(IcebornSlot and getDmg("ICEBORN",enemy,myHero) or 0)                                                 
                    local onspelldamage = (LiandrysSlot and getDmg("LIANDRYS",enemy,myHero) or 0)+(BlackfireSlot and getDmg("BLACKFIRE",enemy,myHero) or 0)
                    local combo1 = qdamage*3 + edamage + rdamage + onspelldamage --0 cd
                    local combo2 = onspelldamage
                    local combo3 = onspelldamage
                    local combo4 = onspelldamage
                    if QREADY then
                            combo2 = combo2 + qdamage*3
                            combo3 = combo3 + qdamage*2
                            combo4 = combo4 + qdamage
                    end
                    if EREADY then
                            combo2 = combo2 + edamage
                            combo3 = combo3 + edamage
                            combo4 = combo4 + edamage
                    end
                    if RREADY then
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
                            combo1 = combo1*1.2 + dfgdamage            
                            combo2 = combo2*1.2 + dfgdamage
                            combo3 = combo3*1.2 + dfgdamage
                            combo4 = combo4*1.2 + dfgdamage
                    end
                    if IREADY and EvelynnConfig.autoignite then
                            combo1 = combo1 + ignitedamage
                            combo2 = combo2 + ignitedamage
                            combo3 = combo3 + ignitedamage
                    end
                    combo1 = combo1 + hitdamage*2 + onhitdmg    
                    combo2 = combo2 + hitdamage*2 + onhitdmg
                    combo3 = combo3 + hitdamage + onhitdmg         
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
     
    function OnCreateObj(object)
       if objectIsValid(object) then table.insert(myObjectsTable, object) end
    end
     
    function OnDraw()
            if EvelynnConfig.drawcircles and not myHero.dead then
                    DrawCircle(myHero.x, myHero.y, myHero.z, range, 0xFF00CC) --R range
                    DrawCircle(myHero.x, myHero.y, myHero.z, 500, 0x9966CC) --Q range
                    DrawCircle(myHero.x, myHero.y, myHero.z, 290, 0x33FFCC) --E range
                    if ts.target ~= nil then
                            for j=0, 10 do
                                    DrawCircle(ts.target.x, ts.target.y, ts.target.z, 40 + j*1.5, 0x00FF00)
                            end
                    end
            end
            for i=1, heroManager.iCount do
                    local enemydraw = heroManager:GetHero(i)
                    if ValidTarget(enemydraw) then
                            if EvelynnConfig.drawcircles then
                                    if killable[i] == 1 then
                                            for j=0, 20 do
                                                    DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0x0000FF)
                                            end
                                    elseif killable[i] == 2 then
                                            for j=0, 10 do
                                                    DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
                                            end
                                    elseif killable[i] == 3 then
                                            for j=0, 10 do
                                                    DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
                                                    DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + j*1.5, 0xFF0000)
                                            end
                                    elseif killable[i] == 4 then
                                            for j=0, 10 do
                                                    DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
                                                    DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + j*1.5, 0xFF0000)
                                                    DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 140 + j*1.5, 0xFF0000)
                                            end
                                    end
                            end
                            if EvelynnConfig.drawtext and waittxt[i] == 1 and killable[i] ~= 0 then
                                    PrintFloatText(enemydraw,0,floattext[killable[i]])
                            end
                    end
                    if waittxt[i] == 1 then waittxt[i] = 30
                    else waittxt[i] = waittxt[i]-1 end
            end
    end