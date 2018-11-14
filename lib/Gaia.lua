require 'class'

local lg=love.graphics
local random=love.math.random
local plant=table.insert


local Seed = require 'lib/Seed'
local Tree = require 'lib/Tree'

local Gaia = class(function(self)
  self.x = -2000
  self.y = 200
  self.width = 4000
  self.height = 400
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
  plant(self.mao, Seed())
end

function Gaia:update(dt)
  self.elapsed = self.elapsed + dt
  if self.elapsed > 1 then
    -- self:addTrees(1, 0)
    self.elapsed = 0
  end 
end

function Gaia:draw()
  lg.setColor(self.color)
  lg.rectangle('fill', self.x, self.y, self.width, self.height)
end

return Gaia