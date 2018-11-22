--[[
Miu Planet (Amy, Pink)
]]--

require 'class'
local lume = require 'lume'


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

local Camera = require 'lib/Camera'
-- Joysticks
local Joystick = require 'lib/Joystick'
local movePad, attackPad

function moveInArea(x, dx, min, max)
  return (x > min or dx > 0) and (x < max or dx < 0)
end

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
  -- collidaes
  self.dao = {}
  self.font=lg.newFont('assets/KasaivalGB.ttf')
  
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
  local W,H = lg.getDimensions()
  local s=self
  self:dharma({s.Gaia,s.Pink,s.Cyan}) 
  self.Ground = self.Gaia.Ground

  do -- joysticks
    local x,y,r=W*0.85,H*0.75,64
    local c1={.2,.1,.8,.5}
    local c2={.8,.1,.2,.5}
    
    movePad=Joystick(W-x, y, r, c1)
    attackPad=Joystick(x, y, r, c2)
  end
end

function collision(pink, cyan)
  local flag = false
  if #pink % 2 == 1 then return end
  
  if pink[1] < cyan[2] and pink[2] > cyan[1] then
      flag = true
    else
      flag = false
    end
   
  return flag
end

function Miu:eye(m, offsetX, offsetY)
  local x,y = offsetX or 0
  local y = offsetY or 0
  local W,H=lg.getDimensions()
  local ao = {}
 
  for i,v in ipairs(m) do
    if v.draw then
      local offX,offY = 0,0
      if v.w then
        offX = v.w
      end
      if v.h then
        offY = v.h
      end
      if v.x and v.y then
        if v.x >= x-offX and v.x <= x+W+offX and v.y >= y-offY and v.y <= y+H+offY then
          table.insert(ao,v)
        end
      else
        table.insert(ao,v)
      end
    end
  end 
  return ao
end



function Miu:update(dt)
  local Pink,Cyan=self.Pink,self.Cyan
  local Ground=self.Ground

  if Camera.prevX ~= Camera.x then
    self.ao = Miu:eye(self.mao, -Camera.x)
    Camera.prevX = Camera.x
  end
  self.ao = lume.sort(self.ao, 'y')
 
  self.coli = lume.collision(Pink, Ground.mao)
  if #self.coli > 0 then
    for i,c in ipairs(self.coli) do
      Pink:collide(c)
      c:collide(Pink)
    end
  end
  
  local W,H = lg.getDimensions()
  do -- attackPad position
    local cx=Camera.x
    local ap=attackPad
    local ppx=self.Pink.Portal.x
    if ap.x>=ppx+cx-ap.r or ap.x>W*0.85 then
      ap.x = ap.x-8
    elseif ap.x<
W*0.85 and ap.x<ppx+cx-ap.r-8 then
      ap.x = ap.x + 8
    end
    
  end
  local dx, dy
  movePad:update(dt)
  -- move Camera and Pink
  dx,dy = movePad.dx, movePad.dy
  dx,dy = Pink:regulateSpeed(dx, dy)
  if moveInArea(-Camera.x, dx, Cyan.base.x, Pink.Portal.x - W*.5) and moveInArea(Pink.x, -dx, W*.8 - Camera.x, W*.2 - Camera.x) then
    Camera.x = Camera.x - dx
  end

  Pink:move(dx,dy)

  -- collisions
  --local phb=Pink:getHitbox()
  local ohb=Cyan.base:getHitbox()
 --if collision(phb, ohb) then
 --   Pink:defend(Cyan.base:attack(Pink))
  --end

  attackPad:update(dt)
  -- attack
  dx,dy = attackPad.dx, attackPad.dy
  if dx ~= 0 or dy ~= 0 then
    Pink:attack(dx, dy)
  end
  -- update mao
  for i,v in ipairs(self.mao) do
    if v.update then
      v:update(dt, self)
    end
    if v.hp and v.hp <= 0 then
      -- lettin go
      nirvana(self.mao, i)
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


function Miu:draw() 
  lg.setFont(self.font)

  lg.translate(Camera.x, Camera.y)
  lg.scale(Camera.scale) 
  for i,v in ipairs(self.ao) do
    v:draw()
  end
  lg.print(-Camera.x,-Camera.x+30,30)

  lg.reset()
  movePad:draw()
  attackPad:draw()
end

return Miu