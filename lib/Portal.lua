require 'class'

local lg=love.graphics

local Camera=require 'lib/Camera'     
local Button=require 'lib/Button'

local Portal = class(function(self,x,y,w,h)
  local W,H=lg.getDimensions()
  self.x=x or 2000
  self.y=y or 0
  self.w=w or 150
  self.h=h or H
  self.color={.2,.2,.2 }
  self.feedback=Button(self.x+10, self.h-38, 128, 32, 'give feedback', {0,.8,.9} , {.4,0,.4})
end) 

function Portal:update(dt)
  self.feedback:update(dt, Camera.x)
  if self.feedback.hit then
    --open web link to mailto friend cateye
  end
end

function Portal:draw()
  local s=self
  lg.setColor(self.color)
  lg.rectangle('fill',s.x,s.y,s.w,s.h)
  lg.setColor(.7,.2,.4)
  lg.printf('kasaival',self.x,20,self.w,'center')
  self.feedback:draw()
end

return Portal