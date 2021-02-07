local scenes = {
    {
        quests = {
            {
                type = "kill",
                item = "shrub",
                head = "Burn down",
                amount = 20,
                tail = "shrubs"
            },
        },
        plants = {
            ["Kali"] = {
                amount = 50,
                props = {
                    randStage = true,
                }
            },
        }
    },
    {
        quests = {
            {
                type = "kill",
                item = "cactus",
                head = "Burn down a",
                amount = 50,
                tail = "cactuses"
            },
        },
        plants = {
            ["Saguaro"] = {
                amount = 20,
                props = {
                    randStage = true
                }
            }
        },
        mobs = { 
            ["Dog"] = {
                amount = 10,
            }
        }
    },
    {
        quests = {
            {
                type = "time",
                head = "Survive for",
                amount = 60,
                tail = "seconds"
            }
        },
        weather = {sandstorm =true},
        mobs = {
            ["Dog"] = {
                amount = 10,
            }
        }

    }
}

local background = {
    name = "desert",
    sy = 0.6,
    scx = 0.3
}

local ground = {
    cs = {
        {0.85, 0.92, 0.55, 0.6, 0.38, 0.38 },
        {0.92, 0.96, 0.49, 0.55, 0.28, 0.38 },
        {0.92, 0.94, 0.44, 0.50, 0.38, 0.38 },
        {0.94, 0.96, 0.44, 0.50, 0.38, 0.38 },
        {0.87, 0.92, 0.49, 0.51, 0.4, 0.42 },
        {0.85, 0.92, 0.55, 0.6, 0.38, 0.38 },
        {0.77, 0.87, 0.62, 0.68, 0.38, 0.4 },
        {0.85, 0.92, 0.62, 0.68, 0.25, 0.32 },

    },
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
    },
}

local sky = { y = 0 }
local weather = {dry=true}
return {weather = weather , scenes = scenes, width = 9000, background = background, ground = ground, music = music, sky = sky, next = "Grassland"}
