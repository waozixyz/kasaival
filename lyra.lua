require 'class'

local lg=love.graphics

local state=require 'state'

setmetatable(_G, { __index = require('cargo').init('/') })

local Camera=require 'camera'
local Chi=require 'lib/Chi'
local Miu=require 'lib/Miu'
local Poh=require 'lib/Poh' 

local lyra=class(function(self)
  state.w,state.h=800,600
  local x,y=0,0
  self.ao={} 
  self.box={Chi,Miu,Poh}
  state.eye=Camera(state.w,state.h,{x=x,y=y,resizable=true, maintainAspectRatio=true})
end)
 
function lyra:load(key)
  local obj=self.box[key]()
  if obj.load then
   obj:load()
  end
  self.obj=obj
end

function lyra:dharma(dt,mao)
  local result={}
  for i,v in ipairs(mao) do
    if v.hp and v.hp<0 or v.sx and v.sx<0 or v.scale and v.scale<0 then
      table.remove(mao,i)
    else
      if v.mao then
        local t=self:dharma(dt,v.mao)
        for i,v in ipairs(t) do
          table.insert(result,v)
        end
      end
      table.insert(result,v)
    end
  end
  return result
end

function lyra:sight(dt,mao)
  local x,y=state.eye:getWorldCoordinates(0,0)
  local ao={}

  for _,v in ipairs(mao) do
    local toAo=false
    if v.draw then
      local w,h=0,0
      local a,b
      if v.w then
        w = v.w
      end
      if v.h then
        h = v.h
      end
      if v.x and v.y then
        if v.x>=x-w and v.x<=x+w+state.eye.w*.5 and v.y>=y-h and v.y<=y+state.eye.h*.5 then
         toAo=true
        end
      end
    else
      toAo=true
    end
    if toAo then
      table.insert(ao,v)
    end
  end 
  return ao
end

function lyra:update(dt)
  state.eye:update()
 
  local obj=self.obj
  if obj then
    if obj.update then obj:update(dt) end
    if obj.mao then
     local mao=self:dharma(dt,obj.mao)
      for _,o in ipairs(mao) do
        if o.update then
          o:update(dt)
        end
      end
      self.ao=mao
      self.mao=mao
    end
  end
end

function lyra:draw()

  state.eye:push()
  lg.setColor(1,1,1)
  --lg.printf(state.eye.w,-160,-220,500,'center')
  if self.ao then
    for _,o in ipairs(self.ao) do
      if o.draw then
        o:draw()
      end
    end
  end
  local obj=self.obj
  if obj and obj.draw then
    obj:draw()
  end 
  state.eye:pop()
end

return lyra
