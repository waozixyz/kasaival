local ground = {
    cs = {
        {0.85, 0.92, 0.55, 0.6, 0.38, 0.38 },
        {0.92, 0.96, 0.52, 0.57, 0.28, 0.38 },
        {0.96, 0.96, 0.44, 0.54, 0.38, 0.38 },
        {0.96, 0.96, 0.44, 0.54, 0.98, 0.98 },
        {0.96, 0.96, 0.54, 0.64, 0.38, 0.38 },
    },
}

local music = {
    ["Insydnis"] = "The Desert of Dreams.mp3",
    ["Spring"] = "Simple Desert.ogg"
}

local sky = { y = 0 }

return {background = "desert", ground = ground, music = music, sky = sky,}
