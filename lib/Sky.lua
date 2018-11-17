require 'class'

local Star = require 'lib/Star'

local lg=love.graphics
local rand=love.math.random
local portal=table.insert

local Sky = class(function(self)
  self.x = -1000
  self.y = -1000
  self.width = 2000
  self.height = 200
  self.stardust = {}
  for i=1, 100 do
    local img = lg.newImage('assets/sky/' .. (i % 11 + 1 ) .. '.png')
    local x = rand(self.x,self.width)
    local y = rand(self.x,self.width)
    local scale = rand(1, 2) * .1 
    local color = {rand(4,10)*.1,rand(3,10)*.1,rand(4,10)*.1}
    portal(self.stardust, Star(path,x,y,0,scale,color))
  end 
end)

function Sky:update(dt)
  for i, s in ipairs(self.stardust) do
    if s.update then
      s:update(dt)
    end
    s.x = s.x + 0.02
    s.y = s.y  + 0.2
    s.r = s.r + rand(-0.7, 1) * 0.01
    s.scale = s.scale + rand(-1, 1) * 0.001

  end
end

function Sky:draw()
   for i, s in ipairs(self.stardust) do
    s:draw()
  end
end

return Sky