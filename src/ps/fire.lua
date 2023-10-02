local gfx = love.graphics

local function rtn()


    local image1 = gfx.newImage("assets/lightBlur.png")
    image1:setFilter("linear", "linear")

    local ps = gfx.newParticleSystem(image1, 69)
    ps:setColors(.7, 0, 0, 1, .8, 0, 0, 1, .7, 0.3, 0, 1, .8, 0.2, 0, 1)
    ps:setDirection(-1.6)
    ps:setEmissionArea("none", 0, 0, 0, false)
    ps:setEmissionRate(20)
    ps:setEmitterLifetime(-1)
    ps:setInsertMode("top")
    ps:setLinearAcceleration(-2, 0, 0, 0)
    ps:setLinearDamping(0, 0)
    ps:setParticleLifetime(1.8, 2.2)
    ps:setRadialAcceleration(0, 0)
    ps:setRelativeRotation(true)
    ps:setRotation(0, 0)
    ps:setSizes(0.2)
    ps:setSizeVariation(0.2)
    ps:setSpeed(67, 100)
    ps:setSpin(-50, 50)
    ps:setSpinVariation(0)
    ps:setSpread(0.9)
    ps:setTangentialAcceleration(0, 0)
    return ps
end

return rtn