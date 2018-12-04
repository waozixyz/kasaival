require 'class'

local lg=love.graphics

local Dopamine=class(function(self, txt,val,x,y,color)
  local W,H=lg.getDimensions()
  self.z=9999 
  self.x=x or W*.5
  self.y=y or H*.5
  self.txt=txt or 'lvl'
  self.val=val or 999
  self.color=color or {.4,.8,.2}
  local msg=self.txt
  if val > 0 then
    msg='+' .. tostring(val) .. ' ' .. msg
  elseif val < 0 then
    msg=tostring(val) .. ' ' .. msg
  else
    return nil
  end
  self.msg=msg
  self.alpha=1
end)

function Dopamine:update(dt,P)
  self.alpha=self.alpha-.01
end

function Dopamine:draw()
  local c=self.color
  lg.setColor(c[1],c[2],c[3],self.alpha)
  lg.print(self.msg,self.x,self.y)
end

return Dopamine