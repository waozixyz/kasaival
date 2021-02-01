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
local function rtn()

local image1 = LG.newImage("assets/lightBlur.png")
image1:setFilter("linear", "linear")

local ps = LG.newParticleSystem(image1, 36)
ps:setColors(0.75389224290848, 0.84848487377167, 0.016069788485765, 1, 0.60044723749161, 0.69318181276321, 0.013128443621099, 0.62878787517548, 0.83092284202576, 0.96212118864059, 0, 0.75378787517548, 0.90909093618393, 1, 0, 0.69318181276321)
ps:setDirection(2.2236430644989)
ps:setEmissionArea("none", 0, 0, 0, false)
ps:setEmissionRate(19.100435256958)
ps:setEmitterLifetime(10.942975997925)
ps:setInsertMode("top")
ps:setLinearAcceleration(0, 0, 0, 0)
ps:setLinearDamping(0, 0)
ps:setOffset(75, 75)
ps:setParticleLifetime(1.4610106945038, 1.7777777910233)
ps:setRadialAcceleration(0, 0)
ps:setRelativeRotation(false)
ps:setRotation(-0.068856492638588, 0)
ps:setSizes(0.2616568505764)
ps:setSizeVariation(0)
ps:setSpeed(90, 100)
ps:setSpin(0, 0)
ps:setSpinVariation(0)
ps:setSpread(0.46115121245384)
ps:setTangentialAcceleration(0, 0)


return ps

end

return rtn