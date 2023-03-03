local spawner = require "utils.spawner"
local Wind = require "weather.Wind"
local Cloud = require "weather.Cloud"
local Sandstorm = require "ps.Sandstorm"

local ma = love.math
local gr = love.graphics

local function init(self, prop)
    self.prop = prop or {}
    Wind:init()

    self.items = {}
    self.zeito = 1
    self.hilfszeit = 0
    self.stormmove=1
    return self
end

local function draw(self)
    for _, v in ipairs(self.items) do
        gr.setColor(1, 1, 1)
        v:draw()
    end
    if self.storm then
        gr.setColor(1, 1, 1)
        gr.draw(self.storm)
    end
end

--regen wird nach wolke gezeichnet

local function update(self, dt)
    self.stormmove=self.stormmove+100*dt
    self.zeito = self.zeito + dt
    self.hilfszeit = self.hilfszeit + dt
    Wind:update(dt)

    for _, v in ipairs(self.items) do
        v:update(dt)
    end

    if self.zeito / ma.random(1, 10) > 4 then
        if not self.prop.dry then
            for _ = 0, 15 do
                table.insert(self.items, Cloud:init(spawner()))
            end
        end
        self.zeito = 0
    end
    if self.prop.sandstorm then
        if not self.storm then
            self.storm = Sandstorm(self.prop.sandstorm.lifetime)
            self.storm:setPosition(300, 600)
        end
        self.storm:setEmissionRate(self.storm:getEmissionRate() + 1000 * dt)
        local x, y = self.storm:getPosition()
        self.storm:moveTo(x + Wind:getWind(), y)
        self.storm:update(dt)
    else
        self.storm = nil
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

local function addProp(self, prop)
    for k, v in pairs(prop) do
        self.prop[k] = v
    end
end

return {init = init, draw = draw, update = update, addProp = addProp}
