local Branch = require "lib.plants.Branch"

local ma = love.math

return function(self)
    local l = #self.branches
    if l > 0 then
        local prev = self.branches[l]
        local row = {}

        for _, v in ipairs(prev) do
            if v.oh and v.h ~= v.oh then v.h = v.oh end
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
        return row
    end
end