local lyra = require "lib.lyra"

local ma = love.math

local deg_to_rad = math.pi / 180

local function addLeaf(x, y, w, cs)
    return { x = x, y = y, color = lyra.getColor(cs), w = w * ma.random(8, 10) * .1, h = w * ma.random(8, 10) * .1 }
end

return function(self, v, angle, oh)
    local l = #self.branches
    local cs_b, cs_l = self.cs_branch, self.cs_leaf
    local w, h = v.w * self.changeW, v.h * self.changeH
    local rtn = {}
    rtn.color = lyra.getColor(cs_b)
    rtn.deg, rtn.w, rtn.h = angle, w, h
    local nx = math.floor(v.n[1] + math.cos(angle * deg_to_rad) * h)
    local ny = math.floor(v.n[2] + math.sin(angle * deg_to_rad) * h)
    rtn.n = {nx, ny}
    rtn.p = v.n
    local grow_leaf = ma.random(0, 10)
    if l > 2 and grow_leaf > self.leafChance  then
        rtn.leaf = addLeaf(ma.random(-w, w), ma.random(-2, 2), w * self.leafSize, cs_l)
    end
    -- add special variable of original height
    -- used for cactus grow function
    if oh then
        rtn.oh = oh * .7
    end
    return rtn
end