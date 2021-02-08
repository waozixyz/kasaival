-- library functions
local copy = require "lib.copy"
local focus = require "lib.sys.focus"
local lyra = require "lib.lyra"
local push = require "lib.push"
local spawner = require "lib.utils.spawner"

-- Main components
local Background = require "lib.scenery.Background"
local Ground = require "lib.scenery.Ground"
local HUD = require "lib.ui.HUD"
local Tank = require "lib.ui.Tank"
local Music = require "lib.sys.Music"
local Plant = require "lib.plants.Plant"
local Player = require "lib.player.Player"
local Sky = require "lib.scenery.Sky"
local Weather = require "lib.weather.Weather"

-- aliases
local ev = love.event
local gr = love.graphics

local function load_scene(self)
    if lyra.scenes[lyra.currentScene] == nil then
        self.nextStage = true
    else
        local scene = lyra.scenes[lyra.currentScene]
   
        -- current color schemes stored here
        local cs = {}
        do -- load last colorscheme into cs
            if lyra.currentScene > 1 then
                local pg = lyra.scenes[lyra.currentScene - 1].ground
                if pg.cs and pg.cs[#pg.cs] then
                    table.insert(cs, pg.cs[#pg.cs])
                end
            end
            if scene.ground then
                for _, v in ipairs(scene.ground.cs) do
                    table.insert(cs, v)
                end
            end
        end
        -- previous ground width used for mobs and plants
        local pgw = lyra.ground.width or 0
        if scene.ground then
            lyra.ground:add(scene.ground.add, cs)
        end
        if scene.plants then
            -- spawn plants for current Scene
            for _, v in ipairs(scene.plants) do
                for _ = 1, v.amount do
                    local props = v.props or {}
                    for ki,vi in pairs(spawner(pgw)) do props[ki] = vi end
                    local plant = Plant:init(v.name, props)
                    plant.id = #lyra.items
                    table.insert(lyra.items, plant)
                end
            end
        end
        -- spawn mobs for current Scene
        if scene.mobs then
            for _, v in ipairs(scene.mobs) do
                for _ = 1, v.amount do
                    local mob = require("lib.mobs." .. v.name):init(spawner(pgw))
                    mob.id = #lyra.items
                    table.insert(lyra.items, mob)
                end
            end
        end

        -- add weather conditions
        if scene.weather then
            Weather:addProp(scene.weather)
        end
    end
end

local function load_stage(self, stage_name)
    local H = push:getHeight()
    local stage = copy(require("lib.stages." .. stage_name))

    -- init lyra and make sure lyra.player is also in lyra.items
    lyra:init()
    
    -- current stage name
    lyra.current = stage_name
    -- load scenes
    lyra.scenes = stage.scenes
    -- set current scene to 1
    lyra.currentScene = 1
    -- set camera x
    lyra.cx = 0
    -- set to 1 to exit game
    lyra.exit = 0
    -- if true, restart current stage
    lyra.restart = false
    -- set up next stage if stage completed
    lyra.next = stage.next
    -- create a player inside lyra
    lyra.player = Player:init()
    table.insert(lyra.items, lyra.player)

    -- init Background
    Background:init(stage.background)
    -- init Ground
    lyra.ground = Ground:init(stage.ground, H * .5)
    -- init head up display
    HUD:init()
    -- init Music
    Music:next(stage.music)
    if Testing then
        Music:toggle()
    end
    -- init Sky
    Sky:init(stage.sky)
    Weather:init(stage.weather)

    self.nextStage = false
    self.nextScene = false
    load_scene(self)
end

local function init(self)
    load_stage(self, "Desert")
end

local function scene_pause(self)
    if self.nextStage or self.nextScene or self.load_cx then
        return true
    else return false end
end

local function keypressed(self, ...)
    HUD.keypressed(...)
end

local function touch(self, ...)
    HUD.touch(...)
    if not scene_pause(self) then
        lyra.player:touch(...)
    end
end

local function draw(self)
    Sky:draw()
    Background:draw()

    -- translate with camera x
    gr.translate(lyra.cx + Tank.w, 0)

    -- draw Ground
    lyra.ground:draw()
    -- draw entities
    lyra:draw()
    Weather:draw()

    -- undo translation
    gr.translate(-lyra.cx - Tank.w, 0)

    -- draw head up display
    HUD:draw()
end

local function completeQuest(self, id)
    lyra:getCurrentQuests()[id] = nil
    if #lyra:getCurrentQuests() <= 0 then
        self.nextScene = true
    end
end

local function update_quests(self, dt)
    for i, v in ipairs(lyra:getCurrentQuests()) do
        if v.type == "time" then
            v.amount = v.amount - dt
            if v.amount <= 0 then
                completeQuest(self, i)
            end
        elseif v.type == "kill" then
            if lyra.kill_count[v.item] and lyra.kill_count[v.item] >= v.amount then
                completeQuest(self, i)
            end
        end
    end
end

local function update(self, dt)
    local W = push:getWidth()
    HUD:update()
    if lyra.restart then
        if self.count then self.count = self.count + 1 end
        if self.count == 1 then
            load_stage(self, lyra.current)
        end
        self.count = 0
    end
    if lyra.exit == 1 then
        ev.quit()
    end
    if self.nextStage then
        load_stage(self, lyra.next)
    else
        if self.nextScene then
            if lyra.player.x + lyra.cx > W - W / 5 then
                self.load_cx = lyra.cx - (W / 5)
            end
            lyra.currentScene = lyra.currentScene + 1
            load_scene(self)
            self.nextScene = false
        elseif self.load_cx then
            lyra.cx = lyra.cx + (self.load_cx - lyra.cx) * .5
            if math.floor(self.load_cx) == math.floor(lyra.cx) then
                lyra.cx = self.load_cx
                self.load_cx = nil
            end
        else
            if not lyra.paused and  lyra.player.fuel > 0 then
                lyra:update(dt)
                lyra.ground:update(dt)
                lyra.ground:collide(lyra.player)
                update_quests(self, dt)
                Weather:update(dt)
            end
        end
    end
end
return {draw = draw, init = init, keypressed = keypressed, touch = touch, focus = focus, update = update}
