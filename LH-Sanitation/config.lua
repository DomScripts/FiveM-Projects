Config = {}

Config.Debug = {
    Toggle = false,
    debugColour = vec(0, 100, 0, 80),
}

Config.TrashPerTrip = 3
Config.CashPerPerson = 75     -- This number times the amount of people in the group
Config.MaterialPerPerson = 25       -- This number times the amount of people in the group
Config.Trips = 2        -- Amount of trips per job to be completed

Config.NPC = {
    StartModel = 's_m_y_garbage',
    StartModelCoords = vec3(-349.8445, -1548.1686, 26.7213),
    StartModelHeading = 356.3340,

    ExchangeModel = 's_m_y_garbage',
    ExchangeModelCoords = vec3(-355.7421, -1556.1749, 24.1738),
    ExchangeModelHeading = 177.4088,
}

Config.Truck = {
    Model = 'trash2',
    Coords = vec3(-335.1036, -1564.4742, 25.2317),
    Heading = 241.6828,

    ReturnCoords = vec3(-335.4154, -1564.3905, 25.2317),
    ReturnHeading = -30,
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
    {type = 'number', label = 'Amount', required = true, mine = 1}
}

Config.SanitationZones = {
    [1] = {
        ['name'] = 'Rancho',
        ['coords'] = vec3(485.4574, -1812.7850, 28.9906),
        ['size'] = vec3(350,250,20),
        ['rotation'] = 50,
    },
    [2] = {
        ['name'] = 'Docks',
        ['coords'] = vec3(803.9777, -3111.6902, 11.1938),
        ['size'] = vec3(350,150,20),
        ['rotation'] = 90,
    },
    [3] = {
        ['name'] = 'Cypress Flats',
        ['coords']= vec3(927.7657, -2114.5664, 33.8358),
        ['size'] = vec3(700,300,20),
        ['rotation'] = 85,
    },
    [4] = {
        ['name'] = 'El Burro Heights',
        ['coords'] = vec3(1253.3329, -1676.9341, 34.2162),
        ['size'] = vec3(200,200,80),
        ['rotation'] = 30,
    },
    [5] = {
        ['name'] = 'Murrieta Heights',
        ['coords'] = vec3(1177.7987, -1292.3022, 38.8846),
        ['size'] = vec3(235,125,20),
        ['rotation'] = 85,
    },
    [6] = {
        ['name'] = 'East Vinewood',
        ['coords'] = vec3(911.0658, -130.2027, 80.1384),
        ['size'] = vec3(250,225,20),
        ['rotation'] = 147,
    },
    [7] = {
        ['name'] = 'Hawick',
        ['coords'] = vec3(68.8680, -191.0040, 57.3753),
        ['size'] = vec3(300,170,30),
        ['rotation'] = 160,
    },
    [8] = {
        ['name'] = 'Pacific Bluffs',
        ['coords'] = vec3(-1928.8380, -552.5938, 16.5658),
        ['size'] = vec3(50,180,20),
        ['rotation'] = 50,
    },
    [9] = {
        ['name'] = 'Del Perro',
        ['coords'] = vec3(-1796.2903, -666.5953, 14.7114),
        ['size'] = vec3(50,180,20),
        ['rotation'] = 50,
    },
    [10] = {
        ['name'] = 'Chamberlain Hills',
        ['coords'] = vec3(-168.4568, -1627.2463, 35.5527),
        ['size'] = vec3(195,180,20),
        ['rotation'] = 50,
    },
    [11] = {
        ['name'] = 'Burton',
        ['coords'] = vec3(-491.2210, -50.2605, 44.3717),
        ['size'] = vec3(120,60,20),
        ['rotation'] = -5,
    },
    [12] = {
        ['name'] = 'Rockford Hills',
        ['coords'] = vec3(-1257.0668, -212.9066, 45.7159),
        ['size'] = vec3(180,180,25),
        ['rotation'] = 30,
    },
    [13] = {
        ['name'] = 'Richman',
        ['coords'] = vec3(-1556.1067, 51.3037, 60.5772),
        ['size'] = vec3(225,80,20),
        ['rotation'] = -5,
    },
    [14] = {
        ['name'] = 'West Vinewood',
        ['coords'] = vec3(-325.3017, 67.7848, 67.9639),
        ['size'] = vec3(140,170,60),
        ['rotation'] = 0,
    }
}

Config.TargetModels = {
    'p_dumpster_t', 
    'prop_cs_dumpster_01a', 
    'prop_dumpster_01a', 
    'prop_dumpster_02a',
    'prop_dumpster_02b', 
    'prop_dumpster_3a', 
    'prop_dumpster_4a', 
    'prop_dumpster_4b',
    'bkr_prop_fakeid_binbag_01',
    'hei_heist_kit_bin_01',
    'hei_prop_heist_binbag',
    'ng_proc_binbag_01a',
    'p_binbag_01_s',
    'p_rub_binbag_test',
    'prop_bin_01a',
    'prop_bin_02a',
    'prop_bin_03a',
    'prop_bin_04a',
    'prop_bin_05a',
    'prop_bin_06a',
    'prop_bin_07a',
    'prop_bin_07b',
    'prop_bin_07c',
    'prop_bin_07d',
    'prop_bin_08a',
    'prop_bin_08open',
    'prop_bin_10a',
    'prop_bin_10b',
    'prop_bin_11a',
    'prop_bin_11b',
    'prop_bin_12a',
    'prop_bin_14a',
    'prop_bin_14b',
    'prop_bin_beach_01a',
    'prop_cs_bin_01',
    'prop_cs_bin_01_skinned',
    'prop_cs_bin_02',
    'prop_cs_bin_03',
    'prop_cs_rub_binbag_01',
    'prop_cs_street_binbag_01',
    'prop_gas_smallbin01',
    'prop_ld_binbag_01',
    'prop_ld_rub_binbag_01',
    'prop_recyclebin_01a',
    'prop_recyclebin_02_c',
    'prop_recyclebin_02_d',
    'prop_recyclebin_02a',
    'prop_recyclebin_02b',
    'prop_recyclebin_03_a',
    'prop_rub_binbag_01',
    'prop_rub_binbag_01b',
    'prop_rub_binbag_03',
    'prop_rub_binbag_03b',
    'prop_rub_binbag_04',
    'prop_rub_binbag_05',
    'prop_rub_binbag_06',
    'prop_rub_binbag_08',
    'prop_rub_binbag_sd_01',
    'prop_rub_binbag_sd_02',
}