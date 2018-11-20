require 'class'

local lume = require 'lume'

local lg=love.graphics
local random=love.math.random

local Tile = class(function(self,shape,r,g,b,w,h)
  self.element=element or 'plant'
  self.shape=shape
  self.x,self.y=shape[1],shape[2]
  self.r=r or .2
  self.g=g or .2
  self.b=b or .6
  
  self.w = w or 32
  self.h = h or 32
end)

function Tile:getHitbox()
  return {self.x, self.x + self.w, self.y + self.h*.8, self.y + self.h}
end

function Tile:burn()
  self.r = self.r + 0.1
end

function Tile:collide(o)
  if o.element == 'fire' and self.burnable then
    self:burn()
  end
end


function Tile:update()
  local r,g,b = self.r,self.g,self.b
  local el  = self.element

  if r > .6 then
    r = r - .03
    g = g - .04
  elseif r > .4 then
    r = r - .02
    g = g - .03
  elseif r > .2 then
    r = r - .01
    g = g - .02
  end
 
  if g > .6 then
  elseif g > .4 then
    g = g + .03
  else
    g = g + .02
  end
 
  if g > .4 then
    self.burnable = true
  else
    self.burnable = false
  end 
  self.r,self.g,self.b = r,g,b
end

function Tile:draw()
  lg.setColor(self.r,self.g,self.b)
  lg.polygon('fill', self.shape)
end

return Tile
 