require 'class'

local lg=love.graphics
local lm=love.math

local SpriteSheet=require 'lib/SpriteSheet'

local Flame=class(function(self,styl,x,y)
  local W,H=lg.getDimensions()
  styl=styl or 1 
  self.img='assets/flame/spr_'..styl..'.png'
  self.x=x or W*.5
  self.y=y or H*.7
  self.w,self.h=96,192
  -- add animation
  local S=SpriteSheet(self.img,self.w,self.h)
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

function Flame:draw(phi)
  lg.setColor(1,1,1)
  local offX=self.w*.5
  local offY=self.h
  self.anime:draw(self.x,self.y,0,phi,phi,offX,offY)

lg.setColor(.6,.4,.1) 
  lg.print('hi u sexy',59,50)
end

return Flame