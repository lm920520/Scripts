-- Diana v1.1a - Moonraker edition

if myHero.charName ~= "Diana" then return end
--[[   Vars  ]] --
local thetaIterator = 4 --increase to improve performance (0 - 10)
local rangeIterator = 30 --increase to improve performance (from 0-100)
local roundRange = 100 --higher means more minions collected, but possibly less accurate.

local qPred
local ts
local tp

local aaRange = 400
local wRange = 250
local eRange = 410
local eBuffer = 225
local rRange = 760

--[[    Moonlight       ]] --
local MoonLightEnemy = {}
local MoonLightTS = 0
local MoonLight = false
--[[    Damage Calculation      ]] --
local waittxt = {}
local calculationenemy = 1
local floattext = { "Skills are not available", "Able to fight", "Killable", "Murder him!" }
local killable = {}

--[[    Ready   ]] --
local ignite
local QREADY, WREADY, EREADY, RREADY = false, false, false, false
local BRKSlot, DFGSlot, HXGSlot, BWCSlot, TMTSlot, RAHSlot, RNDSlot, YGBSlot
local BRKREADY, DFGREADY, HXGREADY, BWCREADY, TMTREADY, RAHREADY, RNDREADY, YGBREADY, IREADY = false, false, false, false, false, false, false, false, false


--------------------------
--[[  Q Calculations  ]] --
local rangeMax = 830
local enemyMinions = {}
local accel = -1483
local highestCollision
local highestAngle
local highestRange
local MODE_MINION = 1
local MODE_CHAMP = 2
--------------------------
--[[    Prediction      ]] --
local AttackDelayLatency = 1000
local lastBasicAttack = 0
local swingDelay = 1000
local HitBoxSize = GetDistance(myHero.minBBox)
local shotFired = false
local animationEnd = true
local animationTimer = 0
local mainTimer = GetTickCount()
local rtarget


if VIP_USER then
    tp = TargetPredictionVIP(rangeMax, 1800, 0.25, 10)
else
    tp = TargetPrediction(rangeMax, 1800, 250)
end

function OnLoad()
    enemyMinions = minionManager(MINION_ENEMY, rangeMax, player, MINION_SORT_HEALTH_ASC)

    DCConfig = scriptConfig("Diana Combo", "DianaCombo")
    DCConfig:addParam("BurstCombo", "Quick Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    DCConfig:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
    DCConfig:addParam("autoMinion", "Q Minions", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
    DCConfig:addParam("orbWalk", "Orb Walk", SCRIPT_PARAM_ONOFF, true)
    DCConfig:addParam("autoignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
    DCConfig:addParam("ultKS", "Ultimate KS", SCRIPT_PARAM_ONOFF, false)
    DCConfig:addParam("useE", "E in Combo", SCRIPT_PARAM_ONOFF, true)
    DCConfig:addParam("drawcirclesSelf", "Draw Circles - Self", SCRIPT_PARAM_ONOFF, true)
    DCConfig:addParam("drawcirclesEnemy", "Draw Circles - Enemy", SCRIPT_PARAM_ONOFF, true)
    DCConfig:addParam("drawText", "Draw Text - Enemy", SCRIPT_PARAM_ONOFF, true)
    DCConfig:permaShow("BurstCombo")
    DCConfig:permaShow("Harass")

    ts = TargetSelector(TARGET_LOW_HP, rangeMax + 100, DAMAGE_MAGIC)
    ts.name = "Diana"
    DCConfig:addTS(ts)

    for i = 1, heroManager.iCount do
        MoonLightEnemy[i] = 0
        waittxt[i] = i * 3
    end

    if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2
    end
end

function OnTick()
    if GetTickCount() - animationTimer > AttackDelayLatency then
        animationEnd = false
    end
    AttackDelayLatency = ((1000 * (-0.435 + (0.625 / 0.625))) / (myHero.attackSpeed / (1 / 0.625))) - GetLatency() * 2

    ts:update()

    ReadyCheck()
    if ts.target then
        qPred = tp:GetPrediction(ts.target)
    end

    if DCConfig.autoMinion then
        enemyMinions:update()
        CrescentCollision(MODE_MINION)
        if highestCollision > 0 and highestRange > 0 then
            CastSpell(_Q, myHero.x + highestRange * math.cos(highestAngle), myHero.z + highestRange * math.sin(highestAngle))
        elseif #enemyMinions.objects == 1 then
            CastSpell(_Q, enemyMinions.objects[1].x, enemyMinions.objects[1].z)
        end
    end



    if ts.index ~= nil then MoonLightTS = MoonLightEnemy[ts.index] end

    if DCConfig.BurstCombo and ts.target then
        UseItems(ts.target)
        CrescentCollision(MODE_CHAMP)
        BurstCombo(ts.target)
    elseif DCConfig.BurstCombo and heroCanMove() and DCConfig.orbWalk then
        myHero:MoveTo(mousePos.x, mousePos.z)
    end
    --[[    Harass  ]] --
    if DCConfig.Harass and ts.target then
        Harass(ts.target)
    end
    --[[    Ignite  ]] --
    if DCConfig.autoignite then
        AutoIgnite()
    end
    if DCConfig.ultKS and RREADY then
        ultKillSteal()
    end
end

function attackedSuccessfully()
    shotFired = false
    lastBasicAttack = GetTickCount()
end

function attackEnemy(enemy)
    if enemy.dead or not enemy.valid then return end
    myHero:Attack(enemy)
    shotFired = true
end

function moveToCursor()
    local moveSqr = math.sqrt((mousePos.x - myHero.x) ^ 2 + (mousePos.z - myHero.z) ^ 2)
    local moveX = myHero.x + 300 * ((mousePos.x - myHero.x) / moveSqr)
    local moveZ = myHero.z + 300 * ((mousePos.z - myHero.z) / moveSqr)
    myHero:MoveTo(moveX, moveZ)
end

function heroCanMove()
    return (timeToShoot() or (not shotFired and GetTickCount() - lastBasicAttack > AttackDelayLatency / 2))
end

function timeToShoot()
    return (GetTickCount() > lastBasicAttack + AttackDelayLatency)
end

function isEnemyInAttackRange(enemy)
    local enemyTrueDistance
    if enemy ~= nil then
        if getDistanceOffset(enemy) > 0 then
            enemyTrueDistance = GetDistance(enemy) + getDistanceOffset(enemy) - getHitBoxRadius(enemy)
        else
            enemyTrueDistance = GetDistance(enemy) - getHitBoxRadius(enemy)
        end
        return (enemyTrueDistance < getMyTrueRange())
    end
end

function getDistanceOffset(enemy)
    local distance = GetDistance(enemy) - getHitBoxRadius(enemy) + 60
    if distance > getMyTrueRange() then return 0 end
    return distance / 9.85
end

function getHitBoxRadius(target)
    return GetDistance(target.maxBBox, target.minBBox) / 2
end

function getMyTrueRange()
    return getRange() + HitBoxSize
end

function getRange()
    return myHero.range
end



function OnDraw()
    if tick == nil or GetTickCount() - tick >= 100 then
        tick = GetTickCount()
        DmgCalculation()
    end
    if DCConfig.drawcirclesSelf and not myHero.dead then
        if QREADY then DrawCircle(myHero.x, myHero.y, myHero.z, 900, 0xFF0000) end
        if EREADY then DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0x00CCCC) end
    end
    if DCConfig.drawcirclesEnemy and ts.target ~= nil then
        for j = 0, 10 do
            DrawCircle(ts.target.x, ts.target.y, ts.target.z, 40 + j * 1.5, 0x00FF00)
        end
    end
    for i = 1, heroManager.iCount do
        local enemydraw = heroManager:GetHero(i)
        if ValidTarget(enemydraw) then
            if DCConfig.drawcirclesEnemy then
                if killable[i] == 1 then
                    for j = 0, 20 do
                        DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j * 1.5, 0x0000FF)
                    end
                elseif killable[i] == 2 then
                    for j = 0, 10 do
                        DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j * 1.5, 0xFF0000)
                    end
                elseif killable[i] == 3 then
                    for j = 0, 10 do
                        DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j * 1.5, 0xFF0000)
                        DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + j * 1.5, 0xFF0000)
                    end
                elseif killable[i] == 4 then
                    for j = 0, 10 do
                        DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j * 1.5, 0xFF0000)
                        DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + j * 1.5, 0xFF0000)
                        DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 140 + j * 1.5, 0xFF0000)
                    end
                end
            end
            if DCConfig.drawText and waittxt[i] == 1 and killable[i] ~= 0 then
                PrintFloatText(enemydraw, 0, floattext[killable[i]])
            end
        end
        if waittxt[i] == 1 then waittxt[i] = 30
        else waittxt[i] = waittxt[i] - 1
        end
    end
end

function CrescentCollision(mode)

    local targetOriginal = {}
    local targetArray = {}
    local tsTargetOriginal = {}
    local theta, tsTargetAngle, tsTarget, tsAngle, tsVo, tsTestZ
    local targetAngle, target, angle, vo, testZ
    local tsFlag = false
    highestCollision = 0
    highestAngle = 0
    highestRange = 0
    if mode == MODE_CHAMP then
        for i = 1, heroManager.iCount do
            local hero = heroManager:GetHero(i)
            if ValidTarget(hero, rangeMax) then
                local dis = tp:GetPrediction(hero)
                table.insert(targetArray, dis)
            end
        end
        if ts.target and qPred then
            tsTargetOriginal = Vector(qPred.x - myHero.x, myHero.y, qPred.z - myHero.z)
            tsTargetAngle = tsTargetOriginal:polar()
        end
    elseif mode == MODE_MINION then
        targetArray = enemyMinions.objects
    end

    if #targetArray > 1 and QREADY then
        local rightTheta, leftTheta = GetBoundingVectors(targetArray)
        for newTheta = rightTheta, leftTheta, thetaIterator do --increase theta
            theta = math.rad(newTheta)

            for range = 400, rangeMax, rangeIterator do --increase range
                if highestCollision < #targetArray then
                    local collisionCount = 0
                    if mode == MODE_CHAMP and ts.target and qPred then --prioritize ts.target
                        tsTargetOriginal = Vector(qPred.x - myHero.x, myHero.y, qPred.z - myHero.z)
                        tsTarget = tsTargetOriginal:rotated(0, theta, 0)
                        tsAngle = math.rad((-47) - (830 - range) / (-20)) --interpolate launch angle
                        tsVo = math.sqrt((range * accel) / math.sin(2 * tsAngle)) -- initial velocity
                        tsTestZ = math.tan(tsAngle) * tsTarget.x - (accel / (2 * tsVo ^ 2 * math.cos(tsAngle) ^ 2)) * tsTarget.x ^ 2
                        if math.abs(math.ceil(tsTestZ) - math.ceil(qPred.z)) <= roundRange then
                            tsFlag = true
                            collisionCount = collisionCount + 1
                        else
                            tsFlag = false
                        end
                    end
                    if mode == MODE_MINION or (tsFlag and mode == MODE_CHAMP) then --only search other champs if ts.target is a collision
                        for index, minions in pairs(targetArray) do --iterate over minion/champ array
                            if mode == MODE_MINION or minions.charName ~= ts.target.charName then
                                targetOriginal = Vector(minions.x - myHero.x, myHero.y, minions.z - myHero.z)
                                targetAngle = targetOriginal:polar()

                                if (targetAngle <= newTheta) and ((mode ~= MODE_CHAMP) or (tsTargetAngle and tsTargetAngle <= newTheta)) then --angle of theta must be greater than target
                                    target = targetOriginal:rotated(0, theta, 0) --rotate to neutral axis
                                    angle = math.rad((-47) - (830 - range) / (-20)) --interpolate launch angle
                                    vo = math.sqrt((range * accel) / math.sin(2 * angle)) -- initial velocity
                                    testZ = math.tan(angle) * target.x - (accel / (2 * vo ^ 2 * math.cos(angle) ^ 2)) * target.x ^ 2

                                    if math.abs(math.ceil(testZ) - math.ceil(target.z)) <= roundRange then --compensate for rounding
                                        --collision detected
                                        collisionCount = collisionCount + 1
                                    end

                                    if collisionCount > highestCollision then
                                        highestCollision = collisionCount
                                        highestAngle = theta --in radians
                                        highestRange = range
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function AutoIgnite()
    if IREADY then
        local ignitedmg = 0
        for i = 1, heroManager.iCount, 1 do
            local enemyhero = heroManager:getHero(i)
            if ValidTarget(enemyhero, 600) then
                ignitedmg = 50 + 20 * myHero.level
                if enemyhero.health <= ignitedmg then
                    CastSpell(ignite, enemyhero)
                end
            end
        end
    end
end

function ultKillSteal()

    for i = 1, heroManager.iCount, 1 do
        local enemyhero = heroManager:getHero(i)
        if ValidTarget(enemyhero, rRange) then
            if enemyhero.health <= getDmg("R", enemyhero, myHero, 1) then
                CastSpell(_R, enemyhero)
            end
        end
    end
end

function ReadyCheck()
    BRKSlot, DFGSlot, HXGSlot, BWCSlot, TMTSlot, RAHSlot, RNDSlot, YGBSlot = GetInventorySlotItem(3153), GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3077), GetInventorySlotItem(3074), GetInventorySlotItem(3143), GetInventorySlotItem(3142)
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
    YGBREADY = (YGBSlot ~= nil and myHero:CanUseSpell(YGBSlot) == READY)
    IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
end

function UseItems(target)
    if GetDistance(target) < 550 then
        if DFGREADY then CastSpell(DFGSlot, target) end
        if HXGREADY then CastSpell(HXGSlot, target) end
        if BWCREADY then CastSpell(BWCSlot, target) end
        if BRKREADY then CastSpell(BRKSlot, target) end
        if YGBREADY then CastSpell(YGBSlot, target) end
        if TMTREADY and GetDistance(target) < 275 then CastSpell(TMTSlot) end
        if RAHREADY and GetDistance(target) < 275 then CastSpell(RAHSlot) end
        if RNDREADY and GetDistance(target) < 275 then CastSpell(RNDSlot) end
    end
end

function BurstCombo(target)
    if target and isEnemyInAttackRange(target) and DCConfig.orbWalk then
        if timeToShoot() or shotFired == true then
            attackEnemy(target)
        else
            if heroCanMove() and DCConfig.orbWalk then
                myHero:MoveTo(target.x, target.z)
            end
        end
    elseif heroCanMove() and DCConfig.orbWalk then
        if target then
            myHero:MoveTo(target.x, target.z)
        else
            myHero:MoveTo(mousePos.x, mousePos.z)
        end
    end

    if GetTickCount() - mainTimer < 49 then return end
    mainTimer = GetTickCount()

    if qPred ~= nil and QREADY and GetDistance(qPred) <= rangeMax then
        if (QREADY and RREADY) or (QREADY and not isEnemyInAttackRange(target)) or (QREADY and target.health < target.maxHealth * 0.3) then
            if highestCollision > 0 then
                CastSpell(_Q, myHero.x + highestRange * math.cos(highestAngle), myHero.z + highestRange * math.sin(highestAngle))
            else
                CastSpell(_Q, qPred.x, qPred.z)
            end
            myHero:Attack(target)
            if RREADY then
                QTick = GetTickCount()
            else
                QTick = nil
            end
            rtarget = target
        end
        myHero:Attack(target)
        QTick = GetTickCount()
        RDelay = (250 + (GetDistance(qPred) / 1.8))
    end
    if WREADY and GetDistance(target) <= wRange then
        CastSpell(_W)
    end
    if EREADY and GetDistance(target) > eBuffer and GetDistance(target) < eRange and DCConfig.useE then
        CastSpell(_E)
    end
    if GetDistance(target) <= aaRange and DCConfig.orbWalk == false then
        myHero:Attack(target)
    end

    if RREADY and rtarget and ValidTarget(rtarget, rRange) and QTick ~= nil then
        if GetTickCount() - QTick >= RDelay and MoonLight == false and GetTickCount() - QTick < 3000 - RDelay then
            CastSpell(_W)
            CastSpell(_R, rtarget)
            MoonLight = true
        end
    end
end

function Harass(target)

    if qPred and QREADY and GetDistance(qPred) <= rangeMax then
        CrescentCollision(MODE_CHAMP)
        if highestCollision > 0 then
            CastSpell(_Q, myHero.x + highestRange * math.cos(highestAngle), myHero.z + highestRange * math.sin(highestAngle))

        else
            CastSpell(_Q, qPred.x, qPred.z)
        end
    end
end

function OnCreateObj(Object)
    if Object.name:find("Diana_Q_moonlight_champ.troy") then
        for i = 1, heroManager.iCount do
            local enemy = heroManager:GetHero(i)
            if enemy.team ~= myHero.team and GetDistance(Object, enemy) < 50 then
                MoonLightEnemy[i] = true
            end
        end
    end
end

function OnProcessSpell(unit, spell)
    if unit.isMe and spell.name == "DianaArc" then MoonLight = false end
    if unit.isMe and (spell.name:find("Attack") ~= nil) then
        attackedSuccessfully()
    end
end

function OnDeleteObj(Object)
    if Object.name:find("Diana_Q_moonlight_champ.troy") then
        for i = 1, heroManager.iCount do
            local enemy = heroManager:GetHero(i)
            if enemy.team ~= myHero.team and GetDistance(Object, enemy) < 50 then
                MoonLightEnemy[i] = false
            end
        end
    end
end

function DmgCalculation()
    local enemy = heroManager:GetHero(calculationenemy)
    if ValidTarget(enemy) then
        local ignitedamage, dfgdamage, hxgdamage, bwcdamage, brkdamage, tmtdamage, rahdamage = 0, 0, 0, 0, 0, 0, 0
        local pdamage = getDmg("P", enemy, myHero)
        local qdamage = getDmg("Q", enemy, myHero)
        local wdamage = getDmg("W", enemy, myHero)
        local rdamage = getDmg("R", enemy, myHero, 1)
        local hitdamage = getDmg("AD", enemy, myHero)
        local ignitedamage = (ignite and getDmg("IGNITE", enemy, myHero) or 0)
        local dfgdamage = (DFGSlot and getDmg("DFG", enemy, myHero) or 0)
        local hxgdamage = (HXGSlot and getDmg("HXG", enemy, myHero) or 0)
        local bwcdamage = (BWCSlot and getDmg("BWC", enemy, myHero) or 0)
        local brkdamage = (BRKSlot and getDmg("RUINEDKING", enemy, myHero) or 0)
        local tmtdamage = (TMTSlot and getDmg("TIAMAT", enemy, myHero) or 0)
        local rahdamage = (RAHSlot and getDmg("HYDRA", enemy, myHero) or 0)
        local combo1 = hitdamage * 2 + pdamage + qdamage + wdamage + rdamage
        local combo2 = hitdamage * 2 + pdamage
        local combo3 = 0
        local combo4 = 0
        if QREADY then
            combo2 = combo2 + qdamage
            combo3 = combo3 + qdamage
            combo4 = combo4 + qdamage
        end
        if WREADY then
            combo2 = combo2 + wdamage
            combo3 = combo3 + wdamage
        end
        if RREADY then
            combo2 = combo2 + rdamage
            combo3 = combo3 + rdamage
            combo4 = combo4 + rdamage
        end
        if DFGREADY then
            combo1 = combo1 + dfgdamage
            combo2 = combo2 + dfgdamage
            combo3 = combo3 + dfgdamage
        end
        if HXGREADY then
            combo1 = combo1 + hxgdamage
            combo2 = combo2 + hxgdamage
            combo3 = combo3 + hxgdamage
        end
        if BWCREADY then
            combo1 = combo1 + bwcdamage
            combo2 = combo2 + bwcdamage
            combo3 = combo3 + bwcdamage
        end
        if BRKREADY then
            combo1 = combo1 + brkdamage
            combo2 = combo2 + brkdamage
            combo3 = combo3 + brkdamage
        end
        if TMTREADY then
            combo1 = combo1 + tmtdamage
            combo2 = combo2 + tmtdamage
            combo3 = combo3 + tmtdamage
        end
        if RAHREADY then
            combo1 = combo1 + rahdamage
            combo2 = combo2 + rahdamage
            combo3 = combo3 + rahdamage
        end
        if IREADY then
            combo1 = combo1 + ignitedamage
            combo2 = combo2 + ignitedamage
            combo3 = combo3 + ignitedamage
        end
        if combo4 >= enemy.health then killable[calculationenemy] = 4
        elseif combo3 >= enemy.health then killable[calculationenemy] = 3
        elseif combo2 >= enemy.health then killable[calculationenemy] = 2
        elseif combo1 >= enemy.health then killable[calculationenemy] = 1
        else killable[calculationenemy] = 0
        end
    end
    if calculationenemy == 1 then calculationenemy = heroManager.iCount
    else calculationenemy = calculationenemy - 1
    end
end

function areClockwise(testv1, testv2)
    return -testv1.x * testv2.z + testv1.z * testv2.x > 0 --true if v1 is clockwise to v2
end

function GetBoundingVectors(coneTargetsTable)

    --Build table of enemies in range
    local n = 1
    local v1, v2, v3 = 0, 0, 0
    local largeN, largeV1, largeV2 = 0, 0, 0
    local theta1, theta2 = 0, 0

    if #coneTargetsTable >= 2 then -- true if calculation is needed
        for i = 1, #coneTargetsTable, 1 do
            for j = 1, #coneTargetsTable, 1 do
                if i ~= j then
                    --Position vector from player to 2 different targets.
                    v1 = Vector(coneTargetsTable[i].x - myHero.x, myHero.y, coneTargetsTable[i].z - myHero.z)
                    v2 = Vector(coneTargetsTable[j].x - myHero.x, myHero.y, coneTargetsTable[j].z - myHero.z)

                    if #coneTargetsTable == 2 then --only 2 targets, the result is found.
                        largeV1 = v1
                        largeV2 = v2
                    else
                        --Determine # of vectors between v1 and v2
                        local tempN = 0
                        for k = 1, #coneTargetsTable, 1 do
                            if k ~= i and k ~= j then
                                --Build position vector of third target
                                v3 = Vector(coneTargetsTable[k].x - myHero.x, myHero.y, coneTargetsTable[k].z - myHero.z)
                                --For v3 to be between v1 and v2
                                --it must be clockwise to v1
                                --and counter-clockwise to v2
                                if areClockwise(v3, v1) and not areClockwise(v3, v2) then
                                    tempN = tempN + 1
                                end
                            end
                        end
                        if tempN > largeN then
                            --store the largest number of contained enemies
                            --and the bounding position vectors
                            largeN = tempN
                            largeV1 = v1
                            largeV2 = v2
                        end
                    end
                end
            end
        end
    end

    theta1 = largeV1:polar() - 20
    theta2 = largeV2:polar() + 20
    if theta2 < theta1 then
        theta1 = theta1 - 360
    end
    return theta1, theta2
end