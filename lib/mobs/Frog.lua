local gr = love.graphics
local ma = love.math
local Animation = require "lib.utils.Animation"
local copy = require "lib.copy"
local lyra = require "lib.lyra"



local function init(self,spawn)
   self.move = 0 
    self.x = spawn.x or 1000
    self.y = spawn.y
    self.direction = 1
    
    self.anime = Animation:init(gr.newImage("assets/mobs/frog.png"), 64, 64, 1)
    return copy(self)
end


local function draw(self)
    local sx, sy = 1, 1
    gr.setColor(1,1,1)
    gr.draw(self.anime.spriteSheet, self.anime.quads[self.anime:spritenumber(1,8)],self.x+self.move*self.direction, self.y+math.sin(self.anime.currentTime-math.pi/8)^2*20, 0, self.direction*-1, 1, sx, sy)
end




local function update(self, dt)
    self.anime.currentTime = self.anime.currentTime + dt
    self.move = self.anime.currentTime + self.move
    if self.anime.currentTime >= self.anime.duration then
        self.anime.currentTime = 0
    end

    if self.x < lyra.startx then
        self.direction = 1
    elseif self.x > lyra.ground.width + lyra.startx then
        self.direction = -1
    end
end 

return {init = init, draw = draw, update = update}