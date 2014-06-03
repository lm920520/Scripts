--[[ Rapey Renekton v1.2 by DeniCevap
	Used Ulimited's Damage and Draw functions ( edited of course for Renekton. )

	Spacebar to unleash his powers.
	Z to disable Ultimate or use the shift menu
	
	Feautures:
	Combo: AA when possible then abilites -> E -> W -> Q -> E -> R
	Draws a cricle and a floating text on the enemy if it is killable. 
--]]
        
        
        --[[                    Config            ]]
		        
local player = GetMyHero()
if player.charName ~= "Renekton" then return end
        
        --[[                    Code                    ]]
	local swingDelay = 0.15 
    local range = 550 
	local Qrange = 429 
	local kill = {}
	local ts
	local tp

	local dice = nil
	local swing = nil
	local lastBasicAttack = nil
		
	local tp
	local ts

function OnLoad()
	rkConfig = scriptConfig("Rapeyton", "rape")
	rkConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32) --Spacebar
	rkConfig:addParam("useUlt", "Ultimate", SCRIPT_PARAM_ONKEYTOGGLE, true, 90) --Z
	rkConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	rkConfig:permaShow("scriptActive")
	rkConfig:permaShow("useUlt")
	ts.name = "Renekton"
	tp = TargetPrediction(550, 2, 10)
	ts = TargetSelector(TARGET_LOW_HP,550,DAMAGE_PHYSICAL,false)
	rkConfig:addTS(ts)
	PrintChat("Rapey Renekton v1.2 Loaded")
end


function OnProcessSpell(unit, spell)
	if unit.isMe and (spell.name:find("Attack") ~= nil) then
		swing = 1
		lastBasicAttack = os.clock()
	end
end
	
function OnTick()
ts:update()
DamageReport()

    if swing == 1 and os.clock() > lastBasicAttack + 0.2 then
        swing = 0
    end

	if rkConfig.scriptActive and ts.target ~= nil and player:GetDistance(ts.target) < range then
		local pp = tp:GetPrediction(ts.target)
			if pp ~= nil then
				if player:CanUseSpell(_E) == READY then
					CastSpell(_E,pp.x, pp.z) 
					dice = 1
				end
			end
			if player:CanUseSpell(_W) == READY and swing == 1 then
				CastSpell(_W, ts.target)
				swing = 0
			end
			if player:CanUseSpell(_Q) == READY and GetDistance(ts.target) <= Qrange then
				CastSpell(_Q)
			end
			if player:CanUseSpell(_E) == READY and dice == 1 then
				if pp ~= nil then
					CastSpell(_E,pp.x, pp.z) 
					dice = 0
				end
			end
	
		if ValidTarget(ts.target, range) then
            player:Attack(ts.target)
        end
		
		if rkConfig.useUlt then
			if player:CanUseSpell(_R) == READY then
				CastSpell(_R)
				player:Attack(ts.target)
			end
		end
	end
end
	
function DamageReport()
ts:update()
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
		local ADdmg = getDmg("AD",enemy,player)
		local qdmg = getDmg("Q",enemy,player)
		local wdmg = getDmg("W",enemy,player)
		local edmg = getDmg("E",enemy,player)
		local rdmg = getDmg("R",enemy,player)
	
		local possible = edmg*2 + wdmg + qdmg + rdmg + ADdmg
		local thatkill = 0
		
		if player:CanUseSpell(_Q) == READY then
			thatkill = thatkill + qdmg
			if player:CanUseSpell(_E) == READY  then
			thatkill = thatkill + edmg
			end
		end
		
		if player:CanUseSpell(_W) == READY then
			thatkill = thatkill + wdmg
		end
	
		if player:CanUseSpell(_E) == READY  then
			thatkill = thatkill + edmg*2
		end
				
		if player:CanUseSpell(_R) == READY then
			thatkill = thatkill + rdmg
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

	
function OnDraw()
	if rkConfig.drawcircles then
		if player.dead ~= true then
		DrawCircle(player.x, player.y, player.z, 550, 0xFFFF0000)
		DrawCircle(player.x, player.y, player.z, 429, 0xFFFF0000)
		if ts.target ~= nil then
			DrawText("Target: " .. ts.target.charName, 18,100,100, 0xFF00FF00)
			DrawCircle(ts.target.x,ts.target.y,ts.target.z, 100, 0xFF80FF00)
		end
		for i=1, heroManager.iCount do
			local enemydraw = heroManager:GetHero(i)
				if ValidTarget(enemydraw) then
					if kill[i] == 1 then
						PrintFloatText(enemydraw,0,"Cooldown")
						DrawCircle(enemydraw.x,enemydraw.y,enemydraw.z, 100, 0xFF80FF00)
						DrawCircle(enemydraw.x,enemydraw.y,enemydraw.z, 150, 0xFF80FF00)
					elseif kill[i] == 2 then
						PrintFloatText(enemydraw,0,"RAPEY TIME!!")
						DrawCircle(enemydraw.x,enemydraw.y,enemydraw.z, 100, 0xFF80FF00)
						DrawCircle(enemydraw.x,enemydraw.y,enemydraw.z, 150, 0xFF80FF00)
						DrawCircle(enemydraw.x,enemydraw.y,enemydraw.z, 200, 0xFF80FF00)
					end
				end
			end
		end
	end
end
		
function OnSendChat(msg)
	ts:OnSendChat(msg, "pri")
end