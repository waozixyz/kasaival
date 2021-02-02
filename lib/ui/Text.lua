local copy = require "lib.copy"
local push = require "lib.push"

local Font = require "lib.ui.Font"

local gr = love.graphics

local function init(self, text, prop)
    local W, H = push:getDimensions()
    local tmpl = {
        align = "center",
        size = 42,
        x = W * .5,
        y = H * .4,
        color = {.7, 0, .34}
    }
    for k, v in pairs(tmpl) do
        self[k] = prop[k] or v
    end
    self.text = gr.newText(Font(self.size), text)
    self.w = self.text:getWidth()
    return copy(self)
end

local function update(self, text)
    if text then
        self.text = gr.newText(Font(self.size), text)
    end
end

local function getAlignX(align, x, w)
    if align == "center" then
        return x - w * .5
    elseif align == "left" then
        return x
    elseif align == "right" then
        return x - w
    end
end
local function draw(self, alpha)
    self.color[4] = alpha
    gr.setColor(self.color)
    gr.draw(self.text, getAlignX(self.align, self.x, self.w), self.y)
end

return {init = init, update = update, draw = draw}