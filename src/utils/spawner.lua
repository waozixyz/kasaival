local push = require "utils.push"
local state = require "state"

local ma = love.math


return function(startX, startY)
    startX = startX or  0
    startY = startY or 0
    local H = push:getHeight()
    local y = ma.random(H - state.gh, H) + startY

    local W = state.gw
    local x = ma.random(0 + startX, W)

    return { x = x, y = y}
end

