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
    set_screen("Game")
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

love.keyboard.keysPressed = { }
love.keyboard.keysReleased = { }
-- returns if specified key was pressed since the last update
function love.keyboard.wasPressed(key)
	if (love.keyboard.keysPressed[key]) then
		return true
	else
		return false
	end
end
-- returns if specified key was released since last update
function love.keyboard.wasReleased(key)
	if (love.keyboard.keysReleased[key]) then
		return true
	else
		return false
	end
end
-- concatenate this to existing love.keypressed callback, if any
function love.keypressed(key, unicode)
	love.keyboard.keysPressed[key] = true
end
-- concatenate this to existing love.keyreleased callback, if any
function love.keyreleased(key)
	love.keyboard.keysReleased[key] = true
end
-- call in end of each love.update to reset lists of pressed\released keys
function love.keyboard.updateKeys()
	love.keyboard.keysPressed = { }
	love.keyboard.keysReleased = { }
end

function love.update(dt)
    local x, y = push:toGame(mouse.getPosition())
    
    if x and y then
        suit.updateMouse(x, y)
        if mouse.isDown(1) and screen.touch then
            screen:touch(x, y, dt)
        end
    end
    print(#love.keyboard.keysPressed)
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