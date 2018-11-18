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
  self.ground = {}
  self.ground.y = 00
  self.ground.h = 400

  -- add gaia
  self.Gaia = Gaia()

  -- add harmony
  local W,H = lg.getDimensions()
  self.Pink = Pink('assets/flame_1.png', 128, 256, W*.5, H*.5, 1, 1)
  self.Cyan = Cyan()
  self.Cyan.base = Ocean

  self.mao = {}
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
  self:dharma({s.Gaia})
end

function Miu:sort(ao, i)
  local tmp
  if ao[i].y > ao[i+1].y then 
    tmp=ao[i+1]
    ao[i+1]=ao[i]
    ao[i]=tmp
    if i > 1 then
      self:sort(ao, i-1)
    end
  end
  return ao
end

function Miu:update(dt)
  local W,H = lg.getDimensions()
  local ao = self.mao

  -- sort ao
  for i=1,#ao-1 do
    ao = self:sort(ao,i)
  end      

  -- update ao
  for i,v in ipairs(ao) do
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
        v.sx = (v.y / self.ground.height) * (v.hp/hpMax)
      else
        v.sx = v.y / self.ground.height
      end
      v.sy = v.sx
    end
  end
end

function Miu:draw() 
 for i,v in ipairs(self.mao) do
    if v.draw then
      v:draw()
    end
  end

  lg.print(self.mao[1].y, 0, 0)
  lg.print(self.mao[1].label, 0, 30)


  lg.print(self.mao[2].y, 40, 0)
  lg.print(self.mao[2].label, 40, 30)


  lg.print(self.mao[3].y, 80, 0)
  lg.print(self.mao[3].label, 80 , 30)
end

return Miu