require 'class'

local lg=love.graphics

local Chi=class(function(self)
  self.id=0
  self.mao={}
end)

function Chi:update(dt)

end

function Chi:draw()
  lg.setColor(1,.4,.1) 
  lg.print('hi u sexy',59,50)
end

return Chi
