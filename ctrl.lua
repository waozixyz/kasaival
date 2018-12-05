local state=require 'state'

local le=love.event

local Menu = require 'lib/Menu'
local Miu = require 'lib/Miu'
local Portal = require 'lib/Portal'

local ctrl={}

local lyra={
  [0]= Menu,
  [1]= Miu,
  [2]= Portal,
}

function ctrl.now(x)
  if x == nil then
    return
  elseif x == -1 or lyra[x] == nil then
    le.quit()
  else
    state.c=lyra[x]()
    if state.c.load then
      state.c:load()
    end  
    state.n=nil
  end
end

function ctrl.dharma(dt)
  ctrl.now(state.n)
  local x=state.c
  if x and x.update then
    x:update(dt)
  end
end

function ctrl.paint()
  local x=state.c
  if x and x.draw then
    x:draw()
  end
end

return ctrl