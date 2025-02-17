local Inventory = exports.ox_inventory
local QBCore = exports["qbx-core"]:GetCoreObject()


--!---------------------------------------------------------------------------------------------------
--! Get onDuty Cop Stuff
--!---------------------------------------------------------------------------------------------------
lib.callback.register('LH-DrugSales:WeedCornering.GetOnDutyCops', function()
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

--!---------------------------------------------------------------------------------------------------
--! Hand Off Stuff
--!---------------------------------------------------------------------------------------------------
RegisterNetEvent("LH-DrugSales:WeedCornering.HandOff", function()
    local src = source 

    local count = Inventory:GetItemCount(src, "fullbag")
    if count > 1 then count = math.random(Config.Cornering.MinBaggieSaleAmount, Config.Cornering.MaxBaggieSaleAmount) end 

    Inventory:RemoveItem(src, "fullbag", count)
    Inventory:AddItem(src, "money", (count * Config.Cornering.BaggieRewardAmount))

    local count = Inventory:GetItemCount(src, "black_money")
    if count == 0 then return end 
    local cleanMoneyAmount = math.random(Config.Cornering.MinAmountToWash, Config.Cornering.MaxAmountToWash)
    if count >= cleanMoneyAmount then 
        Inventory:RemoveItem(src, "black_money", cleanMoneyAmount)
        Inventory:AddItem(src, "money", cleanMoneyAmount)
    else 
        Inventory:RemoveItem(src, "black_money", count)
        Inventory:AddItem(src, "money", count)
    end 
end)