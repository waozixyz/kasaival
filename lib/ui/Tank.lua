local lyra = require "lib.lyra"
local push = require "lib.push"

local Fuel = require "lib.player.Fuel"
local Text = require "lib.ui.Text"

local gr = love.graphics

local function init(self)
    self.w = 32
    self.text = Text:init(lyra.player.kelvin, {y = 30, size = 64})
    self.range = 18000
    return self
end


local function draw(self)
    local H = push:getHeight()
    gr.setColor(0, 0, 0)
    gr.rectangle("fill", 0, 0, self.w, H)
    gr.setColor(.5, 0, .2)
    local h = Fuel.amount / Fuel.max * H
    gr.rectangle("fill", 0, H - h, self.w, h)
    gr.setColor(1, 1, 1)
    self.text:draw()
end

local function update(self, dt)
end

return {init = init, update = update, draw = draw}