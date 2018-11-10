local lg=love.graphics

local SpriteSheet = require 'lib/SpriteSheet'

local Player={}
Player.__index=Player

function Player.new(img, w, h, x, y, scale)
  local obj={img=img, w=w, h=h, x=x, y=y, scale=scale}
  return setmetatable(obj, Player)
end

function Player:load()
  local s=self
  
  -- add animations
  local S=SpriteSheet.new(s.img, s.w, s.h)
  s.selected=1
  
  
  local a=S:createAnimation()
  for col=1,20 do
    a:addFrame(col, 1)
  end
  
  a:setDelay(0.08)
  s.a = a
end

function Player:update(dt)
  local s=self
  s.a:update(dt)
end

function Player:draw()
  local s=self
  s.a:draw(s.w, 0)
  
  
  local a=s.a[s.selected]
  if a then
    love.graphics.print(string.format("Animation: %d Delay: %f", s.selected, a:getDelay()), 100, 100)
  end

end

return Player
