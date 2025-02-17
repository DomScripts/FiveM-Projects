local GroupFunctions = {}
local JobGroups = {}


local function dprint(...)
    if not Config.Debug then return end 
    print("Debug: ".. ...)
end

RegisterNetEvent("ds_jobmanagement:CheckPlayerTempJob", function()
    local src = source

    local player = ManagementFunction.GetPlayer(src)
    local job = ManagementFunction.GetPlayerJob(player)
    dprint("Check if player has temp job:", "Source:", src, "Job:", job)

    for i=1, #Config.TempJobs do 
        if job == Config.TempJobs[i] then 
            ManagementFunction.SetPlayerJob(player)
            break
        end 
    end 
end)

--Fetch all groups for a specified job
--@param  job: string
--@return jobGroupList: table
lib.callback.register('ds_jobmanagement:fetchGroups', function(source, job)
    local jobGroupList = {}


    for i = 1, #JobGroups do 

        if JobGroups[i].jobName == job then 
            table.insert(jobGroupList, JobGroups[i])
        end 

    end 

    return jobGroupList
end)


--Fetch the option list of available groups for a specified job 
--@param  job:string
--@return menuGroupOptions: table
lib.callback.register('ds_jobmanagement:fetchMenuGroupOptions', function(source, menuTitle, job)
    local menuGroupOptions = {}

    for i = 1, #JobGroups do 

        if JobGroups[i].jobName == job then 

            local player = ManagementFunction.GetPlayerByCitizenId(JobGroups[i].owner)
            local firstname, lastname = ManagementFunction.GetPlayerName(player)

            local metadata = {{label = "Owner", value = firstname.." "..lastname}}

            for j = 1, #JobGroups[i].members do 

                player = ManagementFunction.GetPlayerByCitizenId(JobGroups[i].members[j])
                local firstname, lastname = ManagementFunction.GetPlayerName(player)
                table.insert(metadata, {label = "Member", value = firstname.." "..lastname})
                
            end 

            table.insert(menuGroupOptions, {
                title = firstname.." "..lastname,
                arrow = true,
                event = "ds_jobmanagement:GroupOptions",
                metadata = metadata,
                args = {menuTitle, JobGroups[i]},
            })

        end

    end
    
    return menuGroupOptions
end)


--Check if player is a owner or member of a job group
--@param   citizenId: string
--@return  inGroup: bool
--@return  groupId: number or nil
--@return  groupData:table or nil 
function GroupFunctions.inGroup(citizenId)
    local inGroup = false
    local groupId, groupData = nil, nil

    for key, array in ipairs(JobGroups) do 

        if array.owner == citizenId then 
            inGroup = true
            groupId = key 
            groupData = JobGroups[key]
            break
        end 

        for _, value in pairs(array.members) do 
            if (value == citizenId) then 
                inGroup = true
                groupId = key 
                groupData = JobGroups[key]
                break
            end 
        end 

    end 

    return inGroup, groupId, groupData

end 

lib.callback.register('ds_jobmanagement:inGroup', function(source, citizenId)
    local inGroup, groupId, groupData = GroupFunctions.inGroup(citizenId)
    return inGroup, groupId, groupData
end)

exports("inGroup", function(citizenId)
    local inGroup, groupId, groupData = GroupFunctions.inGroup(citizenId)
    return inGroup, groupId, groupData
end)


--Check if player is a owner of a group
--@param   citizenId: string
--@return  isOwner: bool
--@return  groupId: number or nil
--@return  groupData:table or nil 
function GroupFunctions.isOwner(citizenId)
    local isOwner = false
    local groupId, groupData = nil, nil

    for key, array in pairs(JobGroups) do 

        if array.owner == citizenId then 
            isOwner = true
            groupId = key 
            groupData = JobGroups[key]
            break
        end 

    end 

    return isOwner, groupId, groupData
end

lib.callback.register('ds_jobmanagement:isOwner', function(source, citizenId)
    local isOwner, groupId, groupData = GroupFunctions.isOwner(citizenId)
    return isOwner, groupId, groupData
end)

exports('isOwner', GroupFunctions.isOwner(citizenId))


--Check if player is a member of a group
--@param   citizenId: string
--@return  isMember: bool
--@return  groupId: number or nil
function GroupFunctions.isMember(citizenId)
    local isMember = false
    local groupId = nil

    for key, array in ipairs(JobGroups) do 

        for _, value in pairs(array.members) do 
            if (value == citizenId) then 
                isMember = true
                groupId = key 
                break
            end 
        end 

    end 

    return isMember, groupId
end

lib.callback.register('ds_jobmanagement:isMember', function(source, citizenId)
    local isMember, groupId = GroupFunctions.isMember(citizenId)
    return isMember, groupId
end)

exports('isMember', GroupFunctions.isMember(citizenId))


--Creates a job group 
--@param  job: string
RegisterNetEvent("ds_jobmanagement:createGroup", function(job)
    local src = source
    
    local player = ManagementFunction.GetPlayer(src)
    local citizenId = ManagementFunction.GetPlayersCitizenId(player)

    local inGroup, _, _ = GroupFunctions.inGroup(citizenId)
    if inGroup then lib.notify(src, {description=Strings["inGroup"], type="error"}) return end 
    
    table.insert(JobGroups, {
        owner = citizenId,
        members = {},
        inJob = false,
        jobName = job,
        maxMembers = Config.Settings[job].MaxMembers,
    })
    lib.notify(src, {description=Strings["createdGroup"], type="success"})
end)


--Joins a job group
--@param  groupInfo: table
RegisterNetEvent("ds_jobmanagement:joinGroup", function(args)
    local src = source
    local groupInfo = args[1]

    local player = ManagementFunction.GetPlayer(src)
    local citizenId = ManagementFunction.GetPlayersCitizenId(player)
    local firstname, lastname = ManagementFunction.GetPlayerName(player)

    local inGroup, groupId, groupData = GroupFunctions.inGroup(citizenId)
    if inGroup then lib.notify(src, {description=Strings["inGroup"], type='error'}) return end 

    if #groupInfo.members + 1 >= groupInfo.maxMembers then lib.notify(src, {description=Strings["groupFull"], type='error'}) return end

    local _, groupId = GroupFunctions.inGroup(groupInfo.owner)
    table.insert(JobGroups[groupId].members, citizenId)
    lib.notify(src, {description=Strings["joinGroup"], type='success'})

    local owner = ManagementFunction.GetPlayerByCitizenId(groupInfo.owner)
    local ownerSource = ManagementFunction.GetPlayerSource(owner)
    lib.notify(ownerSource, {description=firstname.." "..lastname..Strings["Owner-MemberJoin"]})
end)


--Disbands group if owner / leaves group if member
--@param  type: string
--@param  citizenId: string
--@param  groupOwner: string
RegisterNetEvent("ds_jobmanagement:LeaveGroup", function(type, citizenId, groupOwner)
    local src = source

    if type == "owner" then 

        for key, array in pairs(JobGroups) do 

            if array.owner == citizenId then

                local members = array.members
                table.remove(JobGroups, key)
                lib.notify(src, {description=Strings["Owner-DisbandGroup"], type ="inform"})

                for i = 1, #members do 
                    local player = ManagementFunction.GetPlayerByCitizenId(members[i])
                    local playerSource = ManagementFunction.GetPlayerSource(player)
                    lib.notify(playerSource, {description=Strings["Member-DisbandGroup"], type="inform"})
                end 

                break
            end 
    
        end 

    end 

    if type == "member" then 

        for key, array in ipairs(JobGroups) do 

            for index, value in pairs(array.members) do 

                if (value == citizenId) then 
                    
                    table.remove(array.members, index)
                    lib.notify(src, {description=Strings["Member-LeaveGroup"], type="inform"})

                    local player = ManagementFunction.GetPlayerByCitizenId(citizenId)
                    local firstname, lastname = ManagementFunction.GetPlayerName(player)

                    local owner = ManagementFunction.GetPlayerByCitizenId(groupOwner)
                    local ownerSource = ManagementFunction.GetPlayerSource(owner)
                    lib.notify(ownerSource, {description=firstname.." "..lastname..Strings["Owner-MemberLeaveGroup"], type="inform"})

                    break
                end 

            end 
    
        end 

    end 

end)


-- Formats the member option and returns the options to the client
--@param  
lib.callback.register("ds_jobmanagement:FetchGroupMemberNames", function(source, groupInfo)
    local names = {}

    local player = ManagementFunction.GetPlayerByCitizenId(groupInfo.owner)
    local firstname, lastname = ManagementFunction.GetPlayerName(player)
    table.insert(names, {name = firstname.." "..lastname, citizenId = groupInfo.owner})

    for i = 1, #groupInfo.members do 

        player = ManagementFunction.GetPlayerByCitizenId(groupInfo.members[i])
        firstname, lastname = ManagementFunction.GetPlayerName(player)

        table.insert(names, {name = firstname.." "..lastname, citizenId = groupInfo.members[i]})

    end 

    return names
end)


--Promotes a member from the group to the new owner
--@param table / array
RegisterNetEvent("ds_jobmanagement:PromoteMember", function(args)
    local src = source 
    local groupInfo, memberInfo = args[1], args[2]

    for _, array in pairs(JobGroups) do 

        if array.owner == groupInfo.owner then 

            for index, value in pairs(array.members) do 

                if value == memberInfo.citizenId then 
                    local member = ManagementFunction.GetPlayerByCitizenId(memberInfo.citizenId)
                    local firstname, lastname = ManagementFunction.GetPlayerName(member)
                    local memberSource = ManagementFunction.GetPlayerSource(member)

                    lib.notify(src, {description=Strings["Owner=PromotMember"]..firstname.." "..lastname, type="inform"})
                    lib.notify(memberSource, {description=Strings["Member-GetPromoted"], type="inform"})

                    table.remove(array.members, index)
                    array.owner = memberInfo.citizenId
                    table.insert(array.members, groupInfo.owner)
                end 

            end 

        end 

    end 

end)


--Removes a member from the group by the owner
--@param  table / array
RegisterNetEvent("ds_jobmanagement:KickMember", function(args)
    local src = source
    local groupInfo, memberInfo = args[1], args[2]

    for key, array in pairs(JobGroups) do 

        if array.owner == groupInfo.owner then 

            for i = 1, #array.members do 

                if array.members[i] == memberInfo.citizenId then 
                    local member = ManagementFunction.GetPlayerByCitizenId(memberInfo.citizenId)
                    local memberSource = ManagementFunction.GetPlayerSource(member)
                    local firstname, lastname = ManagementFunction.GetPlayerName(member)

                    lib.notify(src, {description=Strings["Owner-KickMember"].." "..firstname.." "..lastname, type="inform"})
                    lib.notify(memberSource, {description=Strings["Member-KickMember"], type="error"})
                    table.remove(array.members, i)
                end 

            end 

        end 

    end 
end)


-- Swaps the groups inJob back to false
function GroupFunctions.ChangeGroupStatusToNotInJob(groupData)
    local success = false 

    for key, array in pairs(JobGroups) do 

        if array.owner == groupData.owner then 

            if JobGroups[key].inJob == true then
                JobGroups[key].inJob = not JobGroups[key].inJob
                success = true
                break
            else break end 

        end 

    end 

    return success

end

exports("ChangeGroupStatusToNotInJob", function(groupData)
    local success = GroupFunctions.ChangeGroupStatusToNotInJob(groupData)
    return success
end)


--Swaps the inJob bool of a group
--@param  citizenId:string 
--@return success: bool
local function ChangeGroupStatusToInJob(citizenId)
    local success = false 

    for key, array in pairs(JobGroups) do 

        if array.owner == citizenId then 

            if JobGroups[key].inJob == false then
                JobGroups[key].inJob = not JobGroups[key].inJob
                success = true
                break
            else break end 

        end 

    end 

    return success 

end 



--Returns if the player started the job or not 
--@return inJob: boolean
lib.callback.register('ds_jobmanagement:startJob', function(source)
    local src = source

    local player = ManagementFunction.GetPlayer(src)
    local citizenId = ManagementFunction.GetPlayersCitizenId(player)
    
    local isOwner, _, groupData = GroupFunctions.isOwner(citizenId)

    if not isOwner then lib.notify(src, {description=Strings["start-job-not-owner"], type="error"}) return end 

    local success = ChangeGroupStatusToInJob(citizenId)
    return success, groupData
end)