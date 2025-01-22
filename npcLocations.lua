Config.Rewards = {
    ['tow'] = 500,
    ['repair'] = 500
}

Config.NPCJobs = {
    {
        npcCoords = vector3(-1558.4471, 2134.2812, 57.6997), -- NPC spawn location
        npcHeading = 304.9506, --NPC Heading
        vehicleCoords = vector4(-1559.8953, 2136.2502, 57.5287, 323.2817), -- Vehicle spawn location (x, y, z, heading)
        jobName = "Repair Vehicle", --Blip name
        type = "tow", -- Job type, options: "repair" or "tow"
        carModel = 'adder', -- Car model for the job
        npcModel = `a_f_m_beach_01` -- NPC model for the job
    },
    {
        npcCoords = vector3(-1558.4471, 2134.2812, 57.6997), -- NPC spawn location
        npcHeading = 304.9506, --NPC Heading
        vehicleCoords = vector4(-1559.8953, 2136.2502, 57.5287, 323.2817), -- Vehicle spawn location (x, y, z, heading)
        jobName = "Tow Vehicle", --Blip name
        type = "tow", -- Job type, options: "repair" or "tow"
        carModel = 'adder', -- Car model for the job
        npcModel = `a_f_m_beach_01` -- NPC model for the job
    }
}
