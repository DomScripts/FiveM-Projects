local Target = exports.ox_target
local Inventory = exports.ox_inventory

fishingStartBlip = AddBlipForCoord(Config.NPC.StartModelCoords)
SetBlipSprite(fishingStartBlip, 317)
SetBlipColour(fishingStartBlip, 3)
AddTextEntry("FISHING-BLIP", "Fishing")
BeginTextCommandSetBlipName("FISHING-BLIP")
EndTextCommandSetBlipName(fishingStartBlip)

fishingSalesBlip = AddBlipForCoord(Config.NPC.SellModelCoords)
SetBlipSprite(fishingSalesBlip, 317)
SetBlipColour(fishingSalesBlip, 3)
AddTextEntry("FISHING-SALES", "Fishing Sales")
BeginTextCommandSetBlipName("FISHING-SALES")
EndTextCommandSetBlipName(fishingSalesBlip)


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

function ResetTargetOnClick()
    Target:disableTargeting(true)
    Target:disableTargeting(false)
end

function StartJobNPCZoneOnExit() 
    DeleteEntity(FishStartNPC)
end 

function SellFishNPCZoneOnEnter()
    FishSellNPC = SpawnEntity(Config.NPC.SellModel, Config.NPC.SellModelCoords, Config.NPC.SellModelHeading)
    SetSellTargetOptions(FishSellNPC)
end

function SellFishNPCZoneOnExit()
    DeleteEntity(FishSellNPC)
end

function SetUpWaypoint(coords)
    AddTextEntry("FISHING-WAYPOINT", "Fishing Zone")

    fishingWaypoint = AddBlipForCoord(coords)
    BeginTextCommandSetBlipName("FISHING-WAYPOINT")
    EndTextCommandSetBlipName(fishingWaypoint)
    SetBlipColour(fishingWaypoint, 3)

    SetBlipRoute(fishingWaypoint, true)
    SetBlipRouteColour(fishingWaypoint, 3)
end