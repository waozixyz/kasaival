require 'class'

local SpriteSheet = require 'lib/SpriteSheet'

local lg=love.graphics
local lm=love.math

local Blob=class(function(self, img, w, h, x, y, sx, sy)
  local W,H = lg.getDimensions()
  self.img = img or 'assets/blob.png'
  self.x = x or 30
  self.y = y or 300
  self.w = 64
  self.h = 64 
  self.sx = sx or .5
  self.sy = sy or .5
  self.atk = 0.1
  self.maxSpeed = 4
  self.closerFaster = 1
  self.hp = 100
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
  for col=1,2 do
    a:addFrame(col, 1)
  end
  a:setDelay(0.08)
  self.animation=a

end)

function Blob:getColor()
  local r = lm.random(0, 20) / 100
  local g = lm.random(30, 40 ) / 100
  local b = lm.random(50, 80) / 100
  return r, g, b
end


function Blob:attack(obj, collision)
  if collision then
    obj.hp = obj.hp - self.atk
    self.xp = self.xp + 1
  end
end

function Blob:getHitbox()
  local x, y, width, height = self.x, self.y, self.width, self.height

  return {x + width * 0.5, x - width * 0.5, y - height * 0.5, y + height * 0.5}
end

function move(x, y)
  return x+lm.random(-1,1), y+lm.random(-1, 1) 
end

function followObj(x1, x2, speed)
  if x1 < x2 then
	   return speed
  elseif x1 > x2 then
	   return -speed
	 else
    return 0
  end
end

function Blob:follow(obj, stageWidth)
	 local dx, dy = 0, 0
  -- rotating
	 local sp_r = lm.random(-13, 42) * 0.01 
	 -- speed
  local sp_c = stageWidth / (self.x - obj.x + 1)
  if sp_c < 0 then sp_c =  sp_c * -1 end
	 if sp_c > self.maxSpeed then sp_c = self.maxSpeed end
	
  local speed = (sp_r + sp_c) * 0.5
	  
  if self.level == 0 then
	   dx = followObj(self.x, obj.x, speed)
  elseif self.level == 1 then
    if self.hp > 50 then
      dx = followObj(self.x, obj.x, speed)
    else
      dx = followObj(self.x, self.base.x, speed)
    end   end

  local joker = lm.random(0.4, -0.4)
  if self.y < (obj.y +obj.h) then	    dy = speed * joker
 	elseif self.y > obj.y then
    dy = -speed * joker
  end
 
  self.x = self.x + dx
	 self.y = self.y + dy
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
  if self.hp <= 0 then
    self.deaths = self.deaths + 1
    self.alive = false
  end
  self.sx = self.hp / 100
  self.sy = self.sx

  if self.x < base.x + base.w and self.hp < self.hpMax then
    self.hp = self.hp + 1
  end
  self.hp = self.hp + 0.02
end

function Blob:draw()
  self.animation:draw(self.x, self.y, self.r, self.sx, self.sy, self.w*.5, self.h*5)
end

return Blob

