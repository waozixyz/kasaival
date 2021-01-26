local copy = require "lib.copy"
local push = require "lib.push"

local Bckg = require "lib.ui.Bckg"
local Player = require "lib.Player"
local Sakura = require "lib.trees.Sakura"
local Typewriter = require "lib.ui.Typewriter"

local gr = love.graphics
local ke = love.keyboard
local ev = love.event

local function init(self)
    -- step 1: set up the text intro
    self.font = gr.newFont("assets/fonts/hintedSymbola.ttf", 142)
    self[1] = copy(Typewriter):init("Nothing", 200, 40, 132)
    self[2] = copy(Typewriter):init("...nothing at all", 1000, 300, 100)
    self[3] = copy(Typewriter):init("...and yet", 300, 400, 120)
    self[4] = copy(Typewriter):init("you feel something", 900, 700, 100)
    self.alpha = 1
    Bckg:init()
end

local function touch(self)
    self.next = true
end

local function keypressed(self, key, set_mode)
    if key == "escape" then ev.quit() else
    self.next = true
    end
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
    if text_update(self, dt, 1, 4) then
        self.next = true
    end
    if self.next then
        self.alpha = self.alpha - dt
        if self.alpha < .1 then
            set_mode("Menu")
        end
    end
end

local function draw(self)
    gr.setColor(1, 1, 1, 1 - self.alpha)
    Bckg:draw()
    local W, H = push:getDimensions()
    for i = 1, 4 do
        self[i]:draw(self.alpha)
    end 
end

return {draw = draw, init = init, touch = touch, keypressed = keypressed, update = update}
