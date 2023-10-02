local gfx = love.graphics
local copy = require "utils.copy"

local function spritenumber(self, add, mult)
    add, mult = add or 1, mult or 3
    return math.floor(self.currentTime / self.duration * mult) + add
end

local function init(self, image, width, height, duration)

    self.spriteSheet = image

    self.quads = {}

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(self.quads, gfx.newQuad(x, y, width, height, image:getDimensions()))
        end
    end
    self.duration = duration
    self.currentTime = 0
    return copy(self)

end

return {init = init, spritenumber = spritenumber} 