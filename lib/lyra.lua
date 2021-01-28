local function init(self, ...)
    self.items = {}
    for _, v in ipairs({...}) do
        table.insert(self.items, v)
    end
    return self
end

local function update(self, dt)
    for _, v in ipairs(self.items) do
        if v.update then
            v:update(dt)
        end
    end
end

local function draw(self, ...)
    for _, v in ipairs(self.items) do
        if v.draw then
            v:draw(...)
        end
    end
end

return {init = init, update = update, draw = draw, cx = 0, gh = 600}