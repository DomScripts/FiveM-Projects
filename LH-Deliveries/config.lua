Config = {}

Config.Debug = {
    Toggle = false,
    debugColour = vec(0, 100, 0, 80),
}

Config.Job = {
    Boxes = 2,
    Trips = 2,
    Reward = 500, -- Cash per person in the group
}

Config.StartNPC = {
    Model = 's_m_m_postal_02',
    Coords = vec3(69.0575, 127.5103, 78.2105),
    Heading = 160.9539,
}

Config.Truck = {
    Model = 'boxville2',
    Coords = vec3(71.804, 120.588, 79.078),
    Heading = 160.583,
}

Config.DeliveryZones = {
    [1] = {
        Coords = vec3(376.299, 322.467, 103.437),
        Target = vec3(375.514, 334.839, 103.566),
    },
    [2] = {
        Coords = vec3(1159.387, -325.542, 69.205),
        Target = vec3(1163.135, -313.367, 69.205),
    },
    [3] = {
        Coords = vec3(29.109, -1348.248, 29.496),
        Target = vec3(25.5326, -1338.6762, 29.5178),
    },
    [4] = {
        Coords = vec3(-52.216, -1755.597, 29.421),
        Target = vec3(-40.682, -1750.848, 29.421),
    },
    [5] = {
        Coords = vec3(-1226.046, -903.225, 12.338),
        Target = vec3(-1222.817, -912.563, 12.326),
    },
    [6] = {
        Coords = vec3(-1490.124, -382.535, 40.175),
        Target = vec3(-1481.55, -377.794, 40.163),
    }
}
