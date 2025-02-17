Config = {}

Config.Debug = {
    Toggle = false,
    debugColour = vec(0, 100, 0, 80),
}

Config.ShopNPC = {
    model = 's_m_y_construct_01',
    coords = vec3(2707.3708, 2776.7751, 36.8780),
    heading = 33.7801,
}

Config.Tools = {
    jackhammer = {
        time = 5000,
        minReward = 10,
        maxReward = 15,
        animation = {
            dict = 'amb@world_human_const_drill@male@drill@base',
            clip = 'base',
        },
        prop = {
            model = 'prop_tool_jackham',
            bone = 28422,
            pos = vec3(0.05, 0.00, 0.00),
            rot = vec3(0.0, 0.0, 0.0),
        },
    },
    pickaxe = {
        time = 10000,
        minReward = 5,
        maxReward = 10,
        animation = {
            dict = 'melee@large_wpn@streamed_core',
            clip = 'ground_attack_0',
            flag = 1,
        },
        prop = {
            model = 'prop_tool_pickaxe',
            bone = 28422,
            pos = vec3(0.05, 0.00, 0.00),
            rot = vec3(-70.0, 30.0, 0.0)
        },
    },
    shovel = {
        time = 15000,
        minReward = 1,
        maxReward = 5,
        animation = {
            dict = 'amb@world_human_gardener_plant@male@base',
            clip = 'base',
            flag = 1,
        },
        prop = {
            model = 'prop_cs_trowel',
            bone = 28422,
            pos = vec3(0.00, 0.00, 0.00),
            rot = vec3(0.0, 0.0, -1.5)
        },
    },
}

Config.Process = {
    coords = vec3(2655.0359, 2811.4021, 34.4200),
    time = 5000,
    gemRocks = 5, -- Every x dirt processed gives a gem rock
    animation = {
        dict = 'anim@amb@business@coc@coc_unpack_cut@',
        clip = 'fullcut_cycle_v1_cokecutter',
        flag = 1,
    },
    input = {
        {
            type = 'select',
            label = 'Select a material',
            required = true,
            options = {
                {value = 'aluminum', label = 'Aluminum'},
                {value = 'copper', label = 'Copper'},
                {value = 'gold', label = 'Gold'},
                {value = 'iron', label = 'Iron'},
                {value = 'steel', label = 'Steel'}
            }
        },
        {type = 'number', label = 'Amount', required = true, mine = 1}
    }
}

Config.Drill = {
    model = 'gr_prop_gr_speeddrill_01b',
    coords = vec3(1073.5166, -1988.4132, 29.9101),
    heading = 57.1677,
    time = 10000,
    reward = {
        'ruby',
        'sapphire',
        'emerald',
        'diamond'
    },
    animation = {
        dict = 'amb@prop_human_parking_meter@male@idle_a',
        clip = 'idle_a',
        flag = 1,
    }
}

Config.MinableRocksZone = {
    coords = vec3(2952.2576, 2793.0229, 40.8185),
    rockModel = 'prop_rock_1_d',
    respawn = {
        min = 1000,
        max = 5000,
    },
    locations = {
        vec3(2946.4995, 2769.6765, 37.8789),
        vec3(2938.5801, 2775.2109, 37.9311),
        vec3(2952.6575, 2774.2351, 37.9595),
        vec3(2963.0698, 2769.9463, 38.4175),
        vec3(2962.8118, 2778.1653, 38.5578),
        vec3(2944.9851, 2779.6929, 38.0119),
        vec3(2976.0640, 2775.6104, 37.3494),
        vec3(2960.7114, 2790.2666, 39.0193),
        vec3(2952.3350, 2793.7534, 39.3827),
        vec3(2945.0183, 2788.4546, 38.8055),
        vec3(2937.8682, 2783.9619, 38.1805),
        vec3(2938.0085, 2791.5024, 38.7711),
        vec3(2966.5178, 2783.5339, 37.9497),
        vec3(2974.2708, 2784.1501, 37.8751),
        vec3(2974.8833, 2795.0605, 39.6270),
        vec3(2969.5471, 2787.8462, 38.2455),
        vec3(2929.8489, 2791.5310, 39.0995),
        vec3(2933.4536, 2796.9028, 39.4470),
        vec3(2924.9785, 2799.5664, 40.0582),
        vec3(2953.2825, 2821.8506, 42.0132),
        vec3(2944.4036, 2823.5918, 43.0255),
        vec3(2941.4451, 2815.2927, 41.3040),
        vec3(2934.0889, 2814.7346, 42.4559),
        vec3(2923.7869, 2813.4651, 43.4573),
        vec3(2951.0271, 2816.1423, 41.3114),
        vec3(2943.5776, 2793.9473, 39.0265)
    }
}