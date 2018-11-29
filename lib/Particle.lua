require 'class'
local Vector=require 'lib/Vector'
local lg=love.graphics
local lm=love.math

local M=class(function(self, x, y, R, G, B, v)
  self.dead=false
  self.Position=Vector(x, y)
  self.startPosition=self.Position
  self.Velocity=Vector(lm.random(0,3),lm.random(-20,0)):rotate(lm.random(-30, 10))
  self.elapsed=0
  self.livetime=lm.random(2,5)
  self.R=R or lm.random(0, 1)
  self.G=G or lm.random(0, 1)
  self.B=B or lm.random(0, 1)
  self.variable=v or 'R'
  self[self.variable]=lm.random(50, 255)
end)

function M:update(dt, parentPosition)
  self.elapsed=self.elapsed+dt
  local diff=self.startPosition-parentPosition
  local pos=self.Position
 self.Position=pos-diff+self.Velocity*dt
  self.startPosition=self.startPosition-diff
  self.Velocity=self.Velocity:rotate(lm.random(-30, 10))
  if self.elapsed>=self.livetime then
    self.dead=true
  end
end

function M:isDead()
  return self.dead
end

function M:draw()
  local alpha=math.ceil(1.1-1*(self.elapsed/self.livetime))
  if alpha<0 then alpha=0 end
  lg.setColor(self.R, self.G, self.B, alpha)
  lg.circle('fill', self.Position.x, self.Position.y-13, 3, 3)
end
return M

