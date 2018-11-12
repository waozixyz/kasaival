require 'class'

local lg=love.graphics

local SpriteSheet = require 'lib/SpriteSheet'

local Player=class(function(self, img, w, h, x, y, sx, sy)
  local W,H = lg.getDimensions()

  self.img = img or 'assets/player.png'
  self.w = w or 64
  self.h = h or 128
  self.x = x or W*.5
  self.y = y or H*.5
  self.sx = sx or 1
  self.sy = sy or 1
  self.hp = 100
  self.speed = 3
  self.element = 'fire'
end)

function Player.new(options)
  return setmetatable(options, Player)
end

function Player:load()
  -- add animation
  local S=SpriteSheet.new(self.img, self.w, self.h)
  local a=S:createAnimation()
  for col=1,20 do
    a:addFrame(col, 1)
  end
  a:setDelay(0.08)
  self.animation=a
end

function Player:getHitbox()
  local t = {}
  t[1] = self.x + self.w * 0.5
  t[2] = self.x - self.w * 0.5
  t[3] = self.h - 20
  t[4] = self.h
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


function Player:update(dt)
  if self.hp > 0 then
     self.alive = true
  end 
  if self.alive then
    if self.hp <= 0 then
     self.alive = false
    end 
    self.animation:update(dt)
    self:burnUp(.01)
  
    self.sx = self.hp / 100
    self.sy = self.sx
    
    self.speed = self.sx 
  end
end

function Player:draw()
  local s=self
  local x,y,sx,sy=s.x,s.y,s.sx,s.sy
  local w,h=s.w,s.h
  lg.setColor(1,.9,1,.95)
  s.animation:draw(x, y, 0, sx, sy, w*.5, h-0)
end

return Player
