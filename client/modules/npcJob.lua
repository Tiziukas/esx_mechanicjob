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
    SetEntityDrawOutline(vehicle, true)
    SetEntityDrawOutlineColor(251, 155, 4, 1)
end

local function EndJob()
    if activeJob then
        ESX.ShowNotification(TranslateCap('job_ended'))
        if DoesEntityExist(vehicle) then DeleteEntity(vehicle) end
        if repairPoint then repairPoint:delete() end
        if towStartPoint then towStartPoint:delete() end
        if towDropOffPoint then towDropOffPoint:delete() end
        if DoesEntityExist(vehicle) then
            SetEntityAsMissionEntity(vehicle, true, true)
            ESX.Game.DeleteVehicle(vehicle) 
        end
        vehicle, npc, activeJob = nil, nil, nil
        if jobBlip then RemoveBlip(jobBlip) end
    else
        ESX.ShowNotification(TranslateCap('no_active_job'))
    end
end

local function SpawnNPC(coords, pedModel)
    if npc then return npc end
    ESX.Streaming.RequestModel(pedModel)
    npc = CreatePed(4, pedModel, coords.x, coords.y, coords.z, 180.0, false, true)
    print(npc)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetModelAsNoLongerNeeded(pedModel)
end

local function SpawnVehicle(coords, model)
    if vehicle then return vehicle end
    ESX.Game.SpawnVehicle(model, coords, 0.0, function(veh)
        SetVehicleOnGroundProperly(veh)
        vehicle = veh
    end)
    return vehicle
end

local function MonitorRepair()
    CreateThread(function()
        while true do
            Wait(1000)
            if GetVehicleEngineHealth(vehicle) > 950.0 then
                ESX.ShowNotification(TranslateCap('vehicle_repaired'))
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
    print("Creating Repair Start Point")
    if repairPoint then repairPoint:delete() end
    repairPoint = ESX.Point:new({
        coords = job.npcCoords,
        distance = 25.0,
        enter = function()
            if vehicle or npc then 
                ESX.ShowNotification(TranslateCap('vehicle_already_spawned'))
                return EndJob()
            end
            print("Player Entered Zone")
            SpawnVehicle(job.vehicleCoords, job.carModel)
            SpawnNPC(job.npcCoords, job.npcModel)
            Wait(1000)
            SetVehicleEngineHealth(vehicle, 0.0)
            DrawOnVehicle(vehicle)
        end,
        inside = function()
            DrawText3D(job.vehicleCoords, "~INPUT_PICKUP~ Start the job", 0.4)
            if IsControlJustReleased(0, 38) then
                MonitorRepair()
                SetEntityDrawOutline(vehicle, false)
                repairPoint:delete()
                print("Delete Point")
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
            ESX.ShowNotification(TranslateCap('job_complete'))
            DeleteEntity(vehicle)
            TriggerServerEvent('esx_mechanicjob:server:completeJob', activeJob)
            EndJob()
        end
    })
end

local function CreateTowStartPoint(job)
    if towStartPoint then towStartPoint:delete() end
    print("Creating Tow Start Point")
    towStartPoint = ESX.Point:new({
        coords = job.npcCoords,
        distance = 10.0,
        enter = function()
            if vehicle or npc then 
                ESX.ShowNotification(TranslateCap('vehicle_already_spawned'))
                return
            end
            SpawnVehicle(job.vehicleCoords, job.carModel)
            SpawnNPC(job.npcCoords, job.npcModel)
            Wait(1000)
            SetVehicleEngineHealth(vehicle, 0.0)
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
    if activeJob then
        ESX.ShowNotification(TranslateCap('already_active_job'))
        return
    end
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
        { label = TranslateCap('start_job'), value = "start_job" },
        { label = TranslateCap('end_job'), value = "end_job" }
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'npc_job_menu', {
        title = TranslateCap('npc_mechanic_title'),
        align = "top-right",
        elements = elements
    }, function(data, menu)
        if data.current.value == "start_job" then
            if activeJob then
                ESX.ShowNotification(TranslateCap('already_active_job'))
            else
                TriggerServerEvent('esx_mechanicjob:server:startJob')
            end
        elseif data.current.value == "end_job" then
            EndJob()
        end
    end, function(data, menu)
        menu.close()
    end)
end
