local function add(self, fuel)
    self.amount = self.amount + fuel
end

local function burn(self, fuel)
    self:add(-fuel)
end

return {add = add, burn = burn, amount = 1000, max = 3000}