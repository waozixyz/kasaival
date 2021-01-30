local copy = require "lib.copy"
local push = require "lib.push"

local Font = require "lib.ui.Font"

local gr = love.graphics

local function init(self, text, size, y, c)
    local W, H = push:getDimensions()
    self.text = gr.newText(Font(size or 42), text or "KASAIVAL")
    self.color = c or {.7, 0, .34}
    local w, h = self.text:getDimensions()
    self.x, self.y = W * .5 - w * .5, (y or H * .4)
    return copy(self)
end

local function update(self, dt)
end

local function draw(self, alpha)
    self.color[4] = alpha
    gr.setColor(self.color)
    gr.draw(self.text, self.x, self.y)
end

return {init = init, update = update, draw = draw}