local Inventory = exports.ox_inventory
local QBCore = exports["qbx-core"]:GetCoreObject()

FishingGroups = {}
FishCaughtTracker = {}

lib.callback.register('LH-Fishing:fetchGroups', function()
    return FishingGroups
end)

RegisterNetEvent('LH-Fishing:createGroup', function(owner)
    FishingGroups[owner] = {false}     -- Creates open group, assigns owner citizenId as key and in-job to false
end)

local function CheckOwnerOrMember(citizenId)
    local isOwner = false
    local isMember = false

    for key, array in pairs(FishingGroups) do 
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

lib.callback.register('LH-Fishing:formatGroups', function()
    local groupFormat = {}

    for key, _ in pairs(FishingGroups) do
        local citizenId = tostring(key)
        local Player = QBCore.Functions.GetPlayerByCitizenId(citizenId)
        local firstname = Player.PlayerData.charinfo.firstname
        local lastname = Player.PlayerData.charinfo.lastname
        table.insert(groupFormat, {
            title = firstname..' '..lastname,
            event = 'LH-Fishing:fishingGroupOptionMenu',
            args = citizenId
        })
    end 

    return groupFormat
end)

lib.callback.register('LH-Fishing:checkIfInGroup', function(source, citizenId)
    local isOwner, isMember = CheckOwnerOrMember(citizenId)

    if isOwner or isMember then 
        return true 
    else 
        return false 
    end 
end)

RegisterNetEvent('LH-Fishing:joinGroup', function(owner, citizenId)
    local isOwner, isMember = CheckOwnerOrMember(citizenId)

    if #FishingGroups[owner] == 5 then lib.notify(source, {description=Strings["group-full"], type = "error"}) return end

    if isOwner then 
        lib.notify(source, {description=Strings["already-own"], type = "error"})
    elseif isMember then
        lib.notify(source, {description=Strings["already-member"], type = "error"})
    elseif FishingGroups[owner][1] then 
        lib.notify(source, {description=Strings["group-locked"], type = "error"})
    else 
        table.insert(FishingGroups[owner], citizenId)
        lib.notify(source, {description=Strings["join-group"], type = "success"})
    end 

end)

RegisterNetEvent('LH-Fishing:leaveGroup', function(citizenId)
    local isOwner, isMember = CheckOwnerOrMember(citizenId)

    if isOwner then 
        FishingGroups[citizenId] = nil     -- If owner remove entire group
        lib.notify(source, {description=Strings["owner-leave"], type = "success"})
    elseif isMember then
        FishingGroups[key][index] = nil    -- If member remove from group
        lib.notify(source, {description=Strings["member-leave"], type = "success"})
    else 
        lib.notify(source, {description=Strings["not-member"], type = "error"})
    end 
end)


RegisterNetEvent('LH-Fishing:StartJob', function(citizenId)
    local isOwner, isMember = CheckOwnerOrMember(citizenId)

    if not isOwner and not isMember then 
        lib.notify(source, {description=Strings["no-group"], type="error"})
    elseif isMember then 
        lib.notify(source, {description=Strings["leader-start-job"], type="error"})
    else 
        if not FishingGroups[citizenId][1] then 
            FishingGroups[citizenId][1] = true     -- Sets group to in-job
            local fishToCatch = #FishingGroups[citizenId] * Config.FishPerPerson
            FishCaughtTracker[citizenId] = 0
            

            TriggerClientEvent("LH-Fishing:StartFishingJob", source, ActiveFishingZone, fishToCatch, citizenId)    -- Start job for group owner
            for i = 2, #FishingGroups[citizenId] do    -- Loops members, must start at 2 since 1 is bool to see if group is in job or not
                local Player = FishingGroups[citizenId][i]
                TriggerClientEvent("LH-Fishing:StartFishingJob", QBCore.Functions.GetPlayerByCitizenId(Player).PlayerData.source, ActiveFishingZone, fishToCatch, citizenId)    -- Start job for group members
            end
        else 
            lib.notify(source, {description=Strings["in-job"], type="error"})
        end
    end 
end)

RegisterNetEvent("LH-Fishing:CompleteFishingJob", function(groupOwner)
    local money = #FishingGroups[groupOwner] * Config.MoneyPerPerson
    print('Triggered the event')

    if Inventory:CanCarryItem(source, 'money', 1) then 
        print('Searched the inventory')
        Inventory:AddItem(source, 'money', money)
    end
end)




RegisterNetEvent("LH-Test", function(citizenId)
    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenId)
    local psource = Player.PlayerData.source
    print('Source: '..psource)
end)