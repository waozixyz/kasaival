
local gr = love.graphics
local ma = love.math
local Animation = require "lib.utils.Animation"
local copy = require "lib.copy"



local function init(self, prop)
    self.zeito=1
    self.kreiselzeit=1
    self.x = prop.x or 1000
    self.y = prop.y or 600
    
    self.tgrow=true
    self.anime = Animation:init(gr.newImage("assets/mobs/whirlwind.png"), 15.7, 19, 1)
    return copy(self)
end


local function draw(self)
    local sx, sy = 2, 2
    gr.setColor(1, 1, 1)
    gr.draw(self.anime.spriteSheet, self.anime.quads[self.anime:spritenumber()],self.x+self.zeito*(math.sin(self.kreiselzeit)*100), self.y+math.cos(self.kreiselzeit)*140, 0, sx*self.zeito, sy*self.zeito)
end



local function update(self, dt)
    self.randomreset = ma.random(1,10)
    self.kreiselzeit =self.kreiselzeit + 2*dt
    if 2>= self.zeito then 
        self.tgrow =true
    end
    if self.tgrow then 
    self.zeito = self.zeito + dt
    else
        self.zeito = self.zeito-dt
    end
    if 3< (self.randomreset+self.zeito)/5 then
    self.tgrow =false
    end
    self.anime.currentTime = self.anime.currentTime + dt
    if self.anime.currentTime >= self.anime.duration then
        self.anime.currentTime = 0
    end
end 

return {init = init, draw = draw, update = update}