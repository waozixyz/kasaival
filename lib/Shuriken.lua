require 'class'

local lg=love.graphics

local Shuriken=class(function(self, x, y, dx, dy)
  self.x = x or 0
  self.y = y or 0
  self.dx = dx or 1
  self.dy = dy or 1
  self.img = lg.newImage('assets/attack.png')
  self.hp = 100
  self.atk = 18
  self.sx=1
  self.size=.2
  self.r=0
  self.hpsize=true
end)

function Shuriken:update(dt)
  local sc=self.sx*self.size*8 
  self.x=self.x + self.dx*sc
  self.y=self.y + self.dy*sc
  self.hp=self.hp - 2
  self.r=self.r+8*dt
end


function Shuriken:draw()
  lg.setColor(1,1,1)
  local w,h=self.img:getDimensions()
  local sc=self.sx*self.size 
  local r=self.r
  lg.draw(self.img, self.x, self.y, r, sc, sc, w*.5,h*.5)
end

return Shuriken