require 'class'

local lg=love.graphics

local Grass = require 'lib/Grass'
local Tree = require 'lib/Tree'

local Gaia = class(function(self)
  self.x = -2000
  self.y = 200
  self.width = 4000
  self.height = 400
  self.color = {0.2, 0.4, 0.3}
  self.trees = {}
end)

function Gaia:addTree(...)
 table.insert(self.trees, Tree(...))
end

function Gaia:load()
  self:addTree()
end

function Gaia:update(dt)
  for i,v in ipairs(self.trees) do
    if v.update then
      v:update(dt)
    end
  end
end

function Gaia:draw()
  lg.setColor(self.color)
  lg.rectangle('fill', self.x, self.y, self.width, self.height)

  for i,v in ipairs(self.trees) do
   if v.draw then
     v:draw()
   end
  end
end

return Gaia