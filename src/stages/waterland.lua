local scenes = {}

local background = {
    name = "desert",
    sy = 0.6,
    scx = 0.3
}

local ground = {
    cs = {
        {0.2, 0.27, 0.2, 0.3, 0.87, 0.93},
        {0.2, 0.2, 0.98, 0.99, 0.9, 0.98 },
        {0, 0.1, 0.74, 0.76, 0.95, 0.99 },
        {0.01, 0.062, 0.29, 0.31, 0.53, 0.55 },
       -- {0.35, 0.35, 0.49, 0.55, 0.87, 0.92},
       -- {0.38, 0.38, 0.55, 0.6, 0.86, 0,91},
       -- {0.38, 0.38, 0.62, 0.68, 0.77, 0.87 },
      --  {0.25, 0.32, 0.62, 0.68, 0.72, 0.77 },

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
