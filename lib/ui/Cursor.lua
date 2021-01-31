local suit = require("lib.suit")

local mo = love.mouse

local function init(self)
    self.hand = mo.getSystemCursor("hand")
    self.arrow = mo.getSystemCursor("arrow")
end
local function update(self)
    local cursor = self.arrow

    if suit.anyHovered() then
        cursor = self.hand
    end
    if suit.anyHit() then
        cursor = self.arrow
    end
    mo.setCursor(cursor)
end
return {init = init, update = update}
