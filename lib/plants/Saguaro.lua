local ma = love.math

return {
    type = "cactus",
    cs_branch = {.8, .9, .73, .78, .3, .35},
    cs_leaf = {.9, 1, .75, .9, .7, .8},
    growTime = ma.random(1, 2),
    maxStage = ma.random(7, 8),
    w = ma.random(13, 16),
    h = ma.random(42, 52),
    splitChance = 7,
    leafSize = .7,
    leafChance = 4,
    startSpilt = false,
}