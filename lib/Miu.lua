--[[
Miu Planet (Amy, Pink)

todo:
 + add joystick
]]--
require 'class'

local Gaia = require 'lib/Gaia'
local Ocean = require 'lib/Ocean'
local Pink = require 'lib/Pink'
local Cyan = require 'lib/Cyan'

-- ali
local lg=love.graphics
-- go to nirvana
local nirvana = table.remove
-- bring mao to life
local dharma = table.insert

local Miu = class(function(self)
  
  -- add gaia
  self.Gaia = Gaia()

  -- add harmony
  local W,H = lg.getDimensions()
  self.Pink = Pink('assets/flame_1.png', 128, 256, W*.5, H*.5, 1, 1)
  self.Cyan = Cyan()
  self.Cyan.base = Ocean

  self.mao = {}
  -- visible mao's
  self.ao = {}
end)

function Miu:dharma(t)
  for i,v in ipairs(t) do
    table.insert(self.mao,v)
    if v.load then
      v:load()
    end
    if v.mao then
      self:dharma(v.mao)
    end
  end
end


function Miu:load()
  local s=self
  self:dharma({s.Gaia,s.Pink,s.Cyan}) 
  self.Ground = self.Gaia.Ground
end

function Miu:update(dt)
  local W,H = lg.getDimensions()

  -- update mao
  for i,v in ipairs(self.mao) do
    if v.update then
      v:update(dt, self)
    end
    if v.hp and v.hp <= 0 then
      -- lettin go
      nirvana(ao, i)
    end
    if v.y and v.sx then
      -- v.sx = 1 - H / (H + v.y)
      if v.hp then
        local hpMax = v.hpMax or 100
        v.sx = (v.y / self.Ground.h) * (v.hp/hpMax)
      else
        v.sx = v.y / self.Ground.h
      end
      v.sy = v.sx
    end
  end
end

function getIndex(obj, options)
  for i,k in ipairs(options) do
    if obj[k] == nil then
      return i-1
    end
  end
  return #options
end

function Miu:sort(ao, i)
  local tmp
  local a = ao[i].y or -9999
  local b = ao[i+1].y or -9999
  if a > b then 
    tmp=ao[i+1]
    ao[i+1]=ao[i]
    ao[i]=tmp
    if i > 1 then
      self:sort(ao, i-1)
    end
  end
  return ao
end

function Miu:eye(m)
  local W,H=lg.getDimensions()
  local ao = {}
  for i,v in ipairs(m) do
    if v.draw then
      if v.x and v.y then
        if v.x > 0 and v.x < W and v.y > 0 and v.y < H then
          table.insert(ao,v)
        end
      else
        table.insert(ao,v)
      end
    end
  end 
  return ao
end

function Miu:draw() 
  local ao = Miu:eye(self.mao)

  for i,v in ipairs(ao) do
    v:draw()
    lg.print(#ao)
  end
end

return Miu