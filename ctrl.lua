require 'class'

local lg=love.graphics

local state=require 'state'
local lyra=require 'lyra'

local ctrl=class(function(self)
  self.ly=lyra()
  self.ly:load(1)
end)

function ctrl:update(dt)
  if state.new then    
    self.ly:load(state.new)
  end
  self.ly:update(dt)
  state.new=nil
end

function ctrl:draw()
  self.ly:draw()
end

return ctrl
