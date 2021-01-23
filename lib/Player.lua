local push = require("lib.push")
local SpriteSheet = require("lib.SpriteSheet")

local gr = love.graphics

local sprite = nil

local function collided(self, oc, f)
    if (type(oc) == "table") then self.hp = (self.hp + (oc[2] - oc[3]) * .5) end
    if (oc == "plant") then self.hp = (self.hp + .2) end
end

local function getHitbox(self)
    local w = (self.ow * self.scale)
    local h = (self.oh * self.scale)
    return (self.x - (w * 0.5)), (self.x + (w * 0.5)), (self.y - (h * 0.2)), self.y
end

local function draw(self)
    gr.setColor(1, 1, 1)
    sprite:draw(self.x, self.y, 0, self.scale, self.scale, (self.ow * 0.5), self.oh)
end

local function init(self, sav)
    local W, H = push:getDimensions()
    self.x = (sav.x or (W * 0.5))
    self.y = (sav.y or (H * 0.7))
    self.xp = (sav.xp or 0)
    self.hp = (sav.hp or 200)
    self.lvl = (sav.lvl or 0)
    self.speed = (sav.speed or 10)
    local S = SpriteSheet("assets/flame/spr_2.png", self.ow, self.oh)
    local a = S:createAnimation()
    for row = 1, 4 do
        local limit = 43
        if (row == 4) then
            limit = 41
        end
        for col = 1, limit do
            a:addFrame(col, row)
        end
    end
    a:setDelay(0.04)
    sprite = a
end

local function move(self, dx, dy, g, dt)
    local W, H = push:getDimensions()
    local s = self.speed * self.scale * dt * 20
    local dx0, dy0 = (dx * s), (dy * s)
    local x, y = (self.x + dx0), (self.y + dy0)
    if ((x + g.cx) < (W / 4)) then
        g.cx = (g.cx - dx0)
    elseif ((x + g.cx) > (W - (W / 4))) then
        g.cx = (g.cx - dx0)
    end
    if (y > H) then
        y = H
    elseif (y < (H - g.ground.height)) then
        y = (H - g.ground.height)
    end
    self.x, self.y = x, y
end

local function update(self, dt)
    if (self.hp > 260) then
        self.hp = self.hp - 15
    elseif (self.hp > 240) then
        self.hp = self.hp - 2
    elseif (self.hp > 220) then
        self.hp = self.hp - .4
    elseif (self.hp > 170) then
        self.hp = self.hp - .3
    elseif (self.hp > 120) then
        self.hp = self.hp - .2
    elseif (self.hp > 70) then
        self.hp = self.hp - .5
    elseif (self.hp > 50) then
        self.hp = self.hp - 1
    elseif (self.hp > 30) then
        self.hp = self.hp - 3
    else
        self.hp = self.hp - 8
    end
    return sprite:update(dt)
end

return {
    collided = collided,
    draw = draw,
    element = "fire",
    getHitbox = getHitbox,
    init = init,
    move = move,
    oh = 175,
    ow = 31,
    scale = 1,
    update = update
}
