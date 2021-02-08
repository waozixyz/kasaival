local copy = require "lib.copy"
local Wind = require "lib.weather.Wind"
local push = require "lib.push"

local ma = love.math
local gr = love.graphics


local function init(self, spawn)
    self.wolke = false
    self.kreiselzeit = 1
    self.r = 1 
    self.x = 1
    self.y = 1
    self.spawnx = spawn.x or 400
    self.spawny = spawn.y-ma.random(1,200)
    self.windstark = 1
    self.spawnmodifikator = 0
    self.drehmodi=ma.random(1,10)
    self.zeito = 1
    return copy(self)
end






local function draw(self)

    gr.setColor(0, 0, 1)
    -- fühle dich gerne frei sie zu drehen :**
    gr.polygon("fill", self.x, self.y, self.x+10, self.y, self.x+5, self.y+10)
    gr.setColor(1, 1, 1, 1 )
end


local function update(self, dt)
    self.kreiselzeit =self.kreiselzeit + dt
    self.x =  self.spawnx+Wind:getWind()*self.kreiselzeit*10
    self.y = self.spawny+self.kreiselzeit*90

    end 

return {init = init, draw = draw, update = update}