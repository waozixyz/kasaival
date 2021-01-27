local ma = love.math

local deg_to_rad = math.pi / 180

local function rnc(l, r)
    return ma.random(l * 10, r * 10) * .1
end

local function rndColor(cs)
    return {rnc(cs[1], cs[2]), rnc(cs[3], cs[4]), rnc(cs[5], cs[6]), 1}
end

local function addLeaf(self, x, y, w)
    return { x = x, y = y, color = rndColor(self.leafScheme), w = w * ma.random(8, 10) * .1, h = w * ma.random(8, 10) * .1 }
end

local function getLine(self, v, angle)
    local w, h = v.w * 0.9, v.h * 0.95
    local rtn = {}
    rtn.color = rndColor(self.branchScheme)
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

return {now = now, rndColor = rndColor}