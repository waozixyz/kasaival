local lyra = require "lib.lyra"

local ke = love.keyboard

local radToDeg = 180 / math.pi
local degToRad = math.pi / 180

local function touch(self, obj, x, y)
    local px, py = obj.x, obj.y
    x = x - lyra.cx
    local nx, ny = x - px, y - py
    local w = obj.scale * obj.w * 0.2
    local h = obj.scale * obj.h * 0.2
    if nx < w and nx > -w and ny < h and ny > -h then
        nx = nil
        ny = nil
    end
    if nx and ny then
        local angle = math.atan2(nx, ny) * radToDeg
        if angle < 0 then
            angle = 360 + angle
        end
        angle = angle * degToRad
        self.usingTouchMove = true
        return math.sin(angle), math.cos(angle)
    end
end

local function update(self)
    if not self.usingTouchMove then
        local dx, dy = 0, 0
        if ke.isScancodeDown("d", "right", "kp6") then dx = 1 end
        if ke.isScancodeDown("a", "left", "kp4") then dx = -1 end
        if ke.isScancodeDown("s", "down", "kp2") then dy = 1 end
        if ke.isScancodeDown("w", "up", "kp8") then dy = -1 end
        return dx, dy
    end
    self.usingTouchMove = false
end

return { touch = touch, update = update }