local copy = require "lib.copy"
local lyra = require "lib.lyra"
local push = require "lib.push"

local Controller = require "lib.player.Controller"
local Flame = require "lib.ps.Flame"

-- aliases
local gr = love.graphics

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
        HP = HP + burnedFuel
    end
    if obj and obj.element == "plant" then
        if #obj.branches == obj.stages and obj.special == "sakura" then
            self.boostTime = 10
            if not self.boost then
                startBoost(self)
            end
        elseif #obj.branches == obj.stages then
            HP = HP + 5
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
    self.lvl = sav.lvl or 0
    self.speed = sav.speed or 10
    self.flame = Flame()
    self.sizes = {1, 1, 1, 1, 1, 1, 1, 1}
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
    local s = self.speed * self.scale * dt * 20
    dx, dy = dx * s, dy * s
    local x, y = self.x + dx, self.y + dy
    if x + lyra.cx < W / 5 and -lyra.cx > lyra.startx then
        lyra.cx = lyra.cx - dx
    elseif x + lyra.cx > W - (W / 5) and -lyra.cx + W < lyra.ground.width + lyra.startx then
        lyra.cx = lyra.cx - dx
    end
    if x + lyra.cx > W then
        x = W - lyra.cx
    elseif x + lyra.cx < 0 then
        x = 0
    end
    if y > H then
        y = H
    elseif y < H - lyra.ground.height then
        y = H - lyra.ground.height
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
    self.HP = self.HP - (self.burnRate + (1 - self.HP / self.maxHP))*dt
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
    h = 32, -- height
    w = 22, -- width
    bp = .5, -- burn power
    scale = 2,
    update = update,
    burnRate = 20,
    HP = 1000,
    maxHP = 3000
}
