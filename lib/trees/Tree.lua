local Flame = require "lib.ps.Flame"

local gr = love.graphics
local ma = love.math
local deg_to_rad = math.pi / 180

local function burn(c)

    local r, g, b = c[1], c[2], c[3]
    if r < .9 then
        r = r + .04
    end
    if b > .1 then
        b = b - .02
    end
    return {r, g, b}
end

local function collided(self, obj)
    if obj.element == "fire" then
        for _, row in ipairs(self.branches) do
            for _, v in ipairs(row) do
                v.color = burn(v.color)
                if v.leaf then
                    v.leaf.color = burn(v.leaf.color)
                end

                local m = obj.dp
                self.hp = self.hp - m
            end
        end
    end
end

local function rnc(l, r)
    return ma.random(l * 10, r * 10) * .1
end

local function rndColor(cs)
    return {rnc(cs[1], cs[2]), rnc(cs[3], cs[4]), rnc(cs[5], cs[6]), 1}
end

local function addLeaf(self, x, y, w)
    return { x = x, y = y, color = rndColor(self.leafScheme), w = w * ma.random(8, 10) * .1, h = w * ma.random(8, 10) * .1 }
end

local function getLine(self, p, angle, w, h)
    local rtn = {}
    rtn.color = rndColor(self.branchScheme)
    rtn.deg, rtn.w, rtn.h = angle, w, h
    local nx = math.floor(p[1] + math.cos(angle * deg_to_rad) * h)
    local ny = math.floor(p[2] + math.sin(angle * deg_to_rad) * h)
    rtn.n = {nx, ny}
    rtn.p = p
    if #self.branches > 2 then
        rtn.leaf = addLeaf(self, ma.random(-w, w), ma.random(-2, 2), w)
    end
    return rtn
end

local function grow(self)
    local prev = self.branches[#self.branches]
    local row = {}

    for i, v in ipairs(prev) do
        -- make branches thinner
        local w, h = v.w * 0.9, v.h * 0.9

        -- decide if branch should split into two
        local split = ma.random(1, 3)
        if split > 1 or #prev < 3 then
            local sa = self.splitAngle
            table.insert(row, getLine(self, v.n, v.deg - ma.random(sa[1], sa[2]), w, h))
            table.insert(row, getLine(self, v.n, v.deg + ma.random(sa[1], sa[2]), w, h))
        end
        if split == 1 then
            table.insert(row, getLine(self, v.n, v.deg + ma.random(-10, 10), w, h))
        end
     
    end
    table.insert(self.branches, row)
end

local function shrink(self)
    self.elapsed = 0
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
    end
    for _, v in ipairs(leaves) do
        gr.setColor(v.color)
        gr.ellipse("fill", v.x, v.y, v.w, v.h)
    end
    if self.flame then
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
		hp = 100,
		scale = 1,
		branches = {},
        leaves = {},
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
        local branch = {color = rndColor(self.branchScheme), deg = -90, h = h, n = n, p = p, w = w}
        if sav.branches and #sav.branches > 0 then
            self.branches = sav.branches
        else
            table.insert(self.branches, {branch})
        end
        -- grow to currentStage
        for _ = #self.branches, currentStage do
            grow(self)
        end
    end
end

local function update(self, dt)
    local l = #self.branches
    if self.hp > 70 then
        if l < self.maxStage then
            self.elapsed = self.elapsed + dt
            if self.elapsed > self.growTime then
                grow(self)
                self.elapsed = 0
            end
        end
    elseif l > 0 then
        if not self.flame then
            self.flame = Flame()
            
            self.flame:setPosition(self.x, self.y)
        end
        if math.floor(self.hp / l) % 4 == 0 then self.collapseTime = self.collapseTime + 10 * dt end
        if l > math.floor(self.hp / l) then self.collapseTime = self.collapseTime + 10 * dt end
        if l < 5 then self.collapseTime = self.collapseTime + dt end
        if self.collapseTime > self.growTime*.5 then
         --   shrink(self)
            self.collapseTime = 0
        end

        for _, row in ipairs(self.branches) do
            for _, v in ipairs(row) do
                local c = v.color 
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
                v.color = {r, g, b}
            end
        end

  
        if self.flame then
            self.flame:update(dt)
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