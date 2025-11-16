local activeTraps = {}
local activeEffects = {}


CreateThread(function()
    Wait(1000)
    TriggerServerEvent('old_trapSv:requestSync')
end)


local function useTrapItem(trapType)
    local playerPed = PlayerPedId()


    if not Config.Traps[trapType] then
        print('[old_trap] Type de piège invalide: ' .. tostring(trapType))
        return false
    end

    if IsPedInAnyVehicle(playerPed, false) then
        lib.notify({
            type = 'error',
            description = Config.Locale.in_vehicle
        })
        return false
    end

    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)


    for _, trap in pairs(activeTraps) do
        if #(coords - trap.coords) < 5.0 then
            lib.notify({
                type = 'error',
                description = Config.Locale.too_close
            })
            return false
        end
    end


    lib.notify({
        type = 'info',
        description = Config.Locale.placing
    })

    if lib.progressCircle({
            duration = Config.Animation.duration,
            label = 'Placement du piège...',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true
            },
            anim = {
                dict = Config.Animation.dict,
                clip = Config.Animation.anim,
                flag = Config.Animation.flag
            }
        }) then
        TriggerServerEvent('old_trapSv:createTrap', trapType, coords, heading)
        return true
    end

    return false
end


exports('useTrap', function(data, slot)
    local itemName = data.name
    local trapType = nil


    if itemName == 'bouteille_huile' then
        trapType = 'huile'
    elseif itemName == 'morceau_verre' then
        trapType = 'verre'
    end

    if trapType then
        return useTrapItem(trapType)
    end

    return false
end)


RegisterNetEvent('old_trap:syncTrap', function(trapId, trapData)
    activeTraps[trapId] = trapData
    createTrapObject(trapId, trapData)
end)


RegisterNetEvent('old_trap:syncAllTraps', function(traps)
    for trapId, trapData in pairs(traps) do
        activeTraps[trapId] = trapData
        createTrapObject(trapId, trapData)
    end
end)


RegisterNetEvent('old_trap:removeTrap', function(trapId)
    if activeTraps[trapId] and activeTraps[trapId].object then
        DeleteObject(activeTraps[trapId].object)
    end
    activeTraps[trapId] = nil
end)


function createTrapObject(trapId, trapData)
    local trapConfig = Config.Traps[trapData.type]
    if not trapConfig then return end

    local propHash = GetHashKey(trapConfig.prop)
    RequestModel(propHash)

    while not HasModelLoaded(propHash) do
        Wait(10)
    end

    local object = CreateObject(propHash, trapData.coords.x, trapData.coords.y, trapData.coords.z, true, true, false)

    PlaceObjectOnGroundProperly(object)
    FreezeEntityPosition(object, true)


    activeTraps[trapId].object = object
end

if Config.CanPickupTraps then
    CreateThread(function()
        while true do
            local sleep = 1000
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local nearTrap = false


            if not IsPedInAnyVehicle(playerPed, false) then
                for trapId, trap in pairs(activeTraps) do
                    local distance = #(playerCoords - trap.coords)

                    if distance < 2.0 then
                        nearTrap = true
                        sleep = 0

                        ShowHelpText(Config.Locale.pickup_trap)

                        if IsControlJustReleased(0, 38) then
                            if lib.progressCircle({
                                    duration = 2000,
                                    label = Config.Locale.picking_up,
                                    useWhileDead = false,
                                    canCancel = true,
                                    disable = {
                                        car = true,
                                        move = true,
                                        combat = true
                                    },
                                    anim = {
                                        dict = Config.Animation.dict,
                                        clip = Config.Animation.anim,
                                        flag = Config.Animation.flag
                                    }
                                }) then
                                TriggerServerEvent('old_trapSv:pickupTrap', trapId)
                            end
                        end
                        break
                    end
                end
            end

            Wait(sleep)
        end
    end)
end


CreateThread(function()
    while true do
        local sleep = 50
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == playerPed then
            local vehCoords = GetEntityCoords(vehicle)


            local frontLeft = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "wheel_lf"))
            local frontRight = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "wheel_rf"))
            local rearLeft = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "wheel_lr"))
            local rearRight = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "wheel_rr"))

            local checkPoints = {
                vehCoords,
                frontLeft,
                frontRight,
                rearLeft,
                rearRight
            }

            for trapId, trap in pairs(activeTraps) do
                local trapConfig = Config.Traps[trap.type]
                if trapConfig then
                    local triggered = false


                    for _, point in ipairs(checkPoints) do
                        if point and point.x and point.y and point.z then
                            local distance = #(vector3(point.x, point.y, point.z) - trap.coords)

                            if distance < trapConfig.triggerRadius then
                                triggered = true
                                break
                            end
                        end
                    end

                    if triggered and not activeEffects[trapId] then
                        applyTrapEffect(vehicle, trapConfig.effect, trapId)
                    end
                end
            end
        end

        Wait(sleep)
    end
end)



function applyTrapEffect(vehicle, effect, trapId)
    activeEffects[trapId] = true

    if effect.type == 'slide' then
        SetVehicleReduceGrip(vehicle, true)
        SetVehicleReduceTraction(vehicle, true)



        lib.notify({
            type = 'warning',
            description = 'Vous avez glissé sur de l\'huile !'
        })

        CreateThread(function()
            local endTime = GetGameTimer() + effect.duration
            local spinDirection = math.random(0, 1) == 1 and 1 or -1
            local spinForce = effect.spinForce or 0.5

            while GetGameTimer() < endTime do
                local velocity = GetEntityVelocity(vehicle)
                local speed = #(velocity)

                if speed > 1.0 then
                    local lateralForce = math.random(-100, 100) / 100 * effect.intensity
                    ApplyForceToEntity(vehicle, 0, lateralForce, 0.0, 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false,
                        true)
                    SetVehicleSteerBias(vehicle, 1.0)
                    local rotationForce = spinForce * spinDirection * (speed / 10.0)
                    ApplyForceToEntity(vehicle, 0, 0.0, 0.0, 0.0, 0.0, 0.0, rotationForce, 0, true, true, true, false,
                        true)
                end

                Wait(50)
            end

            SetVehicleReduceGrip(vehicle, false)
            SetVehicleReduceTraction(vehicle, false)

            Wait(5000)
            activeEffects[trapId] = nil
        end)
    elseif effect.type == 'tire_burst' then
        local tiresToBurst = {}
        local availableTires = { 0, 1, 2, 3, 4, 5 }


        if effect.randomTires then
            for i = 1, effect.maxTires do
                if #availableTires > 0 then
                    local index = math.random(#availableTires)
                    table.insert(tiresToBurst, availableTires[index])
                    table.remove(availableTires, index)
                end
            end
        else
            for i = 1, math.min(effect.maxTires, #availableTires) do
                table.insert(tiresToBurst, availableTires[i])
            end
        end


        for _, tire in ipairs(tiresToBurst) do
            SetVehicleTyreBurst(vehicle, tire, true, 1000.0)
        end

        lib.notify({
            type = 'error',
            description = 'Vos pneus ont crevé sur du verre !'
        })

        Wait(5000)
        activeEffects[trapId] = nil
    end
end

if Config.Debug then
    CreateThread(function()
        while true do
            for trapId, trap in pairs(activeTraps) do
                local trapConfig = Config.Traps[trap.type]
                if trapConfig then
                    DrawMarker(
                        1,
                        trap.coords.x, trap.coords.y, trap.coords.z - 1.0,
                        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                        trapConfig.triggerRadius * 2, trapConfig.triggerRadius * 2, 0.5,
                        255, 0, 0, 100,
                        false, true, 2, false, nil, nil, false
                    )
                end
            end
            Wait(0)
        end
    end)
end


AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for trapId, trap in pairs(activeTraps) do
        if trap.object and DoesEntityExist(trap.object) then
            DeleteObject(trap.object)
        end
    end
end)
