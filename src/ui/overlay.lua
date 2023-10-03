local copy = require "utils.copy"
local push = require "utils.push"

local Text = require "ui.text"

local gfx = love.graphics

-- get text for overlay
local function init(self,title, subtitle, bckg)
    local H = push:getHeight()
    self.title = Text:init(title, {size = 21, y = H * .4})
    self.subtitle = Text:init(subtitle, {size = 10, y = H * .5})
    self.bckg = bckg or { 0, 0, 0, 0 }
    self.hint = Text:init("Hint: ", {size = 32, y = H * .55})
    return copy(self)
end

local function draw(self, hint)
    local W, H = push:getDimensions()
    gfx.setColor(self.bckg)
    gfx.rectangle("fill", 0, 0, W, H)
    self.title:draw()
    self.subtitle:draw()
    if hint then
        self.hint:update(hint)
        self.hint:draw()
    end
end

return { init = init, draw = draw}