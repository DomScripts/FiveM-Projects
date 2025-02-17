local Inventory = exports.ox_inventory
local QBCore = exports["qbx-core"]:GetCoreObject()

local runActive = false
local runPosition = 0

--!---------------------------------------------------------------------------------------------------
--! Weed Run Stuff
--!---------------------------------------------------------------------------------------------------
lib.callback.register('LH-DrugSales:WeedRuns.GetOnDutyCops', function()
    local policeCount = 0

    for _, v in pairs(QBCore.Functions.GetQBPlayers()) do
        if v then

            if v.PlayerData.job.name == "police" and v.PlayerData.job.onduty then
                policeCount += 1
            end

        end
    end
    return policeCount
end)

RegisterNetEvent("LH-DrugSales:WeedRuns.StartRun", function()
    local src = source

    if Inventory:Search(src, 'count', 'weedbrick') < Config.WeedRun.MinToStart then 
        lib.notify({description=Strings["not-enough-bricks"], type="inform"}) 
        --? Log information
        return 
    end

    if runACtive then lib.notify({description=Strings["not-enough-cops"], type="error"}) return end 

    runActive = true
    runPosition = 0
    local randomLocation = math.random(1, #Config.WeedRun.DropOff)
    TriggerClientEvent("LH-DrugSales:WeedRuns.CreateDropOff", src, randomLocation)
end)

RegisterNetEvent("LH-DrugSales:weedRuns.DropOffPackage", function()
    local src = source

    if Inventory:Search(src, 'count', 'weedbrick') == 0 then return end 

    Inventory:RemoveItem(src, 'weedbrick', 1)
    Inventory:AddItem(src, 'money', (Config.Cornering.BaggieRewardAmount * 10))

    runPosition += 1
    if runPosition == 10 then
        lib.notify(src, {description=Strings["completed-run"], type='success'})
        runActive = false
        runPosition = 0
        return
    end 

    local randomLocation = math.random(1, #Config.WeedRun.DropOff)
    TriggerClientEvent("LH-DrugSales:WeedRuns.CreateDropOff", src, randomLocation)
end)