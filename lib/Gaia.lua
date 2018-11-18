require 'class'

local lg=love.graphics
local random=love.math.random
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
    local x = random(self.x, self.width)
    local y = random(self.y, self.height)
    local scale = (y / self.height)*.5
	   local branchColor =  {
      random(3, 6)*.1,
      random(3, 6)*.1,
      random(3, 6)*.1
    }
    local leafColor = {
      random(3, 6)*.1,
      random(3, 6)*.1,
      random(3, 6)*.1
    }
    growStage = growStage or random(0,10)
	   local growRate = random(1, 3)
    local branchLimit = random(20,120)
    local branchWidth = random(1,4)
    local spread = random(0, 10)

    plant(self.mao, Tree(x, y, scale, growStage, growRate, branchColor, leafColor, branchLimit, branchWidth, spread))
  end
end

function Gaia:load()
  -- self:addTrees(34)
  self.Ground = Ground()
  plant(self.mao, self.Ground)
 -- plant(self.mao, Seed())
 -- plant(self.mao, Sky())
end
--[[--
function Gaia:update(dt)
  self.elapsed = self.elapsed + dt
  if self.elapsed > 1 then
    -- self:addTrees(1, 0)
    self.elapsed = 0
  end 
end]]--

return Gaia