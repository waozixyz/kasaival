local grow = require "plants.grow"
local Fire = require "ps.fire"

local copy = require "utils.copy"
local state = require "state"

local gfx = love.graphics
local ma = love.math


local BURN_COLOR_INCREMENT = {.03, 0, -.01}
local HEAL_COLOR_INCREMENT = {-.0013, .0007, .0007}
    
-- default template
local template = {
    element = "plant",
    type = "tree",
    special = "",
    growTime = 1,
    burnTimer = 0,
    cs_branch = {.5, .7, .2, .4, .2, .3},
    cs_leaf = {.2, .2, .5, .6, .2, .4},
    maxStage = 7,
    x = 600, y = 800,
    scale = 1,
    leafSize = 1,
    leafChance = 0,
    branches = {},
    leaves = {},
    splitAngle = {20, 30},
    -- set the frequency of splitting up branhes
    -- generates random number from 1 - 10
    -- if > splitChance then split
    -- else do not split
    splitChance = 4,
    burnIntensity = 1,
    fuel = 5,
    addFuel = 3,
    changeW = .9,
    changeH = .95,
    currentStage = 0,
    changeColor = {0, 0, 0},
    w = 12, h = 32,
    randStage = false,
 }


-- fill self with properties of plant or prop
local function fillSelf(self, props)
    for k, v in pairs(copy(props)) do
        self[k] = v
    end
end

local function init(self, name, props)
    -- fill with template
    fillSelf(self, template)
    
    -- fill with table if provided
    if props then
        assert(type(props) == "table", "props needs to be a table of key values")
        fillSelf(self, props)
    end

    -- set timer value for values counting to 0
    self.growTimer = self.growTime

    if self.randStage then
        self.currentStage = ma.random(0, self.maxStage)
    end
    if self.currentStage == 0 then
        self.first = true
    else
        for _ = #self.branches, self.currentStage do
            table.insert(self.branches, grow(self))
        end
    end
    -- return the new plant
    return copy(self)
end

local function collided(self, obj)
    local burnedFuel = 0
    if obj.element == "fire" then
        local f = self.fuel - obj.bp * self.burnIntensity
        if f < 0 then f = 0 end
        burnedFuel = self.fuel - f
        self.fuel = f
        self.burnTimer = 4
        if self.fire then
            self.fire:setEmissionRate(20)
        end
        self.dp = obj.db
    end
    return burnedFuel
end

local function shrink(self)
    table.remove(self.branches, #self.branches)
end
local function burnColor(r, g, b)
    if r < .9 then
        r = r + BURN_COLOR_INCREMENT[1]
    end
    if b > .1 then
        b = b + BURN_COLOR_INCREMENT[3]
    end
    return r, g, b
end

local function healColor(r1, g1, b1, cs)
    local r2, g2, b2 = cs[2], cs[3], cs[5]
    if r1 > r2 then
        r1 = r1 + HEAL_COLOR_INCREMENT[1]
    end
    if g1 < g2 then
        g1 = g1 + HEAL_COLOR_INCREMENT[2]
    end
    if b1 < b2 then
        b1 = b1 + HEAL_COLOR_INCREMENT[3]
    end
    return r1, g1, b1
end


local function getColor(self, v, cs)
    local r, g, b, a = v.color[1], v.color[2], v.color[3], v.color[4]
    if self.burning then
        r, g, b = burnColor(r, g, b)
    else 
        r, g, b = healColor(r, g, b, cs)
    end
    -- save this as permanent change
    v.color = {r, g, b}

    -- get current color 
    local cc = self.changeColor
    if cc then
        local growth = (#self.branches +  self.growTimer / self.growTime) / self.maxStage 
        r = r + cc[1] * growth
        g = g + cc[2] * growth
        b = b + cc[3] * growth
    end
    return r, g, b, a
end

local function draw(self)
    local leaves = {}
    local x = self.x
    local l = #self.branches
    if l > 0 then
        for i, row in ipairs(self.branches) do
            for _, v in ipairs(row) do
                local leaf = v.leaf
                local px, py = v.p[1], v.p[2]
                local nx, ny = v.n[1], v.n[2]
                if i == l then
                    nx = px + (nx - px) / (self.growTime / self.growTimer)
                    ny = py + (ny - py) / (self.growTime / self.growTimer)
                    v.color[4] = (self.growTimer / self.growTime)
                    if leaf then
                        leaf.color[4] = (self.growTimer / self.growTime)
                    end
                end
                px, nx = x + px, x + nx
                gfx.setColor(getColor(self, v, self.cs_branch))
                gfx.setLineWidth(v.w * self.scale)
                gfx.line(px, py, nx, ny)
                if leaf then
                    table.insert(leaves, {x = nx + leaf.x, y = ny + leaf.y, w = leaf.w, h = leaf.h, color = leaf.color })
                end
            end
        end
        for _, v in ipairs(leaves) do
            gfx.setColor(getColor(self, v, self.cs_leaf))
            gfx.ellipse("fill", v.x, v.y, v.w, v.h)
        end
    end

    if self.fire then
        gfx.setColor(1, 1, 1)
        gfx.draw(self.fire)
    end
end

local function getHitbox(self)
    local w = self.w * self.scale * 2
    local h = self.h * self.scale * 2
    return self.x - w, self.x + w, self.y - h, self.y + h
end

local function getHeight(self)
    if #self.branches > 0 then
        local h = self.branches[1][1].h * self.scale
        return #self.branches * h * .7
    else
        return 0
    end
end

local function update(self, dt)
    local l = #self.branches
    if (l > 0 or self.first) and self.burnTimer <= 0 then
        if l < self.maxStage then
            self.growTimer = self.growTimer + dt
            if self.growTimer >= self.growTime then
                table.insert(self.branches, grow(self))
                self.growTimer = 0
            end
        end
        self.burning = false
    elseif l > 0 then
        if self.growTimer > 0 then
            self.growTimer = self.growTimer - dt * self.burnIntensity
        else
            shrink(self)
        end
        self.burning = true
        self.burnTimer = self.burnTimer - dt
    else self.burning = false self.dying = true end

    -- have this seperate in case the tree is dead but particles need to die
    if self.burning then
        if not self.fire and l > 0 then
            self.fire = Fire()
            self.fire:setPosition(self.x, self.y)
            self.fire:setSpeed(getHeight(self) * .5)
        end
        self.fire:update(dt)
    elseif self.fire then
        self.fire:setEmissionRate(0)
        self.fire:update(dt)
        if self.fire:getCount() <= 0 then
            self.fire = nil
            if self.dying then
                self.dead = true
            end
        end
    end
end


return {
    init = init,
    update = update,
    collided = collided,
    draw = draw,
    getHitbox = getHitbox,
}