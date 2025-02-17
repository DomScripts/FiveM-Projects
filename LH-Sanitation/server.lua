local QBCore = exports["qbx-core"]:GetCoreObject()
local Inventory = exports.ox_inventory
local Zones = lib.zones

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then 
        return
    end
end)
