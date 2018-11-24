--[[
Miu Planet (Amy, Pink)
]]--

require 'class'
local lume = require 'lume'

local Gaia = require 'lib/Gaia'
local Pink = require 'lib/Pink'
local Cyan = require 'lib/Cyan'

-- ali
local lg=love.graphics
local lt=love.touch

-- go to nirvana
local nirvana = table.remove
-- bring mao to life
local dharma = table.insert

local Camera = require 'lib/Camera'
-- Joysticks
local Joystick = require 'lib/Joystick'
local movePad, attackPad
local GameOver=false

function moveInArea(x, dx, min, max)
  return (x > min or dx > 0) and (x < max or dx < 0)
end

local Miu = class(function(self)
  local W,H = lg.getDimensions()
  self.font=lg.newFont('assets/KasaivalGB.ttf',13)
  self.bigFont=lg.newFont('assets/KasaivalGB.ttf',17)
  do -- joysticks
    local x,y,r=W*0.85,H*0.75,64
    local c1={.2,.1,.8,.5}
    local c2={.8,.1,.2,.5}
    
    movePad=Joystick(W-x, y, r, c1)
    attackPad=Joystick(x, y, r, c2)
  end
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
  Camera.x,Camera.y=0,0
  -- add gaia
  s.Gaia = Gaia()

  -- add harmony
  local W,H = lg.getDimensions()
  s.Pink = Pink('assets/flame_2.png', 96, 192,   W*.5, H*.7)
  s.Pink.hp=100
  s.Cyan = Cyan()

  s.mao={}
  -- visible mao's
  s.ao = {}

  s:dharma({s.Gaia,s.Pink,s.Cyan}) 
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
  local W,H = lg.getDimensions()
  local P,C,G=self.Pink,self.Cyan,self.Gaia
  local Po,Oc,Gr=P.Portal,C.Ocean,G.Ground

  if P.hp and math.floor(P.hp) <= 0 then
    GameOver=true
    local touches = lt.getTouches()
    if #touches > 0 then
      self:load()
      GameOver=false
    end
  else 

  if Camera.prevX ~= Camera.x then
    self.ao = Miu:eye(self.mao, -Camera.x)
    Camera.prevX = Camera.x
  end
  self.ao = lume.sort(self.ao, 'y')
 
  self.coli = lume.collision(P, Gr.mao)
  if #self.coli > 0 then
    for i,c in ipairs(self.coli) do
      P:collide(c)
      c:collide(P)
    end
  end

  movePad:update(dt)
  -- move Camera and Pink
  local dx,dy = movePad.dx, movePad.dy
  dx,dy = P:regulateSpeed(dx, dy)

  if moveInArea(-Camera.x, dx, Oc.x, P.x, Po.x - W*.5) and moveInArea(P.x, -dx, W*.8 - Camera.x, W*.2 - Camera.x) then
    Camera.x = Camera.x - dx

  end

  P:move(dx,dy)

  -- collisions
  --local phb=P:getHitbox()
 -- local ohb=C:getHitbox()
 --if collision(phb, ohb) then
 --   P:defend(Oc:attack(P))
  --end


  do -- attackPad position
    local cx=Camera.x
    local ap=attackPad
    local ppx=Po.x

    if ap.x>=ppx+cx-ap.r or ap.x>W*0.85 then
      ap.x = ap.x-8
    elseif ap.x<
W*0.85 and ap.x<ppx+cx-ap.r-8 then
      ap.x = ap.x + 8
    end
  end

  attackPad:update(dt)
  -- attack
  dx,dy = attackPad.dx, attackPad.dy
  if dx ~= 0 or dy ~= 0 then
    P:attack(dx, dy)
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
        v.sx = (v.y / Gr.h) * (v.hp/hpMax)
      else
        v.sx = v.y / Gr.h
      end
      v.sy = v.sx
    end
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
  local W,H=lg.getDimensions()
  lg.setFont(self.font)
  lg.translate(Camera.x, Camera.y)
  lg.scale(Camera.scale) 
  for i,v in ipairs(self.ao) do
    v:draw(Camera)
  end
  lg.print(tostring(GameOver),-Camera.x+30,30)

  lg.reset()
  movePad:draw()
  attackPad:draw()
  
  if GameOver then
    lg.setFont(self.bigFont)
    lg.setColor(1,.6,.6)
    lg.printf('Game Over',50, H*.5,W,'center')
  end
end

return Miu