local gr = love.graphics
local ma = love.math
local Animation = require "lib.utils.Animation"



local function init(self)
   
    self.x = 1000
    self.y = 600
    
    self.anime = Animation:init(gr.newImage("assets/mobs/frog.png"), 64, 64, 1)
    return self
end


local function draw(self)
    local sx, sy = 2, 2
    gr.draw(self.anime.spriteSheet, self.anime.quads[self.anime:spritenumber(1,8)],self.x, self.y, 0, sx, sy)
end




local function update(self, dt)
    self.anime.currentTime = self.anime.currentTime + dt
    if self.anime.currentTime >= self.anime.duration then
        self.anime.currentTime = 0
    end
end 

return {init = init, draw = draw, update = update}