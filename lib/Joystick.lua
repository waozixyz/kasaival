require 'class'


local lg=love.graphics
local lt=love.touch

local Joystick=class(function(self, x, y, r, c)
  local W,H = lg.getDimensions()
  self.alpha=1
  self.r = r or 64
  self.x = x or self.r
  self.y = y or self.r
  self.elapsed=0
  self.c = c or {.8,.1,.7,.5}
end)

function Joystick:touching(tx, ty)
  local x,y=self.x,self.y
  local d=self.r*2
  if tx > x - d and tx < x + d and ty > y - d and ty < y + d then
    return true
  end
end

function Joystick:update(dt)
  self.elapsed=self.elapsed+dt
  self.alpha=self.alpha*(1 -self.elapsed*.004)
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
      self.alpha=1
      self.elapsed=0
    end
  end
  self.dx, self.dy = dx, dy
end  

function Joystick:draw()
  local x,y,r,c = self.x,self.y,self.r,self.c
  local a=self.alpha
  -- outer circle
 -- lg.setColor(c[1],c[2],c[3],a*.8)
 -- lg.circle('fill', x, y, r)
  
  -- inner circle
  local nx = self.tx or x
  local ny = self.ty or y
 
  lg.setColor(c[1], c[2], c[3 ], a*.8)
  lg.circle('fill', nx, ny, r * 0.6)
end

return Joystick
