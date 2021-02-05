local copy = require "lib.copy"
local lyra = require "lib.lyra"
local push = require "lib.push"

local gr = love.graphics
local ma = love.math

local function balanceColor(c, co, m)
    local d = co - c
    if d > m then
        return m
    elseif d < -m then
        return -m
    else return 0 end
end

local function findElement(c)
    local r, g, b = c[1], c[2], c[3]
    if r > g and r > b then
        return "sand"
    elseif g > r and g > b then
        return "grass"
    elseif b > r and b > g then
        return "water"
    end
end

local function healTile(tile)
    local c = tile.color
    local oc = tile.orgColor
    local r, g, b = c[1], c[2], c[3]
    local element = findElement(oc)
    if element == "grass" then
        if r > .6 then
            r = r - .01
            g = g - .007
            b = b - .002
        elseif r > .5 then
            r = r - .005
            g = g - .005
            b = b - .002
        end
    elseif element == "sand" then

    end
    r = r + balanceColor(r, oc[1], .001)
    g = g + balanceColor(g, oc[2], .0004)
    b = b + balanceColor(b, oc[3], .0001)
    
    if g < .07 then g = .07 end
    if b < .07 then b = .07 end
    return {r, g, b}
end

local function burnTile(tile)
    local c = tile.color
    local r, g, b = c[1], c[2], c[3]
    local oc = tile.orgColor
    local element = findElement(oc)
    if element == "grass" then
        if r < .3 then
            r = r + .17
        elseif r < .5 then
            r = r + .12
        elseif r < .6 then
            r = r + .08
        elseif r < .7 then
            r = r + .05
        elseif r < .8 then
            r = r + .03
        end
    elseif element == "sand" then
        if g > oc[2] - .13 then
            r = r - .005
            g = g - .01
            b = b - .007
        end
    end
    return {r, g, b}
end

local function getTile(i, v)
    if i % 2 == 0 then
        return v.x - v.w * 0.5, v.y, v.x, v.y - v.h, v.x + v.w * 0.5, v.y
    elseif i % 2 == 1 then
        return v.x, v.y - v.h, v.x + v.w * 0.5, v.y, v.x + v.w, v.y - v.h
    end
end
local rows = 13

local function collide(self, obj)
    local l, r, u, d = obj:getHitbox()

    for _, row in ipairs(self.grid) do
        for _, v in ipairs(row) do
            if v.x <= r and v.x + v.w >= l and v.y - v.h <= d and v.y >= u then
                obj:collided(v)
                v.color = burnTile(v)
            end
        end
    end
end

local function draw(self)
    for _, row in ipairs(self.grid) do
        for i, tile in ipairs(row) do
            if lyra:checkVisible(tile) then
                gr.setColor(tile.color)
                gr.polygon("fill", getTile(i, tile))
            end
        end
    end
end
local function init(self, sav)
    -- default values
	local tmpl = {
        grid = {},
        cs = {0, .3, .3, .5, .1, .3}
    }

    -- replace with sav data
    for k,v in pairs(tmpl) do
         self[k] = sav[k] or v
    end

    local H = push:getHeight()
    local y = H - lyra.gh
    self.height = lyra.gh
    local w = self.height / rows
    local h = w
    local i = 0
    if #self.grid == 0 then
        while y < H + h do
            local row = {}
            for x = lyra.startx - w, lyra.gw + lyra.startx + w, w do
                local cs = self.cs
                -- decide which colocscheme to used based on x position of tile
                if type(cs[1]) == "table" then
                    local offset = lyra.startx - w
                    local id = (#cs * (x - offset) / (lyra:getWidth() - offset)) + 1
                    local r = id - math.floor(id)
                    id = math.floor(ma.random(math.floor(r*10), 10) / 10) + math.floor(id)
                    if id < 1 then id = 1 end
                    if id > #cs then id = #cs end      
                    cs = cs[id]
                end

                local c = lyra.getColor(cs)
                table.insert(row, {color = c, h = h, orgColor = c, w = w, x = x, y = y})
                c = lyra.getColor(cs)
                table.insert(row, {color = c, h = h, orgColor = c, w = w, x = x, y = y})
                i = i + 2
            end
            table.insert(self.grid, row)
            y = y + h
        end
    end
    return copy(self)
end
local function update(self, dt)
    for _, row in ipairs(self.grid) do
        for _, tile in ipairs(row) do
            tile.color = healTile(tile)
        end
    end
end
return {collide = collide, draw = draw, grid = {}, init = init, update = update}
