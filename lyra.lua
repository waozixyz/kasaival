require 'class'

local lg=love.graphics

local Chi=require 'lib/Chi'
local Miu=require 'lib/Miu'
local Poh=require 'lib/Poh'

local lyra=class(function(self)
  self.sight={}
  self.x=0
  self.y=0
  self.box={Chi,Miu,Poh}
end)
 
function lyra:load(key)
  local obj=self.box[key]()
  if obj.load then
   obj:load()
  end
  self.obj=obj
end

function lyra:dharma(dt,mao)
  for i,v in ipairs(mao) do
    if v.hp and v.hp<0 or v.sx and v.sx<0 or v.scale and v.scale<0 then
      table.remove(mao,i)
    else
      if v.mao then
        local t=self:dharma(dt,v.mao)
        for i,v in ipairs(t) do
          table.insert(mao,v)
        end
      end
      table.insert(mao,v)

    end
  end
  return mao
end

function lyra:eye(dt,mao)
  local W,H=lg.getDimensions() 
  local ao={}
  x=self.x
  y=self.y

  for i,ao in ipairs(mao) do
    local toAo=false
    if ao.draw then
      local offX,offY = 0,0
      if ao.w then
        offX = ao.w
      end
      if ao.h then
        offY = ao.h
      end
      if ao.x and ao.y then
        local l=ao.x>=x-offX
        local r=ao.x<=x+W+offX
        local d=ao.y>=y-offY
        local u=ao.y<=y+H+offY
        if l and r and d and u then
          toAo=true
        end
      else
        toAo=true
      end
    end
    if toAo then
      table.insert(ao,v)
    end
  end 
  return ao
end

function lyra:update(dt)
  local obj=self.obj
  if obj then
    if obj.update then obj:update(dt) end
    local mao=self:dharma(dt,obj.mao)
    if mao then
      for _,o in ipairs(mao) do
        if o.update then
          o:update(dt)
        end
      end
      self.ao=self:eye(dt,mao)
    end
  end
end

function lyra:draw()
  lg.setColor(1,1,1)
  lg.printf(#self.ao,40,80,500,'center')
  local obj=self.obj
  if obj and obj.draw then
    obj:draw()
  end
  if self.ao then
    for _,o in ipairs(self.ao) do
      if o.draw then
        o:draw()
      end
    end
  end
end

return lyra
