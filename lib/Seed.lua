require 'class'
local Color = require 'lib/Color'

local lg=love.graphics
local random=love.math.random
local deg_to_rad=math.pi/180

function rThree(a1,a2,b1,b2,c1,c3,sf)
   local s = sf or 1
  return random(a1,a2)*.1,random(b1,b2)*.1,random(c1,c2)*.1
end

local Line = class(function(self, color, startX, startY, endX, endY, lineWidth)
  self.color = color or rThree(1,3,1,3,2,6,.1)
  self.startX = startX or 0
  self.startY = startY or 0
  self.endX = endX or 32
  self.endY = endY or 64
  self.lineWidth = lineWidth or 16
end)

function Line:draw(parentX, parentY)
  lg.setLineStyle('smooth')
  lg.setLineWidth(self.lineWidth)
  local x1 = self.startX + parentX
  local y1 = self.startY + parentY
  local x2 = self.endX + parentX
  local y2 = self.endY + parentY
  lg.line(x1, y1, x2, y2)
end

local Shape = class(function(self, color, shape, style, x, y, w, h)
  self.color = color or rThree(1,3,1,3,2,6,.1)
  self.shape = shape or 'rectangle'
  self.style = style or 'fill'
  self.x = x or 0
  self.y = y or 0
  self.w = w or 32
  self.h = h or 64
end)

function Shape:draw(parentX, parentY)
  local x,y=self.x+parentX,self.y+parentY
  lg[self.shape]('fill', x, y, self.w, self.h)
end

local Seed = class(function(self, x, y, dna,  hp, xp, level)
  local W,H = lg.getDimensions()
  self.x = x or W*.6
  self.y = y or H*.6
  self.growRate=2  
  self.color=rThree(2,4,2,4,2,4,.1)
  self.hp = hp or 100
  self.xp = xp or 0
  self.level = level or 0

  self.label='seed'
  self.elapsed = 0

  self.lines = {}
  self.shapes = {}
end)

function Seed:grow()
  local lvl = self.level
  if lvl == 0 then -- sprouting
    local color = rThree(2,3,3,5,3,4,.1)
    local startX = 0
    local startY = 0
  
    local lineWidth = 1
    if #self.lines > 0 then
      local l = self.lines[#self.lines]
      startX = startX + l.startY
      startY = startY + l.endY
      lineWidth = l.lineWidth *.5
    end
    local endX =  startX + 0
    local endY = startY - 5
    table.insert(self.lines, Line(color, startX, startY, endX, endY, lineWidth))
  end
end



function Seed:update(dt)
  self.elapsed = self.elapsed + dt
  if self.elapsed > self.growRate then
    self:grow()
    self.elapsed = 0
  end
end

function Seed:draw()
  for i,p in ipairs({self.lines, self.shapes}) do
    for i,v in ipairs(p) do
      local color = Color(self.color) + Color(v.color)
      lg.setColor(color.r, color.g, color.b) 
      v:draw(self.color, self.x, self.y)
    end
  end
end

return Seed
