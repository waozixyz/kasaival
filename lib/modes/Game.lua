-- library functions
local copy = require "lib.copy"
local lume = require "lib.lume"
local lyra = require "lib.lyra"
local push = require "lib.push"
local serpent = require "lib.serpent"

-- Main components
local Background = require "lib.scene.Background"
local Focus = require "lib.sys.Focus"
local Ground = require "lib.scene.Ground"
local HUD = require "lib.ui.HUD" 
local Music = require "lib.sys.Music"
local Player = require "lib.player.Player"
local Saves = require "lib.sys.Saves"
local Sky = require "lib.scene.Sky"
local Spawner = require "lib.utils.Spawner"

-- plants
local Plant = require "lib.plants.Plant"

-- aliases
local ev = love.event
local fi = love.filesystem
local gr = love.graphics
local ke = love.keyboard
local ma = love.math

local function load_stage(stage_name)
    return copy(require("lib.stages." .. stage_name))
end

local function init(self)
    local stage = load_stage("Tutorial")
    local H = push:getHeight()
    -- set camera x
    lyra.cx = 0
    -- set the ground height
    lyra.gh = H * .5
    -- set the stagewidth
    lyra.gw = stage.width
    -- init Background
    Background:init(stage.background)
    -- init Ground
    self.ground = Ground:init(stage.ground)
    -- init head up display
    HUD:init()
    -- init Music
    Music:play(stage.music)
    -- create a player
    self.player = Player:init()
    -- init Sky
    Sky:init(stage.sky)
    -- add here for auto draw update
    lyra:init(self.player)

    -- spawn some trees
    for k, v in pairs(stage.trees) do
        for i = 1, v.amount do
            local tree = Plant:init(k, Spawner(v.startx))
            tree.id = #lyra.items
            table.insert(lyra.items, tree)
        end
    end
end

local function keypressed(...)
    HUD:keypressed(...)
end

local function touch(self, ...)
    HUD:touch(self, ...)
    self.player:touch(...)
end

local function draw(self)
    Sky:draw()
    Background:draw()

    -- translate with camera x
    gr.translate(lyra.cx, 0)

    -- draw Ground
    self.ground:draw()
    -- draw entities
    lyra:draw()

    -- undo translation
    gr.translate(-lyra.cx, 0)

    -- draw head up display
    HUD:draw(self)
end

local function focus(...)
    Focus(...)
end

local function update(self, dt, set_mode)
    if self.restart then
        set_mode("Game")
    end
    if not self.paused then
        lyra:update(dt)
        self.ground:update(dt)
        self.ground:collide(self.player)
    end
    if self.exit == 1 then
        ev.quit()
    end
    HUD:update(self)
end
return {draw = draw, init = init, keypressed = keypressed, touch = touch, focus = focus, update = update}
