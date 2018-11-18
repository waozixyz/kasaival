require 'class'
local Blob = require 'lib/Blob'

local random=love.math.random

Cyan=class(function(self)
  self.id='cyan'
  self.objs = {}

  for i = 1, 2 do
    local x = random(-400, -40)
    local y = random(200, 600)
    table.insert(self.objs, Blob('assets/blob.png', 64, 64, x, y))
  end 
end)

function Cyan:update(dt, miu)
  for i, v in ipairs(self.objs) do
    v:update(dt)
    if v.hp <= 0 then
      table.remove(self.objs, i)
    end

    v:follow(miu.pink, 2000)

  end
end

function Cyan:draw()
  for i, v in ipairs(self.objs) do
    v:draw()
  end
end

return Cyan