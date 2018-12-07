require 'class'

local lg=love.graphics

local Chi=require 'lib/Chi'
local Miu=require 'lib/Miu'
local Poh=require 'lib/Poh'

local lyra=class(function(self)
  self.sight={}
  self.x=0
  self.y=0
  self.ao={} 
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

function lyra:eye(dt,mao)
  local W,H=lg.getDimensions() 
  local x,y=self.x,self.y
  local ao={}

  for _,v in ipairs(mao) do
    local toAo=false
    if v.draw then
      local offX,offY = 0,0
      if v.w then
        offX = v.w
      end
      if v.h then
        offY = v.h
      end
      if v.x and v.y then
        local l=v.x>=x-offX
        local r=v.x<=x+W+offX
        local d=v.y>=y-offY
        local u=v.y<=y+H+offY
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
    if obj.mao then
     local mao=self:dharma(dt,obj.mao)
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
