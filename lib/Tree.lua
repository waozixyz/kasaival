require 'class'

local lg=love.graphics
local lm=love.math

local Tree = class(function(self,img,x,y,boost)
  local W,H = lg.getDimensions()
  self.burn = false
  self.x = x or 40
  self.y = y or H - 20
  self.hp=hp or 100
  self.scale=scale or 0
  self.size=0
  local t=1
  if type(img) == 'number' then
    t=img
  end
  self.img=lg.newImage('assets/ueki/' .. t .. '.png')
  self.boost=boost or 0
end)

function Tree:grow(dt) 
  self.size=self.size+dt
end

function Tree:load()
  self:grow(self.boost)
end

function Tree:update(dt)
  self:grow(dt)
end

function Tree:draw()
  lg.setColor(1,1,1)
  local w,h=self.img:getDimensions()
  -- scale is managed by miu position
  local scale=self.scale+self.size/400
  lg.draw(self.img,self.x,self.y,0,scale,scale, w*.5,h)
end

return Tree
