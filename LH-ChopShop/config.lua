Config = {}

Config.Debug = {
    Toggle = true,
    debugColour = vec(0, 100, 0, 80),
}

Config.StartNPC = {
    Model = 'a_m_m_og_boss_01',
    Coords = vec3(-207.0442, -1361.3014, 30.2582),
    Heading = 34.0566,
    Wait = {
        Min = 5000,
        Max = 10000,
    },
}

Config.ExchangeInput = {
    {
        type = 'select',
        label = 'Select a material',
        required = true,
        options = {
            {value = 'aluminum', label = 'Aluminum'},
            {value = 'copper', label = 'Copper'},
            {value = 'glass', label = 'Glass'},
            {value = 'iron', label = 'Iron'},
            {value = 'scrapmetal', label = 'Scrap Metal'},
            {value = 'plastic', label = 'Plastic'},
            {value = 'rubber', label = 'Rubber'},
            {value = 'steel', label = 'Steel'}
        }
    },
    {type = 'number', label = 'Amount', required = true, mine = 1},
}

Config.Chop = {
    ProgressCircle = {
        Duration = 5000,
        Label = 'Chopping Part',
        Position = 'bottom',
        canCancel = true,
        Disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
        Anim = {
            Door = {scenario = 'WORLD_HUMAN_WELDING'},
            Wheel = {
                dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                clip = "machinic_loop_mechandplayer",
                flag = 10
            }
        },
        Prop = {},
    },

    SkillCheck = {
        SkillCheckDifficulty = {'easy', 'easy', 'easy', 'easy'},
        SkillCheckKeys = {'1', '2', '3', '4'}
    },

    Reward = {
        Part = {
            Min = 10,
            Max = 20,
        },
        Chassis = {
            Min = 20,
            Max = 30,
            MoneyMin = 500,
            MoneyMin = 750,
        }
    },
}


Config.Cars = {
    List = {
        -- Coupes
        'CogCabrio',
        'Exemplar',
        'F620',
        'Felon',
        'Jackal',
        'Oracle',
        'Sentinel',
        'Windsor2',
        'Zion',
        -- Compacts
        'asbo',
        'blista',
        'brioso',
        'dilettante',
        'issi2',
        'panto',
        'prairie',
        'rhapsody',
        -- Muscle
        'blade',
        'buccaneer',
        'chino',
        'coquette3',
        'deviant',
        'dominator',
        'dukes',
        'faction2',
        'ellie',
        'gauntlet',
        'hotknife',
        'hustler',
        'impaler',
        -- SUV
        'baller',
        'bjxl',
        'cavalcade',
        'dubsta',
        'fq2',
        'granger',
        'gresley',
        'habanero',
        'huntley',
        'patriot',
        'rocoto',
        -- Sedans
        'asea',
        'asterope',
        'cog55',
        'emperor',
        'fugitive',
        'glendale',
        'ingot',
        'intruder',
        'premier',
        'primo',
        'regina',
        'stanier',
        'stratum'
    },
    Location = {
        vec4(353.814, -1697.645, 37.375, 139.865),
        vec4(9.312, -1066.728, 37.74, 249.083),
        vec4(-467.61, -613.472, 30.762, 180.876),
        vec4(-1324.804, -236.358, 42.276, 123.864),
        vec4(-1534.122, -408.859, 41.578, 48.407)
    }
}

Config.ChopLocations = {
    vec3(1565.197, -2158.905, 77.524),
    vec3(-84.579, -2224.341, 7.811),
    vec3(-468.702, -1674.937, 19.063),
}