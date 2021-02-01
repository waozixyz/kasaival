local scenes = {
    {
        quests = {
            ["reach"] = {
                type = "kelvin",
                head = "Reach a temperature of",
                amount = 2200,
                tail = "kelvin"
            },
        }
    },
    {
        quests = {
            ["kill"] = {
                type = "cactus",
                head = "Burn down a",
                amount = 50,
                tail = "cactuses"
            },
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
        {0, .3, .3, .5, .1, .3},

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

local trees = { 
    ["Saguaro"] = {
        amount = 100,
        startx = 2000,
    } 
}

return {scenes = scenes, width = 9000, background = background, ground = ground, music = music, sky = sky, trees = trees, quests = quests}
