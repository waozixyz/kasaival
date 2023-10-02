local copy = require "utils.copy"
local state = require "state"
local push = require "utils.push"

local Controller = require "player.controller"
local Flame = require "ps.flame"

-- aliases
local gfx = love.graphics

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


local function collided(self, obj, burnedFuel)
    local HP = self.HP
    if burnedFuel then
        HP = HP + burnedFuel * 0.01
    end
    if obj and obj.element == "plant" then
        if #obj.branches == obj.stages and obj.special == "sakura" then
            self.boostTime = 10
            if not self.boost then
                startBoost(self)
            end
        elseif #obj.branches == obj.stages then
            HP = HP + .05
        end
    end
    if HP > self.maxHP then
        HP = self.maxHP
    end
    self.HP = HP
end

local function getHitbox(self)
    local w = self.w * self.scale
    local h = self.h * self.scale
    return self.x - w * 0.5, self.x + w * 0.5, self.y - h * 0.5, self.y + h * .5
end

local function draw(self)
    gfx.setColor(1,1,1,1)
    if self.boost then
        gfx.setBlendMode("add")
    else
        gfx.setBlendMode("alpha")
    end
    gfx.draw(self.flame)
    gfx.setBlendMode("alpha")
end

local function init(self, prop)
    prop = prop or {}
    local W, H = push:getDimensions()
    self.x = prop.x or W * .5
    self.y = prop.y or H * .7
    self.speed = prop.speed or 300
    self.flame = Flame()
    self.sizes = {}
    for i = 1, 8 do
        self.sizes[i] = 1
    end
    self.elapsed = 0
    self.boost = false
    return copy(self)
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
    local s = self.speed * self.scale * dt
    dx, dy = dx * s, dy * s
    local x, y = self.x + dx, self.y + dy
    if x + state.cx < W / 5 and -state.cx > state.startx then
        state.cx = state.cx - dx
    elseif x + state.cx > W - (W / 5) and -state.cx + W < state.gw + state.startx then
        state.cx = state.cx - dx
    end
    if x + state.cx > W then
        x = W - state.cx
    elseif x + state.cx < 0 then
        x = 0
    end

    if y > H - self.h * self.scale then
        y = H - self.h* self.scale
    elseif y < H - state.gh - self.h  then
        y = H - state.gh - self.h
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
    local dx, dy = Controller:update()
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
    self.HP = self.HP - self.burnRate*dt
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
    h = 12, -- height
    w = 12, -- width
    bp = 0.01, -- burn power
    scale = 1,
    update = update,
    burnRate = .2,
    HP = 100,
    XP = 0,
    maxXP = 100,
    maxHP = 100,
    type = "player"
}
