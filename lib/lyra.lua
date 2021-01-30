local ma = love.math

local function init(self, ...)
    self.items = {}
    for _, v in ipairs({...}) do
        table.insert(self.items, v)
    end
    return self
end

local push = require "lib.push"

local function update(self, dt)
    for _, v in ipairs(self.items) do
        if v.update then
            v:update(dt)
        end
    end
end

local function draw(self, ...)
    for _, v in ipairs(self.items) do
        if v.draw then
            v:draw(...)
        end
    end
end

local function checkVisible(self, x, w)
    local W = push:getWidth()
    if x + self.cx < W + w and x + self.cx > -w then return true else return false end
end


local function getColor(cs)
    local function rnc(l, r)
        return ma.random(l * 100, r * 100) * .01
    end
    return {rnc(cs[1], cs[2]), rnc(cs[3], cs[4]), rnc(cs[5], cs[6]), 1}
end

return {
    items = {},
    init = init,
    update = update,
    draw = draw,
    checkVisible = checkVisible,
    getColor = getColor,
    cx = 0,
    gh = 600,
    gw = 3000,
    startx = -100
}