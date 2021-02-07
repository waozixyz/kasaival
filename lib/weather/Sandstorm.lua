local copy = require "lib.copy"
local Sandstormps = require "lib.ps.Sandstormps"
local push = require "lib.push"
local lyra = require "lib.lyra"
local Wind = require "lib.weather.Wind"


local ma = love.math
local gr = love.graphics

local function spawnSand (i)
    local x = 0 
    local x1 , x2 = -100, 3100
if 2 >= ma.random(1,2) then 
    x=x1 else x=x2 end 
    return  x ,    0+i*20
    end

local function init(self,i)
     self.x , self.y = spawnSand(i)
    self.ps = Sandstormps()

    return copy(self)
end








local function draw(self)
    local sx ,sy = 1, 1
    gr.setColor(50/255 ,29/255 ,8/255 )
    gr.draw(self.ps, self.x, self.y, 0, sx, sy)

end


local function update(self, dt)

    self.ps:update(dt)
    end
return {init = init, draw = draw, update = update, SpawnSand = SpawnSand}