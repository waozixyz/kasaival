
local gr = love.graphics

local function rtn()
	local image1 = gr.newImage("assets/lightDot.png")
	image1:setFilter("linear", "linear")

	local ps = gr.newParticleSystem(image1, 20)
	ps:setColors(1, 1, 1, 1)
	ps:setDirection(-1.5)
	ps:setEmissionArea("none", 0, 0, 0, false)
	ps:setEmissionRate(10)
	ps:setEmitterLifetime(-1)
	ps:setInsertMode("top")
	ps:setLinearAcceleration(0, 0, 0, 0)
	ps:setLinearDamping(0, 0)
	ps:setParticleLifetime(1.45, 1.7)
	ps:setRadialAcceleration(0, 0)
	ps:setRelativeRotation(false)
	ps:setRotation(0, 0)
	ps:setSizes(0.2)
	ps:setSizeVariation(0)
	ps:setSpeed(-0.17, 21)
	ps:setSpin(0, 0)
	ps:setSpinVariation(0)
	ps:setSpread(3)
	ps:setTangentialAcceleration(0, 0)

	return ps
end

return rtn
