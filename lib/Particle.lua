require 'class'
local Vector=require 'lib/Vector'
local lg=love.graphics
local lm=love.math

local M=class(function(self, x, y, size, R, G, B )
  self.dead=false
  self.size=size or 3
  self.Position=Vector(x, y)
  self.startPosition=self.Position
  self.Velocity=Vector(lm.random(-5,5),lm.random(-30,-20))
  self.elapsed=0
  self.livetime=lm.random(2,5)
  self.R=R or lm.random(0, 1)
  self.G=G or lm.random(0, 1)
  self.B=B or lm.random(0, 1)
  
end)

function M:update(dt, parentPosition)
  self.elapsed=self.elapsed+dt
  local diff=self.startPosition-parentPosition
  local pos=self.Position
 self.Position=pos-diff+self.Velocity*dt
  self.startPosition=self.startPosition-diff
  self.Velocity=self.Velocity:rotate(lm.random(-12, 12))
  if self.elapsed>=self.livetime then
    self.dead=true
  end
end

function M:isDead()
  return self.dead
end

function M:draw()
  local alpha=self.elapsed/self.livetime
  local size=self.size*alpha
  if alpha<0 then alpha=0 end
  lg.setColor(self.R, self.G, self.B, alpha)
  lg.circle('fill', self.Position.x, self.Position.y-13, size, 3)
end
return M

