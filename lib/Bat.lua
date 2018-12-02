require 'class'

local SpriteSheet = require 'lib/SpriteSheet'

local lg=love.graphics
local lm=love.math

local Blob=class(function(self, img, w, h, x, y, sx, sy)
  self.hpsize=true
  local W,H = lg.getDimensions()
  self.img = img or 'assets/Bat.png'
  self.x = x or 30
  self.y = y or 300
  self.w = 64
  self.h = 64 
  self.sx = sx or 1
  self.sy = sy or 1
  self.atk = 0.1
  self.maxSpeed = 4
  self.closerFaster = 1
  self.hp = 100
  self.hpsize=true
  self.hpMax = 100
  self.level = 1
  self.xp = 0
  self.r = 0
  self.seed = {
    lm.random(7, 13),
    lm.random(4, 7),
  }
   -- add animation
  local S=SpriteSheet(self.img, self.w, self.h)
  local a=S:createAnimation()
  for col=1,1 do
    a:addFrame(col, 1)
  end
  a:setDelay(0.08)
  self.animation=a
  self.base={x=-2000}
end)

function Blob:getColor()
  local r = lm.random(90, 100) / 100
  local g = lm.random(60, 100) / 100
  local b = lm.random(50, 800) / 100
  return {r, g, b}
end


function Blob:attack(obj, collision)
  if collision then
    obj.hp = obj.hp - self.atk
    self.xp = self.xp + 1
  end
end

function Blob:getHitbox()
  local x, y, w, h  = self.x, self.y, self.w, self.h

  return {x + w * 0.5, x - w * 0.5, y - h * 0.5, y + h * 0.5}
end

function move(x, y)
  return x+lm.random(-1,1), y+lm.random(-1, 1) 
end

function followObj(o,a,e,u,speed)
  if o < e then
	   return speed
  elseif a > u then
	   return -speed
	 else
    return 0
  end
end

function Blob:follow(dt,obj, stageWidth)
	 local dx, dy = 0, 0
  -- rotating
	 local sp_r = lm.random(-42, 42) * 0.01 
	 -- speed
  local sp_c = stageWidth / (self.x - obj.x + 1)
  if sp_c < 0 then sp_c =  sp_c * -1 end
	 if sp_c > self.maxSpeed then sp_c = self.maxSpeed end
	
  local speed = (sp_r + sp_c) * 5 
  local p=obj:getHitbox()
  local c=self:getHitbox()
  
  if self.level == 1 then
    if self.hp <50 then
      p[1]=self.base.x
      p[2]=p[1]
    end  
  end
  dx = followObj(c[1],c[2],p[1],p[2], speed)

  c=self.y
  p=obj.y
  
  if c<(p-sp_r) then	       
    dy = speed
 	elseif c>(p+sp_r) then
    dy = -speed
  end

  self.x=self.x+dx*dt*4
	 self.y=self.y+dy*dt*4
end

function Blob:destroy()
  self = nil
end

function Blob:updateLevel()
  local lvl = self.level
  local xp = self.xp
  local hp = self.hp
  local hpMax = self.hpMax
  local atk = self.atk

  if xp > 3 * (lvl * lvl + 1) then
    lvl = lvl + 1
    hpMax = hpMax + 2*lvl
    hp = hp + 20
    atk = atk + 1
  end
end
function Blob:update(dt, base)
  self:updateLevel()
  self.animation:update(dt)

  if self.x < self.base.x and self.hp < self.hpMax then
    self.hp = self.hp + 1
  end
  self.hp = self.hp-0.06 
end

function Blob:draw()
  lg.setColor(self:getColor())
  self.animation:draw(self.x, self.y, self.r, self.sx, self.sy, self.w*.5, self.h*.5)
end

return Blob

