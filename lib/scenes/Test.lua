local copy = require "lib.copy"
local push = require "lib.push"

local Player = require "lib.Player"
local Sakura = require "lib.trees.Sakura"
local Typewriter = require "lib.ui.Typewriter"

local gr = love.graphics
local ke = love.keyboard
local ev = love.event

local function init(self)
    self.step = 1

    -- step 1: set up the text intro
    self.font = gr.newFont("assets/fonts/hintedSymbola.ttf", 142)
    self[1] = copy(Typewriter):init("Nothing", 200, 40, 132)
    self[2] = copy(Typewriter):init("...nothing at all", 1000, 300, 100)
    self[3] = copy(Typewriter):init("...and yet", 300, 400, 120)
    self[4] = copy(Typewriter):init("you feel something", 900, 700, 100)
    self.alpha = 1

    -- step 2: drawing flame
    local H = push:getHeight()
    self.tree = Sakura(nil, H * .8, nil, false)
    self.done = false
    self.elapsed = 0
    Player:init({speed = 10})

end

local function touch(self)
    self.next = true
end

local function keypressed(self, key, set_mode)
    if key == "escape" then ev.quit() end
end

local function text_update(self, dt, i, l)
    if i == l then
        if self[i]:update(dt) then
            return true
        end
    elseif self[i]:update(dt) then
      return text_update(self, dt, i + 1, l)
    end
end

local function update(self, dt, set_mode)
    local W = push:getWidth()
    if self.step == 1 then
        if text_update(self, dt, 1, 4) or ke.isScancodeDown("space", "x")then
            self.next = true
        end
        if self.next then
            self.alpha = self.alpha - dt
            if self.alpha < .1 then
                self.step = 2
            end
        end
    elseif self.step > 1 then
        self.elapsed = self.elapsed + dt

        Player:update(dt)
        self.tree:update(dt)

        local dx, dy = 0, 0
        if ke.isScancodeDown("d", "right", "kp6") then dx = 1 end
        if ke.isScancodeDown("a", "left", "kp4") then dx = -1 end
        if ke.isScancodeDown("s", "down", "kp2") then dy = 1 end
        if ke.isScancodeDown("w", "up", "kp8") then dy = -1 end
        Player:move(dx, dy, 0, 100, dt)
        if Player.x > W then
            Player.x = 0
        elseif Player.x < 0 then
            Player.x = W
        end
    end
end

local function draw(self)
    local W, H = push:getDimensions()

    if self.step == 1 then
        for i = 1, 4 do
            self[i]:draw(self.alpha)
        end
    elseif self.step > 1 then
        gr.setColor(.2, .4, .3)
        gr.rectangle("fill", 0, H * .8, W, H * .2)
        Player:draw()
        self.tree:draw()
    end
end

return {draw = draw, init = init, touch = touch, keypressed = keypressed, update = update}
