local lg=love.graphics

local SpriteSheet = require 'lib/SpriteSheet'

local Player={}
Player.__index=Player

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

function Player:update(dt)
  self.animation:update(dt)
end

function Player:draw()
  local s=self
  local x,y,sx,sy=s.x,s.y,s.sx,s.sy
  local w,h=s.w,s.h
  lg.setColor(1,.9,1,.95)
  s.animation:draw(x, y, 0, sx, sy, w*.5, h -20 * sx)
end

return Player
