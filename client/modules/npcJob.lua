local activeJob, vehicle, npc, repairPoint, towStartPoint, towDropOffPoint, jobBlip = nil, nil, nil, nil, nil, nil, nil

local function DrawText3D(coords, text, customEntry)
    local str = text
    local start, stop = string.find(text, "~([^~]+)~")
    if start then
        start = start - 2
        stop = stop + 2
        str = ""
        str = str .. string.sub(text, 0, start)
    end

    if customEntry ~= nil then
        AddTextEntry(customEntry, str)
        BeginTextCommandDisplayHelp(customEntry)
    else
        AddTextEntry(GetCurrentResourceName(), str)
        BeginTextCommandDisplayHelp(GetCurrentResourceName())
    end
    EndTextCommandDisplayHelp(2, false, false, -1)

    SetFloatingHelpTextWorldPosition(1, coords)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
end

local function CreateJobBlip(coords, name)
    if jobBlip then RemoveBlip(jobBlip) end
    jobBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(jobBlip, 357)
    SetBlipColour(jobBlip, 2)
    SetBlipScale(jobBlip, 1.0)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(jobBlip)
    SetNewWaypoint(coords.x, coords.y)
end

local function DrawOnVehicle(veh)
    SetEntityDrawOutline(veh, true)
    SetEntityDrawOutlineColor(251, 155, 4, 1)
end

local function EndJob()
    if not activeJob then return ESX.ShowNotification(Translate('no_active_job')) end
    ESX.ShowNotification(Translate('job_ended'))
    if DoesEntityExist(npc) then DeleteEntity(npc) end
    if jobBlip then RemoveBlip(jobBlip) end
    if repairPoint then repairPoint:delete() end
    if towStartPoint then towStartPoint:delete() end
    if towDropOffPoint then towDropOffPoint:delete() end
    if DoesEntityExist(vehicle) then
        SetEntityAsMissionEntity(vehicle, true, true)
        ESX.Game.DeleteVehicle(vehicle) 
    end
    vehicle, npc, activeJob = nil, nil, nil
end

local function SpawnNPC(coords, heading, pedModel)
    if npc then return npc end
    ESX.Streaming.RequestModel(pedModel)
    npc = CreatePed(0, pedModel, coords.x, coords.y, coords.z - 1.0, heading, false, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    local dict, anim = "oddjobs@assassinate@bus@", "looking_for_help"
    ESX.Streaming.RequestAnimDict(dict)
    TaskPlayAnim(npc, dict, anim, 8.0, 1.0, -1, 16, 0.0, false, false, false)
    SetModelAsNoLongerNeeded(pedModel)
end

local function MonitorRepair()
CreateThread(function()
        while true do
            Wait(1000)
            if GetVehicleEngineHealth(vehicle) > 950.0 then
                ESX.ShowNotification(Translate('vehicle_repaired'))
                TriggerServerEvent('esx_mechanicjob:server:completeJob', activeJob)
                EndJob()
                break
            end
        end
    end)
end

local function FindNearestDropOffPoint(coords)
    local closestPoint, closestDistance = nil, math.huge
    for _, zone in pairs(Config.MechanicZones) do
        local dropOffPointCoords = vector3(zone.dropOffPoint.x, zone.dropOffPoint.y, zone.dropOffPoint.z)
        local distance = #(dropOffPointCoords - vec3(coords.x, coords.y, coords.z))
        if distance < closestDistance then
            closestDistance = distance
            closestPoint = dropOffPointCoords
        end
    end
    return closestPoint
end


local function CreateRepairPoint(job)
    if repairPoint then repairPoint:delete() end
    print("Created point")
    repairPoint = ESX.Point:new({
        coords = job.npcCoords,
        distance = 25.0,
        enter = function()
            if vehicle or npc then 
                ESX.ShowNotification(Translate('vehicle_already_spawned'))
                return EndJob()
            end
            local vehNetId = ESX.AwaitServerCallback("esx_mechanicjob:server:spawnVehicle")
            vehicle = NetworkGetEntityFromNetworkId(vehNetId)
            SpawnNPC(job.npcCoords, job.npcHeading, job.npcModel)
            Wait(1000)
            DrawOnVehicle(vehicle)
        end,
        inside = function()
            DrawText3D(job.vehicleCoords, "~INPUT_PICKUP~ Start the job", 0.4)
            if IsControlJustReleased(0, 38) then
                MonitorRepair()
                SetEntityDrawOutline(vehicle, false)
                repairPoint:delete()
            end
        end
    })
end

local function CreateTowDropOffPoint(dropOffCoords)
    CreateJobBlip(dropOffCoords, 'Meow')
    if not dropOffCoords then return end
    if towDropOffPoint then towDropOffPoint:delete() end
    towDropOffPoint = ESX.Point:new({
        coords = dropOffCoords,
        distance = 10.0,
        enter = function()
            ESX.ShowNotification(Translate('job_complete'))
            DeleteEntity(vehicle)
            TriggerServerEvent('esx_mechanicjob:server:completeJob', activeJob)
            EndJob()
        end
    })
end

local function CreateTowStartPoint(job)
    if towStartPoint then towStartPoint:delete() end
    towStartPoint = ESX.Point:new({
        coords = job.npcCoords,
        distance = 25.0,
        enter = function()
            if vehicle or npc then 
                ESX.ShowNotification(Translate('vehicle_already_spawned'))
                return
            end
            local vehNetId = ESX.AwaitServerCallback("esx_mechanicjob:server:spawnVehicle")
            vehicle = NetworkGetEntityFromNetworkId(vehNetId)
            SpawnNPC(job.npcCoords, job.npcHeading, job.npcModel)
            Wait(1000)
            DrawOnVehicle(vehicle)
        end,
        inside = function()
            DrawText3D(job.vehicleCoords, "~INPUT_PICKUP~ Start the job", 0.4)
            if IsControlJustReleased(0, 38) then
                local dropOffPoint = FindNearestDropOffPoint(job.vehicleCoords)
                CreateTowDropOffPoint(dropOffPoint)
                SetEntityDrawOutline(vehicle, false)
                towStartPoint:delete()
            end
        end
    })
end


RegisterNetEvent('esx_mechanicjob:client:startJob', function(job)
    if activeJob then return ESX.ShowNotification(Translate('already_active_job')) end

    activeJob = job
    
    if job.type == "repair" then
        CreateRepairPoint(job)
    elseif job.type == "tow" then
        CreateTowStartPoint(job)
    end
    CreateJobBlip(job.npcCoords, job.jobName)
end)


function OpenNpcMenu()
    local elements = {
        { label = Translate('start_job'), value = "start_job" },
        { label = Translate('end_job'), value = "end_job" }
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'npc_job_menu', {
        title = Translate('npc_mechanic_title'),
        align = "top-right",
        elements = elements
    }, function(data, menu)
        if data.current.value == "start_job" then
            if activeJob then return ESX.ShowNotification(Translate('already_active_job')) end
            TriggerServerEvent('esx_mechanicjob:server:startJob')
        elseif data.current.value == "end_job" then
            EndJob()
        end
    end, function(data, menu)
        menu.close()
    end)
end
