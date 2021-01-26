local gr = love.graphics

local function rtn()
    local image1 = gr.newImage("assets/ball.png")
    image1:setFilter("linear", "linear")

    local ps = love.graphics.newParticleSystem(image1, 13)
    local a = 1
    ps:setColors(1, 0, 0.2, a, 1, .3, .2, a, 0.9, 0.23, 0, a, 1, 0.6, 0, a)
    ps:setDirection(-1.6)
    ps:setEmissionRate(20)
    ps:setEmitterLifetime(-1)
    ps:setParticleLifetime(1, 1.6)
    ps:setRelativeRotation(true)
    ps:setSizeVariation(0.2)
    ps:setSpeed(200)
    ps:setSpread(1)
    ps:setRotation(0, math.pi * 2)
    ps:setSpin(0, math.pi * 2)
    ps:setSpinVariation(1)
    ps:setTangentialAcceleration( -1, 1)
    ps:start()
--[[
module = {
	{
		system=particleSystem1,
		kickStartSteps=steps1, kickStartDt=dt1, emitAtStart=count1,
		blendMode=blendMode1, shader=shader1,
		texturePreset=preset1, texturePath=path1,
		shaderPath=path1, shaderFilename=filename1
	},
	{ system=particleSystem2, ... },
	...
}
]]
local LG        = love.graphics
local particles = {}

local image1 = LG.newImage("assets/lightBlur.png")
image1:setFilter("linear", "linear")

local ps = LG.newParticleSystem(image1, 69)
ps:setColors(1, 0, 0.7, 0, 1, 0, 0, 1, 0.875, 0.3, 0, 1, 1, 0.4, 0, 1)
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
ps:setSizes(0.4)
ps:setSizeVariation(0.2)
ps:setSpeed(67, 100)
ps:setSpin(-50, 50)
ps:setSpinVariation(0)
ps:setSpread(0.9)
ps:setTangentialAcceleration(0, 0)
return ps
end

return rtn