local Target = exports.ox_target
local Inventory = exports.ox_inventory 
local Input = lib.inputDialog
local Zone = lib.zones
local Emote = exports.scully_emotemenu

local deliveryTruck, holdingBox, inZone, groupOwner
local QBCore = exports["qbx-core"]:GetCoreObject()
local citizenId = QBCore.Functions.GetPlayerData().citizenid

--!---------------------------------------------------------------------------------------------------
--! Random Function Stuff
--!---------------------------------------------------------------------------------------------------
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

function SetUpWaypoint(coords)
    deliveryWaypoint = AddBlipForCoord(coords)
    EndTextCommandSetBlipName(deliveryWaypoint)
    SetBlipColour(deliveryWaypoint, 3)

    SetBlipRoute(deliveryWaypoint, true)
    SetBlipRouteColour(deliveryWaypoint, 3)
end

function ResetTargetOnClick()
    Target:disableTargeting(true)
    Target:disableTargeting(false)
end

--!---------------------------------------------------------------------------------------------------
--! Start Zone Stuff
--!---------------------------------------------------------------------------------------------------
local function deliveriesStartZoneonEnter(self)
    self.deliveryStartNPC = SpawnEntity(Config.StartNPC.Model, Config.StartNPC.Coords, Config.StartNPC.Heading)

    Target:addLocalEntity(self.deliveryStartNPC, {
        {
            label = "Manage Group",
            name = 'deliveriesManageGroup',
            icon = 'fa-regular fa-clipboard',
            distance = 1.5,
            onSelect = function()
                ResetTargetOnClick()
                lib.showContext('deliveriesInfoMenu')
            end
        },
        {
            label = "Get Job",
            name = 'deliveriesGetJob',
            icon = 'fa-regular fa-trash-can',
            distance = 1.5,
            onSelect = function()
                ResetTargetOnClick()
                TriggerServerEvent('LH-Deliveries:StartJob', citizenId)
            end
    }})
end 

local function deliveriesStartZoneonExit(self)
    DeleteEntity(self.deliveryStartNPC)
end

local deliveriesStartZone = Zone.box({
    coords = Config.StartNPC.Coords,
    size = vec3(40,80,10),
    rotation = -20,
    debug = Config.Debug.Toggle,
    debugColour = Config.Debug.debugColour,
    onEnter = deliveriesStartZoneonEnter,
    onExit = deliveriesStartZoneonExit,
})


--!---------------------------------------------------------------------------------------------------
--! Start Job Stuff
--!---------------------------------------------------------------------------------------------------
local function DeliveryZoneOnEnter()
    inZone = true
end 

local function DeliveryZoneOnExit()
    inZone = false
end 

RegisterNetEvent('LH-Deliveries:CreateZone', function(owner, zone, spawnTruck, removeOldZone)
    groupOwner = owner
    if spawnTruck then 
        deliveryTruck = SpawnVehicle(Config.Truck.Model, Config.Truck.Coords, Config.Truck.Heading)
        local deliveryTruckNetId = NetworkGetNetworkIdFromEntity(deliveryTruck)
        TriggerServerEvent('LH-Deliveries:DeliveryTruckSendNetId', citizenId, deliveryTruckNetId)
    end 

    if removeOldZone then 
        deliveryZone:remove()
        Target:removeZone(deliveryDropOffTarget)
        RemoveBlip(deliveryWaypoint)
    end 

    deliveryZone = Zone.box({
        coords = Config.DeliveryZones[zone].Coords,
        size = vec3(30,30,10),
        rotation = -20,
        debug = Config.Debug.Toggle,
        debugColour = Config.Debug.debugColour,
        onEnter = DeliveryZoneOnEnter,
        onExit = DeliveryZoneOnExit
    })

    deliveryDropOffTarget = Target:addSphereZone({
        coords = Config.DeliveryZones[zone].Target,
        radius = 2,
        debug = Config.Debug.Toggle,
        debugColour = Config.Debug.debugColour,
        drawSprite = true,
        options = ({
            {
                label = "Drop-Off Box",
                name = "deliveryDropOffTargetZone",
                icon = "fa-solid fa-box",
                distance = 1.5,
                onSelect = function()
                    ResetTargetOnClick()
                    if not holdingBox then lib.notify({description=Strings["no-box"], type='error'}) return end

                    holdingBox = false
                    Emote:cancelEmote()
                    TriggerServerEvent("LH-Deliveries:DropOffBox", owner)
                end 
            }
        })
    })

    SetUpWaypoint(Config.DeliveryZones[zone].Coords)
end)

RegisterNetEvent("LH-Deliveries:DeliveryTruckSetTarget", function(deliveryTruckNetId)
    deliveryTruck = NetworkGetEntityFromNetworkId(deliveryTruckNetId)
    Target:addLocalEntity(deliveryTruck, {
        label = "Pick-up Box",
        name = 'sanitationPlaceTrash',
        distance = 1.5,
        icon = "fa-solid fa-truck-ramp-box",
        bones = {'platelight'},
        onSelect = function()
            ResetTargetOnClick()
            if not inZone then lib.notify({description=Strings["not-near-store"], type ="error"}) return end 
            if holdingBox then lib.notify({description=Strings["has-box"], type='error'}) return end

            holdingBox = true
            Emote:playEmoteByCommand('cbbox'..tostring(math.random(2,6)))
        end 
    })
end)


--!---------------------------------------------------------------------------------------------------
--! Return Truck Stuff
--!---------------------------------------------------------------------------------------------------
local function returnZoneOnEnter()
    while true do 
        local seats = {IsVehicleSeatFree(deliveryTruck, -1), IsVehicleSeatFree(deliveryTruck, 0), IsVehicleSeatFree(deliveryTruck, 1), IsVehicleSeatFree(deliveryTruck, 2)}

        for i = 1, #seats do 
            if seats[i] == false then 
                break
            end 
            Wait(3000)
            DeleteEntity(deliveryTruck)
            returnZone:remove()
            TriggerServerEvent("LH-Deliveries:CompleteDeliveryJob", groupOwner)
            return
        end 
        Wait(1000)
    end 
end

RegisterNetEvent("LH-Deliveries:CompleteJob", function(owner)
    deliveryZone:remove()
    RemoveBlip(deliveryWaypoint)

    returnZone = Zone.box({
        coords = Config.StartNPC.Coords,
        size = vec3(22,21,10),
        rotation = -20,
        debug = Config.Debug.Toggle,
        debugColour = Config.Debug.debugColour,
        onEnter = returnZoneOnEnter
    })
end)