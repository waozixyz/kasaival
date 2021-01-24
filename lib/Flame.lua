local gr = love.graphics

local function rtn()
    local image1 = gr.newImage("assets/lightDot.png")
    image1:setFilter("linear", "linear")

    local ps = love.graphics.newParticleSystem(image1, 16)
    local a = 1
    ps:setColors(1, 0, 0.7, a, 1, 0, 0, a, 0.875, 0.23, 0, a, 1, 0.4, 0, a)
    ps:setDirection(-1.6)
    ps:setEmissionRate(16)
    ps:setEmitterLifetime(-1)
    ps:setInsertMode("bottom")
    ps:setParticleLifetime(.8, 1)
    ps:setRelativeRotation(true)
    ps:setSizes(.4)
    ps:setSizeVariation(0.2)
    ps:setSpeed(32, 70)
    ps:setSpread(0.8)
    ps:setRotation(0, math.pi * 2)
    ps:setSpin(0, math.pi * 2)
    ps:setSpinVariation(1)
    ps:start()
    return ps
end

return rtn