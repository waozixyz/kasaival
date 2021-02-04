local copy = require "lib.copy"
local push = require "lib.push"

local Player = require "lib.player.Player"
local Sakura = require "lib.plants.Sakura"
local Typewriter = require "lib.ui.Typewriter"
local Dog = require "lib.mobs.Dog"

local gr = love.graphics
local ke = love.keyboard
local ev = love.event

local function init(self)
    self.dog = Dog:init({x = 300, y = 700})
end

local function touch(self)
end

local function keypressed(self, key, set_mode)
    if key == "escape" then ev.quit() end
end

local function update(self, dt, set_mode)
    self.dog:update(dt)
end

local function draw(self)
    self.dog:draw()
end

return {draw = draw, init = init, touch = touch, keypressed = keypressed, update = update}
