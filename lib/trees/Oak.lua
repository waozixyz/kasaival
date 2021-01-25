local Main = require "lib.trees.Main"
local copy = require "lib.copy"

local ma = love.math

return function(x, y, scale, randStage)
    local w = ma.random(22, 27) * scale
    local h = ma.random(62, 96) * scale

    local tree = copy(Main)

    local maxStage = ma.random(7, 8)
    local currentStage = nil
    if randStage then currentStage = ma.random(0, maxStage) else currentStage = 0 end
    local growTime = ma.random(2, 3)
    local bcs1 = {.4, .5, .3, .4, .2, .2}
    local bcs2 = {.5, .6, .2, .3, .2, .3}
    local bcs3 = {.4, .5, .2, .3, .2, .3}

    local lcs1 = {.2, .4, .4, .5, .2, .3}
    local lcs2 = {.2, .3, .4, .5, .2, .4}
    local lcs3 = {.1, .2, .4, .5, .3, .4}

    local bc = ({bcs1, bcs2, bcs3})[ma.random(1, 3)]
    local lc = ({lcs1, lcs2, lcs3})[ma.random(1, 3)]
    tree:init(
        {
            branchScheme = bc,
            leafScheme = lc,
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