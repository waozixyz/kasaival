--[[
Miu Planet (Amy, Pink)
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
-- Only through the portal can we get an updatte to the game
local Portal = {
  x = 2000
}

-- Joysticks
local Joystick = require 'lib/Joystick'
local movePad, attackPad


-- Camera
local Camera = {
  x = 0,
  y = 0,
  scale = 1,
}

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
function Miu:update(dt)
  local Pink,Cyan =self.Pink,self.Cyan
  local W,H = lg.getDimensions()
 
  local dx, dy
  movePad:update(dt)
  -- move Camera and Pink
  dx,dy = movePad.dx, movePad.dy
  dx,dy = Pink:regulateSpeed(dx, dy)
  if moveInArea(-Camera.x, dx, Cyan.base.x, Portal.x - W*.5) and moveInArea(Pink.x, -dx, W*.8 - Camera.x, W*.2 - Camera.x) then
    Camera.x = Camera.x - dx
  end

  Pink:move(dx,dy)

  -- collisions
  local phb=Pink:getHitbox()
  local ohb=Cyan.base:getHitbox()
  if collision(phb, ohb) then
    Pink:defend(Cyan.base:attack(Pink))
  end

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
  lg.translate(Camera.x, Camera.y)
  lg.scale(Camera.scale) 
    
  local ao = Miu:eye(self.mao)

  for i,v in ipairs(ao) do
    v:draw()
    lg.print(#ao)
  end

  lg.reset()
  movePad:draw()
  attackPad:draw()

end

return Miu