local Grow = require "lib.plants.Grow"
local Fire = require "lib.ps.Fire"

local copy = require "lib.copy"
local lyra = require "lib.lyra"

local gr = love.graphics
local ma = love.math

    
-- default template
local template = {
    -- element is obvious, but used for collisions
    element = "plant",
    -- default type of plant
    type = "tree",
    -- special powerups, nothing is default
    special = "",
    -- how long it takes to grow
    growTime = 1,
    -- timer to know when to stop burning
    burnTimer = 0,
    -- branch colorscheme
    cs_branch = {.5, .7, .2, .4, .2, .3},
    -- leaf colorscheme
    cs_leaf = {.2, .2, .5, .6, .2, .4},
    -- how many layers the tree will have
    maxStage = 7,
    -- coords
    x = 600, y = 800,
    -- scale
    scale = 1,
    -- size of leaves
    leafSize = 1,
    -- chance of growing a leaf, 0 - 10, 0 is to grow always
    leafChance = 0,
    -- table of all branches, each layer in their of table
    branches = {},
    -- table of all layer
    leaves = {},
    -- the random angle divergence
    splitAngle = {20, 30},
    -- set the frequency of splitting up branhes
    -- generates random number from 1 - 10
    -- if > splitChance then split
    -- else do not split
    splitChance = 4,
    -- how fast this material burns
    burnIntensity = 15,
    -- the amount of fuel this plant provides
    fuel = 20,
    -- the scale of how the size should change at each growth
    changeW = .9,
    changeH = .95,
    -- used for first branch
    currentStage = 0,
    changeColor = {0, 0, 0},
    w = 12, h = 32,
 }


-- fill self with properties of plant or prop
local function fill_self(self, props)
    for k, v in pairs(copy(props)) do
        self[k] = v
    end
end

local function init(self, name, sav)
    -- fill with template
    fill_self(self, template)
    -- fill with name of plant if provided
    if name then
        assert(type(name) == "string", "name of plant needs to be string")
        local props = require ("lib.plants." .. name)
        assert(type(props) == "table", "props from name need to be a table of key values")
        fill_self(self, props)
    end
    -- fill with table if provided
    if sav then
        assert(type(sav) == "table", "save needs to be a table of key values")
        fill_self(self, sav)
    end

    -- set timer value for values counting to 0
    self.growTimer = self.growTime

    if self.randStage then
        self.currentStage = ma.random(0, self.maxStage)
    end
    do
        -- make one start branch if no branches given
        if #self.branches == 0 then
            local w, h = self.w, self.h
            local p = {0, self.y}
            local n = {0, self.y - h}
            local branch = {}
            if not self.twoBranch then
                local b = {deg = -90, h = h, n = n, p = p, w = w}
                b.color = lyra.getColor(self.cs_branch)
                table.insert(branch, b)
            else
                n = {ma.random(5,10), self.y - h}
                local b1 = {deg = -100, h = h, n = n, p = p, w = w}
                b1.color = lyra.getColor(self.cs_branch)
                table.insert(branch, b1)
                n = {ma.random(-10,-5), self.y - h}
                local b2 = {deg = -80, h = h, n = n, p = p, w = w}
                b2.color = lyra.getColor(self.cs_branch)
                table.insert(branch, b2)
            end
            table.insert(self.branches, branch)
            
        end
        -- grow to currentStage
        for _ = #self.branches, self.currentStage do
            table.insert(self.branches, Grow(self))
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
        r = r + .03
    end
    if b > .1 then
        b = b - .01
    end
    return r, g, b
end

local function healColor(r1, g1, b1, cs)
    local r2, g2, b2 = cs[2], cs[3], cs[5]
    if r1 > r2 then
        r1 = r1 - .0013
    end
    if g1 < g2 then
        g1 = g1 + .0007
    end
    if b1 < b2 then
        b1 = b1 + .0007
    end
    return r1, g1, b1
end


local function getColor(self, v, cs)
    local r, g, b = v.color[1], v.color[2], v.color[3]
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
    return r, g, b
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
                    if leaf then
                        leaf.color[4] = (self.growTimer / self.growTime)
                    end
                end
                px, nx = x + px, x + nx
                gr.setColor(getColor(self, v, self.cs_branch))
                gr.setLineWidth(v.w * self.scale)
                gr.line(px, py, nx, ny)
                if leaf then
                    table.insert(leaves, {x = nx + leaf.x, y = ny + leaf.y, w = leaf.w, h = leaf.h, color = leaf.color })
                end
            end
        end
        for _, v in ipairs(leaves) do
            gr.setColor(getColor(self, v, self.cs_leaf))
            gr.ellipse("fill", v.x, v.y, v.w, v.h)
        end
    end

    if self.fire then
        gr.setColor(1, 1, 1)
        gr.draw(self.fire)
    end
end

local function getHitbox(self)
    local w = self.w * self.scale * 2
    local h = self.h * self.scale * 2
    return self.x - w, self.x + w, self.y - h, self.y + h
end

local function getHeight(self)
    local h = self.branches[1][1].h * self.scale
    return #self.branches * h * .7
end

local function update(self, dt)
    local l = #self.branches
    if l > 0 and self.burnTimer <= 0 then
        if l < self.maxStage then
            self.growTimer = self.growTimer + dt
            if self.growTimer >= self.growTime then
                table.insert(self.branches, Grow(self))
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