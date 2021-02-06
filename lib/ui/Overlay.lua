local copy = require "lib.copy"
local push = require "lib.push"

local Text = require "lib.ui.Text"

local gr = love.graphics

-- get text for overlay
local function init(self,title, subtitle, bckg)
    local H = push:getHeight()
    self.title = Text:init(title, {size = 64, y = H * .4})
    self.subtitle = Text:init(subtitle, {size = 42, y = H * .5})
    self.bckg = bckg or { 0, 0, 0, 0 }
    return copy(self)
end

local function draw(self)
    local W, H = push:getDimensions()
    gr.setColor(self.bckg)
    gr.rectangle("fill", 0, 0, W, H)
    self.title:draw()
    self.subtitle:draw()
end

return { init = init, draw = draw}