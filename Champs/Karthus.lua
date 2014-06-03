--[[
Karthus - Death Defied 1.0
by markkevin

Additional credits to:
TRUS(for the old one that motivated me)
HeX(for helping me with buffs)

Combo - Uses Q W E
Poke - Just pokes with Q
Auto E - when enemy is in range, automatically toggles E on, if not turns off.Very good to keep on if you like farming with E
Auto Ult after death - When u die and you have ulti up it will use it automatically
Auto Notify - When enemy can die from your ultimate, pings you like a madman and also sends notification to chat :)




TODO
Better Q prediction
Cast ulti 3.5 secs after death for more dmg, if any1 has ideas for that or some special particlenames for his passive i'd be happy to do it
Auto dfg/seraph's / zhonya
]]--
if myHero.charName ~= "Karthus" then return end 

local qRange = 875
local wRange = 1000
local eRange = 425
local ts = TargetSelector(TARGET_LOW_HP_PRIORITY,wRange,DAMAGE_MAGIC, false)


function OnLoad()
kConfig = scriptConfig("Karthus - Death Defied", "Karthus")
kConfig:addParam("scriptActive","Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)  -- space
kConfig:addParam("poke","Q Poke", SCRIPT_PARAM_ONKEYDOWN, false, 65)  -- A
kConfig:addParam("autoE", "Auto E", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("T"))
kConfig:addParam("autoUlt","Auto Ult after death", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("Z"))
kConfig:addParam("autoNotify","Auto notify killable enemies", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("X"))
kConfig:permaShow("scriptActive")
kConfig:permaShow("autoE")
kConfig:permaShow("autoUlt")
ts.name = "Karthus"
kConfig:addTS(ts)
end

function OnTick()
ts:update()


if kConfig.autoUlt then 
bCount = player.buffCount
for i = 1, bCount, 1 do
local Buff = player:getBuff(i)
if Buff.name == "deathdefiedbuff" and Buff.valid then
CastSpell(_R)
end
end
end

if kConfig.autoNotify then
players = heroManager.iCount
 for i = 1, players, 1 do
		target = heroManager:getHero(i)
		
		if target ~= nil and target.team ~= player.team and target.visible and not target.dead then
			rDmg = player:CalcMagicDamage(target, 150*(GetSpellData(_R).level-1)+100+(0.6*player.ap))
			if rDmg > target.health then
				if player:CanUseSpell(_R) == READY then
					PrintChat(target.charName.." has "..target.health.." HP, press R for gold :)")
					PingSignal(PING_FALLBACK,target.x,target.y,target.z,2)
				end
			end
		end
	end	
end


if kConfig.autoE then
	if ValidTarget(ts.target, eRange) then
                        if myHero:CanUseSpell(_E) == READY and not eToggled then
                                
                                
                                        CastSpell(_E)
                                
                        end
								end 
	if not ValidTarget(ts.target, eRange) then
						if eToggled then
						CastSpell(_E)
						end
	end
end

if kConfig.poke then
                if ValidTarget(ts.target, qRange) then
                        if myHero:CanUseSpell(_Q) == READY then

                                        CastSpell(_Q, GetPredictionPos(ts.target, 900).x, GetPredictionPos(ts.target, 900).z)

                        end
								end
	end
if kConfig.scriptActive then

	if ValidTarget(ts.target, wRange) then
                        if myHero:CanUseSpell(_W) == READY then
                                

													CastSpell(_W, GetPredictionPos(ts.target, 300).x, GetPredictionPos(ts.target, 300).z)

                        end
								end

	if ValidTarget(ts.target, qRange) then
                        if myHero:CanUseSpell(_Q) == READY then
                                
                                        CastSpell(_Q, GetPredictionPos(ts.target, 900).x, GetPredictionPos(ts.target, 900).z)
                               
                        end
								end
	if ValidTarget(ts.target, eRange) then
                        if myHero:CanUseSpell(_E) == READY and not buffed then
                                
                                
                                        CastSpell(_E)
                                
                        end
								end 
	if ValidTarget(ts.target) and player:GetDistance(ts.target) > eRange then
						if buffed then
						CastSpell(_E)
						end
	end

end


end





function OnCreateObj(object)
    if object ~= nil and object.name == "Defile_glow.troy" then
        eToggled = true
    end
end

function OnDeleteObj(object)
    if object ~= nil and object.name == "Defile_glow.troy" then
        eToggled = false
    end
end