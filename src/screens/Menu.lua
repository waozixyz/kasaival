local push = require "push"
local lyra = require "lyra"
local Text = require "ui.Text"

local gfx = love.graphics
local ev = love.event

local function init(self)
    local H = push:getHeight()
    self.alpha = 1
    self.next = false
    self.img = gfx.newImage("assets/menu.png")
    self.title = Text:init("KASAIVAL", {size = 86 , y = 50})
    local yellow = {1, .6, .4}
    self.subtitle = Text:init("an out of control flame trying to survive", {size = 25, y = 160})
    self.continue = Text:init("touch to start burning", {size = 50, y = 500, color = yellow} )
    lyra:init(self.title, self.subtitle, self.continue)
end

local function touch(self)
    self.next = true
end

local function keypressed(self, key, set_screen)
    if key == "escape" then 
        ev.quit() 
    elseif key == "space" or key == "return" or key == "x" then
        self.next = true
    end
end


local function update(self, dt, set_screen)
    lyra:update(dt)
    if not self.next and self.alpha > 0 then
        self.alpha = self.alpha - dt
    end
    if self.next then
        self.alpha = self.alpha + dt
        if self.alpha > 1 then
            set_screen("Game")
        end
    end
end

local function draw(self)
    gfx.setColor(1, 1, 1, 1 - self.alpha)
    gfx.draw(self.img, 0, 0, 0, 1.2)

    lyra:draw(.8 - self.alpha)
end

return {draw = draw, init = init, touch = touch, keypressed = keypressed, update = update}
