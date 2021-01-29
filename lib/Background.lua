local lyra = require "lib.lyra"

local fi = love.filesystem
local gr = love.graphics

local function init(self, location)
    local path = "assets/" .. location .. "/"
    local items = fi.getDirectoryItems(path)
    self.images = {}
    for _, v in ipairs(items) do
        table.insert(self.images, gr.newImage(path .. v))
    end
    return self
end

local function draw(self)
    for i, v in ipairs(self.images) do
        gr.draw(v, lyra.startx + lyra.cx * .5 * i / #self.images)
    end
end

local function update(self, dt)

end

return {init = init, draw = draw, update = update}