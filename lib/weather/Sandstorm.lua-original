local copy = require "lib.copy"
local Sandstormps = require "lib.ps.Sandstormps"
local push = require "lib.push"
local lyra = require "lib.lyra"


local ma = love.math
local gr = love.graphics

local function spawnSand (i)
    local W , H = push:getDimensions()
    
    return  (W)/2+math.sin(i/12*math.pi )*150,    (H-lyra.gh)/2+ math.cos(i/12*math.pi )*150
    end

local function init(self,i)
     self.x , self.y = spawnSand(i)
    self.ps = Sandstormps()


    return copy(self)
end








local function draw(self)
    local sx ,sy = 3, 3
    gr.setColor(50/255 ,29/255 ,8/255 )
    gr.draw(self.ps, self.x, self.y, 0, sx, sy)

end


local function update(self, dt)
    
    self.ps:update(dt)
    end
return {init = init, draw = draw, update = update, SpawnSand = SpawnSand}