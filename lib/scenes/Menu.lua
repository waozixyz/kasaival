local push = require("lib.push")
local suit = require("lib.suit")
local Bckg = require("lib.ui.Bckg")
local Cursor = require("lib.ui.Cursor")

local gr = love.graphics
local ev = love.event


local function draw(self)
    Bckg:draw()
end
local function init(self)
    Cursor:init()
    Bckg:init()
end

local function keypressed(self, key, set_mode)
    if ((key == "escape") or (key == "x")) then
        ev.quit()
    end
    if (key == "return") then
        return set_mode("Load")
    end
end
local function update(self, dt, set_mode)
    local W = push:getWidth()
    local w, h = 320, 64
    local x = ((W * 0.5) - (w * 0.5))
    gr.setNewFont(42)
    local start = suit.Button("KASAI", x, 330, w, h)

    if start.hit then
        set_mode("Load")
    end
    local exit = suit.Button("eXtinguish", x, 680, w, h)
    if exit.hit then
        ev.quit()
    end

    Cursor:update()
end
return {draw = draw, init = init, keypressed = keypressed, update = update}
