require 'class'

local lg=love.graphics

local Star = class(function(self,img,x,y,r,scale,color)
  self.img = img or lg.newImage('assets/sky/1.png')
  self.x = x or 50   
  self.y = y or 50
  self.r = r or 0
  self.scale = scale or 1
  self.color = color
end)


function Star:draw() 
  lg.setColor(self.color)
  lg.draw(self.img, self.x, self.y, self.r, self.scale, self.scale)
end

return Star
