local ma = love.math

return {
    type = "tree",
    cs_branch = {.5, .6, .2, .3, .2, .3},
    cs_leaf = {.2, .4, .4, .5, .2, .3},
    growTime = ma.random(3, 4),
    maxStage = ma.random(6, 8),
    w = ma.random(17, 20),
    h = ma.random(42, 46),
    splitChance = 3,
    leafSize = 1,
    leafChance = 4,
    startSpilt = true,
    randCurrentStage = true
}