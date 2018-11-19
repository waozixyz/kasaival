require 'class'

local lg=love.graphics
local random=love.math.random

local Tile = class(function(self,shape,color,w,h)
  self.element=element or 'plant'
  self.shape=shape
  self.x,self.y=shape[1],shape[2]
  self.color=color or {.2,.2,.6}
  self.w = w or 32
  self.h = h or 32
end)

function Tile:getHitbox()
  return {self.x, self.x + self.w, self.y + self.h*.8, self.y + self.h}
end

function Tile:burn()
  local c = self.color
  local r,g,b = c[1],c[2],c[3]
  r = r + 0.08
  c[1],c[2],c[3]=r,g,b
end

function Tile:collide(o)
  if o.element == 'fire' then
    self:burn()
  end
end


function Tile:update()

  local c = self.color
  local r,g,b = c[1],c[2],c[3]

  if self.element == 'plant' then
    if r > .7 then
      self.element = 'earth'
    elseif r > .4 then
      r = r - .02
    else
      r = r - random(0,1)*.01
    end
  elseif self.element == 'earth' then
    if g > .7 then
      self.element = 'plant'
      r = r - .02
    elseif g > .4 then
      g = g + .02
      r = r - .03 
    else
      g = g+ random(0,1)*.01
      r = r - .01
    end
  end
  c[1],c[2],c[3]=r,g,b
end

function Tile:draw()
  lg.setColor(self.color)
  lg.polygon('fill', self.shape)
end

return Tile
 