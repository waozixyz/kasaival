require 'class'

local state=require 'state'
local splashy=require 'lib/splashy'
local Menu=require 'Miu/Menu'
local lg=love.graphics

local mission=function()
  state.stage=Menu()
end

local W=class(function(self)
  self.duration=.08
  local aruga=lg.newImage('ao.png')
  splashy.addSplash(aruga,self.duration,0,0,.5)
  splashy.onComplete(function() mission() end)
end)

function W:update(dt)
  splashy.update(dt)
end

function W:draw()
  splashy.draw()
end

return W
