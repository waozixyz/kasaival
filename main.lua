local lg=love.graphics

local Ground = {}
local Player = {}


function love.load()
  
end



function love.update(dt)
  
end

function love.draw()
  W, H = lg.getDimensions()

  lg.setColor(0.4, 0.2, 0.1 ) 
  lg.rectangle('fill', 0, H * 0.4 , W, H * 0.6 )
end
