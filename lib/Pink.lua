require 'class'
local SpriteSheet = require 'lib/SpriteSheet'
local lg=love.graphics
local Shuriken = require('lib/Shuriken')

local Pink=class(function(self, img, w, h, x, y, sx, sy)
  local W,H = lg.getDimensions()

  self.img = img or 'assets/player.png'
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
  self.walkSpeed = 3
  self.atk = 1
  self.def = 0
  self.hitBox = {}
  self.shurikens = {}
  self.attackSpeed = 5
  self.attackCharge = 100
  self.portal = {
    x = 2000
  }
  -- add animation
  local S=SpriteSheet(self.img, self.w, self.h)
  local a=S:createAnimation()
  for col=1,20 do
    a:addFrame(col, 1)
  end
  a:setDelay(0.08)
  self.animation=a
end)

function Pink:regulateSpeed(dx, dy, speed)
  if not speed then speed = self.walkSpeed end 
  if math.abs(dx) + math.abs(dy) ~= 0 then
    speed = speed / (math.abs(dx) + math.abs(dy))
  end 
  return dx * speed, dy * speed
end

function Pink:move(dx,dy)
  local W,H = lg.getDimensions()
 
  if (self.x < self.portal.x or dx < 0) then
    self.x = self.x + dx
  end

  if (self.y > H*.5 + 3 or dy > 0) and (self.y < H or dy < 0) then
    self.y = self.y + dy
  end
end

function Pink:attack(dx, dy)
  if self.attackCharge > 99 then
    dx, dy = self:regulateSpeed(dx, dy, self.attackSpeed)

    table.insert(self.shurikens, Shuriken(self.x, self.y, dx, dy))
    
    local atkSpeed = self.attackSpeed
    local x = self.x - self.w * .2
    local y = self.y - self.h * .25
    x = x + (dx / atkSpeed) * (self.w * .1)
    y = y + (dy /atkSpeed) * (self.h  * .1)
 
    self.attackCharge = 0
  end
end


function Pink:getHitbox()
  local t = {}
  t[1] = self.x + self.w * 0.5
  t[2] = self.x - self.w * 0.5
  t[3] = self.h - 20
  t[4] = self.h
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


function Pink:update(dt)
  self.animation:update(dt)
  self.attackCharge = self.attackCharge + 3*dt
  for i,s in ipairs(self.shurikens) do
    s:update(dt)
  end
  self:burnUp(.05)

    
  self.speed = self.sx 
end

function Pink:draw()
  for i,s in ipairs(self.shurikens) do
    s:draw()
  end
  lg.setColor(1,.9,1,.95)
  self.animation:draw(self.x, self.y, 0, self.sx, self.sy, self.w*.5, self.h-0)
end

return Pink