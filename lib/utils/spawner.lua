local push = require "lib.push"
local lyra = require "lib.lyra"

local ma = love.math


return function(start_x, start_y)
    start_x = start_x or  0
    start_y = start_y or 0
    local H = push:getHeight()

    local y = ma.random(0, H - lyra.gh)
    local scale = (y + lyra.gh) / H

    local W = lyra:getWidth()
    local x = ma.random(lyra.startx + start_x, W + lyra.startx)
    local vir_x = x / scale

    local rat_x = x / vir_x
    y =  lyra.gh + (y * rat_x)+start_y

    return { x = x, y = y, scale = scale }
end

