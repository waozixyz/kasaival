local Player = require("lib.Player")

local gr = love.graphics

local function draw(self)
    Player:draw()
end
local function init(self)
    Player:init()
end

local function keypressed(self, key, set_mode)
end

local function update(self, dt, set_mode)
    Player:update(dt)
end

return {draw = draw, init = init, keypressed = keypressed, update = update}
