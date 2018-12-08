require 'class'

local lg=love.graphics

local state=require 'state'
local Chi=require 'lib/Chi'
local Miu=require 'lib/Miu'
local Poh=require 'lib/Poh'

local lyra=class(function(self)
  self.x,self.y=0,0
  self.h=600
  local H=lg.getHeight()
  state.phi=H/self.h
  self.sight={}
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
      local w,h=0,0
      local a,b
      if v.w then
        w = v.w
      end
      if v.h then
        h = v.h
      end
      if v.x then
       a=v.x>=x-w and v.x<=x+W+w
      end
      if v.y then
       b=v.y>=y-h and v.y<=y+self.h
      end
      if a and b then
        toAo=true
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
  local H=lg.getHeight()
  state.phi=H/self.h
 
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
      self.mao=mao
    end
  end
end

function lyra:draw()
  local W,H = lg.getDimensions()
  local phi=state.phi
  lg.setColor(1,1,1)
  lg.printf(#self.mao,40,80,500,'center')
  if self.ao then
    for _,o in ipairs(self.ao) do
      if o.draw then
        o:draw(phi)
      end
    end
  end
  local obj=self.obj
  if obj and obj.draw then
    obj:draw(phi)
  end 
end

return lyra
