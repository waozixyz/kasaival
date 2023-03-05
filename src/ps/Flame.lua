local gfx = love.graphics

local image1 = gfx.newImage("assets/lightBlur.png")
image1:setFilter("linear", "linear")

local function rtn()
    local ps = gfx.newParticleSystem(image1, 50)
    ps:setColors(1, 0.2, 0.8, 0.5, 1, 0, 0, 1, 0.9, 0.3, 0, 1, 1, 0.4, 0, 1)
    ps:setDirection(-math.rad(90))
    ps:setEmissionRate(25)
    ps:setEmitterLifetime(-1)
    ps:setInsertMode("top")
    ps:setParticleLifetime(0.8, 1)
    ps:setRotation(0, 0)
    ps:setSpeed(50, 200)
    ps:setSpread(0.7)
    return ps
end

return rtn
