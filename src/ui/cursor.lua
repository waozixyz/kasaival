local suit = require("suit")
local mouse = love.mouse

local function init(self)
    self.hand = mouse.getSystemCursor("hand")
    self.arrow = mouse.getSystemCursor("arrow")
end

local function update(self)
    local cursor = self.arrow
    local isHovered = suit.anyHovered() 
    local isHit = suit.anyHit()

    if isHovered then
        cursor = self.hand
    end

    if isHit then
        cursor = self.arrow
    end

    mouse.setCursor(cursor)
end

return {
    init = init,
    update = update
}
