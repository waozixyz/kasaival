local copy = require "copy"
local state = require "state"
local utils = require "utils"
local push = require "push"

local Tile = require "scenery.Tile"
local ems = require "ems"

local ma = love.math

local rows = 9

local function add(self, width, cs)
    local H = push:getHeight()
    local y = H - self.height
    local w = self.height / rows
    local h = w
    local i = 0
    local startx = self.lastx or state.startx
    -- left and right bound of ground
    local left = startx - w
    local right = startx + width + w
    local x
    while y < H + h do
        local row = {}
        x = left
        while x < right do
            cs = cs or self.cs
            local cs_i = 1
            -- decide which colocscheme to used based on x position of tile
            if type(cs[cs_i]) == "table" then
                local id = #cs * (x - left) / (right - left) + 1
                local r = id - math.floor(id)
                id = math.floor(ma.random(math.floor(r * 10), 10) / 10 + id)
                if id < 1 then
                    id = 1
                end
                if id > #cs then
                    id = #cs
                end
                cs_i = id
            end

            local c = utils.getColor(cs[cs_i])
            local fuel = c[2] - c[3]
            table.insert(row, Tile:init({color = c, h = h, orgColor = c, w = w, x = x, y = y, fuel = fuel, orgFuel = fuel}))
 
            i = i + 1
            x = x + w * 0.5
        end
        table.insert(self.grid, row)
        y = y + h * 0.5
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
                obj:collided(nil, burnedFuel)
            end
        end
    end
end

local function draw(self)
    for _, row in ipairs(self.grid) do
        for i, v in ipairs(row) do
            if ems:checkVisible(v) then
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
