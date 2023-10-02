local push = require "push"

local gfx = love.graphics

local function rtn(lifetime)
    local W, H = push:getDimensions()
    lifetime = lifetime or -1
    local image1 = gfx.newImage("assets/lightBlur.png")
    image1:setFilter("linear", "linear")

    local ps = gfx.newParticleSystem(image1, 50000)
    ps:setColors(.8, .42, .15, 1, .8, .32, .15, 1, .7, .52, .15, 1, .9, .42, .25, 1)
    ps:setEmissionArea("normal", 64, H, 0, false)
    ps:setEmissionRate(2000)
    ps:setEmitterLifetime(lifetime)
    ps:setInsertMode("top")
    ps:setLinearDamping(0, 0)
    ps:setOffset(0, 0)
    ps:setParticleLifetime(5, 20)
    ps:setRadialAcceleration(0, 0)
    ps:setRelativeRotation(false)
    ps:setSizes(0.07, 0.08, 0.09)
    ps:setSizeVariation(0.02)
    ps:setSpeed(-300, 0)
    ps:setSpread(0.2)
    ps:setDirection(math.pi)
    ps:setRadialAcceleration(0, 50)
    ps:setSpinVariation(1)

    return ps
end

return rtn
