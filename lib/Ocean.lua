require 'class'

local lg=love.graphics

local Ocean = class(function(self)
  self.x = -2000
  self.y = 200
  self.w = 200
  self.h = 400
  self.color = {0.1, 0.05, 0.4}
  self.level = 1
  self.xp = 0 
end)

function Ocean:attack(obj)
  if obj.element == 'fire' then
    return 23 * self.level
  else return 0 end
end
  

function Ocean:load(stage)
 
end


function Ocean:getHitbox()
  return {self.x, self.x + self.width, self.y, self.y + self.height}
end

function Ocean:update(dt, stage)

 

 
end

function Ocean:draw()
 
  lg.setColor(self.color)
  lg.rectangle('fill', self.x, self.y, self.w, self.h)
  
end
return Ocean