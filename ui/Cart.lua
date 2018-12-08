require 'class'

local lg=love.graphics
local lt=love.touch

local Cart=class(function(self,x,y,w,h)
  local H=lg.getHeight() 
  self.x=x or 0
  self.y=y or 0
  self.w=w or 108
  self.h=h or 108
end)

function Cart:update(dt)

end

function Cart:draw(phi)
  local x,y=self.x,self.y*phi
  local w,h=self.w,self.h
  
  lg.setColor(.6,.6,.6,.5)     
  lg.rectangle('line',x,y,w,h)
end

return Cart