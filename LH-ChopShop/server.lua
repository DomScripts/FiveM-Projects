local Inventory = exports.ox_inventory

--!---------------------------------------------------------------------------------------------------
--! Job Stuff
--!---------------------------------------------------------------------------------------------------
RegisterNetEvent("LH-ChopShop:StartJob", function()
    local src = source

    local randomZone = math.random(1, #Config.Cars.Location)
    local randomCar = math.random(1, #Config.Cars.List)

    Wait(math.random(Config.StartNPC.Wait.Min, Config.StartNPC.Wait.Max))

    TriggerClientEvent("LH-ChopShop:AssignZone", src, randomZone, randomCar)    
end)


--!---------------------------------------------------------------------------------------------------
--! Exchange Stuff
--!---------------------------------------------------------------------------------------------------
RegisterNetEvent("LH-ChopShop:ExchangeMaterials", function(input)
    local src = source
    local item, count = input[1], input[2]
    local amount = Inventory:Search(src, 'count', 'recyclablematerial')

    if count > amount then 
        lib.notify(src, {description=Strings["not-enough"], type='error'})
        return
    end 

    if not Inventory:CanCarryItem(src, item, count) then 
        lib.notify(src, {description=Strings["cant-carry"], type='error'})
        return
    end

    Inventory:RemoveItem(src, 'recyclablematerial', count)
    Inventory:AddItem(src, item, count)
end)


--!---------------------------------------------------------------------------------------------------
--! Reward Stuff
--!---------------------------------------------------------------------------------------------------
RegisterNetEvent("LH-ChopShop:ChopDoorReward", function(part, data, doorIndex)
    local src = source
    if part == "door" or part == "wheel" then 
        local reward = math.random(Config.Chop.Reward.Part.Min, Config.Chop.Reward.Part.Max)
        if not Inventory:CanCarryItem(src, 'recyclablematerial', reward) then return end
        Inventory:AddItem(src, 'recyclablematerial', reward)
    elseif part == "chassis" then 
        local reward = math.random(Config.Chop.Reward.Chassis.Min, Config.Chop.Reward.Chassis.Max)
        local rewardMoney = math.random(Config.Chop.Reward.Chassis.Min, Config.Chop.Reward.Chassis.Max)
        if not Inventory:CanCarryItem(src, 'recyclablematerial', reward) then return end
        Inventory:AddItem(src, 'recyclablematerial', reward)
        Inventory:AddItem(src, 'black_money', rewardMoney)
    end 

    TriggerClientEvent("LH-ChopShop:RemoveProp", src, part, data, doorIndex)
end)