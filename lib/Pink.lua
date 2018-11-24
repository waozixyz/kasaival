require 'class'

local SpriteSheet = require 'lib/SpriteSheet'

local lg=love.graphics
local lm=love.math

local Shuriken = require 'lib/Shuriken'
local Portal = require 'lib/Portal'

local Pink=class(function(self, img, w, h, x, y, sx, sy)
  local W,H = lg.getDimensions()
  self.label = 'pink'
  self.img = 'assets/flame.png'
  self.w = w or 64
  self.h = h or 128
  self.x = x or W*.5
  self.y = y or H*.5
  self.sx = sx or 1
  self.sy = sy or 1
  self.hp = 100
  self.hpMax = 100
  self.speed = 3
  self.element = 'fire'
  self.walkSpeed = 8
  self.atk = 1
  self.def = 0
  self.hitBox = {}
  self.shurikens = {}
  self.attackSpeed = 5
  self.attackCharge = 100
  self.Portal = Portal(2000)
  self.r,self.g,self.b=1,1,1 
  self.invinsible=false
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
end)

function Pink:regulateSpeed(dx, dy, speed)
  if not speed then speed = self.walkSpeed end 
  if math.abs(dx) + math.abs(dy) ~= 0 then
    speed = speed / (math.abs(dx) + math.abs(dy))
  end 
  return dx*speed, dy*speed
end

function Pink:move(dx,dy)
  local W,H = lg.getDimensions()
 
  if (self.x < self.Portal.x or dx < 0) then
    self.x = self.x + dx
  end

  if (self.y > H*.5 + 3 or dy > 0) and (self.y < H or dy < 0) then
    self.y = self.y + dy
  end
end

function Pink:attack(dx, dy)
  if self.attackCharge > 1 then
    dx, dy = self:regulateSpeed(dx, dy, self.attackSpeed)
    
    local atkSpeed = self.attackSpeed
    local px = self.x - self.w * .2
    local py = self.y - self.h * .25
    x = px + (dx / atkSpeed) * (self.w * .1)
    y = py + (dy /atkSpeed) * (self.h  * .1)
   table.insert(self.shurikens, Shuriken(x,  y, dx, dy))
    self.attackCharge = 0
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


function Pink:update(dt, Miu)
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
  for i,s in ipairs(self.shurikens) do
    s:update(dt)
    if s.sx <=0 or s.sy <=0 then
      table.remove(self.shurikens,i)
    end
  end
  
  do --burnUp
    local G = Miu.Gaia.Ground

    local b = (.1+G.b) - (G.r+G.g)*.5*.08
    if G.b > .5 then
      b = b + G.b
    end
    self:burnUp(b)
  end
  self.speed = self.sx 
end

function Pink:draw()
  local r,g,b=self.r,self.g,self.b
  lg.setColor(r,g,b)
  self.animation:draw(self.x, self.y, 0, self.sx, self.sy, self.w*.5, self.h-7)
  lg.setColor(1,1,0)
  for i,s in ipairs(self.shurikens) do
    s:draw()
  end
end

return Pink
