

local Ocean = {  
  x = -2000,
  y = 200,
  width = 200,
  height = 400,
  color = {0.1, 0.05, 0.4},
  level = 1,
  xp = 0,
  hitBox = {},
}
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

function Ocean:draw(phi)
  love.graphics.setColor(self.color)
  love.graphics.rectangle('fill', self.x * phi, self.y * phi, self.width * phi, self.height * phi)
  
end
return Ocean