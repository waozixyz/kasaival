local copy = require "utils.copy"
local push = require "utils.push"

local font = require "ui.font"

local gfx = love.graphics

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
        self[k] = (prop and prop[k]) or v
    end
    self.text = gfx.newText(font(self.size), text)
    self.w = self.text:getWidth()
    return copy(self)
end

local function update(self, text)
    if text and type(text) == "string" then
        self.text = gfx.newText(font(self.size), text)
        self.w = self.text:getWidth()
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
    gfx.setColor(self.color)
    gfx.draw(self.text, getAlignX(self.align, self.x, self.w), self.y)
end

return {init = init, update = update, draw = draw}