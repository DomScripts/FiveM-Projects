local Inventory = exports.ox_inventory
local QBCore = exports["qbx-core"]:GetCoreObject()

SanitationGroups = {}
TrashCollectedTracker = {}
CompletedTripsTracker = {}


lib.callback.register('LH-Sanitation:fetchGroups', function()
    return SanitationGroups
end)

RegisterNetEvent('LH-Sanitation:createGroup', function(owner)
    SanitationGroups[owner] = {false}     -- Creates open group, assigns owner citizenId as key and in-job to false
end)

local function CheckOwnerOrMember(citizenId)
    local isOwner = false
    local isMember = false

    for key, array in pairs(SanitationGroups) do 
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

lib.callback.register('LH-Sanitation:formatGroups', function()
    local groupFormat = {}

    for key, _ in pairs(SanitationGroups) do
        local citizenId = tostring(key)
        local Player = QBCore.Functions.GetPlayerByCitizenId(citizenId)
        local firstname = Player.PlayerData.charinfo.firstname
        local lastname = Player.PlayerData.charinfo.lastname
        table.insert(groupFormat, {
            title = firstname..' '..lastname,
            event = 'LH-Sanitation:sanitationGroupOptionMenu',
            args = citizenId
        })
    end 

    return groupFormat
end)

lib.callback.register('LH-Sanitation:checkIfInGroup', function(source, citizenId)
    local isOwner, isMember = CheckOwnerOrMember(citizenId)

    if isOwner or isMember then 
        return true 
    else 
        return false 
    end 
end)

RegisterNetEvent('LH-Sanitation:joinGroup', function(owner, citizenId)
    local isOwner, isMember = CheckOwnerOrMember(citizenId)

    if #SanitationGroups[owner] == 2 then lib.notify(source, {description=Strings["group-full"], type = "error"}) return end

    if isOwner then 
        lib.notify(source, {description=Strings["already-own"], type = "error"})
    elseif isMember then
        lib.notify(source, {description=Strings["already-member"], type = "error"})
    elseif SanitationGroups[owner][1] then 
        lib.notify(source, {description=Strings["group-locked"], type = "error"})
    else 
        table.insert(SanitationGroups[owner], citizenId)
        lib.notify(source, {description=Strings["join-group"], type = "success"})
    end 

end)

RegisterNetEvent('LH-Sanitation:leaveGroup', function(citizenId)
    local isOwner, isMember = CheckOwnerOrMember(citizenId)

    if isOwner then 
        SanitationGroups[citizenId] = nil     -- If owner remove entire group
        lib.notify(source, {description=Strings["owner-leave"], type = "success"})
    elseif isMember then
        SanitationGroups[key][index] = nil    -- If member remove from group
        lib.notify(source, {description=Strings["member-leave"], type = "success"})
    else 
        lib.notify(source, {description=Strings["not-member"], type = "error"})
    end 
end)


RegisterNetEvent('LH-Sanitation:StartJob', function(citizenId)
    local src = source
    local isOwner, isMember = CheckOwnerOrMember(citizenId)

    if not isOwner and not isMember then 
        lib.notify(src, {description=Strings["no-group"], type="error"})
    elseif isMember then 
        lib.notify(src, {description=Strings["leader-start-job"], type="error"})
    else 
        if not SanitationGroups[citizenId][1] then 
            SanitationGroups[citizenId][1] = true
            TrashCollectedTracker[citizenId] = 0
            CompletedTripsTracker[citizenId] = 0
            
            local randomZone = math.random(#Config.SanitationZones)
            TriggerClientEvent('LH-Sanitation:CreateZone', src, citizenId, randomZone, true, true, false)
            lib.notify(src, {description=Strings["goto-zone"], type="inform"})
            for i = 2, #SanitationGroups[citizenId] do
                local Player = SanitationGroups[citizenId][i]
                TriggerClientEvent('LH-Sanitation:CreateZone', QBCore.Functions.GetPlayerByCitizenId(Player).PlayerData.source, citizenId, randomZone, false, true, false)
                lib.notify(QBCore.Functions.GetPlayerByCitizenId(Player).PlayerData.source, {description=Strings["goto-zone"], type="inform"})
            end
        else 
            lib.notify(src, {description=Strings["in-job"], type="error"})
        end
    end 
end)

RegisterNetEvent('LH-Sanitation:SendGarbageTruckID', function(citizenId, garbageTruck)
    for i = 2, #SanitationGroups[citizenId] do
        local Player = SanitationGroups[citizenId][i]
        TriggerClientEvent('LH-Sanitation:SetGarbageTruckTarget', QBCore.Functions.GetPlayerByCitizenId(Player).PlayerData.source, garbageTruck)
    end
end)

RegisterNetEvent("LH-Sanitation:ThrowTrashInTruck", function(owner)
    TrashCollectedTracker[owner] = TrashCollectedTracker[owner] + 1

    if TrashCollectedTracker[owner] == Config.TrashPerTrip then 
        TrashCollectedTracker[owner] = 0
        CompletedTripsTracker[owner] = CompletedTripsTracker[owner] + 1
        local randomZone = math.random(#Config.SanitationZones)

        if CompletedTripsTracker[owner] == Config.Trips then 
            TriggerClientEvent("LH-Sanitation:CompleteJob", QBCore.Functions.GetPlayerByCitizenId(owner).PlayerData.source, owner)
            lib.notify(QBCore.Functions.GetPlayerByCitizenId(owner).PlayerData.source, {description=Strings["return-truck"], type="success"})
            for i = 2, #SanitationGroups[owner] do
                TriggerClientEvent('LH-Sanitation:CompleteJob', QBCore.Functions.GetPlayerByCitizenId(Player).PlayerData.source, owner)
                local Player = SanitationGroups[owner][i]
                lib.notify(QBCore.Functions.GetPlayerByCitizenId(Player).PlayerData.source, {description=Strings["return-truck"], type="inform"})
            end
        else 
            TriggerClientEvent('LH-Sanitation:CreateZone', QBCore.Functions.GetPlayerByCitizenId(owner).PlayerData.source, owner, randomZone, false, false, true)
            lib.notify(QBCore.Functions.GetPlayerByCitizenId(owner).PlayerData.source, {description=Strings["goto-zone"], type="inform"})
            for i = 2, #SanitationGroups[owner] do
                local Player = SanitationGroups[owner][i]
                TriggerClientEvent('LH-Sanitation:CreateZone', QBCore.Functions.GetPlayerByCitizenId(Player).PlayerData.source, owner, randomZone, false, false, true)
                lib.notify(QBCore.Functions.GetPlayerByCitizenId(Player).PlayerData.source, {description=Strings["goto-zone"], type="inform"})
            end
        end 

    else 
        lib.notify(QBCore.Functions.GetPlayerByCitizenId(owner).PlayerData.source, {description="Collected: "..TrashCollectedTracker[owner].."/"..Config.TrashPerTrip, type="infrom"})
        for i = 2, #SanitationGroups[owner] do 
            local Player = SanitationGroups[citizenId][i]
            lib.notify(QBCore.Functions.GetPlayerByCitizenId(Player).PlayerData.source, {description="Collected: "..TrashCollectedTracker[owner].."/"..Config.TrashPerTrip, type="infrom"})
        end
    end 
end)

RegisterNetEvent("LH-Sanitation:CompleteSanitationJob", function(owner)
    local src = source
    local moneyCount = #SanitationGroups[owner] * Config.CashPerPerson
    local materialAmount = #SanitationGroups[owner] * Config.MaterialPerPerson

    if not Inventory:CanCarryItem(src, 'money', 1) then 
        lib.notify(src, {description=Strings["cant-carry"], type='error'})
        return
    end 

    SanitationGroups[owner][1] = false
    TrashCollectedTracker[owner] = {}
    CompletedTripsTracker[owner] = 0
    Inventory:AddItem(src, 'money', moneyCount)
    Inventory:AddItem(src, 'recyclablematerial', materialAmount)
end)

RegisterNetEvent("LH-Sanitation:ExchangeMaterials", function(input)
    local src = source
    local count, item = input[1], input[2]
    local amount = Inventory:Search(src, 'count', 'recyclablematerial')
    print(count, amount)

    if count > amount then 
        lib.notify(src, {description=Strings["not-enough"], type='error'})
        return
    end 

    if not Inventory:CanCarryItem(src, item, count) then 
        lib.notify(src, {description=Strings["cant-carry"], type='error'})
        return
    end

    Inventory:RemoveItem(src, 'recyclablematerial', count)
    Inventory:AddItem(src, item, count)
end)