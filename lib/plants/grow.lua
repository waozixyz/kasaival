local lyra = require "lib.lyra"

local ma = love.math

local deg_to_rad = math.pi / 180

local function addLeaf(self, x, y, w)
    return { x = x, y = y, color = lyra.getColor(self.leafScheme), w = w * ma.random(8, 10) * .1, h = w * ma.random(8, 10) * .1 }
end

local function getLine(self, v, angle)
    local w, h = v.w * 0.9, v.h * 0.95
    local rtn = {}
    rtn.color = lyra.getColor(self.branchScheme)
    rtn.deg, rtn.w, rtn.h = angle, w, h
    local nx = math.floor(v.n[1] + math.cos(angle * deg_to_rad) * h)
    local ny = math.floor(v.n[2] + math.sin(angle * deg_to_rad) * h)
    rtn.n = {nx, ny}
    rtn.p = v.n
    if #self.branches > 2 then
        rtn.leaf = addLeaf(self, ma.random(-w, w), ma.random(-2, 2), w)
    end
    return rtn
end

local function now(self)
    if #self.branches > 0 then
        local prev = self.branches[#self.branches]
        local row = {}

        for _, v in ipairs(prev) do
            -- decide if branch should split into two
            local split = ma.random(1, 3)
            if split > 1 or #prev < 3 then
                local sa = self.splitAngle
                table.insert(row, getLine(self, v, v.deg - ma.random(sa[1], sa[2])))
                table.insert(row, getLine(self, v, v.deg + ma.random(sa[1], sa[2])))
            end
            if split == 1 then
                table.insert(row, getLine(self, v, v.deg + ma.random(-10, 10)))
            end
        
        end
        table.insert(self.branches, row)
    end
end

local function burnColor(c)
    local r, g, b = c[1], c[2], c[3]
    if r < .9 then
        r = r + .03
    end
    if b > .1 then
        b = b - .01
    end
    return {r, g, b}
end

local function burn(self)
    for _, row in ipairs(self.branches) do
        for _, v in ipairs(row) do
            v.color = burnColor(v.color)
            if v.leaf then
                v.leaf.color = burnColor(v.leaf.color)
            end
        end
    end
end

local function healColor(c)
    local r, g, b = c[1], c[2], c[3]
    if r > .3 then
        r = r - .0013
    end
    if g < .2 then
        g = g + .0007
    end
    if b < .12 then
        b = b + .0007
    end
    return {r, g, b}
end

local function heal(self)
    for _, row in ipairs(self.branches) do
        for _, v in ipairs(row) do
            v.color = healColor(v.color)
            if v.leaf then
                v.leaf.color = healColor(v.leaf.color)
            end
        end
    end
end


return {now = now, burn = burn, heal = heal}