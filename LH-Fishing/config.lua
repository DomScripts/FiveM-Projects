Config = {}

Config.Debug = {
    Toggle = false,
    debugColour = vec(0, 100, 0, 80),
}

Config.SkillCheckKeys = {'1', '2', '3', '4'}

Config.SellPrice = 30
Config.IllegalPrice = 500

Config.FishPerPerson = 2
Config.MoneyPerPerson = 500

Config.ActiveFishingZones = {
    vec3{-248.4874, 4268.6802, 33.3359},
    vec3{-84.0133, 4248.4590, 34.4436},
    vec3{1306.0597, 4255.5513, 33.9086},
    vec3{1997.0448, 4529.2114, 30.3550},
    vec3{2197.1768, 4613.8086, 33.8784},
    vec3{2358.9929, 4295.5625, 32.7461}
}

Config.NPC = {
    StartModel = 'a_m_m_hillbilly_01',
    StartModelCoords = vec3(-1504.7040, 1511.1404, 114.2887),
    StartModelHeading = 251.1603,

    SellModel = 'a_m_m_mexcntry_01',
    SellModelCoords = vec3(-1830.5743, -1180.5623, 13.3230),
    SellModelHeading = 334.7479,
}

Config.FishingLoot = {
    [1] = {
        ['name'] = 'catfish',
        ['chance'] = 60,
        ['legal'] = true,
        ['skillcheck'] = {
            'easy', 'easy', 'easy'
        }
    },
    [2] = {
        ['name'] = 'largemouthbass',
        ['chance'] = 60,
        ['legal'] = true,
        ['skillcheck'] = {
            'easy', 'easy', 'easy'
        }
    },
    [3] = {
        ['name'] = 'redfish',
        ['chance'] = 65,
        ['legal'] = true,
        ['skillcheck'] = {
            'easy', 'easy', 'easy'
        }
    },
    [4] = {
        ['name'] = 'salmon',
        ['chance'] = 65,
        ['legal'] = true,
        ['skillcheck'] = {
            'easy', 'easy', 'easy'
        }
    },
    [5] = {
        ['name'] = 'stingray',
        ['chance'] = 20,
        ['legal'] = false,
        ['skillcheck'] = {
            'medium', 'medium', 'medium'
        }
    },
    [6] = {
        ['name'] = 'stripedbass',
        ['chance'] = 45,
        ['legal'] = true,
        ['skillcheck'] = {
            'easy', 'easy', 'easy'
        }
    },
    [7] = {
        ['name'] = 'shark',
        ['chance'] = 20,
        ['legal'] = false,
        ['skillcheck'] = {
            'medium', 'medium', 'medium'
        }
    },
}