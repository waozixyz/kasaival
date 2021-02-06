local copy = require "lib.copy"
local Sandstormps = require "lib.ps.Sandstormps"
local ma = love.math
local gr = love.graphics



local function init(self,spawn)
    self.x = spawn.x or 400
    self.y = spawn.y or 400
    self.ps = Sandstormps()
    return copy(self)
end



local function draw(self)
    local sx ,sy = 4, 4
    gr.setColor(50/255 ,29/255 ,8/255 )
    gr.draw(self.ps, self.x, self.y, 0, sx, sy)

end


local function update(self, dt)
    
    self.ps:update(dt)
    end
return {init = init, draw = draw, update = update}