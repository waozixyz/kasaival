-- library functions
local copy = require "utils.copy"
local focus = require "sys.focus"
local state = require "state"
local push = require "utils.push"
local spawner = require "utils.spawner"
local ems = require "ems"
local json = require "dkjson"

-- Main components
local Background = require "scenery.background"
local Ground = require "scenery.ground"
local HUD = require "ui.hud"
local Music = require "sys.music"
local Player = require "player.player"
local Sky = require "scenery.sky"
-- local Weather = require "weather.Weather"

-- Aliases
local ev = love.event
local gfx = love.graphics

local Testing = true

local function loadScene(self)
    if state.scenes[state.currentScene] == nil then
        state.nextStage = true
    else
        local scene = state.scenes[state.currentScene]

        local colorSchemes = {}
        do
            if state.currentScene > 1 then
                local previousGround = state.scenes[state.currentScene - 1].ground
                if previousGround.colorSchemes and previousGround.colorSchemes[#previousGround.colorSchemes] then
                    table.insert(colorSchemes, previousGround.colorSchemes[#previousGround.colorSchemes])
                end
            end
            if scene.ground then
                for _, v in ipairs(scene.ground.colorSchemes) do
                    table.insert(colorSchemes, v)
                end
            end
        end
        -- previous ground width used for mobs and plants
        local previousGroundWidth = state.gw or 0
        if scene.ground then
            self.ground:add(scene.ground.add, colorSchemes)
        end
        -- spawn plants and mobs for current Scene
        if scene.spawn then
            for _, item in ipairs(scene.spawn) do
                for _ = 1, item.amount do
                    ems:createAndAddItem(item, previousGroundWidth)
                end
            end
        end
        -- add spawners to stage
        if scene.spawners then
            for _, item in ipairs(scene.spawners) do
                item.time = 0
                item.pgw = previousGroundWidth
                table.insert(self.spawn, item)
            end
        end
        --[[
        -- add weather conditions
        if scene.weather then
            Weather:addProp(scene.weather)
        end
        ]]--
    end
end

local function loadStage(self, stage_name)
    local H = push:getHeight()
    local content = love.filesystem.read("data/stages/" .. stage_name .. ".json")
    local stage, pos, err = json.decode(content, 1, nil)

    if not stage then
        print("Error loading stage:", err)
        return
    end
    state:init()
    state.current = stage_name
    state.scenes = stage.scenes
    state.currentScene = 1
    state.cx = 0
    state.exit = 0
    state.restart = false
    state.next = stage.next
    ems:addEntity(Player:init())
    Background:init(stage.background)
    self.ground = Ground:init(stage.ground, H * .5)
    HUD:init()
    Music:next(stage.music)
    if Testing then
        Music:toggle()
    end
    Sky:init(stage.sky)

    --Weather:init(stage.weather)

    state.nextStage = false
    state.nextScene = false
    self.spawn = {}
    loadScene(self)

end

local function init(self)
    loadStage(self, "dune_drift")
end

local function keypressed(self, ...)
    HUD.keypressed(...)
end

local function scenePause(self)
    if state.nextStage or state.nextScene or self.loadCX then
        return true
    else return false end
end 


local function isPaused()
    return state.paused or ems.player.HP <= 0 or state.questFailed
end

local function touch(self, ...)
    HUD.touch(...)

    if not isPaused() and ems.player and self.ready and not scenePause(self) then
        ems.player:touch(...)
    end
end

local function update(self, dt, set_screen)
    local W = push:getWidth()
    HUD:update()
    if state.restart then
        if self.count then
            self.count = self.count + 1
        end
        if self.count == 1 then
            loadStage(self, state.current)
        end
        self.count = 0
    end
    if state.exit == 1 then
        Music:mute()
        set_screen("Menu")
    end
    if state.nextStage then
        loadStage(self, state.next)
    else
        if state.nextScene then
            if ems.player.x + state.cx > W - W / 5 then
                self.loadCX = state.cx - (W / 5)
            end
            state.currentScene = state.currentScene + 1
            loadScene(self)
            state.nextScene = false
        elseif self.loadCX then
            state.cx = state.cx + (self.loadCX - state.cx) * .5
            if math.floor(self.loadCX) == math.floor(state.cx) then
                state.cx = self.loadCX
                self.loadCX = nil
            end
        else
            if not isPaused() then
                ems:update(dt)
                self.ground:update(dt)
                self.ground:collide(ems.player)
                state:updateQuests(dt)
                --Weather:update(dt)
                for _, v in ipairs(self.spawn) do
                    v.time = v.time + dt
                    if v.time > v.interval then
                        local count = ems:countItemsByTypeAndName(v.entityType, v.entityName)
                        if v.maxAmount == nil or count < v.maxAmount then
                            ems:createAndAddItem(v)
                            v.time = 0
                        end
                    end
                end
                if not self.ready then self.ready = true end
            end
        end
    end
end

local function draw(self)
    Sky:draw()
    Background:draw()

    -- translate with camera x
    gfx.translate(state.cx, 0)

    -- draw Ground
    self.ground:draw()
    -- draw entities
    ems:draw()
    --Weather:draw()

    -- undo translation
    gfx.translate(-state.cx, 0)

    -- draw head up display
    HUD:draw()
end

return {draw = draw, init = init, keypressed = keypressed, touch = touch, focus = focus, update = update}