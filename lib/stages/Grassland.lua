local scenes = {
    {
        quests = {
            ["reach"] = {
                type = "kelvin",
                head = "",
                amount = 10200,
                tail = ""
            },
        },
        plants = { 
            ["Oak"] = {
                amount = 100,
                startx = 2000,
            } 
        },
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
    name = "grassland",
    sy = 0.5,
    scx = 0.1
}

local ground = {
    cs = {
        {0, .3, .3, .5, .1, .3},
        {.1, .4, .3, .5, .2, .4},
        {.1, .4, .4, .6, .2, .4},
        {0, .3, .4, .6, .1, .3},

    },
}

local music = {
    {
        author = "Spring",
        title = "Maintheme",
        ext = "mp3"
    },
    {
        author = "Spring",
        title = "Map",
        ext = "ogg"
    },
    {
        author = "Spring",
        title = "Drama",
        ext = "ogg"
    },
}

local sky = { y = 0 }
return {scenes = scenes, width = 16000, background = background, ground = ground, music = music, sky = sky}
