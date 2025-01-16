local tireIndices = {
    { boneName = "wheel_lf", index = 0 }, 
    { boneName = "wheel_rf", index = 1 }, 
    { boneName = "wheel_lr", index = 2 }, 
    { boneName = "wheel_rr", index = 3 }, 
    { boneName = "wheel_lm1", index = 4 },
    { boneName = "wheel_rm1", index = 5 } 
}

local function getNearestTire(vehicle)
    local ESX.PlayerData.ped = ESX.PlayerData.pedId()
    local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
    local closestTireIndex = nil
    local closestDistance = math.huge
    local closestTirePos = nil

    for _, tireData in ipairs(tireIndices) do
        local boneIndex = GetEntityBoneIndexByName(vehicle, tireData.boneName)
        if boneIndex ~= -1 then
            local tirePos = GetWorldPositionOfEntityBone(vehicle, boneIndex)
            local distance = #(playerCoords - tirePos)

            if not IsVehicleTyreBurst(vehicle, tireData.index, false) and distance < closestDistance then
                closestDistance = distance
                closestTireIndex = tireData.index
                closestTirePos = tirePos
            end
        end
    end

    return closestTireIndex, closestTirePos
end

local function repairTire(vehicle, tireIndex)
    if DoesEntityExist(vehicle) and tireIndex then
        SetVehicleTyreFixed(vehicle, tireIndex)
        SetVehicleWheelHealth(vehicle, tireIndex, 100.0)
    end
end

RegisterNetEvent('esx_mechanicjob:client:useTireKit', function()
    local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
    local vehicle = ESX.Game.GetClosestVehicle(playerCoords)

    local nearestTireIndex, nearestTirePos = getNearestTire(vehicle)
    if not nearestTireIndex then
        ESX.ShowNotification("No damaged tire found.")
        return
    end

    local offset = vector3(0.5, 0, 0)
    local inFrontOfTire = nearestTirePos + GetOffsetFromEntityInWorldCoords(vehicle, offset)

    TaskGoStraightToCoord(ESX.PlayerData.ped, inFrontOfTire.x, inFrontOfTire.y, inFrontOfTire.z, 1.0, -1, 0.0, 0.0)

    local timeout = GetGameTimer() + 10000
    while not IsEntityAtCoord(ESX.PlayerData.ped, inFrontOfTire.x, inFrontOfTire.y, inFrontOfTire.z, 5.0, 5.0, 5.0, false, true, 0) do
        Wait(100)
        if GetGameTimer() > timeout then
            print("Could not reach tire position")
            break
        end
    end

    ClearPedTasks(ESX.PlayerData.ped)
    ESX.Progressbar("repairing_tire", 5000, {
        FreezePlayer = true,
        animation = {
            type = "anim",
            dict = "mini@prostitutes@sexlow_veh",
            lib = "low_car_sex_to_prop_p2_player"
        },
        onFinish = function()
            repairTire(vehicle, nearestTireIndex)
        end
    })
end)
