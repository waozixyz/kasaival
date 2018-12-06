local state=require 'state'

local le=love.event
local lg=love.graphics
local lm=love.math

local Chi=require 'lib/Chi'
local Miu=require 'lib/Miu'
local Portal=require 'lib/Portal'
local Voyager=require 'lib/Voyager'
local ctrl={}

local lyra={
  [0]=Chi,
  [1]=Miu,
  [2]=Voyager,
  mao={},
  ao={},
  x=0,
  y=0,
}

function ctrl.now(x)
  if x == nil then
    return
  elseif x == -1 or lyra[x] == nil then
   local lol=lm.random(0,8)
   local olo=lm.random(0,13)
   local x=(lol+olo)*.5
   if lol > 6 and x > 9 then
     ctrl.now(1)
   else
     le.quit()
   end
  else
    state.c=lyra[x]()
    if state.c.load then
      state.c:load()
    end  
    state.n=nil
  end
end


function getActive()
  local mao=lyra.mao
  for i,ao in ipairs(mao) do
    if ao.hp and ao.hp<0 or ao.sx and ao.sx<0 or ao.scale and ao.scale<0 then
      table.remove(mao,i)
    else

    if not ao.added and ao.mao then
      for i,o in ipairs(ao.mao) do
        table.insert(mao,o)
      end
      ao.added=true
    end
    end
  end
  lyra.mao=mao
end

function getVisible(m,x,y)
  local W,H=lg.getDimensions()
  x=x or 0
  y=y or 0
  
  local ao = lyra.ao
 
  for i,v in ipairs(m) do
    if v.draw then
      local offX,offY = 0,0
      if v.w then
        offX = v.w
      end
      if v.h then
        offY = v.h
      end
      if v.x and v.y then
        if v.x >= x-offX and v.x <= x+W+offX and v.y >= y-offY and v.y <= y+H+offY then
          table.insert(ao,v)
        end
      else
        table.insert(ao,v)
      end
    end
  end 
  return ao
end

function ctrl.dharma(dt)
  ctrl.now(state.n)
  local x=state.c
  if x and x.update then
    x:update(dt)
  end
  local x,y=lyra.x,lyra.y
  local m=getActive({lyra[state.n]})
  lyra.ao=getVisible(m,x,y)

end

function ctrl.paint()
  local x=state.c
  if x and x.draw then
    x:draw()
  end
end

return ctrl