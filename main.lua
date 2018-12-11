 local lyra=require 'lyra'

love.load=function()
  lyra.load()
  return nil
end
love.update=function(dt)
  lyra.update(dt)
  return nil
end
love.draw=function()
  lyra.draw()
  return nil
end

