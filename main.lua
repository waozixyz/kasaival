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

state.new=0
local lyra={}
lyra[0] = Menu
lyra[1] = Miu
lyra[2] = Portal

function loadState(x)
  if x == nil or x == -1 or lyra[x] == nil then
    le.quit()
  else
    local ao=state.mao[x]
    state.current = x
    if ao == nil then
      ao=lyra[x]()
      if ao.load then
        ao:load()
      end
     state.mao[x]=ao
    end
  end
end

-- load love
function love.load()
  loadState(state.new) 
end
 

-- update love
function love.update(dt)
  -- update state
  if state.new ~= state.current then     
    loadState(state.new)
  end
  -- update mao
  local ao=state.mao[state.current]
  if ao and ao.update then
    ao:update(dt)
  end
end

-- draw love
function love.draw()
  local ao=state.mao[state.current]
  if ao and ao.draw then
    ao:draw()
  end
end
