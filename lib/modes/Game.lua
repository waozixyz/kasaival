-- library functions
local copy = require "lib.copy"
local lume = require "lib.lume"
local lyra = require "lib.lyra"
local push = require "lib.push"
local serpent = require "lib.serpent"

-- Main components
local Background = require "lib.scenery.Background"
local Focus = require "lib.sys.Focus"
local Ground = require "lib.scenery.Ground"
local HUD = require "lib.ui.HUD" 
local Music = require "lib.sys.Music"
local Player = require "lib.player.Player"
local Saves = require "lib.sys.Saves"
local Sky = require "lib.scenery.Sky"
local Spawner = require "lib.utils.Spawner"
local Dog = require "lib.mobs.Dog"

-- plants
local Plant = require "lib.plants.Plant"

-- aliases
local ev = love.event
local fi = love.filesystem
local gr = love.graphics
local ke = love.keyboard
local ma = love.math

local function load_stage(self, stage_name)
    local H = push:getHeight()
    local stage = copy(require("lib.stages." .. stage_name))
    -- load scenes
    lyra.scenes = stage.scenes
    -- set camera x
    lyra.cx = 0
    -- set the ground height
    lyra.gh = H * .5
    -- set the stagewidth
    lyra.gw = stage.width
    -- set up next stage if stage completed
    lyra.nextStage = stage.nextStage


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
        for _ = 1, v.amount do
            local tree = Plant:init(k, Spawner(v.startx))
            tree.id = #lyra.items
            table.insert(lyra.items, tree)
        end
    end

    -- spawn some Dog
    for _ = 1, 12 do
        table.insert(lyra.items, Dog:init( Spawner()))
    end

    -- store time elapsed in game
    self.elapsed = 0
    -- kill count will store the death of a plant or mob in multiple tables
    -- the key is used to determine what type died
    for k, v in pairs(lyra:getCurrentQuests()) do
        if k == "kill" then
            if not lyra.kill_count[v.type] then
                lyra.kill_count[v.type] = 0
            end
        end
    end
end

local function init(self)
    load_stage(self, "Desert")
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

local function update_quests(dt)
    for k, v in pairs(lyra:getCurrentQuests()) do
        if k == "survive" then
            v.amount = v.amount - dt
        end
        if v.amount <= 0 or v.amount == lyra.kill_count[v.type] then
            lyra:completeQuest(k)
        end
    end
end

local function update(self, dt, set_mode)
    if lyra.loadNextStage then
        load_stage(self, lyra.nextStage)
    end
    self.elapsed = self.elapsed + dt
    if self.restart then
        set_mode("Game")
    end
    if not self.paused then
        lyra:update(self, dt)
        self.ground:update(dt)
        self.ground:collide(self.player)
        update_quests(dt)
    end
    if self.exit == 1 then
        ev.quit()
    end
    HUD:update(self)
end
return {draw = draw, init = init, keypressed = keypressed, touch = touch, focus = focus, update = update}
