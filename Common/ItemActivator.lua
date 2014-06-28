class 'ItemActivator'

function ItemActivator__init()
	print("ItemActivator Loaded!")
	MenuActivator = scriptConfig("ItemActivator", "ItemActivator")
	MenuActivator:addParam("HPZ", "HP for Zhonya", SCRIPT_PARAM_SLICE, 15, 0, 100, -1)
end

function ItemActivator:UseItem(item, target)
-- Slots
ZSlot = GetInventorySlotItem(3157)
DFCSlot = GetInventorySlotItem(3128)
-- End Slots

	if item == "Zhonya" then
		if (ZSlot ~= nil and myHero:CanUseSpell(ZSlot) == READY) then
			if (myHero.health * (1/myHero.maxHealth)) <= (15 * 0.01) then
				CastSpell((ZSlot))
			end
		end
	end
	if item == "DFC" then
		if (DFCSlot ~= nil and myHero:CanUseSpell(DFCSlot) == READY) and target ~= nil then
			CastSpell((DFCSlot), target)
		end
	end		
end

-- function CountHerosNearPos(range)
	-- n = 0
	-- for i, object in ipairs(GetEnemyHeroes()) do
        -- if GetDistanceSqr(myHero, object) <= range then
            -- n = n + 1
        -- end
    -- end
	-- return n
-- end