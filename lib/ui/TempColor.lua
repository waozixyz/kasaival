local gradientMesh = require "lib.utils.gradientMesh"
local gr = love.graphics
local function init(self)
    self.mesh = gradientMesh( "vertical", {1, 0, 0}, {1, .5, 0}, {1, 1, 0}, {0, 0, 1})
end
local function draw(self)
    gr.draw(self.mesh)

end
local function update(self,dt)


end
return {init = init, update = update, draw = draw}