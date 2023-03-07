local lyra = require "lyra"

local fi = love.filesystem
local gfx = love.graphics

local function init(self, data)
    if data == nil then return self end
    -- load scale for x and y
    self.sx, self.sy = data.sx or 1, data.sy or 1
    -- change lyra.cx by this scale
    self.scx = data.scx or .5
    -- get folder path for assets used
    local path = "assets/scenery/" .. data.name .. "/"
    local items = fi.getDirectoryItems(path)
    -- load each item into self.images table
    self.images = {}
    for _, v in ipairs(items) do
        table.insert(self.images, gfx.newImage(path .. v))
    end
    self.width = self.images[1]:getWidth()

    return self
end

local function draw(self)
    if self.images == nil then return end
    for i, v in ipairs(self.images) do
        gfx.draw(v, lyra.startx + lyra.cx * self.scx * i / #self.images, 0, 0, self.sx, self.sy)
    end
    for i, v in ipairs(self.images) do
        gfx.draw(v, lyra.startx + lyra.cx * self.scx * i / #self.images + self.width, 0, 0, self.sx, self.sy)
    end
end

local function update(self, dt)

end

return {init = init, draw = draw, update = update}