require 'class'

local Tile = require 'lib/Tile'

local Ground = class(function(self, x, y, w, h)
  self.x = x or -2000
  self.y = y or 200
  self.w = w or 4000
  self.h = h or 400
  self.mao = {}
end)

function Ground:addTile(shape,color)
  table.insert(self.mao, Tile(shape,color))
end

function Ground:loadTiles()
	 local color,shape
 	local scale = 1
  local w,h = 32,32

 	local y = self.y
	 while y < self.h do
    local x = self.x
		  while x < self.w do
		    scale = y / 400
      color={.2,.3,.6}
	    	shape = {x, y, x + w*scale, y, x + 16*scale, y + h*scale}
	     self:addTile(shape,color,w,h)
      color={.2,.6,.2}
			   shape = {x + 16 * scale, y + h*scale, x + (w+16)*scale, y + h*scale, x + w*scale, y}
		    self:addTile(shape,color,w,h)
		    x = x + w*scale
		end
	 y = y + h*scale
	end
end

function Ground:load()
  self:loadTiles()
end


return Ground