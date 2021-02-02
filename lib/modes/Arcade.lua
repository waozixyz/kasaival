-- library functions
local copy = require("lib.copy")
local lume = require("lib.lume")
local push = require("lib.push")
local serpent = require("lib.serpent")

-- Main components
local Ground = require("lib.scenery.Ground")
local HUD = require("lib.ui.HUD")
local Music = require("lib.sys.Music")
local Player = require "lib.player.Player"
local Saves = require "lib.sys.Saves"
local Sky = require "lib.scenery.Sky"
local Spawner = require "lib.plants.Spawner"

-- plants
local MainTree = require "lib.plants.Tree"
local SakuraTree = require "lib.plants.Sakura"
local OakTree = require "lib.plants.Oak"

-- aliases
local fi = love.filesystem
local gr = love.graphics
local ke = love.keyboard
local ma = love.math

local function addTree(self, randStage)
    -- get random x y coord in game
    local x, y, scale = Spawner(self.width, self.height)
    -- decide which tree to grow
    local chance = ma.random(0, 100)
    local tree
    if chance > 2 then
        tree = OakTree(x, y, scale, randStage)
    else
        tree = SakuraTree(x, y, scale, randStage)
    end
    -- add to plants table
    table.insert(self.plants, tree)
end

local function getProp(e)
    local t = {}
    for k, v in pairs(e) do
        if k ~= "move" and k ~= "init" and k ~= "collided" and k ~= "update" and k ~= "draw" and k ~= "getHitbox" and k ~= "collide" then
            t[k] = v
        end
    end
    return t
end
local function save(self)
    local sav = {}
    sav["sky"] = getProp(self.sky)
    sav["p"] = getProp(self.player)
    sav["g"] = getProp(self.ground)
    local t = {}
    for _, v in ipairs(self.plants) do table.insert(t, getProp(v)) end
    sav["t"] = t
    sav["cx"] = self.cx
    sav["elapsed"] = self.elapsed
    sav["muted"] = self.muted
    sav["treeTime"] = self.treeTime

    fi.write(self.saveFile, serpent.dump(sav))
end

local function checkCollision(o1, o2)
    local l1, r1, u1, d1 = o1:getHitbox()
    local l2, r2, u2, d2 = o2:getHitbox()

    if l1 <= r2 and r1 >= l2 and u1 <= d2 and d1 >= u2 then
        return true
    else
        return false
    end
end

local function init(self, _, saveFile)
    -- default init for every game
    self.restart, self.paused, self.exit = false, false, 0
    local W, H= push:getDimensions()
    self.usingTouchMove = false
    self.width = W * 3
    self.height = H / 2.5
    HUD:init()

    -- load save content if possible
    self.saveFile = saveFile or Saves:nextSave()
    local sav = {}
    if fi.getInfo(self.saveFile) then
        local contents = fi.read(self.saveFile)
        _, sav = serpent.load(contents)
    end

    self.elapsed = sav.elapsed or 0
    self.muted = sav.muted or true
    self.treeTime = sav.treeTime or 0
    self.cx = sav.cx or 0


    self.plants = {}
    local sky, p, g, t = sav.sky or {}, sav.p or {}, sav.g or {}, sav.t or nil

    -- init sky
    self.sky = copy(Sky):init(sky)

    -- ini ground
    self.ground = copy(Ground):init(g, self.width, self.height)

    -- ini player
    self.player = copy(Player):init(p)

    -- init plants
    if t and #t > 0 then
        for _, v in ipairs(t) do
            table.insert(self.plants, copy(MainTree))
            local tree = self.plants[#self.plants]
            tree:init(v)
        end
    else
        for _ = 1, 60 do
            addTree(self, true)
        end
    end

end

local function keypressed(...)
    HUD:keypressed(...)
end

local function touch(self, x, y, dt)
    HUD:touch(self, x, y)
    if not self.paused and y > 100 then
        self.player:touch(self, x, y, dt)
    end
end

local function draw(self)
    -- draw sky
    self.sky:draw(self.cx)

    -- translate with camera x
    gr.translate(self.cx, 0)

    -- draw ground
    self.ground:draw(self)

    -- make entities table
    local entities = {self.player}
    for _, tree in ipairs(self.plants) do
        if self:checkVisible(tree.x, 200) then
            table.insert(entities, tree)
        end
    end
    -- sort entities by y axis
    entities = lume.sort(entities, "y")
    -- draw entities
    for _, entity in ipairs(entities) do
        entity:draw()
    end

    -- undo translation
    gr.translate(-self.cx, 0)

    -- draw over head display
    HUD:draw(self)
end

local function focus(...)
    HUD:focus(...)
end

local function update(self, dt, set_mode)
    HUD:update(self)
    local _, H = push:getDimensions()
    if self.muted then
        Music:mute()
    else
        Music:play()
    end

    if self.restart then
        set_mode("Game")
    end
    if self.exit == 1 then
        if Testing then
            love.event.quit()
        end
        self.exit = 2
    elseif self.exit == 2 then
        gr.captureScreenshot(self.saveFile .. ".png")
        save(self)
        self.exit = 3
    elseif self.exit == 3 then
        if Music.bgm then
            Music.bgm:pause()
        end
        love.event.quit()
    elseif not self.paused and self.player.kelvin > 0 then
        self.treeTime = self.treeTime + dt
        if self.treeTime > 1 then
            addTree(self)
            self.treeTime = 0
        end
        self.elapsed = self.elapsed + dt
        self.player.scale = (self.player.y / H) * self.player.kelvin * 0.01

        self.player:update(dt, self)
        for i, tree in ipairs(self.plants) do
            if tree.x + self.cx < self.width * -0.5 then
                tree.x = tree.x + self.width
            elseif tree.x + self.cx > self.width * 0.5 then
                tree.x = tree.x - self.width
            end
            if #tree.branches > 0 and checkCollision(tree, self.player) then
                self.player:collided(tree.element, tree.special, #tree.branches == tree.maxStage)
                tree:collided(self.player)
            end
            tree:update(dt)
            if tree.dead then
                self.player.xp = self.player.xp + 10
                self.player.kelvin = self.player.kelvin + 1
                table.remove(self.plants, i)
            end
        end
        self.sky:update(dt)
        self.ground:collide(self.player)
        self.ground:update(self, dt)
    end
end
return {checkVisible = checkVisible, draw = draw, init = init, keypressed = keypressed, touch = touch, focus = focus, update = update}
