local Target = exports.ox_target
local Inventory = exports.ox_inventory 
local Input = lib.inputDialog
local Zone = lib.zones

local animal, inZone
local BaitCooldownBool = false 

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
local function huntingShopZoneOnEnter()
    huntingShopNPC = SpawnEntity(Config.ShopNPC.model, Config.ShopNPC.coords, Config.ShopNPC.heading)

    Target:addLocalEntity(huntingShopNPC, {
        label = 'Hunting Shop',
        name = 'huntingShopOpen',
        distance = 1.5,
        icon = 'fa-solid fa-basket-shopping',
        onSelect = function()
            Inventory:openInventory('shop', {type = 'Hunting', id = 1})
        end 
    })
end

local function huntingShopZoneOnExit(self)
    DeleteEntity(huntingShopNPC)
end

local huntingShopZone = Zone.box({
    coords = Config.ShopNPC.coords,
    size = vec3(20,20,10),
    rotation = -12,
    debug = Config.Debug.Toggle,
    debugColour = Config.Debug.debugColour,
    onEnter = huntingShopZoneOnEnter,
    onExit = huntingShopZoneOnExit,
})

local HuntingShopBlip = AddBlipForCoord(Config.ShopNPC.coords)
SetBlipSprite(HuntingShopBlip, Config.HuntingZone.ZoneSprite)
SetBlipColour(HuntingShopBlip, Config.HuntingZone.ZoneColor)
SetBlipDisplay(HuntingShopBlip, 2)
SetBlipAsShortRange(HuntingShopBlip, true)
AddTextEntry("HUNTING-STORE", "Hunting Store")
BeginTextCommandSetBlipName("HUNTING-STORE")
EndTextCommandSetBlipName(HuntingShopBlip)


--!---------------------------------------------------------------------------------------------------
--! Animal Stuff
--!---------------------------------------------------------------------------------------------------
local function SpawnAnimal(coords)
    local randomAnimal = math.random(1, #Config.Animals)
    local randomX = coords.x + math.random(-20, 20)
    local randomY = coords.y + math.random(-20, 20)
    local unusedBool, randomZ = GetGroundZFor_3dCoord(randomX, randomY, 1000.0, false)

    local entity = Config.Animals[randomAnimal].model
    legal = Config.Animals[randomAnimal].legal 
    RequestModel(GetHashKey(entity))
    while not HasModelLoaded(GetHashKey(entity)) do 
        Wait(100)
    end 

    animal = CreatePed(28, entity, randomX, randomY, randomZ, 0, true, true)
    while not DoesEntityExist(animal) do 
        Wait(1000)
    end 
    TaskGoStraightToCoord(animal, coords.x, coords.y, coords.z, 1.0, 10.0, 0, 0)
end


--!---------------------------------------------------------------------------------------------------
--! Zone Stuff
--!---------------------------------------------------------------------------------------------------
local function huntingZoneOnEnter()
    inZone = true
end 

local function huntingZoneOnExit()
    inZone = false
end 

local huntingZone = lib.zones.sphere({
    coords = Config.HuntingZone.Coords,
    radius = Config.HuntingZone.Radius,
    onEnter = huntingZoneOnEnter,
    onExit = huntingZoneOnExit,
    debug = Config.Debug.Toggle,
    debugColour = Config.Debug.debugColour,
})

local HuntingZoneBlip = AddBlipForCoord(Config.HuntingZone.Coords)
SetBlipSprite(HuntingZoneBlip, Config.HuntingZone.ZoneSprite)
SetBlipColour(HuntingZoneBlip, Config.HuntingZone.ZoneColor)
SetBlipDisplay(HuntingZoneBlip, 2)
SetBlipAsShortRange(HuntingZoneBlip, true)
AddTextEntry("HUNTING-ZONE", "Hunting Zone")
BeginTextCommandSetBlipName("HUNTING-ZONE")
EndTextCommandSetBlipName(HuntingZoneBlip)

local HuntingZoneRadius = AddBlipForRadius(Config.HuntingZone.Coords, Config.HuntingZone.Radius)
SetBlipColour(HuntingZoneRadius, Config.HuntingZone.ZoneColor)
SetBlipAlpha(HuntingZoneRadius, 80)

--!---------------------------------------------------------------------------------------------------
--! Bait Stuff
--!---------------------------------------------------------------------------------------------------
local function GetPlayerOffset()
    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)
    local offset = Config.Bait.ShapeTestOffSets.Start
    local coords = GetOffsetFromEntityInWorldCoords(ped, offset.x, offset.y, offset.z - 1.0)
    return vec4(coords.x, coords.y, coords.z, GetEntityHeading(ped) - offset.w)
end 

local function BaitCooldown()
    BaitCooldownBool = true
    Wait(Config.Bait.Cooldown)
    BaitCooldownBool = false
end 

RegisterNetEvent('LH-Hunting:PlaceBait', function(data)
    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)
    local coords, heading = vec3(GetPlayerOffset())

    local ray = StartShapeTestRay(pcoords, coords, 17, ped, 7)
    local _, hit, endCoords, surfaceNormal, materialHash, entity = GetShapeTestResultIncludingMaterial(ray)

    local found = false
    for i = 1, #Materials do 
        if materialHash == Materials[i] then 
            found = true
        end
    end 

    if not inZone then lib.notify(Strings["can-plant-here"]) return end
    if not found then lib.notify(Strings["can-plant-here"]) return end
    if BaitCooldownBool then lib.notify(Strings["bait-cooldown"]) return end 


    if lib.progressCircle({
        duration = Config.Bait.Duration,
        label = Config.Bait.Label,
        position = "bottom",
        useWhileDead = false,
        allowFalling = false,
        canCancel = true,
        disable = {move = true},
        anim = Config.Bait.Animation,
        prop = Config.Bait.Prop,
    }) 
    then 
        TriggerServerEvent("LH-Hunting:RemoveBait")
        lib.notify(Strings["placed-bait"])
        BaitCooldown()

        Wait(Config.Bait.Cooldown / 2)
        SpawnAnimal(pcoords)
    else 
        print("Canceled Bait Place")
    end
end)


--!---------------------------------------------------------------------------------------------------
--! Knife Stuff
--!---------------------------------------------------------------------------------------------------
RegisterNetEvent("LH-Hunting:SkinAnimal", function(data)
    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)
    local closestPed = lib.getClosestPed(pcoords, 1.5)
    local hash = GetEntityModel(closestPed)

    if not IsPedDeadOrDying(closestPed, 1) then return end  -- Checks if the closestPed is dead

    local canSkin = false   -- Checks if this is an animal you can skin (Config.Animals)
    for i = 1, #Config.Animals do 
        if hash == GetHashKey(Config.Animals[i].model) then 
            canSkin = true
        end 
    end 
    if not canSkin then return end 
    
    local canCarryBool = lib.callback.await("LH-Hunting:canCarryItem", false, 'animal_pelt_legal_1', 1)   -- Checks if you can carry the pelt
    if not canCarryBool then return end

    local baitedAnimal = false  -- Checks if this was an animal that you baited
    if closestPed == animal then baitedAnimal = true end 

    if lib.progressCircle({     -- If everything is ok then starts the skin
        duration = Config.Knife.Duration,
        label = Config.Knife.Label,
        position = "bottom",
        useWhileDead = false,
        allowFalling = false,
        canCancel = true,
        disable = {move = true},
        anim = Config.Knife.Animation,
        prop = Config.Knife.Prop
    })
    then 
        local closestPedNetId = NetworkGetNetworkIdFromEntity(closestPed)
        TriggerServerEvent("LH-Hunting:GivePelt", closestPedNetId, baitedAnimal, legal)
    else 
        print("Canceled animal skinning")
    end 
end)


--!---------------------------------------------------------------------------------------------------
--! Sales Stuff
--!---------------------------------------------------------------------------------------------------
local function huntinSalesZoneOnEnter() 
    print("Entered Zone")
    huntingSalesNPC = SpawnEntity(Config.SellNPC.Model, Config.SellNPC.Coords, Config.SellNPC.Heading)

    Target:addLocalEntity(huntingSalesNPC, {
        label = 'Sell Pelts',
        name = 'huntingSales',
        distance = 1.5,
        icon = 'fa-solid fa-basket-shopping',
        onSelect = function()
            local hour = GetClockHours()
            TriggerServerEvent("LH-Hunting:SellPelts", hour)
        end 
    })
end 

local function huntingSalesZoneOnExit()
    DeleteEntity(huntingSalesNPC)
end 

local huntingSalesZone = Zone.box({
    coords = Config.SellNPC.Coords,
    size = vec3(160,175,10),
    rotation = 5,
    debug = Config.Debug.Toggle,
    debugColour = Config.Debug.debugColour,
    onEnter = huntinSalesZoneOnEnter,
    onExit = huntingSalesZoneOnExit,
})

local HuntingSalesBlip = AddBlipForCoord(Config.SellNPC.Coords)
SetBlipSprite(HuntingSalesBlip, Config.HuntingZone.ZoneSprite)
SetBlipColour(HuntingSalesBlip, Config.HuntingZone.ZoneColor)
SetBlipDisplay(HuntingSalesBlip, 2)
SetBlipAsShortRange(HuntingSalesBlip, true)
AddTextEntry("HUNTING-SALES", "Hunting Sales")
BeginTextCommandSetBlipName("HUNTING-SALES")
EndTextCommandSetBlipName(HuntingSalesBlip)


--!---------------------------------------------------------------------------------------------------
--! Hunting Rifle Stuff
--!---------------------------------------------------------------------------------------------------
local scopedWeaponInHand = false

local scopedWeapons = {
    [-1327835241] = true, --WEAPON_HUNTINGRIFLE
}

lib.onCache('weapon', function(value)
    if value and scopedWeapons[value] then
        scopedWeaponInHand = true

        CreateThread(function()
            while scopedWeaponInHand do
                Wait(0)
                isScoped = GetPedConfigFlag(PlayerPedId(), 78)
                if isScoped then 
                    ShowHudComponentThisFrame(14) 

                    local unusedBool, aimedEntity = GetEntityPlayerIsFreeAimingAt(PlayerId())
                    if GetPedType(aimedEntity) == 28 then 
                        -- Allows to shoot gun
                    else 
                        DisablePlayerFiring(PlayerId(), true)
                    end 
                else 
                    DisablePlayerFiring(PlayerId(), true)
                end 
            end
        end)
    else
        scopedWeaponInHand = false
    end
end)
