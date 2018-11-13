require 'class'

local lg=love.graphics
local random=love.math.random

-- x position, y position
-- maximum branches
-- starting position to grow from
-- propability for diverging branches
-- leaf color, branch color
-- scale size of tree
-- rate of growth
local Tree = class(function(self, x, y, scale, growStage, growRate, branchColor, leafColor, branchLimit, branchWidth, spread)
  local W,H = lg.getDimensions()
  self.leafIndex = 1
  self.elapsed = 0
  self.deg_to_rad = math.pi / 180
  self.burn = false
  self.leaves = {}
  self.angle = { -90 }
  self.depth = { 1 }
  self.lastIndex = { 1 }
  self.leftX = 9999999
  self.rightX = -999999
  self.x = x or 40
  self.y = y or H - 20
  self.spread = spread or 20
  self.scale = scale or .5
  self.growStage = growStage or 0
  self.growRate = growRate or .2
 

  self.branches = {
    { self.x, self.y, self.x, self.y - 30 }
  }
  self.branchLimit = branchLimit or 10
  self.drawLeaves = drawLeaves or true
  self.leavesColor = {
    leafColor or {.2,.6,.1}
  }
  self.branchColor = branchColor or {.7,.3,.1}
 self.maxBranchWidth = 10 * self.scale
  self.branchWidth = {
    branchWidth or random(4, self.maxBranchWidth)
  }
end)


function Tree:genBranch(index, depth, angle)
  local length = #self.branches

  local x1 = self.branches[index][3]
  local y1 = self.branches[index][4]

  angle = self.angle[index] + angle
  local x2 = x1 + (math.cos(angle * self.deg_to_rad) * depth * self.branchWidth[length] * 4 * self.scale);
  local y2 = y1 + (math.sin(angle * self.deg_to_rad) * depth * self.branchWidth[length] * 4 * self.scale);


  if x2 < self.leftX then
    self.leftX = x2
  end

  if x2 > self.rightX then
    self.rightX = x2
  end

  local line = {x1, y1, x2, y2}
  table.insert(self.branches, line)
  -- print(x1, x2, y1, y2, index, lastIndex)
  table.insert(self.angle, angle)
  table.insert(self.depth, depth)
  table.insert(self.lastIndex, index + 1)
  table.insert(self.branchWidth, (self.branchWidth[length] * 0.9))
  self:genTempLeaves(x2,y2)
end

function Tree:genTempLeaves(x1, y1)
  local size = (3 + self.branchWidth[#self.branches]) * self.scale
  local circle = { x1, y1, size }
  table.insert(self.leavesColor, self.leavesColor[1])
  table.insert(self.leaves, circle)

  local pos = random(1, 4)
  if pos == 1 then
    circle = { x1*0.99, y1*1.01, size }
  elseif pos == 2 then
    circle = { x1*1.01, y1*0.99, size }
  elseif pos == 3 then
    circle = { x1*0.99, y1*0.99, size }
  elseif pos == 4 then
    circle = { x1*1.01, y1*1.01, size }
  end

  table.insert(self.leavesColor, self.leavesColor[1])
  table.insert(self.leaves, circle)
end

function Tree:removeLeaves()
  if self.leavesColor[self.leafIndex] ~= nil then
    local lr = self.leavesColor[self.leafIndex][1]
    local lg = self.leavesColor[self.leafIndex][2]
    local lb = self.leavesColor[self.leafIndex][3]
    local lr = lr * 0.1
    local lg = lg * 0.1
    local lb = lb * 0.1
    if lr < 40 and lg < 40 and lb < 40 then
      table.remove(self.leaves, self.leafIndex)
    else
      self.leavesColor[self.leafIndex] = {lr, lg, lb}
    end
  end
  if self.leafIndex > #self.leavesColor then
    self.leafIndex = 0
  else
    self.leafIndex = self.leafIndex + 1
  end
end


function Tree:grow()
  local branches = self.branches
  local length = #self.branches
  -- if spread is more than the random number generate two branches, else generate 1
  --for i = 1, length do
    --if self.spread > love.math.random(0, 100) then
  if length < self.branchLimit then
  --  for i = 1, self.levels[length] do
    self:removeLeaves()
    self:removeLeaves()
    self:removeLeaves()
    self:removeLeaves()
    self:removeLeaves()
    self:removeLeaves()

    if random(0, 80) > self.spread then
      self:genBranch(self.lastIndex[length], self.depth[length] + 1, -20)
      self:genBranch(self.lastIndex[length], self.depth[length] + 1, 20)
    else
      self:genBranch(self.lastIndex[length], self.depth[length], 0)
    end
  end
end

function Tree:load()
  for i=0, self.growStage do
    self:grow()
  end
end

function Tree:update(dt)
  self.elapsed = self.elapsed + self.growRate * dt
  if self.elapsed > 10 then
    self:grow()
		  self.elapsed  = 0
	end
end

function Tree:draw()
  local W = lg.getWidth()
  local leftLimit = self.rightX - self.x
  local rightLimit = self.leftX - self.x

  -- do not draw trees out of bound
  if rightLimit < W and leftLimit > 0 then
    for i,b in ipairs(self.branches) do
      local x = b[1]
      lg.setColor(self.branchColor)
      lg.setLineStyle('smooth')
      lg.setLineWidth(self.branchWidth[i])
      lg.line(x + self.x, b[2], b[3] + self.x,  b[4])
    end

    if #self.leaves ~= nil then
      for i = 1, #self.leaves do
        local x = self.leaves[i][1]
        if self.leavesColor[i] ~= nil then
          lg.setColor(self.leavesColor[i])
        else
          lg.setColor(self.leavesColor[1])
        end
        lg.rectangle( "fill", x + self.x, self.leaves[i][2], self.leaves[i][3], self.leaves[i][3] )
      end
    end
  end
end

return Tree
