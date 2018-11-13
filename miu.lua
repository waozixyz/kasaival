require 'class'


local Gaia = require 'lib/Gaia'
local Ocean = require 'lib/Ocean'
local Pink = require 'lib/Pink'
local Cyan = require 'lib/Cyan'

-- ali
local lg=love.graphics

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


function miu:update(dt)
  local W,H = lg.getDimensions()
  -- go to nirvana
  nirvana = table.remove


  -- update ao
  for i,v in ipairs(self.mao) do
    if v.update then
      v:update(dt, self)
    end
    if v.hp and v.hp <= 0 then
      nirvana(self, i)
    end
    if v.y and v.sx then
      v.sx = v.sx - H / (H + v.y)
      v.sy = v.sx
    end
  end
end

function miu:draw()
  -- draw ao
  for i,v in ipairs(self.mao) do
    if v.draw then
      v:draw(1, self)
    end
  end
end

return miu