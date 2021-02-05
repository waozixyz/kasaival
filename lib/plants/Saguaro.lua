local ma = love.math

return {
    type = "cactus",
    cs_branch = {.8, .9, .73, .78, .3, .35},
    cs_leaf = {.9, 1, .75, .9, .7, .8},
    growTime = 3,
    maxStage = 7,
    w = 14,
    h = 42,
    splitChance = 7,
    leafSize = .7,
    leafChance = 4,
    startSpilt = false,
    randStage = false,
}