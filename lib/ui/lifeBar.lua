local lyra = require "lib.lyra"
local font = require "lib.ui.font"

local gr = love.graphics

return function()
    local w, h = 300, 48
    local x, y = 100, 170

    gr.setColor(0, 0, 0)
    gr.rectangle("fill", x, y, w, h)
    gr.setColor(.5, 0, .2)
    local nw = lyra.player.HP / lyra.player.maxHP * w
    gr.rectangle("fill", x, y, nw, h)
    gr.setColor(1, .8, .9)
    gr.setFont(font())
    gr.printf(math.floor(lyra.player.HP * .01) .. "/" .. math.floor(lyra.player.maxHP * .01) .. " HP", x, y, w, "center")
end
