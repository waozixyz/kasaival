local lume = require "lume"
local ma = love.math

local function getColor(cs)
    local function rnc(l, r)
        return ma.random(l * 100, r * 100) * .01
    end
    return {rnc(cs[1], cs[2]), rnc(cs[3], cs[4]), rnc(cs[5], cs[6]), 1}
end

return {
    getColor = getColor,
}
