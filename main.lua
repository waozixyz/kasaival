local push = require("lib.push")
local suit = require("lib.suit")

local ev = love.event
local gr = love.graphics
local ke = love.keyboard
local mo = love.mouse
local sy = love.system

local gameWidth, gameHeight = 1920, 1080
Testing = true

local mode
local function set_mode(mode_name, ...)
    mode = require("lib.scenes." .. mode_name)
    if mode.init then mode:init(set_mode, ...) end
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
    if sy.getOS() == "Android" or sy.getOS() == "iOS" then
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
    set_mode("Splash")

    suit.theme.color = uiTheme
    mode:init(set_mode)
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
    
    if x and y then
        suit.updateMouse(x, y)
        if mo.isDown(1) and mode.touch then
            mode:touch(x, y, dt)
        end
    end
        
    mode:update(dt, set_mode)
end

function love.keypressed(key)
    if key == "f" or key == "f11" then
        push:switchFullscreen()
    elseif ke.isDown("lctrl", "rctrl", "capslock") and key == "q" then
        ev.quit()
    else
        mode:keypressed(key, set_mode)
    end
end

function love.focus(f)
  if mode.focus then
    mode:focus(f)
  end
end
