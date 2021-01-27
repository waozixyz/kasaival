local Fire = require "lib.ps.Fire"

local grow = require "lib.trees.grow"

local gr = love.graphics

local function collided(self, obj)
    if obj.element == "fire" then
        -- reduce hp based on the object destroy power
        self.burnIntensity = obj.dp
        self.burnTimer = 4
        if self.flame then
            self.flame:setEmissionRate(20)
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
                    nx = px + (nx - px) / (self.growTime / self.elapsed)
                    ny = py + (ny - py) / (self.growTime / self.elapsed)
                    if leaf then
                        leaf.color[4] = (self.elapsed / self.growTime)
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

    if self.flame then
        gr.setColor(1, 1, 1)
        gr.draw(self.flame)
    end
end

local function getHitbox(self)
    local first = self.branches[1][1]
    local w = first.w * self.scale * 2
    local h = first.h * self.scale * 2
    return self.x - w, self.x + w, self.y - h, self.y + h
end

local function init(self, sav)
    -- default values
	local tmpl = {
        elapsed = 0,
	    collapseTime = 0,
        branchScheme = {.5, .7, .2, .4, .2, .3},
        leafScheme = {.2, .2, .5, .6, .2, .4},
        element = "plant",
        special = "",
	    growTime = 1,
		maxStage = 7,
		x = 0, y = 0,
		scale = 1,
		branches = {},
        leaves = {},
        burnTimer = 0,
        burnIntensity = 1,
        splitAngle = {20, 30}
    }

    -- replace with sav data
    for k,v in pairs(tmpl) do
         self[k] = sav[k] or v
    end

    do -- fill branches table with data
        local currentStage = sav.currentStage or 0
        local w = sav.w or 12
        local h = sav.h or 32
        local p = {0, self.y}
        local n = {0, self.y - h}
        local branch = {color = grow.rndColor(self.branchScheme), deg = -90, h = h, n = n, p = p, w = w}
        if sav.branches and #sav.branches > 0 then
            self.branches = sav.branches
        else
            table.insert(self.branches, {branch})
        end
        -- grow to currentStage
        for _ = #self.branches, currentStage do
            grow.now(self)
        end
    end
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

local function heal(self)
    for _, row in ipairs(self.branches) do
        for _, v in ipairs(row) do
            v.color = healColor(v.color)
            if v.leaf then
                v.leaf.color = healColor(v.leaf.color)
            end
        end
    end
end

local function getHeight(self)
    local h = self.branches[1][1].h * self.scale
    return #self.branches * h * .7
end
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

local function burn(self)
    for _, row in ipairs(self.branches) do
        for _, v in ipairs(row) do
            v.color = burnColor(v.color)
            if v.leaf then
                v.leaf.color = burnColor(v.leaf.color)
            end
        end
    end
end


local function update(self, dt)
    local l = #self.branches
    if self.burnTimer <= 0 then
        if l < self.maxStage then
            self.elapsed = self.elapsed + dt
            if self.elapsed > self.growTime then
                grow.now(self)
                self.elapsed = 0
            end
        end
        heal(self)
        self.burning = false
    elseif l > 0 then
        if self.elapsed >= 0 then
            self.elapsed = self.elapsed - dt * self.burnIntensity * 15

        else
            shrink(self)
            self.elapsed = self.growTime
        end
        burn(self)
        self.burning = true
        self.burnTimer = self.burnTimer - dt
    else self.burning = false self.dying = true end

    -- have this seperate in case the tree is dead but particles need to die
    if self.burning then
        if not self.flame and l > 0 then
            self.flame = Fire()
            self.flame:setPosition(self.x, self.y)
            self.flame:setSpeed(getHeight(self) * .5)
        end
        self.flame:update(dt)
    elseif self.flame then
        self.flame:setEmissionRate(0)
        self.flame:update(dt)
        if self.flame:getCount() <= 0 then
            self.flame = nil
            if self.dying then
                self.dead = true
            end
        end
    end
end
return {
    collided = collided,
    draw = draw,
    getHitbox = getHitbox,
    init = init,
    update = update
}