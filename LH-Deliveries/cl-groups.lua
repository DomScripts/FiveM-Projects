local QBCore = exports["qbx-core"]:GetCoreObject()
local citizenId = QBCore.Functions.GetPlayerData().citizenid
--!---------------------------------------------------------------------------------------------------
--! First Menu 
--!---------------------------------------------------------------------------------------------------
lib.registerContext({
    id = 'deliveriesInfoMenu',
    title = 'Delivery Groups',
    options = {
    {
        title = 'Create Group',
        description = 'Create a group to collect trash with',
        icon = 'check',
        onSelect = function()
            local groupInfo = lib.callback.await('LH-Deliveries:fetchGroups', false)

            --? Check if player is already in a group
            lib.callback('LH-Deliveries:checkIfInGroup', false, function(inGroup)
                if inGroup then 
                    lib.notify({description=Strings["already-member"], type = 'error'})
                else 
                    TriggerServerEvent('LH-Deliveries:createGroup', citizenId)
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
            local groupInfo = lib.callback.await('LH-Deliveries:fetchGroups', false)
            
            --? Calcualte how many groups there are
            local numberOfGroups = 0
            for _ in pairs(groupInfo) do 
                numberOfGroups = numberOfGroups + 1
            end 

            --? If no groups found show no groups found menu
            if numberOfGroups == 0 then 
                lib.showContext('deliveriesNoGroupsMenu')
                return
            end 

            --? Get all groups for context menu
            local groupFormat = lib.callback.await('LH-Deliveries:formatGroups', false)
            lib.registerContext({
                id = 'deliveriesGroupMenu',
                title = 'Delivery Groups',
                options = groupFormat
            })
            lib.showContext('deliveriesGroupMenu')
        end 
    }}
})

--? Group Menus
lib.registerContext({
    id = 'deliveriesNoGroupsMenu',
    title = 'Deliveries Groups',
    options = {
    {
        title = 'No Groups Found',
        description = 'Create your own deliveries group to get started'
    }
    }
})

RegisterNetEvent('LH-Deliveries:deliveriesGroupOptionMenu', function(owner)
    lib.registerContext({
        id = 'deliveriesGroupOptionMenu',
        title = 'Deliveries Groups',
        options = {
            {
                title = 'Join Group',
                onSelect = function()
                    TriggerServerEvent('LH-Deliveries:joinGroup', owner, citizenId)
                end 
            },
            {
                title = 'Leave Group',
                onSelect = function()
                    TriggerServerEvent('LH-Deliveries:leaveGroup', citizenId)
                end 
            }
        }
    })
    lib.showContext('deliveriesGroupOptionMenu')
end)