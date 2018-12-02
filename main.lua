-- Kasaival
-- state
local state = require 'state'
-- 0, life starts with a Menu
local Menu = require 'lib/Menu'
-- 1, this is a start of a magical journey
local Miu = require 'lib/Miu'
-- 2, a portal to discover
local Portal = require 'lib/Portal'

local le=love.event
local lg=love.graphics
local li=love.image

-- set start stage
state.new = 0

local _M,_P
function loadState(x)
  if x == nil or x == -1 then
    le.quit()
  elseif x == 0 then
    state.current = 0
    Menu:load(x)
  elseif x == 1 then
    state.current = 1
    -- miuuuuu
    if _M == nil then
      _M=Miu()
    end
    _M:load()
  elseif x == 2 then
    state.current = 2
    --load portal
    _P=Portal()
  end
end

-- load love
function love.load()
  loadState(state.new) 
end
 
-- update love
function love.update(dt)
  if state.new ~= state.current then
    loadState(state.new)
  end
 
  if state.current == 0 then
    Menu:update(dt)
  elseif state.current == 1 then
    _M:update(dt)
  elseif state.current == 2 then
    _P:update(dt)
  end
end

-- draw love
function love.draw()
  if state.current == 0 then
    Menu:draw()
  elseif state.current == 1 then
    _M:draw()
  elseif state.current == 2 then
    _P:draw()
  end
end
