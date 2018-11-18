local Rain = {
  drops = {}

}

function Rain:load()
  for i = 1, 100 do
    local drop = {}
    drop.x = love.math.random(-100, 900)
    drop.y = love.math.random(-100, 700)
    drop.width = love.math.random(2, 4)
    drop.height = love.math.random(7, 13)
    table.insert(self.drops, drop)
  end
end

function Rain:update(dt, stage)
  local wind, dir = 1, -1
  for i,drop in ipairs(self.drops) do
   drop.x = drop.x + wind * dir
   drop.y = drop.y + 20 * stage.gravity

   if drop.y > 900 then
     drop.y = -100
     drop.x = love.math.random(-100, 900)
   end
 end 
end

function Rain:draw()
  love.graphics.setColor(0.1, 0.1, 0.5)
  for i,drop in ipairs(self.drops) do
    love.graphics.rectangle('fill', drop.x, drop.y, drop.width, drop.height)
  end
  

end

return Rain