ESX.RegisterClientCallback('esx_mechanicjob:client:checkForVehicle', function(cb)
    local playerPed = ESX.PlayerData.ped
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = ESX.Game.GetClosestVehicle(playerCoords)
    if vehicle == -1 then cb(false) end

    cb(vehicle)
end)

Citizen.CreateThread(function()
    for zoneName, zoneData in pairs(Config.MechanicZones) do
        local blipConfig = zoneData.blip
        local blipLocation = blipConfig.location

        local blip = AddBlipForCoord(blipLocation.x, blipLocation.y, blipLocation.z)

        SetBlipSprite(blip, blipConfig.sprite)  
        SetBlipColour(blip, blipConfig.colour)  
        SetBlipScale(blip, blipConfig.scale)    
        SetBlipAsShortRange(blip, blipConfig.shortRange)  

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blipConfig.name)
        EndTextCommandSetBlipName(blip)
    end
end)


local function ImpoundVehicle()
    local playerPed = ESX.PlayerData.ped
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = ESX.Game.GetClosestVehicle(playerCoords)

    ESX.Progressbar("Impound Vehicle", 5000, {
        FreezePlayer = true,
        animation = {
            type = "anim",
            dict = "mini@prostitutes@sexlow_veh",
            lib = "low_car_sex_to_prop_p2_player"
        },
        onFinish = function()
            ESX.Game.DeleteVehicle(vehicle) 
        end
    })
end

local function BreakVehicle()
    local playerPed = ESX.PlayerData.ped
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = ESX.Game.GetClosestVehicle(playerCoords)

    ESX.Progressbar("Breaking into the vehicle", 5000, {
        FreezePlayer = true,
        animation = {
            type = "anim",
            dict = "mini@prostitutes@sexlow_veh",
            lib = "low_car_sex_to_prop_p2_player"
        },
        onFinish = function()
            SetVehicleDoorsLocked(vehicle, 1)
            SetVehicleDoorsLockedForAllPlayers(vehicle, false)
        end
    })
end

local function FixVehicle()
    local playerPed = ESX.PlayerData.ped
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = ESX.Game.GetClosestVehicle(playerCoords)

    ESX.Progressbar("Fixing vehicle", 5000, {
        FreezePlayer = true,
        animation = {
            type = "anim",
            dict = "mini@prostitutes@sexlow_veh",
            lib = "low_car_sex_to_prop_p2_player"
        },
        onFinish = function()
            SetVehicleEngineHealth(vehicle, 1000)
            SetVehicleEngineOn(vehicle, true, true, false)
            SetVehicleFixed(vehicle)
        end
    })
end

local function CleanVehicle()
    local playerPed = ESX.PlayerData.ped
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = ESX.Game.GetClosestVehicle(playerCoords)

    ESX.Progressbar("Cleaning the vehicle", 5000, {
        FreezePlayer = true,
        animation = {
            type = "anim",
            dict = "mini@prostitutes@sexlow_veh",
            lib = "low_car_sex_to_prop_p2_player"
        },
        onFinish = function()
            WashDecalsFromVehicle(vehicle, playerPed, 1.0)
            SetVehicleDirtLevel(vehicle, 0.1)
            ClearPedTasksImmediately(playerPed)
        end
    })
end

local function OpenVehInteractMenu()
    local elements = {
        {label = 'Repair Vehicle', value = 'repair_veh'},
        {label = 'Clean Vehicle', value = 'clean_veh'},
        {label = 'Break into vehicle', value = 'break_veh'},
        {label = 'Impound vehicle', value = 'impound_veh'}
    }

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'billing_menu',
        {
            title    = 'Mechanic Menu',
            align    = 'top-right',
            elements = elements
        },
        function(data, menu)
            menu.close()
            if data.current.value == 'repair_veh' then
                FixVehicle()
            elseif data.current.value == 'clean_veh' then
                CleanVehicle()
            elseif data.current.value == 'break_veh' then
                BreakVehicle() 
            elseif data.current.value == 'impound_veh' then
                ImpoundVehicle()
            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end

local function OpenMechanicMenu()
    local elements = {
        {label = 'Vehicle Interactions', value = 'veh_interact'},
        {label = 'Billing', value = 'billing'},
        {label = 'NPC Jobs', value = 'npcJobs'}
    }

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'billing_menu',
        {
            title    = 'Mechanic Menu',
            align    = 'top-right',
            elements = elements
        },
        function(data, menu)
            menu.close()
            if data.current.value == 'billing' then
                OpenBillingMenu()
            elseif data.current.value == 'npcJobs' then
                OpenNpcMenu()
            elseif data.current.value == 'veh_interact' then
                OpenVehInteractMenu()
            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end

RegisterCommand('mechanicMenu', function()
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
		OpenMechanicMenu()
	end
end, false)

RegisterKeyMapping('mechanicMenu', 'Open Mechanic Menu', 'keyboard', Config.Controls.mechanicMenu)
