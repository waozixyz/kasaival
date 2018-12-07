-- Kasaival
local ctrl = require 'ctrl'

-- load love
function love.load()
  ctrl=ctrl()
end
 
-- update love
function love.update(dt)
  ctrl:update(dt)
end

-- draw love
function love.draw()
  ctrl:draw()
end