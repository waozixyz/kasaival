local push = require "lib.push"

local gr = love.graphics

local function rtn()
  local W, H = push:getDimensions()
	local image1 = gr.newImage("assets/lightBlur.png")
	image1:setFilter("linear", "linear")

	local ps = gr.newParticleSystem(image1, 50000)
	ps:setColors(.7, .45, .1, 1)
	ps:setEmissionArea("normal", 64, H, 0, false)
	ps:setEmissionRate(2000)
	ps:setInsertMode("top")
	ps:setLinearDamping(0, 0)
	ps:setOffset(0, 60)
	ps:setParticleLifetime(5, 20)
	ps:setRadialAcceleration(0, 0)
	ps:setRelativeRotation(false)
	ps:setSizes(0.07, 0.08, 0.09)
	ps:setSizeVariation(0.02)
	ps:setSpeed(0, 300)
	ps:setSpread(0.2)
	ps:setTangentialAcceleration(0, 0)

	return ps
end

return rtn
