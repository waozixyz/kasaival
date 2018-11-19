-- Kasaival
-- with lyra you can go anywhere
local lyra = require 'lyra'
-- state
local state = require 'state'
-- this is a start of a magical journey
local Miu = require 'lib/Miu'


local currentState = 1
function loadState(x)
  if x == 0 then
    lyra:load(x)
    currentState = 0
  elseif x == 1 then
    -- miuuuuu
    Miu = Miu()
    Miu:load()
    currentState = 1
  end
end
local lw=love.window
local li=love.image
-- load love
function love.load()
  state.newState = currentState
  lw.setIcon(li.newImageData('icon.png'))
  loadState(state.newState)
end
 
-- update love
function love.update(dt)
  if state.newState ~= currentState then
    loadState(state.newState)
  end
 
  if currentState == 0 then
    lyra:update()
  elseif currentState == 1 then
    Miu:update(dt)
  end

  if love.keyboard.isDown('escape') then
    love.event.quit()
  end
end

-- draw love
function love.draw()
  if currentState == 0 then
    lyra:draw()
  elseif currentState == 1 then
    Miu:draw()
  end
end
