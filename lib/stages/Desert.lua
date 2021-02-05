local scenes = {
    {
        quests = {
            ["reach"] = {
                type = "kelvin",
                head = "Reach a temperature of",
                amount = 2200,
                tail = "kelvin",
                fnc = function(self, lyra)
                    if lyra.player.kelvin >= self.amount then
                        return true
                    else return false end
                end
            },
        }
    },
    {
        quests = {
            ["kill"] = {
                type = "cactus",
                head = "Burn down a",
                amount = 50,
                tail = "cactuses",
                fnc = function(self, lyra)
                    if lyra.kill_count[self.type] and lyra.kill_count[self.type] >= self.amount then
                        return true
                    else return false end
                end
            },
        },
        mobs = { 
            ["Dog"] = {
                amount = 20,
            }
        }
    },
}

local background = {
    name = "desert",
    sy = 0.6,
    scx = 0.3
}

local ground = {
    cs = {
        {0.85, 0.92, 0.55, 0.6, 0.38, 0.38 },
        {0.92, 0.96, 0.52, 0.57, 0.28, 0.38 },
        {0.96, 0.96, 0.44, 0.54, 0.38, 0.38 },
        {0.96, 0.96, 0.44, 0.54, 0.38, 0.38 },
        {0.87, 0.92, 0.49, 0.55, 0.4, 0.42 },
        {0.85, 0.92, 0.55, 0.6, 0.38, 0.38 },
        {0.77, 0.87, 0.62, 0.68, 0.38, 0.38 },
        {0.72, 0.77, 0.62, 0.68, 0.25, 0.32 },

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

return {weather = "dry", scenes = scenes, width = 9000, background = background, ground = ground, music = music, sky = sky, next = "Grassland"}
