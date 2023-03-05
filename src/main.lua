local copy = require("copy")
local push = require("push")
local suit = require("suit")

local ev = love.event
local gfx = love.graphics
local kbd = love.keyboard
local mouse = love.mouse
local sys = love.system


local gameWidth, gameHeight = 800, 600
local fullscreen = sys.getOS() == "Android" or sys.getOS() == "iOS" and true or false
local resizable = not fullscreen
local windowWidth, windowHeight = fullscreen and gfx.getDimensions() or 800, 600

local mode
local function set_mode(mode_name, ...)
    mode = copy(require("modes." .. mode_name))
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
    push:setupScreen(
        gameWidth, 
        gameHeight,
        windowWidth,
        windowHeight,
        {fullscreen = fullscreen, highdpi = true, resizable = resizable}
    )
    set_mode("Game")
    suit.theme.color = uiTheme
    mode:init(set_mode)
    gfx.setDefaultFilter("nearest", "nearest")

end

function love.resize(w, h)
    if mode.resize then
        mode:resize()
    end
    push:resize(w, h)
end

function love.draw()
    push:start()
    gfx.setColor(1, 1, 1)
    mode:draw()
    gfx.setColor(1, 1, 1)
    suit.draw()
    push:finish()
end


function love.update(dt)
    local x, y = push:toGame(mouse.getPosition())
    
    if x and y then
        suit.updateMouse(x, y)
        if mouse.isDown(1) and mode.touch then
            mode:touch(x, y, dt)
        end
    end
        
    mode:update(dt, set_mode)
end

function love.keypressed(key)
    if key == "f" or key == "f11" then
        push:switchFullscreen()
    elseif kbd.isDown("lctrl", "rctrl", "capslock") and key == "q" then
        ev.quit()
    else
        mode:keypressed(key, set_mode)
    end
end

function love.focus(f)
    if mode.focus then mode:focus(f) end
end

function love.errorhandler(msg)
    print("Error: " .. msg)
end