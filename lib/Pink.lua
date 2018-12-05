require 'class'
local lume=require 'lume'
local SpriteSheet=require 'lib/SpriteSheet'

local lg=love.graphics
local lm=love.math

local Shuriken = require 'lib/Shuriken'
local Dopamine=require('lib/Dopamine')

local Pink=class(function(self, img, w, h, x, y, sx, sy)
  local W,H = lg.getDimensions()
  self.label = 'pink'
  self.img = 'assets/chi.png'
  
  self.w = w or 64
  self.h = h or 128
  self.x = x or W*.5
  self.y = y or H*.5
  self.sx = sx or 1
  self.sy = sy or 1
  self.hp = 100
  self.hpsize=true
  self.hpMax = 200
  self.speed = 3
  self.element = 'fire'
  self.walkSpeed = 8
  self.atk = 1
  self.def = 0
  
  self.attackSpeed = 5
  self.attackCharge = 100
  self.Portal = { x=2000, y=0}
  self.r,self.g,self.b=1,1,1 
  self.invincible=false
  self.mao={self.Portal}
  -- add animation
  local S=SpriteSheet(self.img, self.w, self.h)
  local a=S:createAnimation()
  for row=1,8 do
    local limit=22
    if row==8 then limit=19 end
    for col=1,limit do
      a:addFrame(col, row)
    end
  end

  a:setDelay(0.08)
  self.animation=a
  self.lvl=0
end)

function Pink:regulateSpeed(dx, dy, speed)
  if not speed then speed = self.walkSpeed end 
  if math.abs(dx) + math.abs(dy) ~= 0 then
    speed = speed / (math.abs(dx) + math.abs(dy))
  end 
  return dx*speed, dy*speed
end

function Pink:attack(dx, dy)
  if self.attackCharge > 1 then
    dx,dy = self:regulateSpeed(dx,dy,self.attackSpeed)
    
    local atkSpeed = self.attackSpeed
    local px=self.x-self.w*.2
    local py=self.y-self.h*.25
    x=px+(dx/atkSpeed)*(self.w*.1)
    y=py+(dy/atkSpeed)*(self.h*.1)
table.insert(self.mao, Shuriken(x,y,dx,dy))
    self.attackCharge=0
    self.hp=self.hp-3
  end
end

function Pink:collide(o)
  if o.element == 'plant' then
    self.hp = self.hp + .001
  elseif o.element == 'water' then
    self.hp = self.hp - .01
  end
end
function Pink:getHitbox()
  local t = {}
  t[1] = self.x - self.w * .2 * self.sx
  t[2] = self.x + self.w * .2 * self.sx
  t[3] = self.y + self.h * .1
  t[4] = self.y + self.h * .3
  return t
end

function Pink:addDopamine(txt,val,c)
  c=c or {.5,.2,.7}
 
  if val < 0 then
    c={1-c[1],1-c[2],1-c[3]}
  end
  local x=self.x
  local y=self.y-self.h*.3

  table.insert(self.mao, Dopamine(txt,val,x,y,c))
end

function Pink:burnUp(x)
  self.hp = self.hp - x
end

function Pink:defend(attack)
  local defence = 0

  if self.def and  self.def > 0 then
    defence = math.log(self.def)
  end
    
  self.hp = self.hp - attack
end

function Pink:lvlup(a)
  a=a or 1
  self.lvl=self.lvl+a
  self.hpMax=self.hpMax+10*a
  if a > 0 then
    self.hp=self.hpMax*.5
  elseif a < 0 then
    self.hp=self.hpMax*.5
  end
  self:addDopamine('lvl',a)
end

function Pink:lvldown(a)
  a=a or 1
  self:lvlup(-a)
end

function Pink:update(dt, Miu)
  local G=Miu._G
  local GG=G.Ground
  local r,g,b = self.r,self.g,self.b
  if self.invincible then  
    r = lm.random(-.05,.1)
    if r>1 then r=0 elseif r<0 then r=1 end
    g = g + lm.random(-.05,.1)
    if g>1 then g=0 elseif g<0 then g=1 end
    b = b + lm.random(-.05,.1)
    if b>1 then b=0 elseif b<0 then b=1 end
  else
    if r < 1 then r=r+.01 end
    if g < 1 then g=g+.01 end
    if b < 1 then b=b+.01 end
  end
  self.r,self.g,self.b=r,g,b

  self.animation:update(dt)
  self.attackCharge = self.attackCharge + dt
 
  --burnUp
  if GG then
    local b= (.1+GG.b)-(GG.r+GG.g)*.5
    if GG.b > .5 then
      b = b + GG.b
    end
    if GG.b > .7 then
      b = b + 10
    end
    self:burnUp(b)
  end
  
  self.speed = self.sx 
  self.hp=lume.clamp(self.hp,0,self.hpMax)
  if self.hp == self.hpMax then
    self:lvlup()
  elseif self.hp < 60 then
    self:lvldown()
  end
end

function Pink:draw()
  local r,g,b=self.r,self.g,self.b
  lg.setColor(r,g,b)
  local x,y=self.x,self.y
  local sx,sy=self.sx,self.sy
  local w,h=self.w,self.h
  local offX,offY=w*.5,h-13
  self.animation:draw(x, y, 0, sx, sy, offX,offY)
end

return Pink
