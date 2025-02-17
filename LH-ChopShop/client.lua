local Target = exports.ox_target
local Inventory = exports.ox_inventory 
local Input = lib.inputDialog
local Zone = lib.zones

local inJob, gotCar = false


--!---------------------------------------------------------------------------------------------------
--! random Function Stuff
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

function ResetTargetOnClick()
    Target:disableTargeting(true)
    Target:disableTargeting(false)
end

function SetUpWaypoint(coords)
    chopCarWaypoint = AddBlipForCoord(coords)
    EndTextCommandSetBlipName(chopCarWaypoint)
    SetBlipColour(chopCarWaypoint, 3)

    SetBlipRoute(chopCarWaypoint, true)
    SetBlipRouteColour(chopCarWaypoint, 3)
end

--!---------------------------------------------------------------------------------------------------
--! Start NPC Stuff
--!---------------------------------------------------------------------------------------------------
local function chopStartZoneOnEnter(self)
    self.chopshopStartNPC = SpawnEntity(Config.StartNPC.Model, Config.StartNPC.Coords, Config.StartNPC.Heading)

    Target:addLocalEntity(self.chopshopStartNPC, {
        {
            label = "Get A Job",
            name = 'deliveriesManageGroup',
            icon = 'fa-solid fa-car',
            distance = 1.5,
            onSelect = function()
                ResetTargetOnClick()

                if inJob then lib.notify({description=Strings["inJob"], type="error"}) return end 

                inJob = true
                lib.notify({description=Strings["wait-for-job"], type="inform"})
                TriggerServerEvent("LH-ChopShop:StartJob")
            end
        },
        {
            label = "Exchange Materials",
            name = 'deliveriesGetJob',
            icon = 'fa-regular fa-trash-can',
            distance = 1.5,
            onSelect = function()
                ResetTargetOnClick()
                
                local input = lib.inputDialog("Exchange Materials", Config.ExchangeInput)

                if not input then return else 
                    TriggerServerEvent('LH-ChopShop:ExchangeMaterials', input)
                end 
            end
    }})
end 

local function chopStartZoneOnExit(self)
    DeleteEntity(self.chopshopStartNPC)
end 

local chopStartZone = Zone.box({
    coords = Config.StartNPC.Coords,
    size = vec3(60,60,20),
    rotation = 30,
    debug = Config.Debug.Toggle,
    debugColour = Config.Debug.debugColour,
    onEnter = chopStartZoneOnEnter,
    onExit = chopStartZoneOnExit,
})

--!---------------------------------------------------------------------------------------------------
--! Chop Zone Stuff
--!---------------------------------------------------------------------------------------------------
local function ChopVehicleDoor(data, doorIndex)
    local part
    local success = lib.skillCheck(Config.Chop.SkillCheck.SkillCheckDifficulty, Config.Chop.SkillCheck.SkillCheckKeys)
    if not success then return end 

    if data.bones[1] == "chassis_dummy" then 
        part = "chassis"
    else 
        part = "door"
        SetVehicleDoorOpen(chopCar, doorIndex, false, false)
    end 
    print("Part: "..part)

    Target:disableTargeting(true)
    if lib.progressCircle({
        duration = Config.Chop.ProgressCircle.Duration,
        label = Config.Chop.ProgressCircle.Label,
        position = Config.Chop.ProgressCircle.Position,
        canCancel = Config.Chop.ProgressCircle.canCancel,
        disable = Config.Chop.ProgressCircle.Disable,
        anim = Config.Chop.ProgressCircle.Anim.Door,
        prop = Config.Chop.ProgressCircle.Prop,
        })
    then 
        TriggerServerEvent("LH-ChopShop:ChopDoorReward", part, data, doorIndex)
        Target:disableTargeting(false)
    else 
        Target:disableTargeting(false)
    end 
end 

local function ChopVehicleWheel(wheelIndex, data)
    local success = lib.skillCheck(Config.Chop.SkillCheck.SkillCheckDifficulty, Config.Chop.SkillCheck.SkillCheckKeys)
    local part = 'wheel'
    if not success then return end 

    Target:disableTargeting(true)
    if lib.progressCircle({
        duration = Config.Chop.ProgressCircle.Duration,
        label = Config.Chop.ProgressCircle.Label,
        position = Config.Chop.ProgressCircle.Position,
        canCancel = Config.Chop.ProgressCircle.canCancel,
        disable = Config.Chop.ProgressCircle.Disable,
        anim = Config.Chop.ProgressCircle.Anim.Wheel,
        prop = Config.Chop.ProgressCircle.Prop,
        })
    then 
        TriggerServerEvent("LH-ChopShop:ChopDoorReward", part, wheelIndex, data)
        Target:disableTargeting(false)
    else 
        Target:disableTargeting(false)
    end 
end 

RegisterNetEvent("LH-ChopShop:RemoveProp", function(part, data, doorIndex)
    if part == "door" then 
        Target:removeLocalEntity(chopCar, data.name)
        SetVehicleDoorCanBreak(chopCar, doorIndex, true)
        SetVehicleDoorBroken(chopCar, doorIndex, true)
    elseif part == "wheel" then 
        Target:removeLocalEntity(chopCar, data.name)
        SetVehicleWheelsCanBreak(chopCar, true)
        SetVehicleTyreBurst(chopCar, doorIndex, true, 1000.0)
    elseif part == "chassis" then 
        DeleteEntity(chopCar)
        lib.notify({description=Strings["job-completed"], tpye="success"})
        inJob, gotCar = false
    end 
end)

local function SetChopTargetOptions()
    Target:addLocalEntity(chopCar, {
        {
            -- Hood
            name = 'ox:option1',
            icon = 'fa-solid fa-car',
            label = 'Chop Hood',
            bones = {'bonnet'},
            onSelect = function(data)
                local doorIndex = 4
                ChopVehicleDoor(data, doorIndex)
            end 
        },{
            -- Front Driver Door
            name = 'ox:option2',
            icon = 'fa-solid fa-car',
            label = 'Chop Front Driver Door',
            bones = {'door_dside_f'},
            onSelect = function(data)
                local doorIndex = 0
                ChopVehicleDoor(data, doorIndex)
            end 
        },{
            -- Front Passenger Door
            name = 'ox:option3',
            icon = 'fa-solid fa-car',
            label = 'Chop Front Passenger Door',
            bones = {'door_pside_f'},
            onSelect = function(data)
                local doorIndex = 1
                ChopVehicleDoor(data, doorIndex)
            end 
        },{
            -- Rear Driver Door
            name = 'ox:option4',
            icon = 'fa-solid fa-car',
            label = 'Chop Rear Driver Door',
            bones = {'door_dside_r'},
            onSelect = function(data)
                local doorIndex = 2
                ChopVehicleDoor(data, doorIndex)
            end 
        },{
            -- Rear Passenger Door
            name = 'ox:option5',
            icon = 'fa-solid fa-car',
            label = 'Chop Rear Passenger Door',
            bones = {'door_pside_r'},
            onSelect = function(data)
                local doorIndex = 3
                ChopVehicleDoor(data, doorIndex)
            end 
        },{
            -- Trunk
            name = 'ox:option6',
            icon = 'fa-solid fa-car',
            label = 'Chop Trunk',
            bones = {'boot'},
            onSelect = function(data)
                local doorIndex = 5
                ChopVehicleDoor(data, doorIndex)
            end 
        },{
            -- Front Left Tire
            name = 'ox:option7',
            icon = 'fa-solid fa-car',
            label = 'Chop Front Left Tire',
            bones = {'wheel_lf'},
            onSelect = function(data)
                local wheelIndex = 0
                ChopVehicleWheel(wheelIndex, data)
            end 
        },{
            -- Front Right Tire
            name = 'ox:option8',
            icon = 'fa-solid fa-car',
            label = 'Chop Front Right Tire',
            bones = {'wheel_rf'},
            onSelect = function(data)
                local wheelIndex = 1
                ChopVehicleWheel(wheelIndex, data)
            end 
        },{
            -- Back Left Tire
            name = 'ox:option9',
            icon = 'fa-solid fa-car',
            label = 'Chop Back Left Tire',
            bones = {'wheel_lr'},
            onSelect = function(data)
                local wheelIndex = 4
                ChopVehicleWheel(wheelIndex, data)
            end 
        },{
            -- Back Right Tire
            name = 'ox:option10',
            icon = 'fa-solid fa-car',
            label = 'Chop Back Right Tire',
            bones = {'wheel_rr'},
            onSelect = function(data)
                local wheelIndex = 5
                ChopVehicleWheel(wheelIndex, data)
            end 
        },{
            -- Body
            name = 'ox:option11',
            icon = 'fa-solid fa-car',
            label = 'Chop Body',
            distance = 3,
            bones = {'chassis_dummy'},
            onSelect = function(data)
                local option = 'ox:option11'
                ChopVehicleDoor(data)
            end
        }
    })
end 

local function CreateChopZone()
    lib.notify({description=Strings["chop-zone"], type="inform"})
    local randomChopZone = math.random(1, #Config.ChopLocations)
    SetUpWaypoint(Config.ChopLocations[randomChopZone])

    local function chopCarZoneOnEnter()
        lib.notify({description=Strings["chop-car"], type="inform"})
        RemoveBlip(chopCarWaypoint)
        chopCarZone:remove()
        SetChopTargetOptions()
    end 

    chopCarZone = Zone.box({
        coords = Config.ChopLocations[randomChopZone],
        size = vec3(10,10,10),
        debug = Config.Debug.Toggle,
        debugColour = Config.Debug.debugColour,
        onEnter = chopCarZoneOnEnter,
    })
end 


--!---------------------------------------------------------------------------------------------------
--! Start Job Stuff
--!---------------------------------------------------------------------------------------------------
RegisterNetEvent("LH-ChopShop:AssignZone", function(randomZone, randomCar)
    lib.notify({description=Strings["get-car"], type="inform"})
    SetUpWaypoint(Config.Cars.Location[randomZone])

    local function chopSpawnCarZoneOnEnter()
        chopSpawnCarZone:remove()

        chopCar = SpawnVehicle(Config.Cars.List[randomCar], Config.Cars.Location[randomZone])

        lib.onCache('vehicle', function(value)
            if not value then return end
            if gotCar then return end 

            if value == chopCar then 
                gotCar = true
                RemoveBlip(chopCarWaypoint)
                CreateChopZone()
            end 
        end)
    end 

    chopSpawnCarZone = Zone.box({
        coords = vec3(Config.Cars.Location[randomZone].x, Config.Cars.Location[randomZone].y, Config.Cars.Location[randomZone].z),
        size = vec3(60,40,20),
        debug = Config.Debug.Toggle,
        debugColour = Config.Debug.debugColour,
        onEnter = chopSpawnCarZoneOnEnter,
    })
end)