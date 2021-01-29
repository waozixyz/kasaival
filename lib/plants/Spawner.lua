local push = require "lib.push"

local ma = love.math


return function(gw, gh, x, y, pos)
    local H = push:getHeight()

    y = y or ma.random(0, H - gh)
    local scale = (y + gh) / H

    local W = gw
    x = x or ma.random(W * -0.5, W + W * -0.5)

    local vir_x = x / scale

    local rat_x = x / vir_x
    y =  gh + (y * rat_x)

    return x, y, scale
end

