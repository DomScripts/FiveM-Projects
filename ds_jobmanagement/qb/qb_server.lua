if Config.Framework == 'qb' then 

local QBCore = exports["qbx-core"]:GetCoreObject() or exports["qb-core"]:GetCoreObject()
        
ManagementFunction = {}

function ManagementFunction.GetPlayer(src)
    local player = QBCore.Functions.GetPlayer(src) 
    return player
end 

function ManagementFunction.GetPlayerByCitizenId(citizenId)
    local player = QBCore.Functions.GetPlayerByCitizenId(tostring(citizenId))
    return player 
end

function ManagementFunction.GetPlayerJob(player)
    local job = player.PlayerData.job.name
    return job
end

function ManagementFunction.SetPlayerJob(player)
    player.Functions.SetJob("unemployed", 0)
end 

function ManagementFunction.GetPlayerName(player)
    local firstname = player.PlayerData.charinfo.firstname
    local lastname = player.PlayerData.charinfo.lastname
    return firstname, lastname
end
        
function ManagementFunction.GetPlayersCitizenId(player)
    local citizenId = player.PlayerData.citizenid 
    return citizenId 
end 

function ManagementFunction.GetPlayerSource(player)
    local src = player.PlayerData.source
    return src
end

end 