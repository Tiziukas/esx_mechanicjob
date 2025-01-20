local function repairVehicle(veh)
    SetVehicleEngineHealth(veh, 1000)
    SetVehicleEngineOn(veh, true, true, false)
    SetVehicleFixed(veh)
end

RegisterNetEvent('esx_mechanicjob:client:useRepairKit', function()
    local veh = ESX.Game.GetClosestVehicle(playerCoords)

    local vehPos = GetEntityCoords(veh)
    local vehHeading = GetEntityHeading(veh)
    local vehDimensions = GetModelDimensions(GetEntityModel(veh))

    local hoodOffset = 1.0 
    local hoodPos = vector3(
        vehPos.x + (math.cos(math.rad(vehHeading)) * (vehDimensions.y + hoodOffset)),
        vehPos.y + (math.sin(math.rad(vehHeading)) * (vehDimensions.y + hoodOffset)),
        vehPos.z
    )

    TaskGoToCoordAnyMeans(ESX.PlayerData.ped, hoodPos.x, hoodPos.y, hoodPos.z, 1.0, -1, vehHeading, 0.0)

    local timeout = GetGameTimer() + 10000
    while not IsEntityAtCoord(ESX.PlayerData.ped, hoodPos.x, hoodPos.y, hoodPos.z, 5.0, 5.0, 5.0, false, true, 0) do
        Wait(100)
        if GetGameTimer() > timeout then
            ESX.ShowNotification("Could not reach the front of the vehicle.")
            return
        end
    end

    TaskTurnPedToFaceCoord(ESX.PlayerData.ped, vehPos.x, vehPos.y, vehPos.z, 1000)
    Wait(1000)

    SetVehicleDoorOpen(veh, 4, false, false)
    ESX.Progressbar("Fixing Vehicle", Config.ProgressBars.repairKit.time, {
        FreezePlayer = true,
        animation = {
            type = "anim",
            dict = Config.ProgressBars.repairKit.animation.dict,
            lib = Config.ProgressBars.repairKit.animation.lib
        },
        onFinish = function()
            repairVehicle(veh)
        end
    })
end)
