local Inventory = exports.ox_inventory


--!---------------------------------------------------------------------------------------------------
--! Bait Stuff
--!---------------------------------------------------------------------------------------------------
RegisterNetEvent("LH-Hunting:RemoveBait", function()
    local src = source
    Inventory:RemoveItem(src, 'hunting_bait', 1)
end) 


--!---------------------------------------------------------------------------------------------------
--! Knife Stuff
--!---------------------------------------------------------------------------------------------------
lib.callback.register("LH-Hunting:canCarryItem", function(source, item, count)
    local src = source
    if Inventory:CanCarryItem(src, item, count) then return true else return false end 
end)

RegisterNetEvent("LH-Hunting:GivePelt", function(closestPedNetId, baitedAnimal, legal)
    local src = source
    local closestPed = NetworkGetEntityFromNetworkId(closestPedNetId)
    
    if not baitedAnimal then 
        Inventory:AddItem(src, 'animal_pelt_legal_1', 1)
        DeleteEntity(closestPed)
        return
    end 

    if not legal then 
        Inventory:AddItem(src, 'animal_pelt_illegal_3', 1)
        DeleteEntity(closestPed)
        return
    end 

    local randomRewardLevel = math.random(0,100)
    if randomRewardLevel <= Config.RareStarPeltChance then 
        Inventory:AddItem(src, 'animal_pelt_legal_3', 1)
    else 
        Inventory:AddItem(src, 'animal_pelt_legal_2', 1)
    end 
    DeleteEntity(closestPed)
end)


--!---------------------------------------------------------------------------------------------------
--! Sales Stuff
--!---------------------------------------------------------------------------------------------------
RegisterNetEvent("LH-Hunting:SellPelts", function(hour)
    local src = source
    
    for k,v in pairs(Config.SellNPC.LegalPelts) do      -- Search and sell legal pelts
        local count = Inventory:Search(src, 'count', v.name)
        if count >= 1 then 
            local reward = v.price * count
            Inventory:RemoveItem(src, v.name, count)
            Inventory:AddItem(src, v.item, reward)
        end 
    end 

    if hour > 20 or hour < 4 then 
        for k,v in pairs(Config.SellNPC.IllgalPeltsPelts) do      -- Search and sell illegal pelts
            local count = Inventory:Search(src, 'count', v.name)
            if count >= 1 then 
                local reward = v.price * count
                Inventory:RemoveItem(src, v.name, count)
                Inventory:AddItem(src, v.item, reward)
            end 
        end 
    end 
end)