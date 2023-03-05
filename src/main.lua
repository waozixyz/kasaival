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

local screen
local function set_screen(screen_name, ...)
    screen = copy(require("screens." .. screen_name))
    if screen.init then screen:init(set_screen, ...) end
end


function love.load()
    push:setupScreen(
        gameWidth, 
        gameHeight,
        windowWidth,
        windowHeight,
        {fullscreen = fullscreen, highdpi = true, resizable = resizable}
    )
    set_screen("Menu")
    screen:init(set_screen)
    gfx.setDefaultFilter("nearest", "nearest")
end

function love.resize(w, h)
    if screen.resize then
        screen:resize()
    end
    push:resize(w, h)
end

function love.draw()
    push:start()
    gfx.setColor(1, 1, 1)
    screen:draw()
    gfx.setColor(1, 1, 1)
    suit.draw()
    push:finish()
end


function love.update(dt)
    local x, y = push:toGame(mouse.getPosition())
    
    if x and y then
        suit.updateMouse(x, y)
        if mouse.isDown(1) and screen.touch then
            screen:touch(x, y, dt)
        end
    end
        
    screen:update(dt, set_screen)
end

function love.keypressed(key)
    if key == "f" or key == "f11" then
        push:switchFullscreen()
    else
        screen:keypressed(key, set_screen)
    end
end

function love.focus(f)
    if screen.focus then screen:focus(f) end
end

function love.errorhandler(msg)
    print("Error: " .. msg)
end