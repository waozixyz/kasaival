require 'class'

local lg=love.graphics
local lm=love.math
local plant=table.insert

local Sky = require 'lib/Sky'
local Tree = require 'lib/Tree'
local Ground = require 'lib/Ground'

local Gaia = class(function(self)
  self.label='gaia'
  self.color={.2,.4,.3}
  self.elapsed=0
  local G=Ground()
  self.Sky=Sky()
  self.Ground=G 
  self.mao={G}
end)

function addTree(G,boost)  
  local x=lm.random(G.x+800,G.x+G.w)
  local y=lm.random(G.y,G.y+G.h)
  
  local img=lm.random(1,17)
  return Tree(img,x,y,boost or 0)
end

function Gaia:load()
  for i=1,74 do
    local b=lm.random(0,200)
    plant(self.mao,addTree(self.Ground,b))
  end
end

function Gaia:update(dt)
  local G=self.Ground
  
  self.Sky:update(dt,G)
  self.elapsed = self.elapsed + dt
  if self.elapsed > 1 then
    plant(self.mao,addTree(G))
    self.elapsed = 0
  end 
end

function Gaia:draw(eye)
  self.Sky:draw(eye)
  lg.print(#self.mao,30,20)
end

return Gaia