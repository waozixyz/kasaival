require 'class'

local lume = require 'lume'
local Camera = require 'lib/Camera'
local Tile = require 'lib/Tile'

local lg=love.graphics
local lm=love.math

local Ground = class(function(self, x, y, w, h)
  self.r,self.g,self.b=0,0,0
  self.x = x or -2000
  self.y = y or 200
  self.w = w or 4000
  self.h = h or 400
  self.mao = {}
end)

function Ground:addTile(shape,r,g,b)
  local t = Tile(shape,r,g,b)
  table.insert(self.mao, t)
end

function Ground:load()
  -- add tiles represting grass
	 local color,shape
 	local scale = 1
  local w,h = 32,32
 	local y = self.y
  y = y - y/400
	 while y < self.h do
    local x = self.x
		  while x < self.w*.5 do
      local a,b=0,0
      if x<0 then
        a=lm.random(self.x,x)
      elseif x > 1200 then
        b=lm.random(x,self.w-self.x)
      end
      if a > -1500 and b < 1900 then
		      scale = y / 400 
		      shape = {x + 16 * scale, y + h*scale, x + (w+16)*scale, y + h*scale, x + w*scale, y}
        local r = lm.random(0,1)/10
        local g = lm.random(0,1)
        local b = lm.random(0,1)
		      self:addTile(shape,r,g,b,w,h)
      end
		    x = x + w*scale
		end
	 y = y + h*scale
	end
end


function Ground:draw()
  local a = self.x
  local o = self.x + self.w

  r = (-Camera.x)/o * .7
  g = .5 - math.abs(Camera.x)/a * .2 
  b = (-Camera.x)/a *.7
  
  if r < 0 then
    r = r * -1
    if r > .2 then
      r = .2
    end
  end

  r=lume.clamp(r,0,1)
  g=lume.clamp(g,0,1)
  b=lume.clamp(b,0,1)

  lg.setColor(r,g,b)  
  lg.rectangle('fill', self.x,self.y,self.w,self.h)
  
  self.r,self.g,self.b=r,g,b
end


return Ground