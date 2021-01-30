local lyra = require "lib.lyra"

local ma = love.math

local deg_to_rad = math.pi / 180

local function addLeaf(x, y, w, cs)
    return { x = x, y = y, color = lyra.getColor(cs), w = w * ma.random(8, 10) * .1, h = w * ma.random(8, 10) * .1 }
end

return function(l, v, angle, cs_b, cs_l)
    local w, h = v.w * 0.9, v.h * 0.95
    local rtn = {}
    rtn.color = lyra.getColor(cs_b)
    rtn.deg, rtn.w, rtn.h = angle, w, h
    local nx = math.floor(v.n[1] + math.cos(angle * deg_to_rad) * h)
    local ny = math.floor(v.n[2] + math.sin(angle * deg_to_rad) * h)
    rtn.n = {nx, ny}
    rtn.p = v.n
    if l > 2 then
        rtn.leaf = addLeaf(ma.random(-w, w), ma.random(-2, 2), w, cs_l)
    end
    return rtn
end