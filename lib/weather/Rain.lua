local copy = require "lib.copy"
local Wind = require "lib.weather.Wind"

local ma = love.math
local gr = love.graphics


local function init(self, spawn)
    self.kreiselzeit = 1
    self.r = 1 
    self.x = 1
    self.y = 1
    self.spawnx = spawn.x or 400
    self.spawny = spawn.y or 400
    self.rest = 0.5 
    self.windstark = 1
    self.spawnmodifikator = 0
    self.image=gr.newImage("assets/scenery/grassland/Dreieck.png")
    self.drehmodi=ma.random(1,10)
    self.zeito = 1
    return copy(self)
end






local function draw(self)
    gr.setColor(0, 0, 1, 1)
    gr.draw(self.image,self.x ,self.y ,self.r, 0.1, 0.1, self.image:getWidth()/2, self.image:getHeight()/2) 
    gr.setColor(1, 1, 1,1 )
end


local function update(self, dt)
    self.kreiselzeit =self.kreiselzeit + dt
    self.x =  self.spawnx+Wind:getWind()*self.kreiselzeit*10
    self.y = self.spawny+self.kreiselzeit*90
    self.r = self.kreiselzeit*self.drehmodi
    end 

return {init = init, draw = draw, update = update}