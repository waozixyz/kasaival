require 'class'

local lg=love.graphics
local lm=love.math
local plant=table.insert

local Sky = require 'lib/Sky'
local Tree = require 'lib/Tree'
local Ground = require 'lib/Ground'

local Gaia = class(function(self)
  self.label='gaia'
  self.color={0.2, 0.4, 0.3}
  self.mao={}
  self.elapsed=0
end)

function addTree(G)  
  local x=lm.random(G.x,G.x+G.w)
  local y=lm.random(G.y,G.y+G.h)
  local boost=lm.random(0,100)
  local img=lm.random(1,16)
  return Tree(img,x,y,boost)
end

function Gaia:load()
  local G=Ground()
  plant(self.mao, G)

  for i=1,34 do
    plant(self.mao,addTree(G))
  end
  self.Sky=Sky()
  self.Ground=G 
end

function Gaia:update(dt)
  self.Sky:update(dt,self.Ground)
  self.elapsed = self.elapsed + dt
  if self.elapsed > 1 then
    -- self:addTrees(1, 0)
    self.elapsed = 0
  end 
end

function Gaia:draw(eye)
  self.Sky:draw(eye)
end

return Gaia