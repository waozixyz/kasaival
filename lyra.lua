local Menu = require 'lib/Menu'
local lyra = {}

local lg=love.graphics
local miu = 'miu'
local rand=love.math.random

function three(min, max,sf)
  return {rand(min,max)*sf,rand(min,max)*sf,rand(min,max)*sf}
end

function invThree(t)
  return {1-t[1],1-t[2],1-t[3] }
end

function lyra:load(x)
  --self.backgroundColor = {.7,.3,.4} 
  self.bckgColor = three(0,4,.1)

  self.apps = {
    lg.newImage('icon.png'), 
  }

  self.ao = lg.newImage('alpega.png')
  Menu:load(x)
end

function lyra:update(dt)
  local W,H = lg.getDimensions()
  local sf=.9
  Menu:update(dt,self.miu, W*sf, H*sf)
  self.x = W*sf + W*.01
  self.w = W - W*sf - W*.02
end

function drawCalc(img, x, w, offy)
  local W,H = lg.getDimensions()
  local scale=w / img:getWidth() 
  local h=img:getHeight() * scale
  local offsetY = offy or 0
  local y=H*.98 - h - offsetY
 -- if opt = '*' then
   return img, x , y, 0, scale
 --  return x, y, w, h, scale
--  end
end

function lyra:draw()
  local W,H = lg.getDimensions()
  lg.setColor(self.bckgColor)
  lg.rectangle('fill', 0,0,W,H)
  Menu:draw()
  lg.setColor(invThree(self.bckgColor))
  for i,v in ipairs(self.apps) do
    lg.draw(drawCalc(v, self.x, self.w, i*self.w))
  end
  lg.draw(drawCalc(self.ao, self.x, self.w))
end

return lyra
