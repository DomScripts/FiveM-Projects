Config = {}

Config.Debug = {
    Toggle = false,
    debugColour = vec(0, 100, 0, 80),
}

Config.SkillCheckKeys = {'1', '2', '3', '4'}

Config.RareStarPeltChance = 30

Config.ShopNPC = {
    model = 'cs_hunter',
    coords = vec3(-775.8341, 5603.6660, 32.7409),
    heading = 255.4447,
}

Config.HuntingZone = {
    Coords = vec3(-869.9602, 3507.3347, 226.9089),
    Radius = 500.0,

    ZoneSprite = 141,
    ZoneColor = 3,
}

Config.SellNPC = {
    Model = 's_m_m_linecook',
    Coords = vec3(569.4952, 2796.7012, 41.0183),
    Heading = 271.6597,

    LegalPelts = {
        [1] = {
            name = 'animal_pelt_legal_1',
            item = 'money',
            price = 750,
        },
        [2] = {
            name = 'animal_pelt_legal_2',
            item = 'money',
            price = 1000
        },
        [3] = {
            name = 'animal_pelt_legal_3',
            item = 'money',
            price = 1500
        },
    },

    IllgalPelts = {
        [1] = {
            name = 'animal_pelt_illegal_3',
            item = 'black_money',
            price = 2500
        }
    }
}

Config.Bait = {
    Cooldown = 10000,   -- (X * 60000) -> X = Minutes
    Duration = 5000,
    Label = 'Placing Bait',
    Animation = {
        dict = 'amb@world_human_gardener_plant@male@base',
        clip = 'base',
        flag = 1,
    },
    Prop = {
        model = 'prop_cs_trowel',
        bone = 28422,
        pos = vec3(0.00, 0.00, 0.00),
        rot = vec3(0.0, 0.0, -1.5)
    },
    ShapeTestOffSets = {    -- Don't change these unless you know what you are doing
        Start = vector4(0.0, 1.0, -1.0, 0.0),
        End = vector4(0.0, 0.0, 1.0, 0.0),
    },
}

Config.Knife = {
    Duration = 10000,
    Label = 'Skinning Animal',
    Animation = {
        dict = 'amb@world_human_gardener_plant@male@base',
        clip = 'base',
        flag = 1,
    },
    Prop = {
        model = 'w_me_knife_01',
        bone = 28422,
        pos = vec3(0.00, 0.00, 0.00),
        rot = vec3(0.00, 180.00, 0.00)
    },
}

Config.Animals = {
    [1] = {
        ['name'] = 'Deer',
        ['model'] = 'a_c_deer',
        ['legal'] = true,
    },
    [2] = {
        ['name'] = 'Boar',
        ['model'] = 'a_c_boar',
        ['legal'] = true,
    },
    [3] = {
        ['name'] = 'Coyot',
        ['model'] = 'a_c_coyote',
        ['legal'] = true,
    },
    [4] = {
        ['name'] = 'Mountain Lion',
        ['model'] = 'a_c_mtlion',
        ['legal'] = false,
    },
}