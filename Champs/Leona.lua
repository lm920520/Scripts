-- ###################################################################################################### --
-- #                                         Leona- Chosen of the Sun                                   # --
-- #                                                 by mkc                                          	# --
-- ###################################################################################################### --


if myHero.charName ~= "Leona" then return end
-- [Settings]
local ts
local combokey = string.byte("T")
local ultkey = string.byte("Y")
--
local mRange = 125
local eRange = 700
local eSpeed = 2050
local rDelay = 10
--
local ep = TargetPrediction(eRange, eSpeed)


-- [Script Config]
function OnLoad()
	PrintChat("<font color='#CCCCCC'> >> Leona - Chosen of the Sun v,1.2 loaded! <<</font>")
	LeonaConfig = scriptConfig ('Leona - Chosen of the Sun', "mkcLeona")
	LeonaConfig:addParam ("scriptActive", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, combokey)
	LeonaConfig:addParam ("AutoUlt", "Auto Ultimate", SCRIPT_PARAM_ONKEYTOGGLE, false, ultkey)
	LeonaConfig:addParam ("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	LeonaConfig:permaShow ("scriptActive")
	LeonaConfig:permaShow ("AutoUlt")
	ts = TargetSelector(TARGET_LESS_CAST,1000,DAMAGE_MAGIC,false)
	ts.name = "Leona"
	LeonaConfig:addTS(ts)	
end	

-- [Combo]
function OnTick()
	ts:update()
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	teamFight()
	
	if ts.target ~= nil then
        ePred = ep:GetPrediction(ts.target)
        rPred = GetPredictionPos(ts.target, rDelay)
    end
end

function teamFight()
	if LeonaConfig.scriptActive then
		if ValidTarget(ts.target, rangeQ) then
			if rPred ~= nil then
					if RREADY and LeonaConfig.AutoUlt and GetDistance(ts.target) <= eRange then
						CastSpell(_R, rPred.x, rPred.z)
					end
				if EREADY and WREADY and GetDistance(ts.target)<=eRange then 
					CastSpell(_W)
					CastSpell(_E, ePred.x, ePred.z) 
				end
			end
		end
		
		if ValidTarget(ts.target, mRange) then
			if QREADY and GetDistance(ts.target) <= mRange then 
			CastSpell(_Q)
			myHero:Attack(ts.target)
			end
		end
	end
end

-- [Drawing Circles]
function OnDraw()
	if LeonaConfig.drawcircles and not myHero.dead then
		DrawCircle(myHero.x,myHero.y,myHero.z, mRange, 0xFFFF0000)
		DrawCircle(myHero.x,myHero.y,myHero.z, eRange, 0xFF80FF00)
		if LeonaConfig.AutoUlt and myHero:CanUseSpell(_R) == READY then
			DrawCircle(myHero.x,myHero.y,myHero.z, eRange+100, 0xFF80FF00)
		end
		if LeonaConfig.AutoUlt then
			DrawText("AutoUltimate ON",18,100,80,0xFF80FF00)
		else DrawText("AutoUltimate OFF",18,100,80,0xFFFF0000)
		end
		if LeonaConfig.scriptActive then
			DrawText("Script Active",18,100,100,0xFF80FF00)
		end
	end
		if ts.target ~= nil then
			DrawText("Targetting: " .. ts.target.charName, 18, 100, 120, 0xFFFF0000)
			DrawCircle(ts.target.x, ts.target.y, ts.target.z, 100, 0xFF80FF00)
		end                             
	end