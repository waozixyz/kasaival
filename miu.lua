require 'class'


local Gaia = require 'lib/Gaia'
local Ocean = require 'lib/Ocean'
local Pink = require 'lib/Pink'
local Cyan = require 'lib/Cyan'

-- ali
local lg=love.graphics
-- go to nirvana
local nirvana = table.remove

-- For Planet Miu a miu!
local miu = class(function(self)
  local mao = {}

  -- bring mao to life
  local dharma = table.insert
 
  for i,v in ipairs(mao) do
    if v.load then
      v:load(self)
    end
  end
  -- load gaia
  self.gaia = Gaia()

  -- load harmony
  local W,H = lg.getDimensions()
  self.pink = Pink('assets/flame_1.png', 128, 256, W*.5, H*.5, 1, 1)
  self.cyan = Cyan()
  self.cyan.base = Ocean

  -- throw to dharma
  dharma(mao, self.gaia)
  dharma(mao, self.pink)
  dharma(mao, self.cyan)

  self.mao = mao

 -- draw ao
  for i,v in ipairs(self.mao) do
    if v.load then
      v:load()
    end
  end
end)

function miu:ao(dt, mao)
  -- update ao
  for i,v in ipairs(mao) do
    if v.update then
      v:update(dt, self)
    end
    if v.hp and v.hp <= 0 then
      -- lettin go
      nirvana(mao, i)
    end
    if v.y and v.sx then
      -- v.sx = 1 - H / (H + v.y)
      if v.hp then
        local hpMax = v.hpMax or 100
        v.sx = (v.y / self.gaia.height) * (v.hp/hpMax)
      else
        v.sx = v.y / self.gaia.height
      end
      v.sy = v.sx
    end
    if v.mao then
      self:ao(dt, v.mao)
    end
  end
end

function miu:update(dt)
  local W,H = lg.getDimensions()
  
  -- life is suffering
  self:ao(dt, self.mao)
end

-- ein augenblick (eyes symbol)
function miu:now(mao)
  -- draw ao
  for i,v in ipairs(mao) do
    if v.draw then
      v:draw( )
    end
    if v.mao then
      self:now(v.mao)
    end
  end
end

function miu:draw()
   miu:now(self.mao)

  -- print
  lg.print(self.pink.sx)
  lg.print(self.pink.hp, 0, 20)
  lg.print(self.pink.hp / self.pink.hpMax,0,40)

  lg.print(self.pink.y / self.gaia.height,0,60)
end

return miu