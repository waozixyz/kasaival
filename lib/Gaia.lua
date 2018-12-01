require 'class'

local lg=love.graphics
local lm=love.math
local plant=table.insert

local Sky = require 'lib/Sky'
local Seed = require 'lib/Seed'
local Tree = require 'lib/Tree'
local Ground = require 'lib/Ground'

local Gaia = class(function(self)
  self.label='gaia'
  self.color = {0.2, 0.4, 0.3}
  self.mao = {}
  self.elapsed = 0
end)

function Gaia:addTrees(noOfTrees, growStage)
  for i = 1, noOfTrees do
    local x = lm.random(self.x, self.width)
    local y = lm.random(self.y, self.height)
    local scale = (y / self.height)*.5
	   local branchColor =  {
      lm.random(3, 6)*.1,
      lm.random(3, 6)*.1,
      lm.random(3, 6)*.1
    }
    local leafColor = {
      lm.random(3, 6)*.1,
      lm.random(3, 6)*.1,
      lm.random(3, 6)*.1
    }
    growStage=growStage or lm.random(0,10)
	   local growRate = lm.random(1, 3)
    local branchLimit= lm.random(20,120)
    local branchWidth = lm.random(1,4)
    local spread = lm.random(0, 10)

    plant(self.mao, Tree(x, y, scale, growStage, growRate, branchColor, leafColor, branchLimit, branchWidth, spread))
  end
end

function Gaia:load()
  -- self:addTrees(34)
  local G=Ground()
  plant(self.mao, G)
 -- plant(self.mao, Seed())
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