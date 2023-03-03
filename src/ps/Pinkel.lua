local gr = love.graphics
local function rtn()
	local image1 = gr.newImage("assets/lightBlur.png")
	image1:setFilter("linear", "linear")

	local ps = gr.newParticleSystem(image1)
	ps:setColors(0.7, 0.8, 0, 1)
	ps:setEmissionRate(8)
	ps:setInsertMode("top")
	ps:setLinearAcceleration(0, 0, 0, 0)
	ps:setLinearDamping(0, 0)
	ps:setParticleLifetime(.1)
	ps:setRelativeRotation(false)
	ps:setSizes(0.13)
	ps:setSizeVariation(0)
	ps:setSpeed(90, 120)
	ps:setSpread(0.1)
	ps:setDirection(2.22)
	return ps
end

return rtn
