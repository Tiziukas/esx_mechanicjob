Config = {}

Config.Locale = GetConvar('esx:locale', 'en')

Config.Controls = {
	mechanicMenu = "F6"
}

Config.FlipVehicleOnRepair = false --Puts the vehicle on the ground if it was flipped after using the repair kit.

Config.ItemNames = {
    repairKit = 'repairkit'
}

Config.MechanicZones = {
    ["Paleto Bay Customs"] = {
        blip = {
            location = vec3(1930.5258, 2985.7361, 45.6235), -- Location of the blip
            sprite = 446, -- Blip icon | https://docs.fivem.net/docs/game-references/blips/
            colour = 11, -- Blip color | https://docs.fivem.net/docs/game-references/blips/#blip-colors
            scale = 1.0, -- Blip size (1.0 is the standard size)
            shortRange = true, -- If true, the blip will only be visible when near
            name = "Paleto Bay Customs" -- The name displayed when hovering over the blip
        },
        cloakroom = {
            location = vec3(1930.1206, 2985.9067, 45.6234), -- Location of cloakroom marker
            marker = {
                colour = {245, 40, 145, 0.8}, -- RGBA color | https://rgbacolorpicker.com/
                rotate = true, -- Should the marker rotate?
                type = 20, -- Marker type | https://docs.fivem.net/docs/game-references/markers/
                scale = {1.0, 1.0, 1.0} -- Marker scale (x, y, z)
            }
        },
        mechanicStash = {
            location = vec3(1930.5258, 2985.7361, 45.6235),
            marker = {
                colour = {0, 255, 0, 0.8},   -- RGBA color | https://rgbacolorpicker.com/
                rotate = true,  -- Should the marker rotate?
                type = 1,  -- Marker type | https://docs.fivem.net/docs/game-references/markers/
                scale = {1.0, 1.0, 1.0} -- Marker scale (x, y, z)
            }
        },
        bossMenu = {  
            location = vec3(-1496.6725, 2136.5903, 55.937), -- Boss menu marker location  
            marker = {  
                colour = {0, 0, 255, 0.8}, -- RGBA color for the marker  
                rotate = true, -- Should the marker rotate?  
                type = 22, -- Marker type | https://docs.fivem.net/docs/game-references/markers/  
                scale = {1.2, 1.2, 1.2} -- Marker dimensions (x, y, z)  
            }  
        }, 
        dropOffPoint = vec3(-1496.6725, 2136.5903, 55.937) -- The location for the drop-off point for the towing NPC job.
    }
}

Config.ProgressBars = {
    repairKit = {
        time = 5000,
        animation = {
            dict = "missmechanic",
            lib = "work2_in"
        }
    },
    impoundVehicle = {
        time = 5000,
        animation = {
            dict = "ah_2_ext_alt-7",
            lib = "player_one_dual-7"
        }
    },
    breakIntoVehicle = {
        time = 5000,
        animation = {
            dict = "anim@amb@casino@brawl@reacts@hr_blackjack@bg_blackjack_breakout_t02bg_blackjack_breakout_t02_s01_s03",
            lib =  "gawk_loop_female_02"
        }
    },
    fixVehicle = {
        time = 5000,
        animation = {
            dict = "missmechanic",
            lib = "work2_in"
        }
    },
    cleanVehicle = {
        time = 5000,
        animation = {
            dict = "timetable@maid@cleaning_window@idle_b",
            lib = "idle_d"
        }
    },
}

Config.MechanicOutfits = {
    [0] = { -- Job Grade
        male = {
            ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
            ['torso_1']  = 65,  ['torso_2']  = 0,
            ['decals_1'] = 0,   ['decals_2'] = 0,
            ['arms']     = 17,
            ['pants_1']  = 38,  ['pants_2']  = 0,
            ['shoes_1']  = 12,  ['shoes_2']  = 0,
            ['helmet_1'] = -1,  ['helmet_2'] = 0,
            ['chain_1']  = 0,   ['chain_2']  = 0,
            ['mask_1']   = 0,   ['mask_2']   = 0
        },
        female = {
            ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
            ['torso_1']  = 59,  ['torso_2']  = 0,
            ['decals_1'] = 0,   ['decals_2'] = 0,
            ['arms']     = 5,
            ['pants_1']  = 38,  ['pants_2']  = 0,
            ['shoes_1']  = 27,  ['shoes_2']  = 0,
            ['helmet_1'] = -1,  ['helmet_2'] = 0,
            ['chain_1']  = 0,   ['chain_2']  = 0,
            ['mask_1']   = 0,   ['mask_2']   = 0
        }
    },
    [1] = { -- Job Grade
        male = {
            ['tshirt_1'] = 20,  ['tshirt_2'] = 0,
            ['torso_1']  = 66,  ['torso_2']  = 1,
            ['decals_1'] = 0,   ['decals_2'] = 0,
            ['arms']     = 18,
            ['pants_1']  = 39,  ['pants_2']  = 1,
            ['shoes_1']  = 13,  ['shoes_2']  = 1,
            ['helmet_1'] = -1,  ['helmet_2'] = 0,
            ['chain_1']  = 0,   ['chain_2']  = 0,
            ['mask_1']   = 0,   ['mask_2']   = 0
        },
        female = {
            ['tshirt_1'] = 20,  ['tshirt_2'] = 0,
            ['torso_1']  = 60,  ['torso_2']  = 1,
            ['decals_1'] = 0,   ['decals_2'] = 0,
            ['arms']     = 6,
            ['pants_1']  = 39,  ['pants_2']  = 1,
            ['shoes_1']  = 28,  ['shoes_2']  = 1,
            ['helmet_1'] = -1,  ['helmet_2'] = 0,
            ['chain_1']  = 0,   ['chain_2']  = 0,
            ['mask_1']   = 0,   ['mask_2']   = 0
        }
    }
}
