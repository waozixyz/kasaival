local copy = require "lib.copy"
local push = require "lib.push"
local lyra = require "lib.lyra"

local Bckg = require "lib.ui.Bckg"
local Text = require "lib.ui.Text"

local gr = love.graphics
local ev = love.event

local function init(self)
    local H = push:getHeight()
    self.alpha = 1
    self.next = false
    Bckg:init()
    self.title = copy(Text:init("KASAIVAL", 256, H * .1))
    self.subtitle = copy(Text:init("an out of control flame trying to survive", 64, H * .4))
    self.continue = copy(Text:init("touch to start burning", 64, H * .8, {1, .6, .4}))
    lyra:init(self.title, self.subtitle, self.continue)
end

local function touch(self)
    self.next = true
end

local function keypressed(self, key, set_mode)
    if key == "escape" then ev.quit() else
        self.next = true
    end
end

local function update(self, dt, set_mode)
    lyra:update(dt)
    if not self.next and self.alpha > 0 then
        self.alpha = self.alpha - dt
    end
    if self.next then
        self.alpha = self.alpha + dt
        if self.alpha > 1 then
            set_mode("Game")
        end
    end
end

local function draw(self)
    gr.setColor(1, 1, 1, 1 - self.alpha)
    Bckg:draw()
    lyra:draw(.8 - self.alpha)
end

return {draw = draw, init = init, touch = touch, keypressed = keypressed, update = update}
