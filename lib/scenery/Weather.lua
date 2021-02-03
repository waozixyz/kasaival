local Rain = require "lib.weather.Rain"
local Spawner = require "lib.utils.Spawner"
local Wind = require "lib.weather.Wind"

local ma = love.math
local gr = love.graphics


local function init(self )
    Wind:init()
    Rain:init(Spawner(nil, true))
  self.zeito=1
    return self
end






local function draw(self)
    Wind:draw()
    
end


local function update(self, dt)
    self.zeito =self.zeito +dt
    Wind:update(dt)

  if 4 <= (self.zeito/(ma.random(1,10)))
  
   then Rain:draw()
   
   self.zeito=0
  end
 Rain:update(dt)

    end 

return {init = init, draw = draw, update = update}