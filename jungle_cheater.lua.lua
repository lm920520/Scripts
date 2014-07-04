require "MapPosition"

local Ctime
local Cprint = 0
local isrecalling = false

function OnLoad()
	PrintChat("Feez's <font color='#53CF00'>Jungle</font><font color='#DB0004'> Cheater</font>")
	
	-- Menu--
	JCConfig = scriptConfig("Jungle Cheater (" .. myHero.charName .. ")", "junglecheater")
	JCConfig:addSubMenu("Jungle Spots", "junglespots")
	JCConfig:addSubMenu("Draw Settings", "drawsettings")
	JCConfig.drawsettings:addParam("drawspots", "Draw Spots",  SCRIPT_PARAM_ONOFF, true)
	JCConfig.junglespots:addParam("numlockinfo", "Default keys are for numlock", SCRIPT_PARAM_INFO, "")
	JCConfig:addParam("printpos", "Print position in chat", SCRIPT_PARAM_ONKEYDOWN, false, 96) --numpad 0
	JCConfig.junglespots:addParam("spot1", "Red (1)", SCRIPT_PARAM_ONKEYDOWN, false, 97) --numpad 1
	JCConfig.junglespots:addParam("spot2", "Wraiths (2)", SCRIPT_PARAM_ONKEYDOWN, false, 98) --numpad 2
	JCConfig.junglespots:addParam("spot3", "Wolves (3)", SCRIPT_PARAM_ONKEYDOWN, false, 99) --numpad 3
	JCConfig.junglespots:addParam("spot4", "Blue (4)", SCRIPT_PARAM_ONKEYDOWN, false, 100) --numpad 4
	JCConfig.junglespots:addParam("spot5", "Golems (5) ", SCRIPT_PARAM_ONKEYDOWN, false, 101) --numpad 5
	JCConfig.junglespots:addParam("spot6", "Dragon (high level only) (6)", SCRIPT_PARAM_ONKEYDOWN, false, 102) --numpad 6
	JCConfig:addParam("showprint", "Enable script printing in chat", SCRIPT_PARAM_ONOFF, true)
	JCConfig.junglespots:permaShow("spot1")
	
	
end

function OnDraw() 
		if JCConfig.drawsettings.drawspots then
			DrawCircle(7444.8623046875, 56.261837005615, 2980.26171875, 30, ARGB(255, 0, 5, 156)) 
			DrawCircle(7232.5737304688, 51.952449798584, 4671.7133789063, 30, ARGB(255, 0, 5, 156)) 
			DrawCircle(7232.5737304688, 55.254241943359, 4671.7133789063, 30, ARGB(255, 0, 5, 156))
			DrawCircle(3402.3193359375, 53.792419433594, 8429.149410625, 30, ARGB(255, 0, 5, 156))
			DrawCircle(6859.1840820313, 52.699733734131, 11497.25, 30, ARGB(255, 0, 5, 156))
			DrawCircle(7010.9077148438, 57.372627258301, 10021.69140625, 30, ARGB(255, 0, 5, 156))
			DrawCircle(9850.3623046875, 52.639091491699, 8781.2353515625, 30, ARGB(255, 0, 5, 156))
			DrawCircle(11128.295898438, 54.852607727051, 6225.5424804688, 30, ARGB(255, 0, 5, 156))
			DrawCircle(10270.611328125, 54, 4974.5263671875, 30, ARGB(255, 0, 5, 156))
			DrawCircle(7213.7822265625, 54.743419647217, 2103.2778320313, 30, ARGB(255, 0, 5, 156))
			DrawCircle(4142.5556640625, 55.266135169434, 5695.958984375, 30, ARGB(255, 0, 5, 156))
			DrawCircle(6905.4633789063, 53.68051904004, 12402.211914063, 30, ARGB(255, 0, 5, 156))
	end
end


function OnTick()
		if JCConfig.printpos then
		AntiSpamPrint("x:"..myHero.x..", y:"..myHero.y..", z:"..myHero.z)
	end
	
	
	doRedBuff()
	doWraiths()
	doWolves()
	doBlueBuff()
	doGolems()
	doDragon()
	
	
end



function doRedBuff()
		if JCConfig.junglespots.spot1 and (MapPosition:inLeftBase(myHero) or MapPosition:inBottomLeftJungle(myHero) or MapPosition:inTopLeftJungle(myHero)) then 
		myHero:MoveTo(7444.8623046875, 2980.26171875)
		AntiSpamPrint("Going to blue team's red buff -- Smite recommended early")
		elseif JCConfig.junglespots.spot1 and (MapPosition:inRightBase(myHero) or MapPosition:inBottomRightJungle(myHero) or MapPosition:inTopRightJungle(myHero)) then 
		myHero:MoveTo(6859.1840820313, 11497.25)
		
		AntiSpamPrint("Going to red team's red buff -- Smite recommended early \n--Make sure you don't move out of position to keep health high, even when red buff goes back.")
		elseif JCConfig.junglespots.spot1 then
		AntiSpamPrint("Please go to the jungle section of where you want to go")
	end
end

function doWraiths()
		if JCConfig.junglespots.spot2 and (MapPosition:inLeftBase(myHero) or MapPosition:inBottomLeftJungle(myHero) or MapPosition:inTopLeftJungle(myHero)) then 
		--myHero:MoveTo(6688.587890625, 4181.576601563)
		--myHero:MoveTo(7322.6767578125, 5071.1806640625)
		--myHero:MoveTo(7264.9721679688, 5023.3598632813)
		myHero:MoveTo(7232.5737304688, 4671.7133789063)
		AntiSpamPrint("Going to blue team's wraiths -- Smite recommended early")
		elseif JCConfig.junglespots.spot2 and (MapPosition:inRightBase(myHero) or MapPosition:inBottomRightJungle(myHero) or MapPosition:inTopRightJungle(myHero)) then 
		myHero:MoveTo(7010.9077148438, 10021.69140625)
		AntiSpamPrint("Going to red team's wraiths -- Smite recommended early")
		elseif JCConfig.junglespots.spot2 then
		AntiSpamPrint("Please go to the jungle section of where you want to go")
	end
end

function doWolves()
		if JCConfig.junglespots.spot3 and (MapPosition:inLeftBase(myHero) or MapPosition:inBottomLeftJungle(myHero) or MapPosition:inTopLeftJungle(myHero)) then 
		myHero:MoveTo(4142.5556640625, 5695.958984375)
		AntiSpamPrint("Going to blue team's wolves -- Smite recommended early")
		elseif JCConfig.junglespots.spot3 and (MapPosition:inRightBase(myHero) or MapPosition:inBottomRightJungle(myHero) or MapPosition:inTopRightJungle(myHero)) then 
		myHero:MoveTo(9850.3623046875, 8781.2353515625)
		AntiSpamPrint("Going to red team's wolves -- Smite recommended early")
		elseif JCConfig.junglespots.spot3 then
		AntiSpamPrint("Please go to the jungle section of where you want to go")
	end
end

function doBlueBuff()
		if JCConfig.junglespots.spot4 and (MapPosition:inLeftBase(myHero) or MapPosition:inBottomLeftJungle(myHero) or MapPosition:inTopLeftJungle(myHero)) then 
		--myHero:MoveTo(2651.7001953125, 8122.1201171875)
		myHero:MoveTo(3402.3193359375, 8429.149410625)
		AntiSpamPrint("Going to blue team's blue buff -- No smite needed")
		elseif JCConfig.junglespots.spot4 and (MapPosition:inRightBase(myHero) or MapPosition:inBottomRightJungle(myHero) or MapPosition:inTopRightJungle(myHero)) then 
		myHero:MoveTo(11128.295898438, 6225.5424804688)
		AntiSpamPrint("Going to red team's blue buff -- Smite recommended early")
		elseif JCConfig.junglespots.spot4 then
		AntiSpamPrint("Please go to the jungle section of where you want to go")
	end
end

function doGolems()
		if JCConfig.junglespots.spot5 and (MapPosition:inLeftBase(myHero) or MapPosition:inBottomLeftJungle(myHero) or MapPosition:inTopLeftJungle(myHero)) then  
		myHero:MoveTo(7213.7822265625, 2103.2778320313)
		AntiSpamPrint("Going to blue team's golems -- No smite needed")
		elseif JCConfig.junglespots.spot5 and (MapPosition:inRightBase(myHero) or MapPosition:inBottomRightJungle(myHero) or MapPosition:inTopRightJungle(myHero)) then 
		--myHero:MoveTo(7009.0825195313, 12399.134765625)
		myHero:MoveTo(6905.4633789063, 12402.211914063)
		AntiSpamPrint("Going to red team's golems -- No smite needed \n--This spot is good for big golem.")
		elseif JCConfig.junglespots.spot5 then
		AntiSpamPrint("Please go to the jungle section of where you want to go")
	end
end

function doDragon()
		if JCConfig.junglespots.spot6 and myHero.level >= 10 then 
		--myHero:MoveTo(2651.7001953125, 8122.1201171875)
		myHero:MoveTo(10270.611328125, 4974.5263671875)
		--myHero:MoveTo(9254.8564453125, 5038.2119140625)
		if myHero.charName == "Twitch" then
		AntiSpamPrint("Going to dragon \nTip: If the dragon goes back while you are attacking it, don't move. It will come back")
		else
		AntiSpamPrint("Going to dragon")
		end
		elseif JCConfig.junglespots.spot6 and myHero.level < 10 then
		--myHero:MoveTo(10270.611328125, 4974.5263671875)
		myHero:MoveTo(9254.8564453125, 5038.2119140625)
		if myHero.charName == "Twitch" then
		AntiSpamPrint("You might be too low of a level to do dragon.\nGoing to dragon \n--Tip: If the dragon goes back while you are attacking it, don't move. It will come back")
		else
		AntiSpamPrint("You might be too low of a level to do dragon.\nGoing to dragon")
		--myHero:MoveTo(9848.3134765625, 5083.8774414063)
		end
	end
end





--Prevents chatbox spam on keypress

function AntiSpamPrint(stringtoprint) --damn i'm pretty smart
		if JCConfig.showprint then
		if Cprint == 0 then 
			PrintChat(stringtoprint)
			Ctime = GetTickCount()
		else
			if (Ctime + 400) > GetTickCount() then
			else
				PrintChat(stringtoprint)
			end
		end
		Ctime = GetTickCount()
		Cprint = Cprint + 1
	end
end

--Detect if recalling or not
function OnCreateObj(object)
		if object.name == "TeleportHome.troy" and GetDistance(player, object) < 50 then
		isrecalling = true
	end
	if object.name == "TeleportHomeImproved.troy" and GetDistance(player, object) < 50 then
		isrecalling = true
	end
end


function OnDeleteObj(object)
		if object.name == "TeleportHome.troy" and GetDistance(player, object) < 50 then
		isrecalling = false 
	end
	if object.name == "TeleportHomeImproved.troy" and GetDistance(player, object) < 50 then
		isrecalling = false 
	end
end