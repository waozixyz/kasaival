local copy = require "lib.copy"
local push = require "lib.push"
local lyra = require "lib.lyra"

local Player = require "lib.player.Player"
local Sakura = require "lib.plants.Sakura"
local Typewriter = require "lib.ui.Typewriter"
local Batterfly = require "lib.mobs.Batterfly"
local Wolke = require "lib.weather.Wolke"

local gr = love.graphics
local ke = love.keyboard
local ev = love.event

local function init(self)
    lyra:init()
    self.Batterfly = Batterfly:init({x = 1000, y = 700})
end

local function touch(self)
end

local function keypressed(self, key, set_mode)
    if key == "escape" then ev.quit() end
end

local function update(self, dt, set_mode)
    self.Batterfly:update(dt)

end

local function draw(self)
    self.Batterfly:draw()
    
end

return {draw = draw, init = init, touch = touch, keypressed = keypressed, update = update}
