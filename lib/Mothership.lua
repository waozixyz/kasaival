


local Mothership = {  
  path = 'assets/ground/57.jpg',
  x = 600,
  y = 40,
  width = 200,
  height = 500,
  color = {0.7, 0.4, 0.1}
}

function Mothership:load()
  self.image = love.graphics.newImage(self.path)
end

function Mothership:update(dt)


end

function Mothership:draw(phi)

  
  love.graphics.setColor(self.color)
  love.graphics.draw(self.image, self.x * phi, self.y * phi)
end
return Mothership