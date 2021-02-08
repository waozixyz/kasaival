local copy = require "lib.copy"
local Wolkeps = require "lib.ps.Wolkeps"
local ma = love.math
local gr = love.graphics



local function init(self, spawn)
    self.wolke = true
    self.x = spawn.x or 400
    self.y =  10 + ma.random(1,15)
    self.ps = Wolkeps()
   function self.pos(self)
    local table ={x =self.x, y = self.y}
        return table
    end

    return copy(self)
end


local function draw(self)
    local sx ,sy = 5, 5
    gr.setColor(1 ,1 ,1 )
    gr.draw(self.ps, self.x, self.y, 0, sx, sy)


end
    local function update(self, dt)


        self.ps:update(dt)

    end

    return {init =  init , draw = draw , update = update}