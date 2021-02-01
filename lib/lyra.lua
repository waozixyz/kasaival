local lume = require "lib.lume"
local push = require "lib.push"

local ma = love.math

local function init(self, ...)
    self.items = {}
    for _, v in ipairs({...}) do
        if v.id == "player" then
            self.player = v
        end
        table.insert(self.items, v)
    end
    self.visible_items = self.items
    return self
end

-- seperate kinetics and static items
-- since it does not make sense to check collision for static + static
local function get_sm_items(tbl)
    local static = {}
    local kinetic = {}
    for _, v in ipairs(tbl) do
        if v.static then
            table.insert(static, v)
        elseif v.kinetic then
            table.insert(kinetic, v)
        end
    end
    return static, kinetic
end
local function checkCollision(o1, o2)
    local l1, r1, u1, d1 = o1:getHitbox()
    local l2, r2, u2, d2 = o2:getHitbox()

    if l1 <= r2 and r1 >= l2 and u1 <= d2 and d1 >= u2 then
        return true
    else
        return false
    end
end

local function update(self, game, dt)
    for i, v in ipairs(self.items) do
        if v.update then
            v:update(dt)
        end
        if v.dead then
            self.player.xp = self.player.xp + 10
            self.player.kelvin = self.player.kelvin + 1
            if not game.kill_count[v.type] then
                game.kill_count[v.type] = 0
            end
            game.kill_count[v.type] = game.kill_count[v.type] + 1
            table.remove(self.items, i)
        end
    end
    local static_items, kinetic_items = get_sm_items(self.visible_items)
    for _, mv in ipairs(kinetic_items) do
        for _, st in ipairs(static_items) do
            if st.getHitbox and mv.getHitbox and st.collided and mv.collided then
                if checkCollision(mv, st) then
                    mv:collided(st)
                    st:collided(mv)
                end
            end
        end
    end
end

local function checkVisible(self, v)
    local W = push:getWidth()
    if v.x + self.cx < W + v.w and v.x + self.cx > -v.w then return true else return false end
end

local function sort_for_draw(self, tbl)
    local rtn = {}
    for _, v in ipairs(tbl) do
        if v.x and v.w then
            if checkVisible(self, v) then
                table.insert(rtn, v)
            end
        else
            table.insert(rtn, v)
        end
    end
    return lume.sort(rtn, "y")
end

local function draw(self, ...)
    self.visible_items = sort_for_draw(self, self.items)
    for _, v in ipairs(self.visible_items) do
        if v.draw then
            v:draw(...)
        end
    end
end


local function getColor(cs)
    local function rnc(l, r)
        return ma.random(l * 100, r * 100) * .01
    end
    return {rnc(cs[1], cs[2]), rnc(cs[3], cs[4]), rnc(cs[5], cs[6]), 1}
end

local function getWidth(self)
    return (self.gw / #self.scenes) * self.currentQuests
end

local function getCurrentQuests(self)
    return self.scenes[self.currentQuests].quests
end

return {
    scenes = {},
    items = {},
    init = init,
    update = update,
    draw = draw,
    checkVisible = checkVisible,
    getColor = getColor,
    cx = 0,
    gh = 600,
    gw = 3000,
    startx = -100,
    getWidth = getWidth,
    currentQuests = 1,
    getCurrentQuests = getCurrentQuests
}