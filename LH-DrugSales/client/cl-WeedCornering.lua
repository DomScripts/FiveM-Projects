local Target = exports.ox_target
local Inventory = exports.ox_inventory 
local Input = lib.inputDialog
local Zone = lib.zones
local Emote = exports.scully_emotemenu

local cornerActive, inZone = false

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

--!---------------------------------------------------------------------------------------------------
--! Corner Drugs Stuff
--!---------------------------------------------------------------------------------------------------
function SetCorneringNPCSellTargetOptions(entity)
    Target:addLocalEntity(entity, {
        label = "Hand Drugs",
        name = "HandOffDrugs",
        icon = "fa-solid fa-hand-holding-dollar",
        distance = 1.5,
        items = {'fullbag'},
        onSelect = function(data)
            local count = Inventory:Search('count', 'fullbag')
            if count == 0 then lib.notify({description=String["no-more-weed"], type ="error"}) return end 

            local ped = PlayerPedId()
            TaskTurnPedToFaceEntity(ped, data.entity, 2000)
            TaskTurnPedToFaceEntity(data.entity, ped, 2000)
            Wait(500)

            Emote:playEmoteByCommand('keyfob')
            TaskPlayAnim(data.entity, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 2.0, 2.0, 1000, 51, 0, false, false ,false)
            Wait(1000)

            if math.random(1, 100) <= Config.Cornering.ChanceToAlert then exports['ps-dispatch']:SuspiciousActivity() end -- Alert PD
            TriggerServerEvent("LH-DrugSales:WeedCornering.HandOff")

            TaskWanderInArea(data.entity, GetEntityCoords(ped), 100.0, 2, 2.0)
            Wait(30000)
            DeleteEntity(data.entity)
        end,
    })
end 

function SpawnCorneringNPC(data, coords)
    local randomX, randomY, randomZ, unusedBool
    local randomCoords = {randomXoffset = 0, randomYoffset = 0}
    local function GetRandomSpawnCoords(coords)
        for k,_ in pairs(randomCoords) do
            if math.random(0, 1) == 0 then 
                randomCoords[k] = math.random(-30, -20)
            else 
                randomCoords[k] = math.random(20, 30)
            end 
        end
    
        randomX = coords.x + randomCoords.randomXoffset
        randomY = coords.y + randomCoords.randomYoffset
        unusedBool, randomZ = GetGroundZFor_3dCoord(randomX, randomY, coords.z + 10.0, false)
    end 

    GetRandomSpawnCoords(coords)
    while randomZ > coords.z + 5.0 do 
        GetRandomSpawnCoords(coords)
    end 

    local entity = Config.CustomerNPCModels[math.random(1, #Config.CustomerNPCModels)]
    RequestModel(GetHashKey(entity))
    while not HasModelLoaded(GetHashKey(entity)) do 
        Wait(100)
    end 

    local CorneringNPC = CreatePed(28, entity, randomX, randomY, randomZ, 0, true, true)
    while not DoesEntityExist(CorneringNPC) do 
        Wait(1000)
    end 

    SetNetworkIdCanMigrate(CorneringNPC, false)
    SetCorneringNPCSellTargetOptions(CorneringNPC)

    local ts = OpenSequenceTask()
    TaskGoStraightToCoord(0, coords.x + math.random(-5, 5), coords.y + math.random(-5, 5), coords.z, 1.0, 5.0, 0, 0)
    TaskTurnPedToFaceEntity(0, data.entity, -1)
    CloseSequenceTask(ts)

    TaskPerformSequence(CorneringNPC, ts)

end 

function StartCorneringStuff(data)
    if not inZone then lib.notify({description=Strings["not-inZone"], type="error"}) return end
    local onDuty = lib.callback.await('LH-DrugSales:WeedCornering.GetOnDutyCops')
    if onDuty < Config.Cornering.MinCops then lib.notify({description=Strings["not-enough-cops"], type="error"}) return end 

    ResetTargetOnClick()
    SetStopCorneringTargetOption(data)
    SetVehicleDoorOpen(data.entity, 5, false, false)
    Target:removeGlobalVehicle("StartCorneringTargetOption")
    lib.notify({description=Strings["start-cornering"], type="inform"})

    hasCarMoved = false 
    local seconds = 0
    local carCoords = GetEntityCoords(data.entity)

    CreateThread(function()
        while not hasCarMoved do 
            if GetEntityCoords(data.entity).x >= carCoords.x - 5 and GetEntityCoords(data.entity).x <= carCoords.x + 5 and GetEntityCoords(data.entity).y >= carCoords.y - 5 and GetEntityCoords(data.entity).y <= carCoords.y + 5 then 
                seconds += 5
                local chance = math.random() * 100
                if chance + seconds > 100 then 
                    SpawnCorneringNPC(data, carCoords)
                end 
            else 
                StopCorneringStuff(data)
                hasCarMoved = true
            end 
            Wait(5000)
        end 
    end )
end 

function StopCorneringStuff(data)
    hasCarMoved = true
    ResetTargetOnClick()
    SetStartCorneringTargetOption()
    SetVehicleDoorShut(data.entity, 5, false)
    Target:removeLocalEntity(data.entity, "StopCorneringTargetOption")
    lib.notify({description=Strings["stop-cornering"], type="inform"})
end

function SetStopCorneringTargetOption(data)
    Target:addLocalEntity(data.entity, {
        label = "Stop Cornering",
        name = "StopCorneringTargetOption",
        icon = "fa-solid fa-person",
        distance = 1.5,
        bones = {'boot'},
        onSelect = StopCorneringStuff,
    })
end 

function SetStartCorneringTargetOption()
    Target:addGlobalVehicle({
        label = "Start Cornering",
        name = "StartCorneringTargetOption",
        icon = "fa-solid fa-person",
        distance = 1.5,
        bones = {'boot'},
        items = {'fullbag'},
        onSelect = StartCorneringStuff,
    })
end 
SetStartCorneringTargetOption()

local function CorneringSaleZoneOnEnter() inZone = true end 

local function CorneringSaleZoneOnExit() inZone = false end 

local CorneringSaleZone = Zone.poly({
    points = Config.Cornering.SellZone,
    thickness = 100,
    debug = Config.Debug.Toggle,
    debugColour = Config.Debug.debugColour,
    onEnter = CorneringSaleZoneOnEnter,
    onExit = CorneringSaleZoneOnExit,
})





RegisterCommand('drugTest', function()
    local v = GetIsTaskActive(CorneringNPC, 0x7D8F4411)
    if not DoesEntityExist(CorneringNPC) then 
        print("Entity not spawned yet")
        return
    end 
    print(v)
end)