local Zones = lib.zones
local Target = exports.ox_target
local Inventory = exports.ox_inventory
local Emote = exports.scully_emotemenu

local QBCore = exports["qbx-core"]:GetCoreObject()
local groupOwner
local inZone, holdingTrash = false
local trashPickedUp = {}

while not LocalPlayer.state.isLoggedIn do
    Wait(500)
end

local citizenId = QBCore.Functions.GetPlayerData().citizenid

function StartJobNPCZoneOnEnter()
    SanitationStartNPC = SpawnEntity(Config.NPC.StartModel, Config.NPC.StartModelCoords, Config.NPC.StartModelHeading)
    SetSanitationNPCTargetOptions(SanitationStartNPC)

    SanitationExchangeNPC = SpawnEntity(Config.NPC.ExchangeModel, Config.NPC.ExchangeModelCoords, Config.NPC.ExchangeModelHeading)
    SetSanitationExchangeTargetOptions(SanitationExchangeNPC)
end 

--! Initialize NPC Zones
--? Job NPC Zone
local startJobNPCZone = Zones.box({
    coords = Config.NPC.StartModelCoords,
    size = vec3(100,60,20),
    rotation = 60,
    debug = Config.Debug.Toggle,
    debugColour = Config.Debug.debugColour,
    onEnter = StartJobNPCZoneOnEnter,
    onExit = StartJobNPCZoneOnExit
})

--! Set Target Options

--? Job NPC Target
function SetSanitationExchangeTargetOptions(entity)
    Target:addLocalEntity(NetworkGetNetworkIdFromEntity(entity), {
        {
            label = "Exchange Materials",
            name = 'sanitationExchangeMaterials',
            icon = 'fa-regular fa-trash-can',
            distance = 1.5,
            onSelect = function()
                local input = lib.inputDialog("Exchange Materials", Config.ExchangeInput)

                if not input then return else 
                    TriggerServerEvent('LH-Sanitation:ExchangeMaterials', input)
                end 
            end 
        }
    })
end 

function SetSanitationNPCTargetOptions(entity)
    Target:addLocalEntity(NetworkGetNetworkIdFromEntity(entity), {
    {
        label = "Manage Group",
        name = 'sanitationManageGroup',
        icon = 'fa-regular fa-clipboard',
        distance = 1.5,
        onSelect = function()
            ResetTargetOnClick()
            lib.showContext('sanitationInfoMenu')
        end
    },
    {
        label = "Get Job",
        name = 'sanitationGetJob',
        icon = 'fa-regular fa-trash-can',
        distance = 1.5,
        onSelect = function()
            ResetTargetOnClick()
            TriggerServerEvent('LH-Sanitation:StartJob', citizenId)
        end
    }})
end 

--! Register Context Menus
lib.registerContext({
    id = 'sanitationInfoMenu',
    title = 'Sanitation Group',
    options = {
    {
        title = 'Create Group',
        description = 'Create a group to collect trash with',
        icon = 'check',
        onSelect = function()
            local groupInfo = lib.callback.await('LH-Sanitation:fetchGroups', false)

            --? Check if player is already in a group
            lib.callback('LH-Sanitation:checkIfInGroup', false, function(inGroup)
                if inGroup then 
                    lib.notify({description=Strings["already-member"], type = 'error'})
                else 
                    TriggerServerEvent('LH-Sanitation:createGroup', citizenId)
                    lib.notify({description=Strings["created-group"], type = 'success'})
                end 
            end, citizenId)
        end
    },
    {
        title = 'Join Group',
        description = 'Join a friends group',
        icon = 'bars',
        arrow = true,
        onSelect = function()
            local groupInfo = lib.callback.await('LH-Sanitation:fetchGroups', false)
            
            --? Calcualte how many groups there are
            local numberOfGroups = 0
            for _ in pairs(groupInfo) do 
                numberOfGroups = numberOfGroups + 1
            end 

            --? If no groups found show no groups found menu
            if numberOfGroups == 0 then 
                lib.showContext('sanitationNoGroupsMenu')
                return
            end 

            --? Get all groups for context menu
            local groupFormat = lib.callback.await('LH-Sanitation:formatGroups', false)
            lib.registerContext({
                id = 'sanitationGroupMenu',
                title = 'Sanitation Groups',
                options = groupFormat
            })
            lib.showContext('sanitationGroupMenu')
        end 
    }}
})

--? Group Menus
lib.registerContext({
    id = 'sanitationNoGroupsMenu',
    title = 'Sanitation Groups',
    options = {
    {
        title = 'No Groups Found',
        description = 'Create your own sanitation group to get started'
    }
    }
})

RegisterNetEvent('LH-Sanitation:sanitationGroupOptionMenu', function(owner)
    lib.registerContext({
        id = 'sanitationGroupOptionMenu',
        title = 'Sanitation Groups',
        options = {
            {
                title = 'Join Group',
                onSelect = function()
                    TriggerServerEvent('LH-Sanitation:joinGroup', owner, citizenId)
                end 
            },
            {
                title = 'Leave Group',
                onSelect = function()
                    TriggerServerEvent('LH-Sanitation:leaveGroup', citizenId)
                end 
            }
        }
    })
    lib.showContext('sanitationGroupOptionMenu')
end)

local function SanitationZoneOnEnter()
    inZone = true
end

local function SanitationZoneOnExit()
    inZone = false
end

RegisterNetEvent('LH-Sanitation:CreateZone', function(owner, zone, spawnTruck, setTarget, removeOldZone)
    if spawnTruck then 
        groupOwner = owner
        garbageTruck = SpawnVehicle(Config.Truck.Model, Config.Truck.Coords, Config.Truck.Heading)
        TriggerServerEvent('LH-Sanitation:SendGarbageTruckID', citizenId, garbageTruck)
        TriggerEvent('LH-Sanitation:SetGarbageTruckTarget', owner, garbageTruck)
    end 
    
    if setTarget then 
        Target:addModel(Config.TargetModels,
        {
            label = "Pickup Trash",
            name = 'sanitationPickupTrash',
            icon = 'fa-regular fa-trash-can',
            distance = 1.5,
            onSelect = function(data)
                ResetTargetOnClick()
                if not inZone then lib.notify({description=Strings['not-inZone'], type='error'}) return end
    
                local hasPickedUp = false
                for i = 1, #trashPickedUp do 
                    if data.entity == trashPickedUp[i] then 
                        hasPickedUp = true
                        lib.notify({description=Strings['already-pickedUp'], type='error'})
                        return 
                    end
                end
    
                if not hasPickedUp and not holdingTrash then 
                    holdingTrash = true
                    Emote:playEmoteByCommand('gbag')
                    table.insert(trashPickedUp, data.entity)
                end 
            end
        })
    end

    if removeOldZone then 
        sanitationZone:remove()
        RemoveBlip(sanitationWaypoint)
    end 

    sanitationZone = Zones.box({
        coords = Config.SanitationZones[zone].coords,
        size = Config.SanitationZones[zone].size,
        rotation = Config.SanitationZones[zone].rotation,
        debug = Config.Debug.Toggle,
        debugColour = Config.Debug.debugColour,
        onEnter = SanitationZoneOnEnter,
        onExit = SanitationZoneOnExit
    })

    trashPickedUp = {}
    SetUpWaypoint(Config.SanitationZones[zone].coords)
end)

RegisterNetEvent('LH-Sanitation:SetGarbageTruckTarget', function(owner, garbageTruck)
    local garbageTruckNetID = NetworkGetNetworkIdFromEntity(garbageTruck)
    Target:addLocalEntity(garbageTruckNetID, {
        label = "Place Trash",
        name = 'sanitationPlaceTrash',
        distance = 1.5,
        icon = 'fa-regular fa-trash-can',
        bones = {'platelight'},
        onSelect = function()
            ResetTargetOnClick()
            if not holdingTrash then lib.notify({description=Strings["noTrash-toThrow"], type='error'}) return end

            holdingTrash = false
            Emote:cancelEmote()
            TriggerServerEvent("LH-Sanitation:ThrowTrashInTruck", owner)
        end 
    })
end)

local function returnZoneOnEnter()
    while true do 
        local seats = {IsVehicleSeatFree(garbageTruck, -1), IsVehicleSeatFree(garbageTruck, 0), IsVehicleSeatFree(garbageTruck, 1), IsVehicleSeatFree(garbageTruck, 2)}

        for i = 1, #seats do 
            if seats[i] == false then 
                break
            end 
            Wait(3000)
            DeleteEntity(garbageTruck)
            returnZone:remove()
            TriggerServerEvent("LH-Sanitation:CompleteSanitationJob", groupOwner)
            return
        end 
        Wait(1000)
    end 
end

RegisterNetEvent("LH-Sanitation:CompleteJob", function()
    sanitationZone:remove()
    RemoveBlip(sanitationWaypoint)

    returnZone = Zones.box({
        coords = Config.Truck.ReturnCoords,
        size = vec3(15,10,5),
        rotation = Config.Truck.ReturnHeading,
        debug = Config.Debug.Toggle,
        debugColour = Config.Debug.debugColour,
        onEnter = returnZoneOnEnter
    })
end)
