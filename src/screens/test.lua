local copy = require "utils.copy"
local push = require "utils.push"
local state = require "state"

local Player = require "player.player"
local Sakura = require "plants.sakura"
local Typewriter = require "ui.typewriter"
local Batterfly = require "mobs.butterfly"
local Wolke = require "weather.wolke"

local gfx = love.graphics
local ke = love.keyboard
local ev = love.event

local function init(self)
    state:init()
    self.Batterfly = Batterfly:init({x = 1000, y = 700})
end

local function touch(self)
end

local function keypressed(self, key, set_screen)
    if key == "escape" then ev.quit() end
end

local function update(self, dt, set_screen)
    self.Batterfly:update(dt)

end

local function draw(self)
    self.Batterfly:draw()
    
end

return {draw = draw, init = init, touch = touch, keypressed = keypressed, update = update}
