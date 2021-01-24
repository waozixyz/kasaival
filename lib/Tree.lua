local gr = love.graphics
local ma = love.math
local deg_to_rad = math.pi / 180

local function rnc(l, r)
    return ma.random(l * 10, r * 10) * .1
end

local function rndColor(cs)
    return {rnc(cs[1], cs[2]), rnc(cs[3], cs[4]), rnc(cs[5], cs[6])}
end

local function getLine(p, angle, w, h, cs)
    local nx = math.floor(p[1] + math.cos(angle * deg_to_rad) * h)
    local ny = math.floor(p[2] + math.sin(angle * deg_to_rad) * h)
    return {color = rndColor(cs), deg = angle, h = h, n = {nx, ny}, p = p, w = w}
end

local function grow(self)
    local prev = self.branches[#self.branches]
    local new = {}

    for i, v in ipairs(prev) do
        local w, h = v.w * 0.9, v.h * 0.9
        local split = ma.random(0, 5)

        if split > 1 then
            table.insert(new, getLine(v.n, v.deg - ma.random(20, 30), w, h, self.colorScheme))
            table.insert(new, getLine(v.n, v.deg + ma.random(20, 30), w, h, self.colorScheme))
        end
        if split == 1 then
            table.insert(new, getLine(v.n, v.deg + ma.random(-10, 10), w, h, self.colorScheme))
        end
    end
    table.insert(self.branches, new)
end

local function shrink(self)
    self.elapsed = 0
    table.remove(self.branches, #self.branches)
end

local function collided(self, element)
    if element == "fire" then
        for _, row in ipairs(self.branches) do
            for _, v in ipairs(row) do
                local c = v.color
                local r, g, b = c[1], c[2], c[3]
                if r < .9 then
                    r = r + .04
                end
                if b > .1 then
                    b = b - .02
                end
                v.color = {r, g, b}
                self.hp = self.hp - .8
            end
        end
    end
end

local function draw(self)
    local x = self.x
    local l = #self.branches
    if l > 0 then
        for i, row in ipairs(self.branches) do
            for _, v in ipairs(row) do
                local px, py = v.p[1], v.p[2]
                local nx, ny = v.n[1], v.n[2]
                if (i == l) then
                    nx = px + ((nx - px) / (self.growTime / self.elapsed))
                    ny = py + ((ny - py) / (self.growTime / self.elapsed))
                end
                px, nx = x + px, x + nx
                gr.setColor(v.color)
                gr.setLineWidth(v.w * self.scale)
                gr.line(px, py, nx, ny)
            end
        end
    end
end

local function getHitbox(self)
    local first = self.branches[1][1]
    local w = first.w * self.scale * 2
    local h = first.h * self.scale * 2
    return self.x - w, self.x + w, self.y - h, self.y + h
end



local function init(self, sav)
					local tmpl = {
						   elapsed = 0,
					    collapseTime = 0,
					    colorScheme = {.5, .7, .2, .4, .2, .3},
					    element = "plant",
					    growTime = 1,
					    maxStage = 7,
					    x = 0, y = 0,
					    hp = 100,
					    scale = 1,
					    branches = {},
					    leaves = {}
					}

    for k,v in pairs(tmpl) do
         self[k] = sav[k] or v
    end
 
    local currentStage = sav.currentStage or 0
    local w = sav.w or 12
    local h = sav.h or 32
    local p = {0, self.y}
    local n = {0, self.y - h}
    local branch = {color = rndColor(self.colorScheme), deg = -90, h = h, n = n, p = p, w = w}
    if sav.branches and #sav.branches > 0 then
        self.branches = sav.branches
    else
        table.insert(self.branches, {branch})
    end
    for _ = #self.branches, currentStage do
        grow(self)
    end
end

local function update(self, dt)
    local l = #self.branches
    if self.hp > 80 then
        if l < self.maxStage then
            self.elapsed = self.elapsed + dt
            if self.elapsed > self.growTime then
                grow(self)
                self.elapsed = 0
            end
        end
    elseif l > 0 then

        if l > self.hp / l then self.collapseTime = self.collapseTime + 1 end
        if l < 5 then self.collapseTime = self.collapseTime + dt end
        if self.collapseTime > self.growTime*.5 then
            shrink(self)
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
    end
end
return {
    collided = collided,
    draw = draw,
    getHitbox = getHitbox,
    init = init,
    update = update
}