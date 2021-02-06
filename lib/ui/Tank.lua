local lyra = require "lib.lyra"
local push = require "lib.push"

local Fuel = require "lib.player.Fuel"
local Text = require "lib.ui.Text"

local gr = love.graphics

local colors = {
    {.25, 0, 0},
    {.6, 0, 0},
    {.8, 0, 0},
    {.9, 0, 0},
    {1, 0, 0},
    {1, .4, 0},
    {1, .5, .1},
    {1, 1, .25},
    {1, .9, .6},
    {1, .9, .8},
    {1, .96, .9},
}


local function init(self)
    self.w = 32
    self.text = Text:init(lyra.player.kelvin, {y = 30, size = 64})
    self.range = 18000
    return self
end

local function getColor(self)
    local colors = colors
    local i = math.floor(Fuel.amount / (self.range / #colors)) + 1
    local c = colors[i]
    local c2 = colors[i + 1]
    local f = math.floor(Fuel.amount / (self.range / #colors) * 10) % 10 * .1
    return c[1] + c2[1] * f, c[2] + c2[2] * f, c[3] + c2[3] * f
end

local function draw(self)
    local H = push:getHeight()
    gr.setColor(0, 0, 0)
    gr.rectangle("fill", 0, 0, self.w, H)
    gr.setColor(getColor(self))
    local h = Fuel.amount / Fuel.max * H
    gr.rectangle("fill", 0, H - h, self.w, h)
    gr.setColor(1, 1, 1)
    self.text:draw()
end

local function update(self, dt)
end

return {init = init, update = update, draw = draw}