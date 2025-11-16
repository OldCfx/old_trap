local activeTraps = {}
local trapIdCounter = 0


local function generateTrapId()
    trapIdCounter = trapIdCounter + 1
    return trapIdCounter
end


RegisterNetEvent('old_trapSv:createTrap', function(trapType, coords, heading)
    local src = source
    local trapConfig = Config.Traps[trapType]

    if not trapConfig then return end


    local hasItem = exports.ox_inventory:GetItem(src, trapConfig.item, nil, true)

    if hasItem and hasItem >= 1 then
        exports.ox_inventory:RemoveItem(src, trapConfig.item, 1)


        local trapId = generateTrapId()
        activeTraps[trapId] = {
            id = trapId,
            type = trapType,
            coords = coords,
            heading = heading,
            owner = src,
            createdAt = os.time()
        }


        TriggerClientEvent('old_trap:syncTrap', -1, trapId, activeTraps[trapId])


        SetTimeout(trapConfig.duration, function()
            if activeTraps[trapId] then
                TriggerClientEvent('old_trap:removeTrap', -1, trapId)
                activeTraps[trapId] = nil
            end
        end)

        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            description = trapConfig.notification
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = Config.Locale.no_item
        })
    end
end)


RegisterNetEvent('old_trapSv:pickupTrap', function(trapId)
    local src = source

    if not activeTraps[trapId] then return end

    local trap = activeTraps[trapId]
    local trapConfig = Config.Traps[trap.type]

    if not trapConfig then return end


    if Config.PickupOwnTrapsOnly and trap.owner ~= src then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = Config.Locale.not_your_trap
        })
        return
    end


    if Config.ReturnItemOnPickup then
        exports.ox_inventory:AddItem(src, trapConfig.item, 1)
    end


    TriggerClientEvent('old_trap:removeTrap', -1, trapId)
    activeTraps[trapId] = nil

    TriggerClientEvent('ox_lib:notify', src, {
        type = 'success',
        description = Config.Locale.trap_picked
    })
end)


RegisterNetEvent('old_trapSv:removeTrap', function(trapId)
    if activeTraps[trapId] then
        TriggerClientEvent('old_trap:removeTrap', -1, trapId)
        activeTraps[trapId] = nil
    end
end)


RegisterNetEvent('old_trapSv:requestSync', function()
    local src = source
    TriggerClientEvent('old_trap:syncAllTraps', src, activeTraps)
end)


CreateThread(function()
    while true do
        Wait(60000)
        local currentTime = os.time()

        for trapId, trap in pairs(activeTraps) do
            local trapConfig = Config.Traps[trap.type]
            if trapConfig then
                local expirationTime = trap.createdAt + (trapConfig.duration / 1000)
                if currentTime >= expirationTime then
                    TriggerClientEvent('old_trap:removeTrap', -1, trapId)
                    activeTraps[trapId] = nil
                end
            end
        end
    end
end)
