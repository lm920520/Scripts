-- ###################################################################################################### --
-- #                                 Yorick - The world will end in zombies!                            # --
-- #                                      by mkc based on Unlimited's                                   # --
-- ###################################################################################################### --

if myHero.charName ~= "Yorick" then return end

-- ########### Configuration ############

local range = 125
local wrange = 600
local erange = 550

local kill = {}
local ts = TargetSelector(TARGET_LOW_HP,erange,DAMAGE_MAGIC,false)
local player = GetMyHero()
local percent = 10 -- It will launch ult with 10% hp left.

-- ########### End of configuration ############

function OnLoad()

YConfig = scriptConfig("Yorick - The world will end in Zombies", "YorickCombo")
YConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
YConfig:addParam("harass", "Harass (E + W)", SCRIPT_PARAM_ONKEYDOWN, false, 84)
YConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
YConfig:addParam("useult","Use Ult",SCRIPT_PARAM_ONOFF, true)
YConfig:permaShow("scriptActive")
YConfig:permaShow("harass")
ts.name = "Yorick"
YConfig:addTS(ts)
end
 
function OnTick()
	ts:update()
	Damage()
	if ts.target ~= nil and YConfig.harass and GetDistance(ts.target)<wrange then
		CastSpell(_W,ts.target.x,ts.target.z)
		CastSpell(_E,ts.target)
	end
	
	if myHero:GetSpellData(_R).level > 0 and myHero:CanUseSpell(_R) == READY and ts.target ~= nil and player.health < player.maxHealth*(percent/100) and YConfig.useult then
		CastSpell(_R)
		CastSpell(_R,ts.target)
	end

	if ts.target ~= nil and YConfig.scriptActive and GetDistance(ts.target)<erange then
		CastSpell(_W,ts.target.x,ts.target.z)
		CastSpell(_Q)
		myHero:Attack(ts.target)
		CastSpell(_E,ts.target)
		myHero:Attack(ts.target)
	end
end
 
function Damage()
	ts:update()
	for i=1, heroManager.iCount do
	
		if ts.target ~= nil then
			local enemy = ts.target
			local qdmg = getDmg("Q",enemy,myHero)
			local wdmg = getDmg("W",enemy,myHero)
			local edmg = getDmg("E",enemy,myHero)
			local aa = getDmg("AD",enemy,myHero)
			local possible = qdmg + wdmg + edmg + aa
			local thatkill = 0
	
		if myHero:CanUseSpell(_Q) == READY then
			thatkill = thatkill + qdmg + aa
		end
	
		if myHero:CanUseSpell(_W) == READY then
			thatkill = thatkill + wdmg
		end
		
		if myHero:CanUseSpell(_E) == READY then
			thatkill = thatkill + edmg
		end
	
		if thatkill >= enemy.health then
			kill[i] = 2
			elseif possible>= enemy.health then
			kill[i] = 1
			else
			kill[i] = 0
		end
	end
end
end
 
function OnDraw()
	if YConfig.drawcircles and not myHero.dead then
			DrawCircle(myHero.x,myHero.y,myHero.z, 550, 0xFF80FF00)
			if YConfig.scriptActive then
			DrawText("Script Active",18,100,80,0xFF80FF00)
			end
			if YConfig.harass then
			DrawText("Harass",18,100,80,0xFF80FF00)
			end
		
		if ts.target ~= nil then
			DrawText("Targetting: " .. ts.target.charName, 18, 100, 100, 0xFFFF0000)
			DrawCircle(ts.target.x, ts.target.y, ts.target.z, 100, 0xFF80FF00)
		end
		
		for i=1, heroManager.iCount do
			local enemydraw = heroManager:GetHero(i)
			if ts.target ~= nil then
				if ValidTarget(enemydraw) then
					if kill[i] == 1 then
						PrintFloatText(enemydraw,0,"Cooldown")
						DrawCircle(ts.target.x, ts.target.y, ts.target.z, 100, 0xFF80FF00)
					elseif kill[i] == 2 then
						PrintFloatText(enemydraw,0,"Kill!")
						DrawCircle(ts.target.x, ts.target.y, ts.target.z, 100, 0xFF80FF00)
						DrawCircle(ts.target.x, ts.target.y, ts.target.z, 150, 0xFF80FF00)
					end
				end
			end
		end
	end
end


PrintChat(" >> Yorick - The world will end in Zombies!")