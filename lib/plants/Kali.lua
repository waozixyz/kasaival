local ma = love.math

return {
    type = "shrub",
    cs_branch = {.4, .5, .6, .7, .1, .2},
    changeColor = {-.1, -.3, -.2},
    growTime = 3,
    maxStage = 5,
    w = 22, h = 14,
    splitChance = 0,
    leafChance = 10,
    twoBranch = true,
    startSpilt = true,
    splitAngle = {40, 60},
    burnIntensity = 100,
    fuel = 20,
    randStage = true,
}