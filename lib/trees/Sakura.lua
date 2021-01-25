local Main = require "lib.trees.Tree"
local copy = require "lib.copy"

local ma = love.math

return function(x, y, scale, randStage)
    local w = ma.random(22, 27) * scale
    local h = ma.random(72, 86) * scale

    local tree = copy(Main)

    local maxStage = ma.random(7, 8)
    local currentStage = nil
    if randStage then currentStage = ma.random(0, maxStage) else currentStage = 0 end
    local growTime = ma.random(4, 7)

    local bc = {.4, .5, 0, 0, .2, .3}

    local lc = {.8, 1, .6, .7, .7, .8}
    
    tree:init(
        {
            special = "sakura",
            branchScheme = bc,
            leafScheme = lc,
            currentStage = currentStage,
            growTime = growTime,
            h = h,
            maxStage = maxStage,
            scale = scale,
            splitAngle = {30, 40},
            w = w,
            x = x,
            y = y
        }
    )
    return tree
end