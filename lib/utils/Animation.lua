local gr = love.graphics
local copy = require "lib.copy"


local function get_sprite_num(self,add, mult)
    local add, mult = add or 1, mult or 3
    return math.floor(self.currentTime / self.duration * mult) + add
end

local function init(self, image, width, height, duration)

    self.spriteSheet = image

    self.quads = {}

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(self.quads, gr.newQuad(x, y, width, height, image:getDimensions()))
        end
    end
    self.duration = duration
    self.currentTime = 0
    return copy(self)

end

return {init = init, spritenumber = get_sprite_num} 