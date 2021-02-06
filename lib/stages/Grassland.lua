local scenes = {
    {
        quests = {
            ["reach"] = {
                type = "kelvin",
                head = "Reach a temperature of",
                amount = 4200,
                tail = "kelvin",
                fnc = function(self, lyra)
                    if lyra.player.kelvin >= self.amount then
                        return true
                    else return false end
                end
            },
        },


        mobs = { 
            ["Frog"] = {
                amount = 3,
            }
        },


        plants = { 
            ["Oak"] = {
                type ="tree",
                head = "Burn down a",
                amount = 30,
                tail = "trees",
                startx = 2000,
                fnc = function(self, lyra)
                    if lyra.kill_count[self.type] and lyra.kill_count[self.type] >= self.amount then
                        return true
                    else return false end
                end
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
