Config.Rewards = {
    ['tow'] = 500,
    ['repair'] = 500
}

Config.NPCJobs = {
    {
        npcCoords = vector3(-1501.8121, 2095.8499, 58.1666), -- NPC spawn location
        npcHeading = 50, --NPC Heading
        vehicleCoords = vector4(-1506.6669, 2099.3792, 57.8087, 34.9757), -- Vehicle spawn location (x, y, z, heading)
        jobName = "Repair Vehicle", -- Repair job
        type = "tow", -- repair | tow
        carModel = 'adder', -- Car model for the repair job
        npcModel = `s_m_y_mechanic_01` -- NPC model for the repair job
    },
    {
        npcCoords = vector3(-1501.8121, 2095.8499, 58.1666), -- NPC spawn location
        npcHeading = 50, -- NPC heading
        vehicleCoords = vector4(-1506.6669, 2099.3792, 57.8087, 34.9757), -- Vehicle spawn location (x, y, z, heading)
        jobName = "Tow Vehicle", -- Towing job
        type = "tow",
        carModel = 'adder', -- Car model for the tow job
        npcModel = `s_m_y_mechanic_01` -- NPC model for the tow job
    }
}
