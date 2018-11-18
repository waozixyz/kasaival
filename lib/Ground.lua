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
	local t, shape
	local x = 0
	local y = 200
	local offset = {}
	local scale = 1

	while y < self.w do
		scale = y / 200 
		offset.y = y
		while x < self.w do
			offset.x = x - 16
   
   color={.2,.2,.6}
			shape = {offset.x, offset.y, offset.x + 32*scale, offset.y, offset.x + 16*scale, offset.y + 32*scale}
	self:addTile(shape,color)
 
   color={.6,.6,.2}
			shape = {offset.x + 16 * scale, offset.y + 32*scale, offset.x + 48*scale, offset.y + 32*scale, offset.x + 32*scale, offset.y}
		self:addTile(shape,color)
			

			x = x + 32*scale
		end
		x = 0
		y = y + 32*scale
	end
end

function Ground:load()
  self:loadTiles()
end


return Ground