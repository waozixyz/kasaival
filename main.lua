-- Kasaival
-- state
local state = require 'state'
-- 0, life starts with a Menu
local Menu = require 'lib/Menu'
-- 1, this is a start of a magical journey
local Miu = require 'lib/Miu'
-- 2, a portal to discover
local Portal = require 'lib/Portal'

local currentState = 1
function loadState(x)
  if x == nil or x == -1 then
    love.event.quit()
  elseif x == 0 then
    Menu:load(x)
    currentState = 0
  elseif x == 1 then
    -- miuuuuu
    Miu = Miu()
    Miu:load()
    currentState = 1
  elseif x == 2 then
    --load portal
    Portal = Portal()
    currentState = 2
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
    Menu:update()
  elseif currentState == 1 then
    Miu:update(dt)
  elseif currentState == 2 then
    Portal:update(dt)
  end

end

-- draw love
function love.draw()
  if currentState == 0 then
    Menu:draw()
  elseif currentState == 1 then
    Miu:draw()
  elseif currentState == 2 then
    Portal:draw()
  end
end
