if Config.Framework == "esx" then 

local ESX = exports["es_extended"]:getSharedObject()

ManagementFunction = {}

function ManagementFunction.GetPlayer(src)
    local player = ESX.GetPlayerFromId(src)
    return player 
end 

function ManagementFunction.GetPlayerByCitizenId(citizenId) 
    local player = ESX.GetPlayerFromIdentifier(citizenId) 
    return player 
end 

function ManagementFunction.GetPlayerJob(player)
    local job = player.getJob()
    return job.name 
end 

function ManagementFunction.SetPlayerJob(player)
    player.setJob("unemployed", 0)
end

function ManagementFunction.GetPlayerName(player) 
    local name = player.getName()
    local store = {}

    for i in string.gmatch(name, "%S+") do 
        table.insert(store, i)
    end

    local firstname = store[1]
    local lastname = store[2]

    return firstname, lastname
end 

function ManagementFunction.GetPlayersCitizenId(player)
    local citizenId = player.getIdentifier()
    return citizenId
end

function ManagementFunction.GetPlayerSource(player)
    local src = player.source
    return src
end

end