require 'class'

local lg=love.graphics
local lm=love.math

local SpriteSheet=require 'lib/SpriteSheet'

local Flame=class(function(self)
  local W,H = lg.getDimensions()
  self.img = 'assets/chi.png'
 
  -- add animation
  local S=SpriteSheet(self.img,96,192)
  local a=S:createAnimation()
  for row=1,8 do
    local limit=22
    if row==8 then limit=19 end
    for col=1,limit do
      a:addFrame(col, row)
    end
  end
  a:setDelay(0.08)
  self.anime=a
end)

function Flame:update(dt)
  self.anime:update(dt)
end

function Flame:draw()
  lg.setColor(1,1,1)
  self.anime:draw()

lg.setColor(.6,.4,.1) 
  lg.print('hi u sexy',59,50)
end

return Flame
