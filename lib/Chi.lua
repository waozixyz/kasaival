require 'class'

local lg=love.graphics

local Flame=require 'lib/Flame'
local Carousel=require 'ui/Carousel'
local Costumes={
  'Northern Lights',
  'White widdow', 
}

local Chi=class(function(self)
  self.id=0
  self.mao={
    Flame(),
    Carousel(0,400)
  }
end)

function Chi:update(dt)
end

function Chi:draw(phi)
end

return Chi
