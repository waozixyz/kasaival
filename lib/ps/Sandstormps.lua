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
local LG = love.graphics
local function rtn()
	local image1 = LG.newImage("assets/lightBlur.png")
	image1:setFilter("linear", "linear")

	local ps = LG.newParticleSystem(image1, 742)
	ps:setColors(0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0.5, 1, 1, 1, 0)
	ps:setDirection(-0.23255693912506)
	ps:setEmissionArea("none", 0, 0, 0, false)
	ps:setEmissionRate(300.69769287109)
	ps:setEmitterLifetime(-1)
	ps:setInsertMode("top")
	ps:setLinearAcceleration(0, 0, 0, 0)
	ps:setLinearDamping(0, 0)
	ps:setOffset(50, 50)
	ps:setParticleLifetime(1.6473442316055, 2.3492007255554)
	ps:setRadialAcceleration(0, 0)
	ps:setRelativeRotation(false)
	ps:setRotation(0, 0)
	ps:setSizes(0.012172426097095)
	ps:setSizeVariation(0)
	ps:setSpeed(-333.09069824219, 1000.1649780273)
	ps:setSpin(0, 0)
	ps:setSpinVariation(0)
	ps:setSpread(6.2831854820251)
	ps:setTangentialAcceleration(0, 0)

	return ps
end

return rtn
