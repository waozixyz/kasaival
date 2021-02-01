local push = require("lib.push")

local gr = love.graphics

local function draw(self)
    for _, v in ipairs(self.items) do
        gr.draw(self.img, v.x, v.y, 0, v.sx, v.sy)
    end
end
local function init(self, img)
    self.img = img or gr.newImage("assets/menu.jpg")
    self.items = {}
    local W, H = push:getDimensions()
    local w, h = (self.img):getDimensions()
    local ws = (W / w) / (1 + math.floor(W / w))
    w = (w * ws)
    local hs = (H / h) / (1 + math.floor(H / h))
    h = math.floor(h * hs)
    for ww = 0, W, w * 2 do
        for hh = 0, H, h * 2 do
            table.insert(self.items, {sx = ws, sy = hs, x = ww, y = hh})
        end
        for hh = 0, H, h * 2 do
            table.insert(self.items, {sx = ws, sy = (-hs), x = ww, y = hh})
        end
    end
    for ww = 0, W, w * 2 do
        for hh = 0, H, h * 2 do
            table.insert(self.items, {sx = (-ws), sy = hs, x = ww, y = hh})
        end
        for hh = 0, H, h * 2 do
            table.insert(self.items, {sx = (-ws), sy = (-hs), x = ww, y = hh})
        end
    end
end
return {draw = draw, init = init}
