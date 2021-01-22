local push = require("lib.push")
local suit = require("lib.suit")

local ev = love.event
local gr = love.graphics
local ke = love.keyboard
local mo = love.mouse
local sy = love.system
local to = love.touch

local gameWidth, gameHeight = 1920, 1080
Testing = true

local mode = require("src.Menu")

if Testing then mode = require("src.Game") end

local function set_mode(mode_name, ...)
    mode = require(mode_name)
    if mode.init then mode:init(...) end
end

local uiTheme = {
    active = {bg = {.2, 0, .1}, fg = {.5, .1, .2}},
    hovered = {
        bg = {.4, .1, .14},
        fg = {.9, 0, .1}
    },
    normal = {
        bg = {.3, .1, .14},
        fg = {.7, 0, .34}
    }
}

function love.load()
    local fullscreen = false
    local resizable = true
    local windowWidth, windowHeight = 1200, 675
    if ((sy.getOS() == "Android") or (sy.getOS() == "iOS")) then
        fullscreen = true
        resizable = false
        windowWidth, windowHeight = gr.getDimensions()
    end
    push:setupScreen(
        gameWidth,
        gameHeight,
        windowWidth,
        windowHeight,
        {fullscreen = fullscreen, highdpi = true, resizable = resizable}
    )
    suit.theme.color = uiTheme
    mode:init()
end

function love.resize(w, h)
    if mode.resize then
        mode:resize()
    end
    push:resize(w, h)
end

function love.draw()
    push:start()
    gr.setColor(1, 1, 1)
    mode:draw()
    gr.setColor(1, 1, 1)
    suit.draw()
    push:finish()
end

function love.update(dt)
    local x, y = push:toGame(mo.getPosition())
    x = (x or 0)
    y = (y or 0)
    suit.updateMouse(x, y)
    if mode.touch then
        local touches = to.getTouches()
        if (#touches > 0) then
            for i, v in ipairs(touches) do
                local x0, y0 = push:toGame(mo.getPosition(v))
                if (x0 and y0) then
                    mode:touch(x0, y0, dt)
                end
            end
        end
        if mo.isDown(1) then
            local x0, y0 = push:toGame(mo.getPosition())
            if (x0 and y0) then
                mode:touch(x0, y0, dt)
            end
        end
    end
    mode:update(dt, set_mode)
end

function love.keypressed(key)
    if ((key == "f") or (key == "f11")) then
        push:switchFullscreen()
    elseif (ke.isDown("lctrl", "rctrl", "capslock") and (key == "q")) then
        ev.quit()
    else
        mode:keypressed(key, set_mode)
    end
end
