require 'class'

local lg=love.graphics
local lt=love.touch

local state=require 'state'

local Cart=class(function(self,x,y,w,h) 
  self.x=x or state.x
  self.y=y or state.y
  self.w=w or 108
  self.h=h or 108
end)


function Cart:update(dt)

end

function Cart:draw()
  local x,y=self.x,self.y
  local w,h=self.w,self.h
  if self.touch then
    lg.setColor(.8,.8,.8,.5)
lg.rectangle('fill',x,y,w,h)
  else
    lg.setColor(.6,.6,.6,.5)    
 lg.rectangle('line',x,y,w,h)
  end
  
end

return Cart