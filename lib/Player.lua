local push = require("lib.push")
local Flame = require("lib.Flame")

local gr = love.graphics

local function collided(self, oc, f)
    if type(oc) == "table" then self.hp = self.hp + (oc[2] - oc[3]) * .5 end
    if oc == "plant" then self.hp = self.hp + .2 end
end

local function getHitbox(self)
    local w = (self.ow * self.scale)
    local h = (self.oh * self.scale)
    return self.x - (w * 0.5), self.x + (w * 0.5), self.y - (h * 0.2), self.y
end

local function draw(self)
    gr.setColor(1,1,1,1)
    gr.setBlendMode("alpha")
    local W, H = push:getDimensions()
    local sc = self.scale * 2
    local x, y = math.floor(self.x), math.floor(self.y)
    gr.draw(self.flame, x, y, 0, sc, sc, (self.ow * 0.5))
    gr.setBlendMode("alpha")
end

local function init(self, sav)
    sav = sav or {}
    local W, H = push:getDimensions()
    self.x = sav.x or W * .5
    self.y = sav.y or H * .7
    self.xp = sav.xp or 0
    self.hp = sav.hp or 150
    self.lvl = sav.lvl or 0
    self.speed = sav.speed or 20
    self.flame = Flame()
end

local function move(self, dx, dy, g, dt)
    local W, H = push:getDimensions()
    local s = self.speed * self.scale * dt * 20
    dx, dy = dx * s, dy * s
    local x, y = self.x + dx, self.y + dy
    if x + g.cx < W / 4 then
        g.cx = g.cx - dx
    elseif x + g.cx > W - (W / 4) then
        g.cx = g.cx - dx
    end
    if y > H then
        y = H
    elseif (y < (H - g.ground.height)) then
        y = H - g.ground.height
    end
    self.x, self.y = x, y
end

local function update(self, dt)
    if self.hp > 260 then
        self.hp = self.hp - .9
    elseif self.hp > 220 then
        self.hp = self.hp - .6
    elseif self.hp > 160 then
        self.hp = self.hp - .4
    elseif self.hp > 140 then
        self.hp = self.hp - .5
    elseif self.hp > 120 then
        self.hp = self.hp - .3
    elseif self.hp > 100 then
        self.hp = self.hp - .2
    elseif self.hp > 80 then
        self.hp = self.hp - .3
    elseif self.hp > 60 then
        self.hp = self.hp - .4
    else
        self.hp = self.hp - .4
    end
    self.flame:update(dt)

end

return {
    collided = collided,
    draw = draw,
    element = "fire",
    getHitbox = getHitbox,
    init = init,
    move = move,
    oh = 70,
    ow = 23,
    scale = 1,
    update = update
}
