local Target = exports.ox_target
local Inventory = exports.ox_inventory 
local Input = lib.inputDialog
local Zone = lib.zones
local Emote = exports.scully_emotemenu


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

function SetUpWaypoint(coords)
    weedRunSaleWaypoint = AddBlipForCoord(coords)
    EndTextCommandSetBlipName(weedRunSaleWaypoint)
    SetBlipColour(weedRunSaleWaypoint, 3)

    SetBlipRoute(weedRunSaleWaypoint, true)
    SetBlipRouteColour(weedRunSaleWaypoint, 3)
end

function ResetTargetOnClick()
    Target:disableTargeting(true)
    Target:disableTargeting(false)
end


--!---------------------------------------------------------------------------------------------------
--! Spawn Start NPC Stuff
--!---------------------------------------------------------------------------------------------------
local function StartWeedRunNPCZoneOnEnter(self)
    self.StartWeedRunNPC = SpawnEntity(Config.StartWeedRunNPC.Model, Config.StartWeedRunNPC.Coords, Config.StartWeedRunNPC.Heading)

    Target:addLocalEntity(self.StartWeedRunNPC, {
        label = "Get Job",
        name = "StartWeedRun",
        icon = "fa-solid fa-clipboard-question",
        distance = 1.5,
        onSelect = function()
            if Inventory:Search('count', 'weedbrick') < Config.WeedRun.MinToStart then lib.notify({description=Strings["not-enough-bricks"], type="inform"}) return end
            local onDuty = lib.callback.await('LH-DrugSales:WeedRuns.GetOnDutyCops')
            if onDuty < Config.WeedRun.MinCops then lib.notify({description=Strings["not-enough-cops"], type="error"}) return end 
            TriggerServerEvent("LH-DrugSales:WeedRuns.StartRun") 
        end 
    })
end 

local function StartWeedRunNPCZoneOnExit(self)
    DeleteEntity(self.StartWeedRunNPC)
end 

local StartWeedRunNPCZone = Zone.sphere({
    coords = Config.StartWeedRunNPC.Coords,
    radius = 45,
    onEnter = StartWeedRunNPCZoneOnEnter,
    onExit = StartWeedRunNPCZoneOnExit,
    debug = Config.Debug.Toggle,
    debugColour = Config.Debug.debugColour,
})


--!---------------------------------------------------------------------------------------------------
--! Create Weed Run Stuff
--!---------------------------------------------------------------------------------------------------
local function WeedRunDropOffZoneOnEnter(self, data)
    local WeedRunDropOffNPC = SpawnEntity(Config.CustomerNPCModels[math.random(1, #Config.CustomerNPCModels)], Config.WeedRun.DropOff[self.randomLocation])

    Target:addLocalEntity(WeedRunDropOffNPC, {
        label = "Hand Package",
        name = "handweedpackageoff",
        icon = "fa-solid fa-cannabis",
        distance = 1.5,
        items = {'weedbrick'},
        onSelect = function()
            if lib.progressCircle({
                duration = Config.WeedRun.ProgressCircle.Duration,
                label = Config.WeedRun.ProgressCircle.Label,
                position = Config.WeedRun.ProgressCircle.Position,
                canCancel = Config.WeedRun.ProgressCircle.canCancel,
                disable = Config.WeedRun.ProgressCircle.Disable,
            })
            then
                if math.random(1, 100) <= Config.Cornering.ChanceToAlert then exports['ps-dispatch']:SuspiciousActivity() end -- Alert PD
                RemoveBlip(weedRunSaleWaypoint)
                TriggerServerEvent("LH-DrugSales:weedRuns.DropOffPackage")
            end 
        end 
    })
end 

RegisterNetEvent("LH-DrugSales:WeedRuns.CreateDropOff", function(randomLocation)
    if WeedRunDropOffZone then WeedRunDropOffZone:remove() end
    SetUpWaypoint(Config.WeedRun.DropOff[randomLocation])
    local WeedRunDropOffZone = Zone.sphere({
        coords = Config.WeedRun.DropOff[randomLocation],
        radius = 45,
        onEnter = WeedRunDropOffZoneOnEnter,
        debug = Config.Debug.Toggle,
        debugColour = Config.Debug.debugColour,
    }) 

    WeedRunDropOffZone.randomLocation = randomLocation
end)
