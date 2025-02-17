local Zones = lib.zones
local Target = exports.ox_target
local Inventory = exports.ox_inventory
local Emote = exports.scully_emotemenu

local QBCore = exports["qbx-core"]:GetCoreObject()
local groupOwner, fishToComplete

while not LocalPlayer.state.isLoggedIn do
    Wait(500)
end

local citizenId = QBCore.Functions.GetPlayerData().citizenid
local inZone = false
local isFishing = false
local completedJob = false

function StartJobNPCZoneOnEnter()
    FishStartNPC = SpawnEntity(Config.NPC.StartModel, Config.NPC.StartModelCoords, Config.NPC.StartModelHeading)
    SetFishNPCTargetOptions(FishStartNPC)

    if completedJob then
        TriggerServerEvent("LH-Fishing:CompleteFishingJob", groupOwner)
        FisingZone:remove()
        completedJob = false
    end 
end 

--! Initialize NPC Zones
--? Job NPC Zone
local startJobNPCZone = Zones.box({
    coords = Config.NPC.StartModelCoords,
    size = vec3(25,20,10),
    rotation = 75,
    debug = Config.Debug.Toggle,
    debugColour = Config.Debug.debugColour,
    onEnter = StartJobNPCZoneOnEnter,
    onExit = StartJobNPCZoneOnExit
})

--? Fish Sell NPC Zone
local sellFishNPCZone = Zones.box({
    coords = Config.NPC.SellModelCoords,
    size = vec3(40,40,20),
    rotation = 60,
    debug = Config.Debug.Toggle,
    debugColour = Config.Debug.debugColour,
    onEnter = SellFishNPCZoneOnEnter,
    onExit = SellFishNPCZoneOnExit
})

--! Set Target Options
--? Sell Fish Target
function SetSellTargetOptions(entity)
    Target:addLocalEntity(NetworkGetNetworkIdFromEntity(entity), {
        label = "Sell Fish",
        name = 'sellFish',
        icon = 'fa-solid fa-fish-fins',
        distance = 1.5,
        onSelect = function()
            ResetTargetOnClick()
            local hour = GetClockHours()
            TriggerServerEvent('LH-Fishing:SellFish', hour)
        end 
    })
end 

--? Job NPC Target
function SetFishNPCTargetOptions(entity)
    Target:addLocalEntity(NetworkGetNetworkIdFromEntity(entity), {
    {
        label = "Manage Group",
        name = 'fishingManageGroup',
        icon = 'fa-regular fa-clipboard',
        distance = 1.5,
        onSelect = function()
            ResetTargetOnClick()
            lib.showContext('fishingInfoMenu')
        end
    },
    {
        label = "Get Job",
        name = 'fishingGetJob',
        icon = 'fa-solid fa-fish-fins',
        distance = 1.5,
        onSelect = function()
            ResetTargetOnClick()
            TriggerServerEvent('LH-Fishing:StartJob', citizenId)
        end
    }})
end 

--! Register Context Menus
--? Fishing Start Menu
lib.registerContext({
    id = 'fishingInfoMenu',
    title = 'Fishing Group',
    options = {
    {
        title = 'Create Group',
        description = 'Create a group to go fishing with',
        icon = 'check',
        onSelect = function()
            local groupInfo = lib.callback.await('LH-Fishing:fetchGroups', false)

            --? Check if player is already in a group
            lib.callback('LH-Fishing:checkIfInGroup', false, function(inGroup)
                if inGroup then 
                    lib.notify({description=Strings["already-member"], type = 'error'})
                else 
                    TriggerServerEvent('LH-Fishing:createGroup', citizenId)
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
            local groupInfo = lib.callback.await('LH-Fishing:fetchGroups', false)
            
            --? Calcualte how many groups there are
            local numberOfGroups = 0
            for _ in pairs(groupInfo) do 
                numberOfGroups = numberOfGroups + 1
            end 

            --? If no groups found show no groups found menu
            if numberOfGroups == 0 then 
                lib.showContext('fishingNoGroupsMenu')
                return
            end 

            --? Get all groups for context menu
            local groupFormat = lib.callback.await('LH-Fishing:formatGroups', false)
            lib.registerContext({
                id = 'fishingGroupMenu',
                title = 'Fishing Groups',
                options = groupFormat
            })
            lib.showContext('fishingGroupMenu')
        end 
    }}
})

--? Group Menus
lib.registerContext({
    id = 'fishingNoGroupsMenu',
    title = 'Fishing Groups',
    options = {
    {
        title = 'No Groups Found',
        description = 'Create your own fishing group to get started'
    }
    }
})

RegisterNetEvent('LH-Fishing:fishingGroupOptionMenu', function(owner)
    lib.registerContext({
        id = 'fishingGroupOptionMenu',
        title = 'Fishing Groups',
        options = {
            {
                title = 'Join Group',
                onSelect = function()
                    TriggerServerEvent('LH-Fishing:joinGroup', owner, citizenId)
                end 
            },
            {
                title = 'Leave Group',
                onSelect = function()
                    TriggerServerEvent('LH-Fishing:leaveGroup', citizenId)
                end 
            }
        }
    })
    lib.showContext('fishingGroupOptionMenu')
end)


--! Start Job Stuff
local function reelInFish()
    local fish = Config.FishingLoot[math.random(1, #Config.FishingLoot)]
    local chanceToCatch = math.random(1,100)

    if fish.chance > chanceToCatch then 
        lib.notify({description=Strings["got-nibble"], type="inform"})
        Wait(1000)

        local success = lib.skillCheck(fish['skillcheck'], Config.SkillCheckKeys)
        if success then 
            lib.notify({description="You caught a ".. fish.name .."!", type="success"})
            print("Group owner 2: ".. groupOwner)
            TriggerServerEvent("LH-Fishing:giveFish", fish, groupOwner, fishToComplete)
            Emote:cancelEmote()
            isFishing = false
        else 
            lib.notify({description=Strings["lost-fish"], type="error"})
        end 
    end 
end

local function startFishing(slot, durability)
    if isFishing then return end
    Emote:playEmoteByCommand('fishing2')
    isFishing = true

    local seconds = 0
    CreateThread(function()
        while isFishing do 
            Wait(5000)
            seconds = seconds + 5
            local chance = math.random() * 100
            if chance + seconds > 100 then 
                reelInFish(slot)
            end 
        end 
    end)
end

local function FishingZoneOnEnter()
    inZone = true
    RemoveBlip(fishingWaypoint)
end

local function FishingZoneOnExit()
    inZone = false
end

RegisterNetEvent('LH-Fishing:StartFishingJob', function(ActiveFishingZone, fishToCatch, fishGroupOwner)
    print("Group owner 1: ".. fishGroupOwner)
    groupOwner = fishGroupOwner
    fishToComplete = fishToCatch
    lib.notify({description=Strings["goto-zone"], type="inform"}) 
    FisingZone = lib.zones.box({
        coords = Config.ActiveFishingZones[ActiveFishingZone],
        size = vec3(80,80,20),
        rotation = 75,
        debug = Config.Debug.Toggle,
        debugColour = Config.Debug.debugColour,
        onEnter = FishingZoneOnEnter,
        onExit = FishingZoneOnExit
    })
    SetUpWaypoint(Config.ActiveFishingZones[ActiveFishingZone])
end)

RegisterNetEvent('LH-Fishing:Fish', function()
    if not inZone then 
        lib.notify({description=Strings["no-zone"], type="error"})
        return
    end 

    startFishing()
end)

RegisterNetEvent('LH-Fishing:CompleteJob', function()
    lib.notify({description=Strings["return-job"], type"success"})
    completedJob = true
end)