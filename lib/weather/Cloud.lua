local copy = require "lib.copy"
local push = require "lib.push"
local lyra = require "lib.lyra"

local Rain = require "lib.weather.Rain"
local Wolkeps = require "lib.ps.Wolkeps"

local ma = love.math
local gr = love.graphics

local function init(self, spawn)
    self.x = spawn.x or 400
    self.y = 30 + ma.random(1, 15)
    self.ps = Wolkeps()
    self.items = {}
    self.raining = true
    self.rainTime = ma.random(1, 3)
    self.rainTimer = ma.random(0, self.rainTime * .5)
    return copy(self)
end

local function draw(self)
    for _, v in ipairs(self.items) do
        v:draw()
    end
    local sx, sy = 5, 5
    gr.setColor(1, 1, 1)
    gr.draw(self.ps, self.x, self.y, 0, sx, sy)
end

local function addRain(self)
    table.insert(self.items, Rain:init(self.x + ma.random(-20, 20), self.y + 30))
end

local function update(self, dt)
    self.ps:update(dt)
    if self.raining then
        self.rainTimer = self.rainTimer + dt
        if self.rainTimer > self.rainTime then
            addRain(self)
            self.rainTimer = 0
        end
    end
    for i, v in ipairs(self.items) do
        v:update(dt)
        -- regen entfeernrn
        if v.y >= push:getHeight() - lyra.gh then
            table.remove(self.items, i)
            v:update(dt)
        end
    end
end

return {init = init, draw = draw, update = update}
