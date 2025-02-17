if Config.Framework == 'qb' then 

local QBCore = exports["qbx-core"]:GetCoreObject() or exports["qb-core"]:GetCoreObject()

ManagementFunction = {}
    
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    TriggerServerEvent("ds_jobmanagement:CheckPlayerTempJob")
end)

function ManagementFunction.GetPlayerCitizenId()
    local citizenId = QBCore.Functions.GetPlayerData().citizenid 
    return citizenId 
end 
    
end 