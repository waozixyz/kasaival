local copy = require "utils.copy"
local Wind = require "weather.wind"
local push = require "utils.push"

local ma = love.math
local gfx = love.graphics

local function init(self, x, y)
    self.time = 1
    self.x, self.y = x, y
    self.r = ma.random(1, 10) * .1
    return copy(self)
end

local function draw(self)
    gfx.setColor(0, 0, 1, .4)
    local x, y = self.x, self.y
    local w = 5 * math.sin(self.time * self.r)
    if w < 1 and w > -1 then
        w = 5 * math.cos(self.time * self.r)
    end
    gfx.polygon("fill", x - w, y, x + w * .5, y + 10, x + w, y)
end

local function update(self, dt)
    self.time = self.time + dt
    self.x = self.x + Wind:getWind() 
    self.y = self.y + self.time
end

return {init = init, draw = draw, update = update}
