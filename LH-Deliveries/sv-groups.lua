local Inventory = exports.ox_inventory 

local QBCore = exports["qbx-core"]:GetCoreObject()

DeliveriesGroups = {}
BoxesDroppedOffTracker = {}
CompletedTripsTracker = {}

lib.callback.register('LH-Deliveries:fetchGroups', function()
    return DeliveriesGroups
end)

RegisterNetEvent('LH-Deliveries:createGroup', function(owner)
    DeliveriesGroups[owner] = {false}     -- Creates open group, assigns owner citizenId as key and in-job to false
end)

local function CheckOwnerOrMember(citizenId)
    local isOwner = false
    local isMember = false

    for key, array in pairs(DeliveriesGroups) do 
        if (key == citizenId) then 
            isOwner = true      -- Loops key's to check if player owns a group
            break
        end 

        for index, value in ipairs(array) do 
            if (value == citizenId) then 
                isMember = true     -- Loops value's to check if player is a member of a group
                break
            end 
        end
    end 

    return isOwner, isMember
end 

lib.callback.register('LH-Deliveries:formatGroups', function()
    local groupFormat = {}

    for key, _ in pairs(DeliveriesGroups) do
        local citizenId = tostring(key)
        local Player = QBCore.Functions.GetPlayerByCitizenId(citizenId)
        local firstname = Player.PlayerData.charinfo.firstname
        local lastname = Player.PlayerData.charinfo.lastname
        table.insert(groupFormat, {
            title = firstname..' '..lastname,
            event = 'LH-Deliveries:deliveriesGroupOptionMenu',
            args = citizenId
        })
    end 

    return groupFormat
end)

lib.callback.register('LH-Deliveries:checkIfInGroup', function(source, citizenId)
    local isOwner, isMember = CheckOwnerOrMember(citizenId)

    if isOwner or isMember then 
        return true 
    else 
        return false 
    end 
end)

RegisterNetEvent('LH-Deliveries:joinGroup', function(owner, citizenId)
    local isOwner, isMember = CheckOwnerOrMember(citizenId)
    if #DeliveriesGroups[owner] == 2 then lib.notify(source, {description=Strings["group-full"], type = "error"}) return end

    if isOwner then 
        lib.notify(source, {description=Strings["already-own"], type = "error"})
    elseif isMember then
        lib.notify(source, {description=Strings["already-member"], type = "error"})
    elseif DeliveriesGroups[owner][1] then 
        lib.notify(source, {description=Strings["group-locked"], type = "error"})
    else 
        table.insert(DeliveriesGroups[owner], citizenId)
        lib.notify(source, {description=Strings["join-group"], type = "success"})
    end 

end)

RegisterNetEvent('LH-Deliveries:leaveGroup', function(citizenId)
    local isOwner, isMember = CheckOwnerOrMember(citizenId)

    if isOwner then 
        DeliveriesGroups[citizenId] = nil     -- If owner remove entire group
        lib.notify(source, {description=Strings["owner-leave"], type = "success"})
    elseif isMember then
        DeliveriesGroups[key][index] = nil    -- If member remove from group
        lib.notify(source, {description=Strings["member-leave"], type = "success"})
    else 
        lib.notify(source, {description=Strings["not-member"], type = "error"})
    end 
end)


RegisterNetEvent('LH-Deliveries:StartJob', function(citizenId)
    local src = source
    local isOwner, isMember = CheckOwnerOrMember(citizenId)

    if not isOwner and not isMember then 
        lib.notify(src, {description=Strings["no-group"], type="error"})
    elseif isMember then 
        lib.notify(src, {description=Strings["leader-start-job"], type="error"})
    else 
        if not DeliveriesGroups[citizenId][1] then 
            DeliveriesGroups[citizenId][1] = true
            BoxesDroppedOffTracker[citizenId] = 0
            CompletedTripsTracker[citizenId] = 0
            
            local randomZone = math.random(#Config.DeliveryZones)
            TriggerClientEvent('LH-Deliveries:CreateZone', src, citizenId, randomZone, true, false)
            lib.notify(src, {description=Strings["goto-zone"], type="inform"})
            for i = 2, #DeliveriesGroups[citizenId] do
                local Player = DeliveriesGroups[citizenId][i]
                TriggerClientEvent('LH-Deliveries:CreateZone', QBCore.Functions.GetPlayerByCitizenId(Player).PlayerData.source, citizenId, randomZone, false, false)
                lib.notify(QBCore.Functions.GetPlayerByCitizenId(Player).PlayerData.source, {description=Strings["goto-zone"], type="inform"})
            end
        else 
            lib.notify(src, {description=Strings["in-job"], type="error"})
        end
    end 
end)

RegisterNetEvent('LH-Deliveries:DeliveryTruckSendNetId', function(citizenId, deliveryTruckNetId)
    local src = source
    TriggerClientEvent('LH-Deliveries:DeliveryTruckSetTarget', src, deliveryTruckNetId)
    for i = 2, #DeliveriesGroups[citizenId] do
        local Player = DeliveriesGroups[citizenId][i]
        TriggerClientEvent('LH-Deliveries:DeliveryTruckSetTarget', QBCore.Functions.GetPlayerByCitizenId(Player).PlayerData.source, deliveryTruckNetId)
    end
end)

RegisterNetEvent("LH-Deliveries:DropOffBox", function(owner)
    BoxesDroppedOffTracker[owner] = BoxesDroppedOffTracker[owner] + 1

    if BoxesDroppedOffTracker[owner] == Config.Job.Boxes then 
        BoxesDroppedOffTracker[owner] = 0
        CompletedTripsTracker[owner] = CompletedTripsTracker[owner] + 1
        local randomZone = math.random(#Config.DeliveryZones)

        if CompletedTripsTracker[owner] == Config.Job.Trips then 
            TriggerClientEvent("LH-Deliveries:CompleteJob", QBCore.Functions.GetPlayerByCitizenId(owner).PlayerData.source, owner)
            lib.notify(QBCore.Functions.GetPlayerByCitizenId(owner).PlayerData.source, {description=Strings["return-truck"], type="inform"})
            for i = 2, #DeliveriesGroups[owner] do
                local Player = DeliveriesGroups[owner][i]
                TriggerClientEvent('LH-Deliveries:CompleteJob', QBCore.Functions.GetPlayerByCitizenId(Player).PlayerData.source, owner)
                lib.notify(QBCore.Functions.GetPlayerByCitizenId(Player).PlayerData.source, {description=Strings["return-truck"], type="inform"})
            end
        else 
            TriggerClientEvent('LH-Deliveries:CreateZone', QBCore.Functions.GetPlayerByCitizenId(owner).PlayerData.source, owner, randomZone, false, true)
            lib.notify(QBCore.Functions.GetPlayerByCitizenId(owner).PlayerData.source, {description=Strings["goto-zone"], type="inform"})
            for i = 2, #DeliveriesGroups[owner] do
                local Player = DeliveriesGroups[owner][i]
                TriggerClientEvent('LH-Deliveries:CreateZone', QBCore.Functions.GetPlayerByCitizenId(Player).PlayerData.source, owner, randomZone, false, true)
                lib.notify(QBCore.Functions.GetPlayerByCitizenId(Player).PlayerData.source, {description=Strings["goto-zone"], type="inform"})
            end
        end 

    else 
        lib.notify(QBCore.Functions.GetPlayerByCitizenId(owner).PlayerData.source, {description=Strings["dropoff-box"]..BoxesDroppedOffTracker[owner].."/"..Config.Job.Boxes, type="infrom"})
        for i = 2, #DeliveriesGroups[owner] do 
            local Player = DeliveriesGroups[owner][i]
            lib.notify(QBCore.Functions.GetPlayerByCitizenId(Player).PlayerData.source, {description=Strings["dropoff-box"]..BoxesDroppedOffTracker[owner].."/"..Config.Job.Boxes, type="infrom"})
        end
    end 
end)

RegisterNetEvent("LH-Deliveries:CompleteDeliveryJob", function(owner)
    local src = source
    local moneyCount = #DeliveriesGroups[owner] * Config.Job.Reward
    print(#DeliveriesGroups[owner], Config.Job.Reward)

    if not Inventory:CanCarryItem(src, 'money', 1) then 
        lib.notify(src, {description=Strings["cant-carry"], type='error'})
        return
    end 

    DeliveriesGroups[owner][1] = false
    BoxesDroppedOffTracker[owner] = {}
    CompletedTripsTracker[owner] = 0
    Inventory:AddItem(src, 'money', moneyCount)
end)