local push = require "utils.push"
local state = require "state"

local ma = love.math


return function(start_x, start_y)
    start_x = start_x or  0
    start_y = start_y or 0
    local H = push:getHeight()
    local y = ma.random(H - state.gh, H) + start_y

    local W = state.gw
    local x = ma.random(state.startx + start_x, W + state.startx)

    return { x = x, y = y}
end

