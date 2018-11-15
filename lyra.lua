local Menu = require '/lib/Menu'

local lyra = {}

local lg=love.graphics
local miu = 'miu'

function lyra:load()
  self.backgroundColor = {.7,.3,.4}
  Menu:load(miu)
end

function lyra:update(dt)
  local sf=.9
  Menu:update(dt,self.miu, lg.getWidth()*sf, lg.getHeight()*sf)
end


function lyra:draw()
  lg.setColor(self.backgroundColor)
  lg.rectangle('fill', 0,0,lg.getDimensions())
  Menu:draw()
end

return lyra
