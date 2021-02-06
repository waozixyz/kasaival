local Rain = require "lib.weather.Rain"
local spawner = require "lib.utils.spawner"
local Wind = require "lib.weather.Wind"
local push = require "lib.push"
local lyra = require "lib.lyra"
local Wolke = require "lib.weather.Wolke"
local Sandstorm = require "lib.weather.Sandstorm"

local ma = love.math
local gr = love.graphics

local function init(self, prop)
  self.prop = prop
  Wind:init()
  
  self.items = {}
  self.sandstorms = {}

  self.zeito = 1
  self.hilfszeit = 0
  return self
end



local function addSandstorms(self)
  for i = 0, 24, 1 do
    table.insert(self.sandstorms, Sandstorm:init(i))
  
  end
end


local function addwolke(self)
  for _ = 0, 15, 1 do
    table.insert(self.items, Wolke:init(spawner(nil, 0)))
  end
end

local function addrain(self)
  for i, v in ipairs(self.items) do
    if v.wolke then
      table.insert(self.items, Rain:init(v:pos()))
    end
  end
end

local function draw(self)

  for i, v in ipairs(self.sandstorms) do
    v:draw()
    end





  for i, v in ipairs(self.items) do
    if not v.wolke then 
    v:draw()
    end
  end
  for i, v in ipairs(self.items) do
    if not v.wolke then 
    v:draw()
    end
  end
  for i, v in ipairs(self.items) do
    if v.wolke then 
    v:draw()
    end
  end
end

local function update(self, dt)
  local H = push:getHeight()
  self.zeito = self.zeito + dt
  self.hilfszeit = self.hilfszeit + dt
  Wind:update(dt)

  for i, v in ipairs(self.sandstorms) do
    v:update(dt)
    end
  

  --if 4 <= self.hilfszeit / ma.random(1, 10) then
   -- if self.prop ~= "dry" then
   --   addrain(self)
  -- end
 ---  self.hilfszeit = 0
 --end
  if 4 <= (self.zeito / (ma.random(1, 10))) then
    
    if self.prop ~= "dry" then
      addwolke(self)
      addrain(self)
    else 
      addSandstorms(self)

    end
    self.zeito = 0
  end

  for i, v in ipairs(self.items) do
    v:update(dt)
    if v.y > H - lyra.gh then
      table.remove(self.items, i)
    end
  end
  --wolken despanw idee
  if  15 <= self.hilfszeit+ma.random (1,10)then
    for i, v in ipairs(self.items) do
      if v.wolke then
        if 5 < ma.random(1, 7) then
          table.remove(self.items, i)
        end
      end
      self.hilfszeit = 0
    end
  end
end

return {init = init, draw = draw, update = update}
