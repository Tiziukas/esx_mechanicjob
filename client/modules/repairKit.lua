local function repairVehicle(veh)
    SetVehicleEngineHealth(veh, 1000)
    SetVehicleEngineOn(veh, true, true, false)
    SetVehicleFixed(veh)
end

RegisterNetEvent('esx_mechanicjob:client:useRepairKit', function()
    local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
    local vehicle = ESX.Game.GetClosestVehicle(playerCoords)
    local vehCoords = GetEntityCoords(vehicle)
    local distance = #(playerCoords - vehCoords)
    if distance > 5 then
        return print("Car was too far")
    end
    
    SetVehicleDoorOpen(vehicle, 4, false, false)
    ESX.Progressbar("Fixing Vehicle", Config.ProgressBars.repairKit.time, {
        FreezePlayer = true,
        animation = {
            type = "anim",
            dict = Config.ProgressBars.repairKit.animation.dict,
            lib = Config.ProgressBars.repairKit.animation.lib
        },
        onFinish = function()
            repairVehicle(vehicle)
        end
    })
end)
