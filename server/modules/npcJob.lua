local jobCooldowns = {}
local activeJobs = {}
local dropOffPoint = {}

local JOB_TYPE_REPAIR <const> = "repair"
local JOB_TYPE_TOW <const> = "tow"
local MAX_JOB_DISTANCE <const> = 15.0
local JOB_COOLDOWN_TIME <const> = 60

local function dropPlayer(_source, message)
    print(string.format('%s was dropped due to %s', GetPlayerName(_source), message))
    ---DropPlayer(_source, "Cheating")
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

RegisterNetEvent('esx_mechanicjob:server:startJob', function()
    local _source <const> = source
    local xPlayer <const> = ESX.GetPlayerFromId(_source)

    if not xPlayer then
        return
    end

    if not xPlayer.job or xPlayer.job.name ~= "mechanic" then
        dropPlayer(_source, "You are not a mechanic!")
        return
    end
    local job = Config.NPCJobs[math.random(#Config.NPCJobs)]

    activeJobs[_source] = {job = job, dropOffPoint = FindNearestDropOffPoint(job.vehicleCoords)}

    TriggerClientEvent("esx_mechanicjob:client:startJob", _source, job)
    print(string.format('Player %s started job %s', GetPlayerName(_source), job.type))
end)

RegisterNetEvent('esx_mechanicjob:server:completeJob', function(job)
    local _source <const> = source
    local xPlayer <const> = ESX.GetPlayerFromId(_source)
    local distance

    if not xPlayer then
        return
    end

    if not xPlayer.job or xPlayer.job.name ~= "mechanic" then
        dropPlayer(_source, "Not Mechanic")
        return
    end

    if not activeJobs[_source] then
        dropPlayer(_source, "Job was not active")
        return
    end

    local currentJob = activeJobs[_source]
    print(json.encode(currentJob))
    if currentJob.job.type ~= job.type then
        dropPlayer(_source, "Job type mismatch!")
        return
    end

    local playerCoords = GetEntityCoords(GetPlayerPed(_source))

    if currentJob.type == 'repair' then
        distance = #(playerCoords - vec3(currentJob.vehicleCoords.x, currentJob.vehicleCoords.y, currentJob.vehicleCoords.z))
    else
        distance = #(playerCoords - vec3(currentJob.dropOffPoint.x, currentJob.dropOffPoint.y, currentJob.dropOffPoint.z))
    end
    
    if distance > MAX_JOB_DISTANCE then
        dropPlayer(_source, "Player was too far")
        return
    end

    --if jobCooldowns[_source] and jobCooldowns[_source] > os.time() then
    --    dropPlayer(_source, "Cooldown breached.")
    --    return
    --end

    jobCooldowns[_source] = os.time() + JOB_COOLDOWN_TIME

    local reward = Config.Rewards[currentJob.job.type]
    if currentJob.job.type == JOB_TYPE_REPAIR then
        xPlayer.addMoney(reward)
    elseif currentJob.job.type == JOB_TYPE_TOW then
        xPlayer.addMoney(reward)
    else
        dropPlayer(_source, "Error: Unknown job type.")
        return
    end

    activeJobs[_source] = nil
    print(string.format('Mechanic job completed: %s for player %s', currentJob.type, _source))
end)
