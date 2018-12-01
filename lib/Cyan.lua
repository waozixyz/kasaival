require 'class'

local Ocean = require 'lib/Ocean'
local Bat= require 'lib/Bat'

local lg=love.graphics
local lm=love.math

local Cyan=class(function(self)
  local W,H=lg.getDimensions()
  self.mao = {}
  
  for i = 1, 2 do
    local x = lm.random(-400, -40)
    local y = lm.random(200, 600)
    table.insert(self.mao, Bat('assets/Bat.png', 24, 17, x, y))
  end 
  self.Ocean=Ocean()
  
end)

function Cyan:update(dt, Miu)
  self.Ocean:update(dt)
  for i, v in ipairs(self.mao) do
    if v.hp <= 0 then
      table.remove(self.mao, i)
    end

    v:follow(dt, Miu._P, Miu._G.Ground.w)
  end
end

function Cyan:draw()
  self.Ocean:draw()
 
end

return Cyan