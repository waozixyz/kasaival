-- Kasaival
local ctrl = require 'ctrl'
local state = require 'state'

-- load love
function love.load()
  state.n=1
end
 
-- update love
function love.update(dt)
  ctrl.dharma(dt)
end

-- draw love
function love.draw()
  ctrl.paint()
end