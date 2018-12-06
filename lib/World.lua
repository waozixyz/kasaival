require 'class'

local World=class(function(self)


end)

function World:update(dt)

end

function World:draw()
  lg.setColor(1,0,1)
  lg.rectangle(0,0,50,50)
end

return World
