local state = require "state"
local font = require "ui.font"

local gfx = love.graphics

return function(y, v, maxV, txt, color, showMax)
    local w, h = 100, 15
    local x, y = 20, y or 90

    gfx.setColor(0, 0, 0)
    gfx.rectangle("fill", x, y, w, h)
    gfx.setColor(color or {.5, 0, .2})
    local nw = v / maxV * w
    gfx.rectangle("fill", x, y, nw, h)
    gfx.setColor(1, .8, .9)
    gfx.setFont(font())
    local text = math.floor(v) 
    if showMax then
        text = text .. "/" .. math.floor(maxV)
    end
    text = text .. " " .. txt
    gfx.printf(text, x, y, w, "center")
end
