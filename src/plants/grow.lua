local utils = require "utils"

local Branch = require "plants.branch"

local ma = love.math

return function(self)
    local prev = self.branches[#self.branches]
    local row = {}
    if not prev then
        -- make one start branch if no branches given
        local w, h = self.w, self.h
        local p = {0, self.y}
        local n = {0, self.y - h}
        if not self.twoBranch then
            local b = {deg = -90, h = h, n = n, p = p, w = w}
            b.color = utils.getColor(self.cs_branch)
            table.insert(row, b)
        else
            n = {ma.random(5, 10), self.y - h}
            local b1 = {deg = -100, h = h, n = n, p = p, w = w}
            b1.color = utils.getColor(self.cs_branch)
            table.insert(row, b1)
            n = {ma.random(-10, -5), self.y - h}
            local b2 = {deg = -80, h = h, n = n, p = p, w = w}
            b2.color = utils.getColor(self.cs_branch)
            table.insert(row, b2)
        end
        self.first = false
    else
        for _, v in ipairs(prev) do
            if v.oh and v.h ~= v.oh then
                v.h = v.oh
            end
            -- decide if branch should split into two
            local split = ma.random(0, 10)

            if split > self.splitChance or #prev < 3 and self.startSplit then
                local sa = self.splitAngle
                --- CACTUS
                if self.type == "cactus" then
                    table.insert(row, Branch(self, v, -90))
                    local rd = v.deg + ma.random(30, 40) * ma.random(-1, 1)
                    local oh = v.h
                    v.h = oh * .6
                    table.insert(row, Branch(self, v, rd, oh))
                else -- TREE
                    local rd = v.deg - ma.random(sa[1], sa[2])
                    table.insert(row, Branch(self, v, rd))
                    rd = v.deg + ma.random(sa[1], sa[2])
                    table.insert(row, Branch(self, v, rd))
                end
            else
                --CACTUS
                if self.type == "cactus" then
                    table.insert(row, Branch(self, v, -90))
                else -- TREE
                    table.insert(row, Branch(self, v, v.deg + ma.random(-10, 10)))
                end
            end
        end
    end
    self.fuel = self.fuel + self.addFuel
    return row
end
