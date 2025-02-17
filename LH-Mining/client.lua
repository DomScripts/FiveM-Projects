local Target = exports.ox_target
local Inventory = exports.ox_inventory 
local Input = lib.inputDialog
local Zone = lib.zones

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

--!---------------------------------------------------------------------------------------------------
--! Shop Stuff
--!---------------------------------------------------------------------------------------------------
local function miningShopZoneOnEnter()
    miningShopNPC = SpawnEntity(Config.ShopNPC.model, Config.ShopNPC.coords, Config.ShopNPC.heading)

    Target:addLocalEntity(miningShopNPC, {
        label = 'Mining Shop',
        name = 'miningShopOpen',
        distance = 1.5,
        icon = 'fa-solid fa-basket-shopping',
        onSelect = function()
            Inventory:openInventory('shop', {type = 'Mining', id = 1})
        end 
    })
end

local function miningShopZoneOnExit()
    DeleteEntity(miningShopNPC)
end

local miningShopZone = Zone.box({
    coords = Config.ShopNPC.coords,
    size = vec3(200,150,20),
    rotation = 30,
    debug = Config.Debug.Toggle,
    debugColour = Config.Debug.debugColour,
    onEnter = miningShopZoneOnEnter,
    onExit = miningShopZoneOnExit,
})


--!---------------------------------------------------------------------------------------------------
--! Rock Stuff
--!---------------------------------------------------------------------------------------------------
local function rockSpawnZoneOnEnter()
    TriggerServerEvent("LH-Mining:SpawnMinableRocks")
    Target:addModel(Config.MinableRocksZone.rockModel, {
        label = "Mine Rock",
        name = "mineRock",
        distance = 1.5,
        icon = "fa-solid fa-hammer",
        onSelect = function(data)
            local entity = NetworkGetNetworkIdFromEntity(data.entity)
            local coords = GetEntityCoords(data.entity)
            TriggerServerEvent("LH-Mining:SearchInventoryForTools", entity, coords)
        end
    })
end

local function rockSpawnZoneOnExit()
    Target:removeModel(Config.MinableRocksZone.rockModel, "mineRock")
end

local rockSpawnZone = Zone.sphere({
    coords = Config.MinableRocksZone.coords,
    radius = 150,
    debug = Config.Debug.Toggle,
    debugColour = Config.Debug.debugColour,
    onEnter = rockSpawnZoneOnEnter,
    onExit = rockSpawnZoneOnExit,
})

RegisterNetEvent("LH-Mining:StartMining", function(entity, coords, tool, rewardAmount)
    Target:disableTargeting(true)
    if lib.progressCircle({
        duration = Config.Tools[tool].time,
        label = "Mining Rock",
        position = "bottom",
        useWhileDead = false,
        allowFalling = true,
        canCancel = true,
        disable = {move = true},
        anim = Config.Tools[tool].animation,
        prop = Config.Tools[tool].prop,

    }) then 
        TriggerServerEvent("LH-Mining:MineRockReward", entity, coords, rewardAmount)
        Target:disableTargeting(false)
    else 
        print("Canceled mining") 
        Target:disableTargeting(false)
    end
end)


--!---------------------------------------------------------------------------------------------------
--! Process Stuff
--!---------------------------------------------------------------------------------------------------
Target:addSphereZone({
    coords = Config.Process.coords,
    radius = 1,
    debug = Config.Debug.Toggle,
    debugColour = Config.Debug.debugColour,
    options = {
        {
            label = "Process Dirt",
            name = "processDirt",
            distance = 1.5,
            icon = "fa-solid fa-mortar-pestle",
            onSelect = function()
                local input = Input("Process Dirt", Config.Process.input)

                if not input then return end 
                TriggerServerEvent("LH-Mining:SearchInventoryForDirt", input)
            end
        }
    }
})

RegisterNetEvent("LH-Mining:StartProcess", function(input)
    Target:disableTargeting(true)
    if lib.progressCircle({
        duration = Config.Process.time,
        label = "Cleaning Dirt",
        position = "bottom",
        useWhileDead = false,
        allowFalling = true,
        canCancel = true,
        disable = {move = true},
        anim = Config.Process.animation,
        prop = {},
    }) then 
        TriggerServerEvent("LH-Mining:ProcessReward", input)
        Target:disableTargeting(false)
    else 
        print("Canceled Process")
        Target:disableTargeting(false)
    end 
end)


--!---------------------------------------------------------------------------------------------------
--! Gem Drill Stuff
--!--------------------------------------------------------------------------------------------------- 
local function drillSpawnZoneOnEnter(self)
    self.drill = CreateObject(GetHashKey(Config.Drill.model), Config.Drill.coords, false)
    Wait(100)
    SetEntityHeading(self.drill, Config.Drill.heading)

    Target:addLocalEntity(self.drill, {
        label = 'Open Gemrock',
        name = 'gemRockDrill',
        icon = 'fa-regular fa-gem',
        distance = 1.5,
        onSelect = function()
            TriggerServerEvent("LH-Mining:BreakOpenGemRock")
        end 
    })
end

local function drillSpawnZoneOnExit(self)
    DeleteEntity(self.drill)
end

local drillSpawnZone = Zone.box({
    coords = vec3(Config.Drill.coords.x + 20, Config.Drill.coords.y - 10, Config.Drill.coords.z),
    size = vec3(40,65,20),
    rotation = 55,
    debug = Config.Debug.Toggle,
    debugColour = Config.Debug.debugColour,
    onEnter = drillSpawnZoneOnEnter,
    onExit = drillSpawnZoneOnExit,
})

RegisterNetEvent("LH-Mining:StartBreakOpen", function(amount)
    Target:disableTargeting(true)
    if lib.progressCircle({
        duration = Config.Drill.time,
        label = "Breaking Rock",
        position = "bottom",
        useWhileDead = false,
        allowFalling = true,
        canCancel = true,
        disable = {move = true},
        anim = Config.Drill.animation,
        prop = {},
    }) then 
        TriggerServerEvent("LH-Mining:DrillReward", amount)
        Target:disableTargeting(false)
    else 
        print("Canceled Process")
        Target:disableTargeting(false)
    end 
end)