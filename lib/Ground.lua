
local grass = require('lib/grass')


local Ground = {  
  x = -2000,
  y = 200,
  width = 4000,
  height = 400,
  color = {0.2, 0.4, 0.3}
}

function Ground:load()
 
end

function Ground:update(dt)
  
  
end

function Ground:draw(phi)
  love.graphics.setColor(self.color)
  love.graphics.rectangle('fill', self.x * phi, self.y * phi, self.width * phi, self.height * phi)
  
end
return Ground