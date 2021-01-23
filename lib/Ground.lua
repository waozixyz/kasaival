local push = require("lib.push")

local gr = love.graphics
local ma = love.math

local function rndColor()
    local r = ma.random(0, 3) * .1
    local g = ma.random(3, 5) * .1
    local b = ma.random(1, 4) * .1
    return {r, g, b}
end

local function balanceColor(c, co, m)
    local d = co - c
    if (d > m) then
        return m
    elseif (d < -m) then
        return -m
    else return 0 end
end

local function healTile(tile)
    local c = tile.color
    local co = tile.orgColor
    local r, g, b = c[1], c[2], c[3]
    local ro, go, bo = co[1], co[2], co[3]
    if (r > .6) then
        r = (r - .01)
        g = (g - .007)
        b = (b - .002)
    elseif (r > .5) then
        r = (r - .005)
        g = (g - .005)
        b = (b - .002)
    else
        r = (r + balanceColor(r, ro, .001))
        g = (g + balanceColor(g, go, .0003))
        b = (b + balanceColor(b, bo, .00005))
    end
    if (g < .07) then g = .07 end
    if (b < .07) then b = .07 end
    return {r, g, b}
end

local function burnTile(tile)
    local c = tile.color
    local r, g, b = c[1], c[2], c[3]
    if (r < .3) then
        r = (r + .17)
    elseif (r < .5) then
        r = (r + .12)
    elseif (r < .6) then
        r = (r + .08)
    elseif (r < .7) then
        r = (r + .05)
    elseif (r < .8) then
        r = (r + .03)
    end
    return {r, g, b}
end

local function getTile(i, v)
    if (i % 2 == 0) then
        return (v.x - (v.w * 0.5)), v.y, v.x, (v.y - v.h), (v.x + (v.w * 0.5)), v.y
    elseif ((i % 2) == 1) then
        return v.x, (v.y - v.h), (v.x + (v.w * 0.5)), v.y, (v.x + v.w), (v.y - v.h)
    end
end
local rows = 20

local function collide(self, obj)
    local l, r, u, d = obj:getHitbox()

    for _, row in ipairs(self.grid) do
        for _, v in ipairs(row) do
            if ((v.x <= r) and ((v.x + v.w) >= l) and ((v.y - v.h) <= d) and (v.y >= u)) then
                obj:collided(v.color)
                v.color = burnTile(v)
            end
        end
    end
end

local function draw(self, g)
    for _, row in ipairs(self.grid) do
        for i, tile in ipairs(row) do
            if g:checkVisible(tile.x, tile.w) then
                gr.setColor(tile.color)
                gr.polygon("fill", getTile(i, tile))
            end
        end
    end
end
local function init(self, sav, gw, gh)
    local H = push:getHeight()
    local y = gh
    self.height = (H - y)
    local w = (self.height / rows)
    local h = w
    local i = 0
    if (sav and sav.grid) then self.grid = sav.grid else self.grid = {} end
    if (#self.grid == 0) then
        while (y < (H + h)) do
            local row = {}
            w, h = (w + 1), (h + 1)
            for x = (gw * -0.5), (gw - (gw * 0.5)), w do
                local c = rndColor()
                table.insert(row, {color = c, h = h, orgColor = c, w = w, x = x, y = y})
                c = rndColor()
                table.insert(row, {color = c, h = h, orgColor = c, w = w, x = x, y = y})
                i = (i + 2)
            end
            table.insert(self.grid, row)
            y = (y + h)
        end
    end
end
local function update(self, dt, g)
    for _, row in ipairs(self.grid) do
        for _, tile in ipairs(row) do
            tile.color = healTile(tile)
            if (((tile.x + g.cx) - tile.w) < (g.width * -0.5)) then
                tile.x = (tile.x + g.width)
            elseif ((tile.x + g.cx) > (g.width * 0.5)) then
                tile.x = (tile.x - g.width)
            end
        end
    end
    return nil
end
return {collide = collide, draw = draw, grid = {}, init = init, update = update}
