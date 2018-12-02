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
  self.size=.3
  self.hpsize=true
end)

function Shuriken:update()
  self.x = self.x + self.dx
  self.y = self.y + self.dy
  self.hp = self.hp - 1
  
end


function Shuriken:draw()
  lg.setColor(1,1,0)
  local w,h=self.img:getDimensions()
  local sc=self.sx*self.size 
  lg.draw(self.img, self.x, self.y, 0, sc, sc, w*.5,h*.5)
end

return Shuriken