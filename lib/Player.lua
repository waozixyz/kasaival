require 'class'

local SpriteSheet = require 'lib/SpriteSheet'

local gr=love.graphics
local ma=love.math

local Shuriken = require 'lib/Shuriken'
local Flame=require 'lib/Flame'

local defaultControls = {
  [1] = {
    scancodes = {'up', 'w'}, 
    dy = -1,
  },
  [2] = { 
    scancodes = {'right', 'd'},
    dx = 1,
  },
  [3] = { 
    scancodes = {'down', 's'},
    dy = 1,
  },
  [4] = { 
    scancodes = {'left', 'a'},
    dx = -1,
  }
}

function scancodeDown(options)
  for i, option in ipairs(options) do
    if love.keyboard.isScancodeDown(option) then 
      return true
    end
  end
end

function keyMove(c, speed)
  local dx, dy = 0, 0
  for s = 1,#c do
    if scancodeDown(c[s].scancodes) then 
      if c[s].dx ~= nil then dx = dx + c[s].dx * speed end
      if c[s].dy ~= nil then dy = dy + c[s].dy * speed end
    end
  end
  return dx, dy
end

function touchMove(id, x, y, speed)
  local tx, ty = love.touch.getPosition(id)

  if tx > x then 
    dx =  speed
  elseif tx < x then 
    dx= -speed
  end
  if ty > y then 
    dy  = speed
  elseif ty < y then 
    dy = -speed
  end

  return dx, dy
end


local Player=class(function(self, img, w, h, x, y, sx, sy)
  local W,H = gr.getDimensions()
  self.label = 'pink'
  self.w = w or 64
  self.h = h or 128
  self.x = x or W*.5
  self.y = y or H*.5
  self.sx = sx or 1
  self.sy = sy or 1
  self.maxSize = maxSize or 10
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
  self.r,self.g,self.b=1,1,1 
  
  self.invincible=false
  
  local s=self
  local size=self.hp/self.maxSize
  self.Flame=Flame(1, s.x,s.y,size,{s.r,s.g,s.b})
  

end)

function Player:regulateSpeed(dx, dy, speed)
  if not speed then speed = self.walkSpeed end 
  if math.abs(dx) + math.abs(dy) ~= 0 then
    speed = speed / (math.abs(dx) + math.abs(dy))
  end 
  return dx*speed, dy*speed
end

function Player:move(dx,dy)
  local W,H = gr.getDimensions()
 
  if (self.x < W or dx < 0) and (self.x > 0 or dx > 0) then
    self.x = self.x + dx
  end

  if (self.y > H*.5 + 3 or dy > 0) and (self.y < H or dy < 0) then
    self.y = self.y + dy
  end
  self.Flame.x=self.x
  self.Flame.y=self.y
end

function Player:attack(dx, dy)
  if self.attackCharge > 1 then
    dx, dy = self:regulateSpeed(dx, dy, self.attackSpeed)
    
    local atkSpeed = self.attackSpeed
    local px = self.x - self.w * .2
    local py = self.y - self.h * .25
    x=px+(dx/atkSpeed)*(self.w*.1)
    y=py+(dy/atkSpeed)*(self.h*.1)
   table.insert(self.shurikens, Shuriken(x,  y, dx, dy))
    self.attackCharge = 0
  end
end

function Player:collide(o)
  if o.element == 'plant' then
    self.hp = self.hp + .001
  elseif o.element == 'water' then
    self.hp = self.hp - .01
  end
end
function Player:getHitbox()
  local t = {}
  t[1] = self.x - self.w * .2 * self.sx
  t[2] = self.x + self.w * .2 * self.sx
  t[3] = self.y + self.h * .1
  t[4] = self.y + self.h * .3
  return t
end

function Player:burnUp(x)
  self.hp = self.hp - x
end

function Player:defend(attack)
  local defence = 0

  if self.def and  self.def > 0 then
    defence = math.log(self.def)
  end
    
  self.hp = self.hp - attack
end


function Player:update(dt, Miu)
  local F = self.Flame
  F.size=self.hp/self.maxSize
  F.x=self.x
  F.y=self.y
  F:update(dt)
  
 

  local r,g,b = self.r,self.g,self.b
  if self.invincible then  
    r = ma.random(-.05,.1)
    if r>1 then r=0 elseif r<0 then r=1 end
    g = g + ma.random(-.05,.1)
    if g>1 then g=0 elseif g<0 then g=1 end
    b = b + ma.random(-.05,.1)
    if b>1 then b=0 elseif b<0 then b=1 end
    
  else
    if r < 1 then r=r+.01 end
    if g < 1 then g=g+.01 end
    if b < 1 then b=b+.01 end
  end
  self.r,self.g,self.b=r,g,b

  
  self.attackCharge = self.attackCharge + dt
  for i,s in ipairs(self.shurikens) do
    s:update(dt)
    if s.sx <=0 or s.sy <=0 then
      table.remove(self.shurikens,i)
    end
  end
  
  self:burnUp(.1)
 
  self.speed = self.sx 


  local dx, dy = 0, 0

  dx, dy = keyMove(defaultControls, self.speed)
  local touches = love.touch.getTouches()

  for i, id in ipairs(touches) do 
    dx, dy = touchMove(id, x + w, y + h, self.speed)
  end


  self:move(dx, dy)
end

function Player:draw()
  self.Flame:draw()
  local r,g,b=self.r,self.g,self.b
  gr.setColor(r,g,b)
  
  gr.setColor(1,1,0)
  for i,s in ipairs(self.shurikens) do
    s:draw()
  end
end

return Player
