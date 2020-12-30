 require 'class'

local Star = require 'lib/Star'

local ga=love.graphics
local ma=love.math
local portal=table.insert

local Sky = class(function(self,x,y)
  local bckg=1
  self.img=ga.newImage('assets/sky/bckg-' .. bckg .. '.jpg')
  self.nebula=ga.newImage('assets/sky/nebula.png') 
  self.speed=3
  self.label='sky'
  self.w = 800
  self.h = 1000
  self.x = x or -self.w*.5
  self.y = y or -self.h*.5
  self.startY=self.y
  self.stardust = {}
  for i=1, 50 do
    local img = ga.newImage('assets/sky/' .. (i % 11 + 1) .. '.png')
    local x = ma.random(self.x,self.w)
    local y = ma.random(self.y,self.h)
    local scale = ma.random(1, 4) * .08  
    local color = {ma.random(1,10)*.1,ma.random(1,10)*.1,ma.random(1,10)*.1}
    portal(self.stardust, Star(path,x,y,0,scale,color))
  end


  for i=1, 10 do
    local img = ga.newImage('assets/sky/' .. (i % 3 + 14) .. '.png')
    local x = ma.random(self.x,self.w)
    local y = ma.random(self.y,self.h)
    local scale = ma.random(5, 10) * .1 

    portal(self.stardust, Star(path,x,y,0,scale))
  end 
end)

function Sky:update(dt, gr)
  self.y=self.y+self.speed*dt
  if self.y > self.h then self.y=self.startY end


  self.ashX=1-self.w/gr.w
  for i, s in ipairs(self.stardust) do
    if s.update then
      s:update(dt)
    end
    s.x = s.x + dt
    s.y = s.y + dt*self.speed
    s.r = s.r + 0.001
    s.scale = s.scale + ma.random(-1, 1) * 0.001
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

function Sky:draw()
  local x,y=self.x,self.y
  local i=self.img
  local scale=i:getWidth()/self.w

  ga.setColor(1,1,1,.8)
  ga.draw(i,x,y,0,scale)
  ga.draw(i,x,y-i:getHeight()*scale ,0,scale)

  for i, star in ipairs(self.stardust) do
    star:draw(offX)
  end
  ga.draw(self.nebula,x,0)
end

return Sky
