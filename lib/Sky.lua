 require 'class'

local Star = require 'lib/Star'

local lg=love.graphics
local lm=love.math
local portal=table.insert

local Sky = class(function(self,x,y)
  self.img=lg.newImage('assets/sky.jpg')
  self.nebula=lg.newImage('assets/nebula.png') 
  self.speed=3
  self.label='sky'
  self.w = 800
  self.h = 1000
  self.x = x or -self.w*.5
  self.y = y or -self.h*.5
  self.startY=self.y
  self.stardust = {}
  for i=1, 10 do
    local img = lg.newImage('assets/sky/' .. (i % 3 + 14) .. '.png')
    local x = lm.random(self.x,self.w)
    local y = lm.random(self.y,self.h)
    local scale = lm.random(5, 10) * .1 
  --  local color = {rand(4,10)*.1,rand(3,10)*.1,rand(4,10)*.1}
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
    s.scale = s.scale + lm.random(-1, 1) * 0.001
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
  local offX=-eye.x*self.ashX
  local x,y=self.x+offX,self.y
  local i=self.img
  local scale=i:getWidth()/self.w

  lg.setColor(1,1,1,.8)
  lg.draw(i,x,y,0,scale)
  lg.draw(i,x,y-i:getHeight()*scale ,0,scale)

  for i, star in ipairs(self.stardust) do
    star:draw(offX)
  end
  lg.draw(self.nebula,x,0)
end

return Sky