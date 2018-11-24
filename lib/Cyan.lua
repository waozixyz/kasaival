require 'class'

local Ocean = require 'lib/Ocean'

local Blob = require 'lib/Blob'

local lg=love.graphics
local lm=love.math

Cyan=class(function(self)
  local W,H=lg.getDimensions()
  self.objs = {}

  for i = 1, 2 do
    local x = lm.random(-400, -40)
    local y = lm.random(200, 600)
    table.insert(self.objs, Blob('assets/blob.png', 64, 64, x, y))
  end 

  self.Ocean=Ocean
end)

function Cyan:update(dt, Miu)
  for i, v in ipairs(self.objs) do
    v:update(dt, self.Ocean)
    if v.hp <= 0 then
      table.remove(self.objs, i)
    end

    v:follow(Miu.Pink, Miu.Gaia.Ground.w)

  end
end

function Cyan:draw()
  for i, v in ipairs(self.objs) do
    v:draw()
  end
end

return Cyan