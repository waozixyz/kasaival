local Branch = require "lib.plants.Branch"
local Fire = require "lib.ps.Fire"

local lyra = require "lib.lyra"

local gr = love.graphics
local ma = love.math


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

local function grow(self)
    local l = #self.branches
    local cs_b, cs_l = self.cs_branch, self.cs_leaf
    if l > 0 then
        local prev = self.branches[#self.branches]
        local row = {}

        for _, v in ipairs(prev) do
            -- decide if branch should split into two
            local split = ma.random(1, self.splitChance)
            if split > 1 or (#prev < 3 and self.startSplit) then
                local sa = self.splitAngle
                local rd = v.deg - ma.random(sa[1], sa[2])
                table.insert(row, Branch(l, v, rd, cs_b, cs_l))
                rd = v.deg + ma.random(sa[1], sa[2])
                table.insert(row, Branch(l, v, rd, cs_b, cs_l))
            end
            if split == 1 then
                table.insert(row, Branch(l, v, v.deg + ma.random(-10, 10), cs_b, cs_l))
            end
        
        end
        table.insert(self.branches, row)
    end
end

local function new(self, sav)
    -- default template
    local plant = {
        -- element is obvious, but used for collisions
        element = "plant",
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
        -- table of all branches, each layer in their of table
        branches = {},
        -- table of all layer
        leaves = {},
        -- the random angle divergence
        splitAngle = {20, 30},
        -- set the frequency of splitting up branhes
        splitChance = 3,
        -- split branches at the beginnig
        startSplit = true,
        -- how fast this material burns
        burnIntensity = 15,
    }
    -- if sav is a string, then its not from the savefile
    -- loads a new tree usinge the name stored in sav
    local prop = {}
    if type(sav) == "string" then
        prop = require ("lib.plants." .. sav)
    elseif type(sav) == "table" then
        prop = sav
    end
    -- fill self with properties of plant or prop
    for k,v in pairs(plant) do
        self[k] = prop[k] or v
    end
    -- set timer value for values counting to 0
    self.growTimer = self.growTime
    do -- fill branches table with data
        local currentStage = sav.currentStage or 0
        local w = sav.w or prop.w or 12
        local h = sav.h or prop.h or 32
        local p = {0, self.y}
        local n = {0, self.y - h}
        local branch = {color = lyra.getColor(self.cs_branch), deg = -90, h = h, n = n, p = p, w = w}
        if sav.branches and #sav.branches > 0 then
            self.branches = sav.branches
        else
            table.insert(self.branches, {branch})
        end
        -- grow to currentStage
        for _ = #self.branches, currentStage do
            grow(prop)
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
    local first = self.branches[1][1]
    local w = first.w * self.scale * 2
    local h = first.h * self.scale * 2
    return self.x - w, self.x + w, self.y - h, self.y + h
end

local function getHeight(self)
    local h = self.branches[1][1].h * self.scale
    return #self.branches * h * .7
end

local function update(self, dt)
    local l = #self.branches
    if self.burnTimer <= 0 then
        if l < self.maxStage then
            self.growTimer = self.growTimer + dt
            if self.growTimer >= self.growTime then
                grow(self)
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
        print(self.burning)
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
    new = new,
    update = update,
    collided = collided,
    draw = draw,
    getHitbox = getHitbox,
}