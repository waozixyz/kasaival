local scenes = {
    {
        ground = {
            add = 2200,
            cs = {
                {0.85, 0.92, 0.55, 0.6, 0.38, 0.38},
                {0.92, 0.96, 0.49, 0.55, 0.28, 0.38}
            }
        },
        quests = {
            {
                questType = "kill",
                itemType = "shrub",
                head = "Burn down",
                amount = 20,
                tail = "shrubs"
            }
        },
        spawners = {
            {
                type = "plant",
                name = "Kali",
                interval = 1,
                props = {}
            }
        }
    },
    {
        ground = {
            add = 2000,
            cs = {
                {0.85, 0.93, 0.45, 0.52, 0.28, 0.38}
            }
        },
        quests = {
            {
                questType = "kill",
                itemType = "cactus",
                head = "Burn down a",
                amount = 40,
                tail = "cactuses"
            }
        },
        spawn = {
            {
                type = "plant",
                name = "Saguaro",
                amount = 20,
                props = {
                    randStage = true
                }
            },
            {
                type = "mob",
                name = "Dog",
                amount = 10
            }
        }
    },
    {
        ground = {
            add = 6000,
            cs = {
                {0.84, 0.90, 0.43, 0.49, 0.28, 0.34},
                {0.82, 0.87, 0.45, 0.52, 0.30, 0.32},
                {0.85, 0.87, 0.48, 0.52, 0.25, 0.32}
            }
        },
        quests = {
            {
                type = "time",
                head = "Survive for",
                amount = 60,
                tail = "seconds"
            }
        },
        weather = {
            sandstorm = {
                lifetime = 60
            }
        },
        spawn = {
            {
                type = "plant",
                name = "Saguaro",
                amount = 20,
                props = {
                    randStage = true
                }
            },
            {
                type = "plant",
                name = "Kali",
                amount = 50,
                props = {
                    randStage = true
                }
            },
            {
                type = "mob",
                name = "Dog",
                amount = 10
            }
        },
    }
}

local background = {
    name = "desert",
    sy = 0.6,
    scx = 0.3
}

local music = {
    {
        author = "Insydnis",
        title = "The Desert of Dreams",
        ext = "mp3"
    },
    {
        author = "Spring",
        title = "Simple Desert",
        ext = "ogg"
    }
}

local sky = {y = 0}
local weather = {dry = true}
return {
    weather = weather,
    scenes = scenes,
    background = background,
    music = music,
    sky = sky,
    next = "Grassland"
}
