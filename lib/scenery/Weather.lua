local Rain = require "lib.weather.Rain"
local Spawner = require "lib.utils.Spawner"
local Wind = require "lib.weather.Wind"
local push = require "lib.push"

local ma = love.math
local gr = love.graphics


local function init(self )
    Wind:init()
    self.items = {}
    
  self.zeito=1
    return self
end


local function addrain(self)

local H = push:getHeight()

  for _=0 , 100  do
    table.insert(self.items, Rain:init(Spawner(nil, -H)))
    end
end



local function draw(self)
    Wind:draw()
    for i , v in ipairs(self.items) do
      v:draw()
    end
    
end


local function update(self, dt)
    local H = push:getHeight()
    self.zeito =self.zeito +dt
    Wind:update(dt)

  if 4 <= (self.zeito/(ma.random(1,10)))
  
   then addrain(self)
   
   self.zeito=0
  end

  for i , v in ipairs(self.items) do
    v:update(dt)
    if v.y > H then 
      table.remove(self.items, i)
    end
  end

    end 

return {init = init, draw = draw, update = update}