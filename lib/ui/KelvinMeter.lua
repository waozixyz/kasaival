local lyra = require "lib.lyra"
local push = require "lib.push"

local Text = require "lib.ui.Text"

local gr = love.graphics
local colors = {
    {.25, 0, 0},
    {1, 0, 0},
    {1, .4, 0},
    {1, .8, 0},
    {1, 1, .25},
    {1, 1, 1},
    {.7, .7, 1},
    {.5, .5, 1},
    {0, 0, 1},
    {0, 0, .25},
}

local function init(self)
    self.w = 100
    self.text = Text:init(lyra.player.kelvin)
    self.range = 18000
    return self
end

local function getColor(self)
    local k = lyra.player.kelvin
    local i = math.floor(k / (self.range / #colors)) + 1
    local c = colors[i]
    local c2 = colors[i + 1]
    local f = math.floor(k / (self.range / #colors) * 10) % 10 * .1
    return c[1] + c2[1] * f, c[2] + c2[2] * f, c[3] + c2[3] * f
end

local function draw(self)
    local H = push:getHeight()
    gr.setColor(getColor(self))
    gr.rectangle("fill", 0, 0, self.w, H)
    gr.setColor(1, 1, 1)
    self.text:draw()
end

local function update(self, dt)
    self.text:update(tostring(math.floor(lyra.player.kelvin) .. " Kelvin"))

end

return {init = init, update = update, draw = draw}