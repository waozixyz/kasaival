-- library functions
local copy = require "copy"
local focus = require "sys.focus"
local lyra = require "lyra"
local push = require "push"
local spawner = require "utils.spawner"

-- Main components
local Background = require "scenery.Background"
local Ground = require "scenery.Ground"
local HUD = require "ui.HUD"
local Music = require "sys.Music"
local Plant = require "plants.Plant"
local Player = require "player.Player"
local Sky = require "scenery.Sky"
local Weather = require "weather.Weather"

-- aliases
local ev = love.event
local gr = love.graphics

local function add_item(v, pgw)
    local props = v.props or {}
    for ki, vi in pairs(spawner(v.pgw or pgw)) do
        props[ki] = vi
    end
    local item = {}
    if v.type == "plant" then
        item = Plant:init(v.name, props)
    elseif v.type == "mob" then
        item = require("mobs." .. v.name):init(props)
    end
    table.insert(lyra.items, item)
end

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
        -- spawn plants and mobs for current Scene
        if scene.spawn then
            for _, v in ipairs(scene.spawn) do
                for _ = 1, v.amount do
                    add_item(v, pgw)
                end
            end
        end
        -- add spawners to stage
        if scene.spawners then
            for _, v in ipairs(scene.spawners) do
                v.time = 0
                v.pgw = pgw
                v.gw = lyra.ground.width
                table.insert(self.spawn, v)
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
    local stage = copy(require("stages." .. stage_name))

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
    self.spawn = {}
    load_scene(self)

end

local function init(self)
    load_stage(self, "Desert")
end

local function keypressed(self, ...)
    HUD.keypressed(...)
end

local function scene_pause(self)
    if self.nextStage or self.nextScene or self.load_cx then
        return true
    else return false end
end 

local function paused()
    if lyra.paused or lyra.player.HP <= 0 or lyra.questFailed then
        return true
    end
end

local function touch(self, ...)
    HUD.touch(...)
    if not paused() and lyra.player and self.ready and not scene_pause(self) then
        lyra.player:touch(...)
    end
end

local function draw(self)
    Sky:draw()
    Background:draw()

    -- translate with camera x
    gr.translate(lyra.cx, 0)

    -- draw Ground
    lyra.ground:draw()
    -- draw entities
    lyra:draw()
    Weather:draw()

    -- undo translation
    gr.translate(-lyra.cx, 0)

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
        if v.questType == "time" then
            v.amount = v.amount - dt
            if v.amount <= 0 then
                completeQuest(self, i)
            end
        elseif v.questType == "kill" then
            if lyra.kill_count[v.itemType] and lyra.kill_count[v.itemType] >= v.amount then
                completeQuest(self, i)
            end
        end
        if v.fail and v:fail(lyra) then
            lyra.questFailed = true
        end
    end
end

local function update(self, dt)
    local W = push:getWidth()
    HUD:update()
    if lyra.restart then
        if self.count then
            self.count = self.count + 1
        end
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
            if not paused() then
                lyra:update(dt)
                lyra.ground:update(dt)
                lyra.ground:collide(lyra.player)
                update_quests(self, dt)
                Weather:update(dt)
                for _, v in ipairs(self.spawn) do
                    v.time = v.time + dt
                    if v.time > v.interval then
                        add_item(v)
                        v.time = 0
                    end
                end
                if not self.ready then self.ready = true end
            end
        end
    end
end
return {draw = draw, init = init, keypressed = keypressed, touch = touch, focus = focus, update = update}
