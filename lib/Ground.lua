require 'class'

local Camera = require 'lib/Camera'
local Tile = require 'lib/Tile'

local lg=love.graphics

local Ground = class(function(self, x, y, w, h)
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
  y = y - (h-2 )*y/400
	 while y < self.h do
    local x = self.x
		  while x < self.w do
		    scale = y / 400 
			   shape = {x + 16 * scale, y + h*scale, x + (w+16)*scale, y + h*scale, x + w*scale, y}
		    self:addTile(shape,.2,.6,.2,w,h)
		    x = x + w*scale
		end
	 y = y + h*scale
	end
end


function Ground:draw()
  local r,g,b = .2,.3,.3
  local a = self.x
  local o = self.x + self.w
  b = (-Camera.x)/a *.7

  r = (-Camera.x)/o * .7
  g = .5 - math.abs(Camera.x)/a * .2 
  if r < 0 then
    r = r * -1
    if r > .2 then
      r = .2
    end
  end
  
  lg.setColor(r,g,b)  
  lg.rectangle('fill', self.x,self.y,self.w,self.h)
  lg.print(Camera.x, 50,50)
end


return Ground