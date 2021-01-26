local Player = require("lib.Player")
local Sakura = require("lib.trees.Sakura")

local gr = love.graphics
local ke = love.keyboard

local function draw(self)
    self.o1:draw()
    self.o2:draw()
end
local function init(self)
    self.o1 = Player
    self.o1:init()
    self.o2 = Sakura()
end

local function keypressed(self, key, set_mode)
end

local function update(self, dt, set_mode)
    self.o1:update(dt)
    self.o2:update(dt)

    local dx, dy = 0, 0
    if ke.isScancodeDown("d", "right", "kp6") then dx = 1 end
    if ke.isScancodeDown("a", "left", "kp4") then dx = -1 end
    if ke.isScancodeDown("s", "down", "kp2") then dy = 1 end
    if ke.isScancodeDown("w", "up", "kp8") then dy = -1 end
    self.o1:move(dx, dy, 200, 0, dt)
end

return {draw = draw, init = init, keypressed = keypressed, update = update}
