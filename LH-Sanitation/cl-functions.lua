local Target = exports.ox_target
local Inventory = exports.ox_inventory


function SpawnEntity(entity, coords, heading)
    RequestModel(GetHashKey(entity))
    while not HasModelLoaded(GetHashKey(entity)) do 
        Wait(100)
    end 

    local entity = CreatePed(1, GetHashKey(entity), coords, heading, false, true)
    Wait(1000)
    FreezeEntityPosition(entity, true)
    SetEntityInvincible(entity, true)
    SetBlockingOfNonTemporaryEvents(entity, true)
    SetModelAsNoLongerNeeded(GetHashKey(entity))
    return entity
end

function SpawnVehicle(entity, coords, heading)
    RequestModel(GetHashKey(entity))
    while not HasModelLoaded(GetHashKey(entity)) do 
        Wait(100)
    end 

    local vehicle = CreateVehicle(GetHashKey(entity), coords, heading, true, true)
    Wait(1000)
    SetModelAsNoLongerNeeded(GetHashKey(entity))
    return vehicle
end

function ResetTargetOnClick()
    Target:disableTargeting(true)
    Target:disableTargeting(false)
end

function StartJobNPCZoneOnExit() 
    DeleteEntity(SanitationStartNPC)
    DeleteEntity(SanitationExchangeNPC)
end 

function SetUpWaypoint(coords)
    --AddTextEntry("FISHING-WAYPOINT", "Fishing Zone")

    sanitationWaypoint = AddBlipForCoord(coords)
    --BeginTextCommandSetBlipName("FISHING-WAYPOINT")
    EndTextCommandSetBlipName(sanitationWaypoint)
    SetBlipColour(sanitationWaypoint, 3)

    SetBlipRoute(sanitationWaypoint, true)
    SetBlipRouteColour(sanitationWaypoint, 3)
end