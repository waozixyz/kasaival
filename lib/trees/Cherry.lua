local Main = require "lib.trees.Main"
local copy = require "lib.copy"

local ma = love.math

return function(x, y, scale, randStage)
    local w = ma.random(22, 27) * scale
    local h = ma.random(62, 96) * scale

    local tree = copy(Main)

    local maxStage = ma.random(6, 8)
    local currentStage = nil
    if randStage then currentStage = ma.random(0, maxStage) else currentStage = 0 end
    local growTime = ma.random(1, 3)
    local cs1 = {.5, .7, .2, .4, .2, .3}
    local cs2 = {.5, .6, .4, .6, .2, .3}
    local cs3 = {.3, .5, .2, .4, .3, .5}

    local c = ({cs1, cs2, cs3})[ma.random(1, 3)]
    tree:init(
        {
            colorScheme = c,
            currentStage = currentStage,
            growTime = growTime,
            h = h,
            maxStage = maxStage,
            scale = scale,
            w = w,
            x = x,
            y = y
        }
    )
    return tree
end