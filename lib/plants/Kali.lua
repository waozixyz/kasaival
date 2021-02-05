local ma = love.math

return {
    type = "shrub",
    cs_branch = {.7, .9, .4, .6, .2, .3},
    growTime = ma.random(1,2),
    maxStage = ma.random(4, 5),
    w = ma.random(12, 15),
    h = ma.random(9, 12),
    splitChance = 0,
    leafChance = 10,
    twoBranch = true,
    startSpilt = true,
    splitAngle = {40, 60},
    burnIntensity = 100,
    fuel = 20,
    randCurrentStage = true
}