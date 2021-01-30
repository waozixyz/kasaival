local push = require "lib.push"
local lyra = require "lib.lyra"

local ma = love.math


return function(x, y)
    local H = push:getHeight()

    y = y or ma.random(0, H - lyra.gh)
    local scale = (y + lyra.gh) / H

    local W = lyra.gw
    x = x or ma.random(lyra.startx, W + lyra.startx)

    local vir_x = x / scale

    local rat_x = x / vir_x
    y =  lyra.gh + (y * rat_x)

    return { x = x, y = y, scale = scale }
end

