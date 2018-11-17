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
  self.sx = .15
  self.sy = .15
end)

function Shuriken:update()
  self.x = self.x + self.dx
  self.y = self.y + self.dy
  self.hp = self.hp - 1
  self.osx = self.sx * (self.hp / 100)
  self.sy = self.osx
end

function Shuriken:draw()
  lg.draw(self.img, self.x, self.y, 0, self.osx, self.sy)
end

return Shuriken