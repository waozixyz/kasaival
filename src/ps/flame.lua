local gfx = love.graphics

local image1 = gfx.newImage("assets/lightBlur.png")
image1:setFilter("linear", "linear")

local function rtn()
    local ps = gfx.newParticleSystem(image1, 100)  -- Increased max particles
    ps:setColors(1, 0.5, 0.2, 1, 1, 0.2, 0, 1, 0.7, 0.1, 0, 0.5, 0.4, 0.05, 0, 0.2)
    ps:setDirection(-math.rad(90))
    ps:setEmissionRate(50)  -- Increased emission rate
    ps:setEmitterLifetime(-1)
    ps:setInsertMode("top")
    ps:setParticleLifetime(0.5, 1.5)  -- Varied particle lifetime
    ps:setRotation(0, 0)
    ps:setSpeed(50, 250)  -- Increased speed range
    ps:setSpread(1)  -- Increased spread for a more dynamic flame
    ps:setSizes(1, 0.8, 0.6, 0.4, 0.2)  -- Added size variation
    ps:setSizeVariation(0.5)

    return ps
end

return rtn
