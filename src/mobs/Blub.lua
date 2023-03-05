local Player = require("player.Player")

local gfx = love.graphics

local function draw(self)
    Player:draw()
end
local function init(self)
    Player:init()
end

local function keypressed(self, key, set_screen)
end

local function update(self, dt, set_screen)
    Player:update(dt)
end

return {draw = draw, init = init, keypressed = keypressed, update = update}
