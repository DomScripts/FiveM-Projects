if Config.Framework == "esx" then 

local ESX = exports["es_extended"]:getSharedObject()

ManagementFunction = {}

AddEventHandler("esx:playerLoaded", function(player, xPlayer, isNew)
    TriggerServerEvent("ds_jobmanagement:CheckPlayerTempJob")
end)

function ManagementFunction.GetPlayerCitizenId()
    local citizenId = ESX.PlayerData.identifier
    return citizenId 
end 

end 