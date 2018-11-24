require 'class'

local Star = require 'lib/Star'

local lg=love.graphics
local rand=love.math.random
local portal=table.insert

local Sky = class(function(self)
  
  self.label='sky'
  self.x = 0
  self.y = 0
  self.w = 1000
  self.h = 2000
  self.stardust = {}
  for i=1, 100 do
    local img = lg.newImage('assets/sky/' .. (i % 11 + 1 ) .. '.png')
    local x = rand(self.x,self.w)
    local y = rand(self.y,self.h)
    local scale = rand(1, 2) * .1 
    local color = {rand(4,10)*.1,rand(3,10)*.1,rand(4,10)*.1}
    portal(self.stardust, Star(path,x,y,0,scale,color))
  end 
end)

function Sky:update(dt, gr)
  self.ashX=1-self.w/gr.w
  for i, s in ipairs(self.stardust) do
    if s.update then
      s:update(dt)
    end
    s.x = s.x + 0.02
    s.y = s.y  + 0.2
    s.r = s.r + rand(-0.7, 1) * 0.01
    s.scale = s.scale + rand(-1, 1) * 0.001
    if s.x > self.x+self.w then
      s.x=self.x
    elseif s.x<self.x then
      s.x=self.x+self.w
    end

    if s.y > self.y+self.h then
      s.y=self.y
    elseif s.y<self.y then
      s.y=self.y+self.h
    end
  end
end

function Sky:draw(eye)
  local s=self
   for i, star in ipairs(self.stardust) do
    star:draw(-eye.x*s.ashX)
  end
end

return Sky