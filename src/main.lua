-- Libraries
local copy = require("copy")
local push = require("push")
local suit = require("suit")

-- Shortcuts
local ev = love.event
local gfx = love.graphics
local mouse = love.mouse
local sys = love.system

-- Configuration
local gameWidth, gameHeight = 800, 600
local isMobile = sys.getOS() == "Android" or sys.getOS() == "iOS"
local fullscreen = isMobile
local resizable = not fullscreen
local windowWidth, windowHeight = fullscreen and gfx.getDimensions() or 800, 600

-- Screen Management
local screen
local function set_screen(screen_name, ...)
    screen = copy(require("screens." .. screen_name))
    if screen.init then 
        screen:init(set_screen, ...) 
    end
end

-- LÖVE Callbacks
function love.load()
    push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, 
        {fullscreen = fullscreen, highdpi = true, resizable = resizable}
    )
    set_screen("game")
    gfx.setDefaultFilter("nearest", "nearest")
end

function love.resize(w, h)
    push:resize(w, h)
    if screen.resize then
        screen:resize()
    end
end

function love.draw()
    push:start()
    gfx.setColor(1, 1, 1)
    screen:draw()
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
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

function love.keypressed(key)
    if key == "escape" then
        ev.quit() 
    elseif key == "f" or key == "f11" then
        push:switchFullscreen()
    else
        screen:keypressed(key, set_screen)
    end
    love.keyboard.keysPressed[key] = true
end

function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end

function love.focus(f)
    if screen.focus then 
        screen:focus(f) 
    end
end

function love.errorhandler(msg)
    print("Error: " .. msg)
end

-- Keyboard Helpers
love.keyboard.keysPressed = {}
love.keyboard.keysReleased = {}

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key] or false
end

function love.keyboard.wasReleased(key)
    return love.keyboard.keysReleased[key] or false
end
