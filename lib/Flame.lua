local gr = love.graphics

local function rtn()
    local image1 = gr.newImage("assets/ball.png")
    image1:setFilter("linear", "linear")

    local ps = love.graphics.newParticleSystem(image1, 13)
    local a = 1
    ps:setColors(1, 0, 0.3, a, 1, .3, .2, a, 0.9, 0.23, 0, a, 1, 0.6, 0, a)
    ps:setDirection(-1.6)
    ps:setEmissionRate(8)
    ps:setEmitterLifetime(-1)
    ps:setParticleLifetime(0.6, 1.5)
    ps:setRelativeRotation(true)
    ps:setSizeVariation(0.2)
    ps:setSpeed(32, 70)
    ps:setSpread(1)
    ps:setRotation(0, math.pi * 2)
    ps:setSpin(0, math.pi * 2)
    ps:setSpinVariation(1)
    ps:setTangentialAcceleration( -1, 1)
    ps:start()
    return ps
end

return rtn