local GroupFunctions = {}

local function dprint(...)
    if not Config.Debug then return end 
    print("Debug: ".. ...)
end

--Check if player is a owner or member of a job group
--@param   citizenId: string
--@return  inGroup: bool
--@return  groupId: string or nil
--@return groupData: table or nil
exports("inGroup", function(citizenId)
    local inGroup, groupId, groupData = lib.callback.await('ds_jobmanagement:inGroup', false, citizenId)
    return inGroup, groupId, groupData
end)


--Check if player is a owner of a group
--@param   citizenId: string
--@return  isOwner: bool
--@return  groupId: string or nil
--@return  groupData:table or nil 
exports("isOwner", function(citizenId)
    local isOwner, groupId, groupData = lib.callback.await('ds_jobmanagement:isOwner', false, citizenId)
    return isOwner, groupId, groupData
end)


--Check if player is a member of a group
--@param   citizenId: string
--@return  isMember: bool
--@return  groupId: string or nil
exports("isMember", function(citizenId)
    local isMember, groupId = lib.callback.await('ds_jobmanagement:isOwner', false, citizenId)
    return isMember, groupId
end)


--Opens owner menu to do kick/promot the specific member selected
--@param 
local function showMemberOptions(args)
    local menuTitle, groupInfo, memberInfo = args[1], args[2], args[3]

    lib.registerContext({
        id = 'ownerMemberOptions',
        title = menuTitle,
        options = {
            {
                title = "Promote",
                serverEvent = "ds_jobmanagement:PromoteMember",
                args = {groupInfo, memberInfo}
            },
            {
                title = "Kick",
                serverEvent = "ds_jobmanagement:KickMember",
                args = {groupInfo, memberInfo}
            }
        }
    })
    lib.showContext('ownerMemberOptions')

end 

--Opens menu displaying members in thee group
--@param  args: string / table
local function showMembers(args)
    local citizenId = ManagementFunction.GetPlayerCitizenId()
    local menuTitle, groupInfo = args[1], args[2]
    local fetchedNames = lib.callback.await("ds_jobmanagement:FetchGroupMemberNames", false, groupInfo)

    if groupInfo.owner == citizenId then 

        local ownerOptions = {{title = fetchedNames[1].name,}}

        for i = 2, #fetchedNames do 
            table.insert(ownerOptions, {
                title = fetchedNames[i].name,
                onSelect = showMemberOptions,
                args = {menuTitle, groupInfo, fetchedNames[i]}
            })
        end 

        lib.registerContext({
            id = 'ownerMemberList',
            title = menuTitle,
            options = ownerOptions
        })
        lib.showContext('ownerMemberList')

    else 

        local memberOption = {}

        for i = 1, #fetchedNames do 
            table.insert(memberOption, {title = fetchedNames[i].name})
        end 

        lib.registerContext({
            id = 'groupMemberList',
            title = menuTitle,
            options = memberOption
        })
        lib.showContext('groupMemberList')

    end 
end 

--Leave group / Disband if owner
--@param args: table
local function leaveGroup(args)
    local citizenId = ManagementFunction.GetPlayerCitizenId()
    local groupInfo = args[1]

    if groupInfo.owner == citizenId then
        local type = "owner"
        TriggerServerEvent("ds_jobmanagement:LeaveGroup", type, citizenId, groupInfo.owner)
        return
    end 

    for i = 1, #groupInfo.members do 

        if groupInfo.members[i] == citizenId then 
            local type = "member"
            TriggerServerEvent("ds_jobmanagement:LeaveGroup", type, citizenId, groupInfo.owner)
            return
        end 

    end 

    lib.notify({description=Strings["Leave-NotInGroup"], type="error"})
end 


--Open options when you select a group
--@param  groupInfo: table
RegisterNetEvent("ds_jobmanagement:GroupOptions", function(args)
    local menuTitle, groupInfo = args[1], args[2]

    lib.registerContext({
        id = 'groupOptions',
        title = menuTitle,
        options = {
            {
                title = 'Join',
                serverEvent = "ds_jobmanagement:joinGroup",
                args = {groupInfo}
            },
            {
                title = 'Members',
                onSelect = showMembers,
                args = {menuTitle, groupInfo}
            },
            {
                title = 'Leave',
                onSelect = leaveGroup,
                args = {groupInfo}
            }
        }
    })
    lib.showContext('groupOptions')

end)


--Opens groups you can join for the specified job
--@param   menuTitle: string
--@param   job: string
local function showJoin(menuTitle, job)
    local menuGroupOptions = lib.callback.await('ds_jobmanagement:fetchMenuGroupOptions', false, menuTitle, job)

    if #menuGroupOptions == 0 then 
        lib.registerContext({
            id = 'noGroups',
            title = menuTitle,
            menu = 'showCreateJoin',
            options = {
                {
                    title = 'No Groups Found',
                    description = 'Create your own group to get started' 
                }
            }
        })
        lib.showContext('noGroups')
        return
    end 

    lib.registerContext({
        id = 'showJoin',
        title = menuTitle,
        menu = 'showCreateJoin',
        options = menuGroupOptions
    })

    lib.showContext('showJoin')
end 


--Opens create/join group menu for player 
--@param  title: string
--@param  job: string
exports("showCreateJoin", function(menuTitle, job)
    lib.registerContext({
        id = 'showCreateJoin',
        title = menuTitle,
        onBack = function()
            dprint("clicked back")
        end,
        options = {
        {
            title = 'Create Group',
            description = 'Create a group',
            icon = 'check',
            onSelect = function()
                TriggerServerEvent("ds_jobmanagement:createGroup", job)
            end
        },
        {
            title = 'Join Group',
            description = 'Join a group',
            icon = 'bars',
            arrow = true,
            onSelect = function()
                showJoin(menuTitle, job)
            end 
        }}
    })
    lib.showContext('showCreateJoin')
end)


exports("startJob", function()
    local inJob = lib.callback.await('ds_jobmanagement:startJob', false)
    return inJob
end)