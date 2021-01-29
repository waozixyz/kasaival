local ground = {
    cs = {
        {0.85, 0.92, 0.55, 0.6, 0.38, 0.38 },
        {0.92, 0.96, 0.52, 0.57, 0.28, 0.38 },
        {0.96, 0.96, 0.44, 0.54, 0.38, 0.38 },
        {0.96, 0.96, 0.44, 0.54, 0.38, 0.38 },
        {0.87, 0.92, 0.49, 0.55, 0.4, 0.42 },
        {0.85, 0.92, 0.55, 0.6, 0.38, 0.38 },
        {0.77, 0.87, 0.62, 0.68, 0.38, 0.38 },
        {0.74, 0.77, 0.72, 0.74, 0.25, 0.32 },

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

return {width = 9000, background = "desert", ground = ground, music = music, sky = sky,}
