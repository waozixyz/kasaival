local gr = love.graphics

local function draw(self)
end
local function init(self)
end

local function keypressed(self, key, set_mode)
end

local function update(self, dt, set_mode)
    set_mode("Menu")
end

return {draw = draw, init = init, keypressed = keypressed, update = update}
