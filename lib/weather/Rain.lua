local gr = love.graphics
local copy = require "lib.copy"
local lyra = require "lib.lyra"
local Wind = require "lib.weather.Wind"


local function init(self)
    self.kreiselzeit=1
    self.x = 400
    self.y = 409
    self.windx , self.windy = Wind:getWind()
    self.image=gr.newImage("assets/scenery/grassland/Dreieck.png")
    return copy(self)
end



local function draw(self)
    gr.setColor(0, 0, 1, 1)
    gr.draw(self.image, self.x+self.windx*self.kreiselzeit, self.y+self.windy*self.kreiselzeit+self.kreiselzeit*90,self.kreiselzeit*3, 0.1, 0.1, self.image:getWidth()/2, self.image:getHeight()/2)
    gr.setColor(1, 1, 1, 1)
end



local function update(self, dt)
    self.kreiselzeit =self.kreiselzeit + dt
end 

return {init = init, draw = draw, update = update}