local Inventory = exports.ox_inventory

local spawnedRocks = false


--!---------------------------------------------------------------------------------------------------
--! Rock Stuff
--!---------------------------------------------------------------------------------------------------
local function SpawnMinableRock(model, coords)
    local rock = CreateObject(GetHashKey(model), coords, true, true)
    Wait(100)
    SetEntityHeading(rock, math.random(1,360) + 0.0)
    FreezeEntityPosition(rock, true)
end

RegisterNetEvent("LH-Mining:SpawnMinableRocks", function()
    if spawnedRocks then return end

    for i = 1, #Config.MinableRocksZone.locations do
        SpawnMinableRock(Config.MinableRocksZone.rockModel, Config.MinableRocksZone.locations[i])
    end
    spawnedRocks = true
end)

RegisterNetEvent("LH-Mining:SearchInventoryForTools", function(entity, coords)
    local src = source
    local tool
    local searchedInventory = Inventory:Search(src, 'count', {'jackhammer', 'pickaxe', 'shovel', 'empty_bucket'})

    if not searchedInventory then lib.notify(src, Strings["no-tool"]) return end

    if searchedInventory["jackhammer"] >= 1 then
        tool = "jackhammer"
    elseif searchedInventory["pickaxe"] >= 1 then
        tool = "pickaxe"
    elseif searchedInventory["shovel"] >= 1 then 
        tool = "shovel"
    else 
        lib.notify(src, Strings["no-tool"]) 
        return 
    end 

    local rewardAmount = math.random(Config.Tools[tool].minReward, Config.Tools[tool].maxReward)

    if searchedInventory["empty_bucket"] < rewardAmount then lib.notify(src, Strings["not-enough-buckets"]) return end 

    if not Inventory:CanCarryItem(src, 'full_bucket', rewardAmount) then return end

    TriggerClientEvent("LH-Mining:StartMining", src, entity, coords , tool, rewardAmount)
end)

RegisterNetEvent("LH-Mining:MineRockReward", function(entity, coords, rewardAmount)
    local src = source
    local rock = NetworkGetEntityFromNetworkId(entity)

    if not DoesEntityExist(rock) then return end

    DeleteEntity(rock)
    Inventory:RemoveItem(src, "empty_bucket", rewardAmount)
    Inventory:AddItem(src, "full_bucket", rewardAmount)
    Wait(math.random(Config.MinableRocksZone.respawn.min, Config.MinableRocksZone.respawn.max))
    SpawnMinableRock(Config.MinableRocksZone.rockModel, coords)
end)


--!---------------------------------------------------------------------------------------------------
--! Process Stuff
--!---------------------------------------------------------------------------------------------------
RegisterNetEvent("LH-Mining:SearchInventoryForDirt", function(input)
    local src = source
    local item, count = input[1], input[2]
    local amount = Inventory:Search(src, 'count', 'full_bucket')
    print(item,count,amount)

    if count > amount then 
        lib.notify(src, Strings["not-enough-dirt"])
        return
    end 

    if not Inventory:CanCarryItem(src, item, count) then return end

    TriggerClientEvent("LH-Mining:StartProcess", src, input)

end)

RegisterNetEvent("LH-Mining:ProcessReward", function(input)
    local src = source
    local item, count = input[1], input[2]
    local gemRocks = math.floor(count/Config.Process.gemRocks)

    Inventory:RemoveItem(src, 'full_bucket', count)
    Inventory:AddItem(src, item, count)
    Inventory:AddItem(src, 'gem_rock', gemRocks)
end)


--!---------------------------------------------------------------------------------------------------
--! Gem Drill Stuff
--!---------------------------------------------------------------------------------------------------
RegisterNetEvent("LH-Mining:BreakOpenGemRock", function()
    local src = source
    local amount = Inventory:Search(src, 'count', 'gem_rock')

    if amount < 1 then lib.notify(src, Strings["no-gemRocks"]) return end

    TriggerClientEvent("LH-Mining:StartBreakOpen", src, amount)
end)

RegisterNetEvent("LH-Mining:DrillReward", function(amount)
    local src = source
    local rewardTable = {}

    for i = 1, amount do 
        local slot = math.random(1, #Config.Drill.reward)

        if rewardTable[slot] == nil then 
            rewardTable[slot] = 0
        end 
        rewardTable[slot] = rewardTable[slot] + 1
    end

    for i = 1, #Config.Drill.reward do 
        Inventory:RemoveItem(src, 'gem_rock', amount)
        Inventory:AddItem(src, Config.Drill.reward[i], rewardTable[i])
    end 
end)