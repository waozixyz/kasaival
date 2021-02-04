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
local gr = love.graphics

local function rtn()
	local image1 = gr.newImage("assets/lightDot.png")
	image1:setFilter("linear", "linear")

	local ps = gr.newParticleSystem(image1, 63)
	ps:setColors(1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0.5, 1, 1, 1, 0)
	ps:setDirection(-1.5707963705063)
	ps:setEmissionArea("none", 0, 0, 0, false)
	ps:setEmissionRate(34.230724334717)
	ps:setEmitterLifetime(-1)
	ps:setInsertMode("top")
	ps:setLinearAcceleration(0, 0, 0, 0)
	ps:setLinearDamping(0, 0)
	ps:setOffset(50, 50)
	ps:setParticleLifetime(1.4013838768005, 1.7447035312653)
	ps:setRadialAcceleration(0, 0)
	ps:setRelativeRotation(false)
	ps:setRotation(0, 0)
	ps:setSizes(0.22222222387791)
	ps:setSizeVariation(0)
	ps:setSpeed(-0.17468774318695, 21.137216567993)
	ps:setSpin(0, 0)
	ps:setSpinVariation(0)
	ps:setSpread(3.170414686203)
	ps:setTangentialAcceleration(0, 0)

	return ps
end

return rtn
