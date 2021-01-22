local copy = require("lib.copy")
local lume = require("lib.lume")
local push = require("lib.push")
local serpent = require("lib.serpent")

local Ground = require("src.Ground")
local HUD = require("src.HUD")
local Music = require("src.Music")
local Player = require("src.Player")
local Saves = require("src.Saves")
local Sky = require("src.Sky")
local Tree = require("src.Tree")

local fi = love.filesystem
local gr = love.graphics
local ke = love.keyboard
local ma = love.math

local function addTree(self, completeTree)
    local H = push:getHeight()

    local y = ma.random(0, H - self.height)
    local scale = (y + self.height) / H

    local W = self.width
    local x = ma.random(W * -.5, W + (W * -.5))

    local vir_x = x / scale

    local rat_x = x / vir_x
    y =  self.height + (y * rat_x)

    local w = (ma.random(22, 33) * scale)
    local h = (ma.random(52, 69) * scale)

    table.insert(self.trees, copy(Tree))

    local tree = self.trees[#self.trees]
    local maxStage = ma.random(8, 10)
    local currentStage = nil
    if completeTree then currentStage = maxStage else currentStage = 0 end
    local growTime = ma.random(0.5, 1)
    local cs1 = {.5, .7, .2, .4, .2, .3}
    local cs2 = {.3, .4, .4, .6, .2, .3}
    local cs3 = {.3, .5, .2, .4, .3, .5}

    local c = ({cs1, cs2, cs3})[ma.random(1, 3)]
    return tree:init(
        {
            colorScheme = c,
            currentStage = currentStage,
            growTime = growTime,
            h = h,
            maxStage = maxStage,
            scale = scale,
            w = w,
            x = x,
            y = y
        }
    )
end

local function getProp(e)
    local t = {}

    for k, v in pairs(e) do
        if ((k ~= "move") and (k ~= "init") and (k ~= "collided") and (k ~= "update") and (k ~= "draw") and (k ~= "getHitbox") and (k ~= "collide")) then
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
    for i, v in ipairs(self.trees) do table.insert(t, getProp(v)) end
    sav["t"] = t
    sav["cx"] = self.cx
    sav["elapsed"] = self.elapsed
    sav["muted"] = self.muted
    sav["treeTime"] = self.treeTime

    local s, m = fi.write(self.saveFile, serpent.dump(sav))
end

local function checkCollision(o1, o2)
    local l1, r1, u1, d1 = o1:getHitbox()
    local l2, r2, u2, d2 = o2:getHitbox()

    if ((l1 <= r2) and (r1 >= l2) and (u1 <= d2) and (d1 >= u2)) then
        return true
    else
        return false
    end
end

local radToDeg = (180 / math.pi)
local degToRad = (math.pi / 180)

local function checkVisible(self, x, w)
    local W = push:getWidth()
    if (((x + self.cx) < (W + w)) and ((x + self.cx) > (-w))) then return true else return false end
end

local function init(self, saveFile)
    -- default init for every game
    self.restart, self.paused, self.exit, self.readyToExit = false, false, false, false
    local W, H= push:getDimensions()
    self.usingTouchMove = false
    self.width = W * 3
    self.height = H / 2.5
    HUD:init()


    -- load save content if possible
    self.saveFile = (saveFile or Saves:nextSave())
    local sav = {}
    if fi.getInfo(self.saveFile) then
        local contents = fi.read(self.saveFile)
        _, sav = serpent.load(contents)
    end

    self.elapsed = (sav.elapsed or 0)
    self.muted = (sav.muted or false)
    self.treeTime = (sav.treeTime or 0)
    self.cx = (sav.cx or 0)

    
    self.trees = {}
    local sky, p, g, t = (sav.sky or {}), (sav.p or {}), (sav.g or {}), (sav.t or nil)

    -- init sky
    self.sky = copy(Sky)
    self.sky:init(sky)
    
    -- ini ground
    self.ground = copy(Ground)
    self.ground:init(g, self.width, self.height)
    
    -- ini player
    self.player = copy(Player)
    self.player:init(p)
    
    -- init trees
    if (t and (#t > 0)) then
        for i, v in ipairs(t) do
            table.insert(self.trees, copy(Tree))
            local tree = self.trees[#self.trees]
            tree:init(v)
        end
    else
        for i = 1, 60 do
            addTree(self, true)
        end
    end

end

local function keypressed(self, key, set_mode)
    HUD:keypressed(self, key)
    if (self.player.hp <= 0) then self.restart = true end
end

local function touch(self, x, y, dt)
    if (self.player.hp <= 0) then self.restart = true end
    if not self.paused then
        local px, py = self.player.x, self.player.y
        local x0 = (x - self.cx)
        local nx, ny = (x0 - px), (y - py)
        local w = (self.player.scale * self.player.ow * 0.2)
        local h = (self.player.scale * self.player.oh * 0.2)
        if ((nx < w) and (nx > (-w)) and (ny < h) and (ny > (-h))) then
            nx = nil
            ny = nil
        end
        if ((y > 100) and nx and ny) then
            local angle = (math.atan2(nx, ny) * radToDeg)
            if (angle < 0) then
                angle = 360 + angle
            end
            angle = angle * degToRad
            local ax, ay = math.sin(angle), math.cos(angle)
            self.player:move(ax, ay, self, dt)
            self.usingTouchMove = true
        end
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
    for _, tree in ipairs(self.trees) do
        if self:checkVisible(tree.x, 200) then
            table.insert(entities, tree)
        end
    end
    -- sort entities by y axis
    entities = lume.sort(entities, "y")
    -- draw entities
    for i, entity in ipairs(entities) do
        entity:draw()
    end

    -- undo translation
    gr.translate(-self.cx, 0)

    -- draw over head display
    HUD:draw(self)
end

local function update(self, dt, set_mode)
    HUD:update(self)
    local _, H = push:getDimensions()
    if self.muted then
        Music:mute()
    else
        Music:play()
    end
    if self.readyToExit then
        do
        end
        Music.bgm:pause()
        set_mode("src.Menu")
    end
    if self.restart then
        set_mode("src.Game")
    end
    if (self.exit and not self.readyToExit) then
        if Testing then
            love.event.quit()
        else
            gr.captureScreenshot((self.saveFile .. ".png"))
            save(self)
            self.readyToExit = true
        end
    end
    if (not self.paused and (self.player.hp > 0)) then
        if not self.usingTouchMove then
            local dx, dy = 0, 0
            if ke.isScancodeDown("d", "right", "kp6") then dx = 1 end
            if ke.isScancodeDown("a", "left", "kp4") then dx = -1 end
            if ke.isScancodeDown("s", "down", "kp2") then dy = 1 end
            if ke.isScancodeDown("w", "up", "kp8") then dy = -1 end
            self.player:move(dx, dy, self, dt)
        end
        self.treeTime = (self.treeTime + dt)
        if (self.treeTime > 1) then
            addTree(self)
            self.treeTime = 0
        end
        self.elapsed = (self.elapsed + dt)
        self.player.scale = ((self.player.y / H) * (self.player.hp * 0.01))
        do
        end
        (self.player):update(dt, self)
        for i, tree in ipairs(self.trees) do
            if ((tree.x + self.cx) < (self.width * -0.5)) then
                tree.x = (tree.x + self.width)
            elseif ((tree.x + self.cx) > (self.width * 0.5)) then
                tree.x = (tree.x - self.width)
            end
            if checkCollision(tree, self.player) then
                do
                end
                (self.player):collided(tree.element)
                tree:collided(self.player.element)
            end
            tree:update(dt)
            if (#tree.branches < 1) then
                self.player.xp = (self.player.xp + 10)
                self.player.hp = (self.player.hp + 2)
                table.remove(self.trees, i)
            end
        end
        self.sky:update(dt)
        self.ground:collide(self.player)
        self.ground:update(dt, self)
        self.usingTouchMove = false
    end
end
return {checkVisible = checkVisible, draw = draw, init = init, keypressed = keypressed, touch = touch, update = update}