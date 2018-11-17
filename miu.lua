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

-- For Planet Miu a miu!
local miu = class(function(self)
  local mao = {}

  for i,v in ipairs(mao) do
    if v.load then
      v:load(self)
    end
  end
  -- load gaia
  self.gaia = Gaia()
  self.ground = {}
  self.ground.height = 400
  -- load harmony
  local W,H = lg.getDimensions()
  self.pink = Pink('assets/flame_1.png', 128, 256, W*.5, H*.5, 1, 1)
  self.cyan = Cyan()
  self.cyan.base = Ocean


end)

function miu:toMao(mao)
  for i,v in ipairs(mao) do
    if v.mao then
      self:toMao(v.mao)
    end
    table.insert(self.mao, v)
  end
end


function miu:load()
  self.mao = {}
  self:toMao({self.gaia, self.pink, self.cyan})
 
  
  for i,v in ipairs(self.mao) do
    if v.load then
      v:load()
    end
  end
end

function miu:ao(dt, mao)
  -- sort ao
  local tmp
  local actions = 1
  while actions > 0 do
    local a = 0
    local i = 1
    while i < #mao - 1 do
      local tmp
      if mao[i].y > mao[i+1].y then
        a = a + 1
        tmp=mao[i+1]
        mao[i+1]=mao[i]
        mao[i]=tmp
      end
      i = i + 2
    end
    actions = a
  end
        

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
        v.sx = (v.y / self.ground.height) * (v.hp/hpMax)
      else
        v.sx = v.y / self.ground.height
      end
      v.sy = v.sx
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

  
end

return miu