require 'class'

local gr=love.graphics

local Star = class(function(self,img,x,y,r,scale,color)
  self.img = img or gr.newImage('assets/sky/1.png')
  self.x = x or 50   
  self.y = y or 50
  self.r = r or 0
  self.scale = scale or 1
  self.color = color or {1,1,1}
end)


function Star:draw() 
  local x=self.x
  local y=self.y
  gr.setColor(self.color)
  gr.draw(self.img, x, y, self.r, self.scale, self.scale)
end

return Star
