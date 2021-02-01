local Grow = require "lib.plants.Grow"
local Fire = require "lib.ps.Fire"

local copy = require "lib.copy"
local lyra = require "lib.lyra"

local gr = love.graphics

    
-- default template
local template = {
    -- set the item propert
    static = true,
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
    -- split branches at the beginnig
    startSplit = true,
    -- how fast this material burns
    burnIntensity = 15,
    -- the scale of how the size should change at each growth
    changeW = .9,
    changeH = .95,
    -- used for first branch
    currentStage = 0,
    w = 12, h = 32,
 }

local function burnColor(c)
    local r, g, b = c[1], c[2], c[3]
    if r < .9 then
        r = r + .03
    end
    if b > .1 then
        b = b - .01
    end
    return {r, g, b}
end

local function healColor(c)
    local r, g, b = c[1], c[2], c[3]
    if r > .3 then
        r = r - .0013
    end
    if g < .2 then
        g = g + .0007
    end
    if b < .12 then
        b = b + .0007
    end
    return {r, g, b}
end


local function changeColor(self, action)
    if action == "heal" then action = healColor
    elseif action == "burn" then action = burnColor end

    for _, row in ipairs(self.branches) do
        for _, v in ipairs(row) do
            v.color = action(v.color)
            if v.leaf then
                v.leaf.color = action(v.leaf.color)
            end
        end
    end
end
-- fill self with properties of plant or prop
local function fill_self(self, props)
    for k,v in pairs(copy(props)) do
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
    do
        -- make one start branch if no branches given
        if #self.branches == 0 then
            local w, h = self.w, self.h
            local p = {0, self.y}
            local n = {0, self.y - h}
            local branch = {color = lyra.getColor(self.cs_branch), deg = -90, h = h, n = n, p = p, w = w}
            table.insert(self.branches, {branch})
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
    if obj.element == "fire" then
        -- reduce hp based on the object destroy power
        self.burnIntensity = obj.dp
        self.burnTimer = 4
        if self.fire then
            self.fire:setEmissionRate(20)
        end
    end
end

local function shrink(self)
    table.remove(self.branches, #self.branches)
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
                gr.setColor(v.color)
                gr.setLineWidth(v.w * self.scale)
                gr.line(px, py, nx, ny)
                if leaf then
                    table.insert(leaves, {x = nx + leaf.x, y = ny + leaf.y, w = leaf.w, h = leaf.h, color = leaf.color })
                end
            end
        end
        for _, v in ipairs(leaves) do
            gr.setColor(v.color)
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
        changeColor(self, "heal")
        self.burning = false
    elseif l > 0 then
        if self.growTimer > 0 then
            self.growTimer = self.growTimer - dt * self.burnIntensity
        else
            shrink(self)
        end
        changeColor(self, "burn")
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