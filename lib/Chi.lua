require 'class'

local lg=love.graphics

local Flame=require 'lib/Flame'

local Chi=class(function(self)
  self.id=0
  self.mao={Flame()}
end)

function Chi:update(dt)

end

function Chi:draw()
  
end

return Chi
