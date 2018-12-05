require 'class'

local lg=love.graphics
local ls=love.system

local ao=require 'ao/index'

local Voyager=class(function(self,goal)
  self.b=goal or ao
end) 

function Voyager:draw()
  lg.setColor(1,1,1)
  lg.printf(self.b,50,50,600,'center')
end

return Voyager