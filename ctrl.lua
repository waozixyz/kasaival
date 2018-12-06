local state=require 'state'

local le=love.event
local lm=love.math

local Chi=require 'lib/Chi'
local Miu=require 'lib/Miu'
local Portal=require 'lib/Portal'
local Voyager=require 'lib/Voyager'
local ctrl={}

local lyra={
  [0]= Chi,
  [1]= Miu,
  ['ao']=Voyager,
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


function getActiveMao(t)
  local mao={}
  for i,a in ipairs(t) do
    if a.hp and a.hp <= 0 or a.sx and a.sx < 0 or a.scale and a.scale < 0 then
      table.remove(t,i)
    else
    table.insert(mao,a)

    if a.mao then
      local ao = self:dharma(a.mao)
      for i,o in ipairs(ao) do
        table.insert(mao,o)
      end
    end
    end
  end
  return mao
end

function ctrl.dharma(dt)
  ctrl.now(state.n)
  local x=state.c
  if x and x.update then
    x:update(dt)
  end

  local mao=getActiveMao(lyra[state.now])
  self.ao = Miu:eye(mao, lyra.x)

end

function ctrl.paint()
  local x=state.c
  if x and x.draw then
    x:draw()
  end
end

return ctrl