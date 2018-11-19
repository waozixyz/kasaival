require 'class'

local lg=love.graphics
local random=love.math.random

local Tile = class(function(self,shape,color,w,h)
  self.shape=shape
  self.x,self.y=shape[1],shape[2]
  self.color=color or {.2,.2,.6}
  self.w = w or 32
  self.h = h or 32
end)

function Tile:update()
  local red = self.color[1]
  if red > .7 then
    red = red - .04
  elseif red > .4 then
    red = red - .02
  elseif red > .3 then
    red = red - random(0,1)*.01
  end
end

function Tile:draw()
  lg.setColor(self.color)
  lg.polygon('fill', self.shape)
end

return Tile
 