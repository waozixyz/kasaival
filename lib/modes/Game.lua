-- library functions
local copy = require("lib.copy")
local lume = require("lib.lume")
local push = require("lib.push")
local serpent = require("lib.serpent")

-- Main components
local Ground = require("lib.Ground")
local HUD = require("lib.ui.HUD")
local Music = require("lib.Music")
local Player = require "lib.Player"
local Saves = require "lib.Saves"
local Sky = require "lib.Sky"
local Spawner = require "lib.Spawner"

-- Trees
local MainTree = require "lib.trees.Tree"
local SakuraTree = require "lib.trees.Sakura"
local OakTree = require "lib.trees.Oak"

-- aliases
local ev = love.event
local fi = love.filesystem
local gr = love.graphics
local ke = love.keyboard
local ma = love.math

local function init(self)
    self.player = copy(Player):init()
    HUD:init()
end

local function keypressed(...)
    HUD:keypressed(...)
end

local function touch(self, x, y, dt)
    HUD:touch(self, x, y)
end

local function draw(self)
    self.player:draw()
    HUD:draw(self)
end

local function focus(...)
    HUD:focus(...)
end

local function update(self, dt, set_mode)
    -- HUD:update(self)
    if not self.paused then
        self.player:update(dt)
    end
    if self.exit == 1 then
        ev.quit()
    end
end
return {draw = draw, init = init, keypressed = keypressed, touch = touch, focus = focus, update = update}
