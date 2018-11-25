require 'class'

local lume = require 'lume'

local lg=love.graphics
local lm=love.math

local Tile = class(function(self,shape,r,g,b,w,h)
  self.element=element or 'plant'
  self.shape=shape
  self.x,self.y=shape[1],shape[2]
  self.r=r or .2
  self.g=g or .2
  self.b=b or .6
  
  self.w = w or 32
  self.h = h or 32
  self.burn = false
end)

function Tile:getHitbox()
  return {self.x, self.x + self.w, self.y + self.h*.8, self.y + self.h}
end

function Tile:collide(o)
  if o.element == 'fire' then
    if self.burnable then
      self.burn = true
    end
  end
end


function Tile:update()
  local d=100 -- rgb divider
  local r,g,b = self.r*d,self.g*d,self.b*d
  local el  = self.element

  if r > 60 then
    r = r - 17
    g = g - 14
  elseif r > 40 then
    r = r - 8
    g = g - 6
  elseif r > 20 then
    r = r - 4
    g = g - 3
  end
  
  if self.burn then
    r = r + 20-b/d
  else
    if g > 60 then
      g = g + lm.random(-.027,.03)
    elseif g > 40 then
      g = g + .1
    else
      g = g + .3
    end
  end

  if g > 10 then
    self.burnable = true
  else
    self.burnable = false
  end
  
  self.r,self.g,self.b = r/d,g/d,b/d
  self.burn = false
end

function Tile:draw()
  lg.setColor(self.r,self.g,self.b)
  lg.polygon('fill', self.shape)
end

return Tile
 