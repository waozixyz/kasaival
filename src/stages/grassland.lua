-- Define local variable `scenes`
local scenes = {
    -- First scene
    {
        -- Ground settings
        ground = {
            add = 8000,
            color_scheme = {
                {0, .2, .4, .5, .1, .2},
                {.1, .4, .5, .6, .1, .3}
            }
        },

        -- Quests
        quests = {
            {
                type = "kill",
                item = "tree",
                head = "Burn down a",
                amount = 70,
                tail = "trees"
            }
        },

        -- Mobs (enemies)
        mobs = {
            ["Frog"] = {
                amount = 3
            }
        },

        -- Plants
        plants = {
            ["Oak"] = {
                amount = 100
            }
        },
    },

    -- Second scene
    {
        -- Ground settings
        ground = {
            add = 8000,
            color_scheme = {
                {.1, .4, .4, .6, .2, .4},
                {0, .3, .4, .6, .1, .3}
            }
        },

        -- Quests
        quests = {
            {
                type = "reach",
                item = "fuel",
                head = "Fill up your fuel tank",
                amount = 3000,
                tail = ""
            }
        },

        -- Plants
        plants = {
            ["Oak"] = {
                amount = 100
            }
        },        
    }
}

-- Define local variables `music` and `sky`
local music = {"StrangerThings.ogg"}
local sky = {y = 0}

-- Return a table with all settings
return {
    scenes = scenes,
    width = 16000,
    background = nil,
    music = music,
    sky = sky
}
