local lyra = require("lib.lyra")
local push = require("lib.push")

local Controller = require("lib.Controller")
local Flame = require("lib.ps.Flame")

-- aliases
local gr = love.graphics
local ly = lyra

local function startBoost(self)
    self.dp = self.dp * 1.5
    self.boost = true
    self.speed = self.speed * 1.5
end

local function stopBoost(self)
    self.dp = self.dp / 1.5
    self.boost = false
    self.speed = self.speed / 1.5
end

local function collided(self, oc, s, full)
    if type(oc) == "table" then self.hp = self.hp + oc[2] - oc[3] end
    if oc == "plant" then
        self.hp = self.hp + .5
        if full and s == "sakura" then
            self.boostTime = 10
            if not self.boost then
                startBoost(self)
            end
        elseif full then
            self.hp = self.hp + 1
        end
    end
end

local function getHitbox(self)
    local w = (self.ow * self.scale)
    local h = (self.oh * self.scale)
    return self.x - w * 0.5, self.x + w * 0.5, self.y - h * 0.5, self.y + h * .5
end

local function draw(self)
    gr.setColor(1,1,1,1)
    if self.boost then
        gr.setBlendMode("add")
    else
        gr.setBlendMode("alpha")
    end
    gr.draw(self.flame)
    gr.setBlendMode("alpha")
end

local function init(self, sav)
    sav = sav or {}
    local W, H = push:getDimensions()
    self.x = sav.x or W * .5
    self.y = sav.y or H * .7
    self.xp = sav.xp or 0
    self.hp = sav.hp or 200
    self.lvl = sav.lvl or 0
    self.speed = sav.speed or 10
    self.flame = Flame()
    self.sizes = {1, 1, 1, 1, 1, 1, 1, 1}
    self.elapsed = 0
    self.boost = false
    return self
end

local function returnTable(t)
    return t[1], t[2], t[3], t[4], t[5], t[6], t[7]
end
local function getSizes(sizes, scale)
    local rtn = sizes
    rtn[7] = rtn[6] * .7
    rtn[6] = rtn[5] * .7
    rtn[5] = rtn[4] * .7
    rtn[4] = rtn[3] * .7
    rtn[3] = rtn[2] * .7
    rtn[2] = rtn[1]
    rtn[1] = scale
    return rtn
end

local function move(self, dx, dy, dt)
    local W, H = push:getDimensions()
    local s = self.speed * self.scale * dt * 20
    dx, dy = dx * s, dy * s
    local x, y = self.x + dx, self.y + dy
    if x + ly.cx < W / 5 then
        ly.cx = ly.cx - dx
    elseif x + ly.cx > W - (W / 5) then
        ly.cx = ly.cx - dx
    end
    if y < H - ly.gh then
        y = H - ly.gh
    end
    self.flame:setPosition(x, y)
    self.flame:setSizes(returnTable(self.sizes))
    self.x, self.y = x, y
end

local function touch(self, x, y, dt)
    local dx, dy = Controller:touch(self, x, y)
    if dx and dy then
        move(self, dx, dy, dt)
    end
end

local function update(self, dt)
    local dx, dy = Controller:update(self, dt)
    if dx and dy then
        move(self, dx, dy, dt)
    end
    if self.boostTime > 0 then
        self.boostTime = self.boostTime - dt
    elseif self.boost then stopBoost(self) end

    self.elapsed = self.elapsed + dt
    
    if self.elapsed > .2 then
        self.sizes = getSizes(self.sizes, self.scale * .5)
        self.elapsed = 0
    end
    
    self.hp = self.hp - (self.hp / 100) * self.burnRate
    if self.hp > 300 then
        self.hp = self.hp - 10
    end
    if self.hp > 230 then
        self.hp = self.hp - self.burnRate
    end
    if self.hp > 150 or self.hp < 50 then
        self.hp = self.hp - 0.5 * self.burnRate
    end
    if self.hp < 80 or self.hp > 120 then
        self.hp = self.hp - 0.2 * self.burnRate
    end
    self.flame:update(dt)

end

return {
    boostTime = 0,
    collided = collided,
    touch = touch,
    draw = draw,
    element = "fire",
    getHitbox = getHitbox,
    init = init,
    oh = 32, -- height
    ow = 32, -- width
    dp = .5, -- destroy power
    scale = 2,
    update = update,
    burnRate = .1,
}
