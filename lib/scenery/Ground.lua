local copy = require "lib.copy"
local lyra = require "lib.lyra"
local push = require "lib.push"

local Tile = require "lib.scenery.Tile"

local ma = love.math

local rows = 13

local function add(self, width, cs)
    local H = push:getHeight()
    local y = H - self.height
    local w = self.height / rows
    local h = w
    local i = 0
    local startx = self.lastx or 0
    -- left and right bound of ground
    local left = lyra.startx + startx - w
    local right = lyra.startx + startx + width + w
    local x
    while y < H + h do
        local row = {}
        x = left
        while x < right do
            cs = cs or self.cs
            local cs_i = 1
           -- print(#cs)
            -- decide which colocscheme to used based on x position of tile
            if type(cs[cs_i]) == "table" then
                local id = #cs * (x - left) / (right - left) + 1
                local r = id - math.floor(id)
                id = math.floor(ma.random(math.floor(r * 10), 10) / 10) + math.floor(id)
                if id < 1 then
                    id = 1
                end
                if id > #cs then
                    id = #cs
                end
                cs_i = id
            end

            local c = lyra.getColor(cs[cs_i])
            local fuel = c[2] - c[3]
            table.insert(row, Tile:init({color = c, h = h, orgColor = c, w = w, x = x, y = y, fuel = fuel, orgFuel = fuel}))
            c = lyra.getColor(cs[cs_i])
            fuel = c[3] - c[2]
            table.insert(row,Tile:init({color = c, h = h, orgColor = c, w = w, x = x, y = y, fuel = fuel, orgFuel = fuel}))
            i = i + 2
            x = x + w
        end
        table.insert(self.grid, row)
        y = y + h
    end
    self.width = self.width + width
    -- save the last x position
    self.lastx = x
end

local function init(self, prop, height)
    local H = push:getHeight()
    self.height = height or H * .5
    -- default values
    local tmpl = {
        grid = {},
        cs = {0, .3, .3, .5, .1, .3}
    }

    -- replace self with prop data
    if prop then
        for k, v in pairs(tmpl) do
            self[k] = prop[k] or v
        end
        if #self.grid == 0 and prop.width then
            add(self, prop.width)
        end
    end
    
    return copy(self)
end

local function collide(self, obj)
    local l, r, u, d = obj:getHitbox()

    for _, row in ipairs(self.grid) do
        for _, v in ipairs(row) do
            if v.x <= r and v.x + v.w >= l and v.y - v.h <= d and v.y >= u then
                local burnedFuel = 0
                burnedFuel = v:burn(obj)
                v.hit = true
                --print(burnedFuel)
                obj:collided(nil, burnedFuel)
            end
        end
    end
end

local function draw(self)
    for _, row in ipairs(self.grid) do
        for i, v in ipairs(row) do
            if lyra:checkVisible(v) then
                v:draw(i)
            end
        end
    end
end
local function update(self, dt)
    for _, row in ipairs(self.grid) do
        for _, v in ipairs(row) do
            v:update(dt)
        end
    end
end
return {collide = collide, draw = draw, grid = {}, init = init, update = update, add = add, width = 0}
