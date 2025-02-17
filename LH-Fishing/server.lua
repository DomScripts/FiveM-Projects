local QBCore = exports["qbx-core"]:GetCoreObject()
local Inventory = exports.ox_inventory
local Zones = lib.zones

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then 
        return
    end

    while true do 
        ActiveFishingZone = math.random(6)
        Wait(3600000) -- 1 hour
    end 
end)

RegisterNetEvent('LH-Fishing:SellFish', function(hour)
    local fishSum = 0

    for i = 1, #Config.FishingLoot do 
        fishSum += Inventory:Search(source, 'count', Config.FishingLoot[i].name)
    end 

    if fishSum < 1 then 
        lib.notify(source, {description = 'Not enough fish to sell', type = 'error'})
        return
    end 

    for i = 1, #Config.FishingLoot do 
        local count = Inventory:Search(source, 'count', Config.FishingLoot[i].name)
        if count >= 1 then
            if not Config.FishingLoot[i].legal then 
                if hour > 20 or hour < 4 then 
                    Inventory:RemoveItem(source, Config.FishingLoot[i].name, count)
                    Inventory:AddItem(source, 'black_money', (fishSum * Config.IllegalPrice))
                end 
            else 
                Inventory:RemoveItem(source, Config.FishingLoot[i].name, count)
                Inventory:AddItem(source, 'money', (fishSum * Config.SellPrice))
            end
        end 
    end 

    lib.notify(source, {description = 'You sold your fish', type = 'success'})
end)

RegisterNetEvent('LH-Fishing:giveFish', function(fish, groupOwner, fishToComplete)
    local src = source

    if Inventory:CanCarryItem(src, fish.name, 1) then 
        print('Gave fish')
        Inventory:AddItem(src, fish.name, 1)

        FishCaughtTracker[groupOwner] = FishCaughtTracker[groupOwner] + 1
        if FishCaughtTracker[groupOwner] % Config.FishPerPerson == 0 then 
            if FishCaughtTracker[groupOwner] == fishToComplete then 
                TriggerClientEvent("LH-Fishing:CompleteJob", src)
                FishingGroups[groupOwner][1] = false
                for i = 2, #FishingGroups[groupOwner] do 
                    local Player = FishingGroups[groupOwner][i]
                    TriggerClientEvent("LH-Fishing:CompleteJob", QBCore.Functions.GetPlayerByCitizenId(Player).PlayerData.source)
                end
            end
        end 
    end 
end)