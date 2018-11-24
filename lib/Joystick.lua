require 'class'


local lg=love.graphics
local lt=love.touch

local Joystick=class(function(self, x, y, r, c)
  local W,H = lg.getDimensions()

  self.r = r or 64
  self.x = x or self.r
  self.y = y or self.r
  self.c = c or {.8,.1,.7,.5}
end)

function Joystick:touching(tx, ty)
  local x,y=self.x,self.y
  local d=self.r*2
  if tx > x - d and tx < x + d and ty > y - d and ty < y + d then
    return true
  end
end

function Joystick:update()
  self.tx,self.ty=nil,nil
  local W,H = lg.getDimensions()
  local x,y,r = self.x,self.y,self.r
  local dx,dy = 0,0
  self.active = false
  local touches = lt.getTouches()
  for i, id in ipairs(touches) do
    local tx, ty = lt.getPosition(id)
    self.active = self:touching(tx, ty) 
    if self.active then
      self.tx = tx
      self.ty = ty
      dx = (tx - x) / 10
      dy = (ty - y) / 10
    end
  end
  self.dx, self.dy = dx, dy
end  

function Joystick:draw()
  local x,y,r,c = self.x,self.y,self.r,self.c
 
  -- outer circle
  lg.setColor(c)
  lg.circle('fill', x, y, r)
  
  -- inner circle
  nx = self.tx or x
  ny = self.ty or y
 
  lg.setColor(c[3], 0.5, c[1], 0.2)
  lg.circle('fill', nx, ny, r * 0.6)
end

return Joystick
