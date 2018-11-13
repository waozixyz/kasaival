require 'class'

local lg=love.graphics
local random=love.math.random

local Grass = require 'lib/Grass'
local Tree = require 'lib/Tree'

local Gaia = class(function(self)
  self.x = -2000
  self.y = 200
  self.width = 4000
  self.height = 400
  self.color = {0.2, 0.4, 0.3}
  self.mao = {}
end)

function Gaia:addTree(...)
 table.insert(self.mao, Tree(...))
end

function rC(i,j)
  return random(i,j) / 255
end

function genColor(r1, r2, g1, g2, b1, b2)
  return {rC(r1,r2), rC(g1,g2), rC(b1,b2)}
end

function Gaia:addForest(noOfTrees, startX, endX, startY, startX)
  for i = 1, noOfTrees do
    local x = random(self.x, self.width)
    local y = random(self.y, self.height)
    local scale = y / self.height
    local growStage = random(1, 20)
	   local branchColor = genColor(120,170,10,60,10,80)
    local leafColor = genColor(0,60,120,200,0,60)
	   local growRate = random(1, 3 )  
    local branchLimit = random(20,120)
    local spread = random(10, 20)

    self:addTree(x, y, scale, growStage, growRate, branchColor, leafColor, branchLimit, spread)
  end
end

function Gaia:load()
  self:addForest(20)
end


function Gaia:draw()
  lg.setColor(self.color)
  lg.rectangle('fill', self.x, self.y, self.width, self.height)
end

return Gaia