require 'class'

local state=require 'state'
local splashy=require 'lib/splashy'
local Menu=require 'lib/Menu'
local lg=love.graphics

local W=class(function(self)
  local aruga=lg.newImage('ao.png')
  splashy.addSplash(aruga,2,1,0,0,.5)
  splasht.onComplete(function() state.stage=Menu())
end)

function W:update(dt)
  splashy.update(dt)
end

function W:draw()
  splashy.draw()
end

return W