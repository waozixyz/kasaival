local copy = require("lib.copy")
local lume = require("lib.lume")
local push = require("lib.push")
local serpent = require("lib.serpent")

local Ground = require("lib.Ground")
local HUD = require("lib.HUD")
local Music = require("lib.Music")
local Player = require("lib.Player")
local Saves = require("lib.Saves")
local Sky = require("lib.Sky")
local Tree = require("lib.Tree")

local fi = love.filesystem
local gr = love.graphics
local ke = love.keyboard
local ma = love.math

local function addTree(self, randStage)
    local H = push:getHeight()

    local y = ma.random(0, H - self.height)
    local scale = (y + self.height) / H

    local W = self.width
    local x = ma.random(W * -0.5, W + W * -0.5)

    local vir_x = x / scale

    local rat_x = x / vir_x
    y =  self.height + (y * rat_x)

    local w = ma.random(22, 33) * scale
    local h = ma.random(62, 96) * scale

    table.insert(self.trees, copy(Tree))

    local tree = self.trees[#self.trees]
    local maxStage = ma.random(6, 8)
    local currentStage = nil
    if randStage then currentStage = ma.random(0, maxStage) else currentStage = 0 end
    local growTime = ma.random(1, 3)
    local cs1 = {.5, .7, .2, .4, .2, .3}
    local cs2 = {.5, .6, .4, .6, .2, .3}
    local cs3 = {.3, .5, .2, .4, .3, .5}

    local c = ({cs1, cs2, cs3})[ma.random(1, 3)]
    tree:init(
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
    for _, v in ipairs(self.trees) do table.insert(t, getProp(v)) end
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

    if l1 <= r2 and r1 >= l2 and u1 <= d2 and d1 >= u2 then
        return true
    else
        return false
    end
end

local radToDeg = 180 / math.pi
local degToRad = math.pi / 180

local function checkVisible(self, x, w)
    local W = push:getWidth()
    if x + self.cx < W + w and x + self.cx > -w then return true else return false end
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
    self.muted = sav.muted or false
    self.treeTime = sav.treeTime or 0
    self.cx = sav.cx or 0

    
    self.trees = {}
    local sky, p, g, t = sav.sky or {}, sav.p or {}, sav.g or {}, sav.t or nil

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
    if t and #t > 0 then
        for _, v in ipairs(t) do
            table.insert(self.trees, copy(Tree))
            local tree = self.trees[#self.trees]
            tree:init(v)
        end
    else
        for _ = 1, 60 do
            addTree(self, true)
        end
    end

end

local function keypressed(self, key, set_mode)
    HUD:keypressed(self, key, set_mode)
end

local function touch(self, x, y, dt)
    HUD:touch(self, x, y)
    if not self.paused then
        local px, py = self.player.x, self.player.y
        x = x - self.cx
        local nx, ny = x - px, y - py
        local w = self.player.scale * self.player.ow * 0.2
        local h = self.player.scale * self.player.oh * 0.2
        if nx < w and nx > -w and ny < h and ny > -h then
            nx = nil
            ny = nil
        end
        if y > 100 and nx and ny then
            local angle = math.atan2(nx, ny) * radToDeg
            if angle < 0 then
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

local function focus(self, f)
    -- when the game is not focused, pause and mute music
    if not f then
        if not self.paused then
            self.unpause = true
            self.paused = true
        end
        if not self.muted then
            self.muted = true
            self.unmute = true
        end
    else
        if self.unmute then
            self.muted = false
            self.unmute = false
        end
        if self.unpause then
            self.paused = false
            self.unpause = false
        end
    end
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
        set_mode("lib.Game")
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
        Music.bgm:pause()
        set_mode("lib.Menu")
    elseif not self.paused and self.player.hp > 0 then
        if not self.usingTouchMove then
            local dx, dy = 0, 0
            if ke.isScancodeDown("d", "right", "kp6") then dx = 1 end
            if ke.isScancodeDown("a", "left", "kp4") then dx = -1 end
            if ke.isScancodeDown("s", "down", "kp2") then dy = 1 end
            if ke.isScancodeDown("w", "up", "kp8") then dy = -1 end
            self.player:move(dx, dy, self, dt)
        end
        self.treeTime = self.treeTime + dt
        if self.treeTime > 1 then
            addTree(self)
            self.treeTime = 0
        end
        self.elapsed = self.elapsed + dt
        self.player.scale = (self.player.y / H) * self.player.hp * 0.01

        self.player:update(dt, self)
        for i, tree in ipairs(self.trees) do
            if tree.x + self.cx < self.width * -0.5 then
                tree.x = tree.x + self.width
            elseif tree.x + self.cx > self.width * 0.5 then
                tree.x = tree.x - self.width
            end
            if checkCollision(tree, self.player) then
                do
                end
                self.player:collided(tree.element)
                tree:collided(self.player)
            end
            tree:update(dt)
            if #tree.branches < 1 then
                self.player.xp = self.player.xp + 10
                self.player.hp = self.player.hp + 1
                table.remove(self.trees, i)
            end
        end
        self.sky:update(dt)
        self.ground:collide(self.player)
        self.ground:update(dt, self)
        self.usingTouchMove = false
    end
end
return {checkVisible = checkVisible, draw = draw, init = init, keypressed = keypressed, touch = touch, focus = focus, update = update}
