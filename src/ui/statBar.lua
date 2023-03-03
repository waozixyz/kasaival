local lyra = require "lyra"
local font = require "ui.font"

local gr = love.graphics

return function(y, v, maxV, txt, color, showMax)
    local w, h = 100, 15
    local x, y = 100, y or 170

    gr.setColor(0, 0, 0)
    gr.rectangle("fill", x, y, w, h)
    gr.setColor(color or {.5, 0, .2})
    local nw = v / maxV * w
    gr.rectangle("fill", x, y, nw, h)
    gr.setColor(1, .8, .9)
    gr.setFont(font())
    local text = math.floor(v) 
    if showMax then
        text = text .. "/" .. math.floor(maxV)
    end
    text = text .. " " .. txt
    gr.printf(text, x, y, w, "center")
end
