local push = require "lib.push"
local lyra = require "lib.lyra"

local ma = love.math


return function(start_x, start_y)
    start_x = start_x or  0
    start_y = start_y or 0
    local H = push:getHeight()
    local y = ma.random(H - lyra.ground.height, H) + start_y

    local W = lyra.ground.width
    local x = ma.random(lyra.startx + start_x, W + lyra.startx)

    return { x = x, y = y}
end

