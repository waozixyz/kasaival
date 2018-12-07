require 'class'

local Poh=class(function(self)
  self.id=0
  self.mao={}

end)

function Poh:update(dt)

end

function Poh:draw()
  lg.setColor(1,.4,.1) 
  lg.print('hi u sexy',59,50)
end

return Poh
