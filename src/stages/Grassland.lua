local scenes = {
    {
        ground = {
            add = 8000,
            cs = {
                {0, .2, .4, .5, .1, .2},
                {.1, .4, .5, .6, .1, .3}
            }
        },


        quests = {
            {
                type = "kill",
                item = "tree",
                head = "Burn down a",
                amount = 70,
                tail = "trees"
            }
        },


        
        mobs = {
            ["Frog"] = {
                amount = 3
            }
        },


        plants = {
            ["Oak"] = {
                amount = 100
            }
        },


        
        
    },
    {

        ground = {
            add = 8000,
            cs = {
                {.1, .4, .4, .6, .2, .4},
                {0, .3, .4, .6, .1, .3}
            }
        },


        quests = {
            {
                type = "reach",
                item = "fuel",
                head = "Fill up your fuel tank",
                amount = 3000,
                tail = ""
            }
        },




        plants = {
            ["Oak"] = {
                amount = 100
            }
        },


        

        
    }
}


local music = {
    "StrangerThings.ogg",
}

local sky = {y = 0}
return {scenes = scenes, width = 16000, background = background, music = music, sky = sky}
