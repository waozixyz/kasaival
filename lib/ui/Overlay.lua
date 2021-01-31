local copy = require "lib.copy"
local push = require "lib.push"

local Text = require "lib.ui.Text"

local gr = love.graphics

-- get text for overlay
local function getText(title, subtitle, bckg)
    local H = push:getHeight()
    local rtn = {}
    rtn.title = Text:init(title, {size = 64, y = H * .4})
    rtn.subtitle = Text:init(subtitle, {size = 42, y = H * .5})
    rtn.bckg = bckg or { 0, 0, 0, 0 }
    return rtn
end

local function draw(item)
    local W, H = push:getDimensions()
    gr.setColor(item.bckg)
    gr.rectangle("fill", 0, 0, W, H)
    item.title:draw()
    item.subtitle:draw()
end

return { getText = getText, draw = draw}