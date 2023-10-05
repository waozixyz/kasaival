local state = require "state"
local fi = love.filesystem
local gfx = love.graphics

local function init(self, data)
    if not data then return self end
    
    self.sx, self.sy = data.sx or 1, data.sy or 1
    self.scx = data.scx or .5

    if not data.name then
        print("Error: No name provided for asset!")
        return self
    end

    local path = "assets/scenery/" .. data.name .. "/"
    local items = fi.getDirectoryItems(path)
    
    self.images = {}
    for _, v in ipairs(items) do
        local image = gfx.newImage(path .. v)
        if image then
            table.insert(self.images, image)
        else
            print("Error loading image:", v)
        end
    end

    if #self.images > 0 then
        self.width = self.images[1]:getWidth()
    end

    return self
end

local function draw(self)
    if not self.images then return end

    local function computeXPosition(i)
        return 0 + state.cx * self.scx * i / #self.images
    end

    for i, v in ipairs(self.images) do
        gfx.draw(v, computeXPosition(i), 0, 0, self.sx, self.sy)
        gfx.draw(v, computeXPosition(i) + self.width, 0, 0, self.sx, self.sy)
    end
end

return {init = init, draw = draw}
