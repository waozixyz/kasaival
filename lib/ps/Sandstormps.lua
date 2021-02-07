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

	local ps = LG.newParticleSystem(image1, 1664)
	ps:setColors(1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0.5, 1, 1, 1, 0)
	ps:setDirection(0)
	ps:setEmissionArea("none", 0, 0, 0, false)
	ps:setEmissionRate(155.67053222656)
	ps:setEmitterLifetime(-1)
	ps:setInsertMode("top")
	ps:setLinearAcceleration(0, 0, 0, 0)
	ps:setLinearDamping(0, 0)
	ps:setOffset(50, 50)
	ps:setParticleLifetime(3.7305538654327, 10.176299095154)
	ps:setRadialAcceleration(0, 0)
	ps:setRelativeRotation(false)
	ps:setRotation(0, 0)
	ps:setSizes(0.032593935728073)
	ps:setSizeVariation(0)
	ps:setSpeed(39.304740905762, 466.31924438477)
	ps:setSpin(0, 0)
	ps:setSpinVariation(0)
	ps:setSpread(0.31415927410126)
	ps:setTangentialAcceleration(0, 0)

	return ps
end

return rtn
