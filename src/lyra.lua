local lume = require "lume"
local push = require "push"

local ma = love.math

local function init(self, ...)
    self.items = {}
    self.cx = 0
    self.gh = 600
    self.gw = 3000
    self.startx = -100
    self.scenes = {}
    self.items = {}
    self.currentScene = 1
    self.next = nil
    self.kill_count = {}

    for _, v in ipairs({...}) do
        table.insert(self.items, v)
    end
    self.visible_items = self.items
    return self
end

local function checkCollision(o1, o2)
    if o1.getHitbox and o2.getHitbox and o1.collided and o2.collided then
        local l1, r1, u1, d1 = o1:getHitbox()
        local l2, r2, u2, d2 = o2:getHitbox()
        if l1 <= r2 and r1 >= l2 and u1 <= d2 and d1 >= u2 then
            o1:collided(o2, o2:collided(o1))
        end
    end
end

local function addDeathCount(self, v)
    if not self.kill_count[v.type] then
        self.kill_count[v.type] = 0
    end
    self.kill_count[v.type] = self.kill_count[v.type] + 1
end

local function update(self, dt)
    for i, v in ipairs(self.items) do
        if v.update then
            v:update(dt)
        end
        if v.dying then
            if not v.recordedDeath then
                addDeathCount(self, v)
                v.recordedDeath = true

                self.player.XP = self.player.XP + 1
            end
        end
        if v.dead then
            if not v.recordedDeath then
                addDeathCount(self, v)
                self.player.XP = self.player.XP + 1
            end
            table.remove(self.items, i)
        end
    end
    if self.player then
        local o1 = self.player
        for _, o2 in ipairs(self.visible_items) do
            if o1 ~= o2 then
                checkCollision(o1, o2)
            end
        end
    end
end

local function checkVisible(self, v)
    local W = push:getWidth()
    local w = v.w + 200 -- add a little extro space
    if v.x + self.cx < W + w and v.x + self.cx > -w then return true else return false end
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

local function getCurrentQuests(self)
    if self.scenes[self.currentScene] and self.scenes[self.currentScene].quests then
        return self.scenes[self.currentScene].quests
    else return {} end
end
local function getCurrentQuestHint(self)
    if self.scenes[self.currentScene] and self.scenes[self.currentScene].questHint then
        return self.scenes[self.currentScene].questHint
    end
     
end

local function getKillCount(self, item)
    if not self.kill_count[item] then
        self.kill_count[item] = 0
    end
    return self.kill_count[item]
end

local function getItems(self, name)
    local rtn = {}
    for _, v in ipairs(self.items) do
        if v.type == name then
            table.insert(rtn, v)
        end
    end
    return rtn
end

return {
    init = init,
    update = update,
    draw = draw,
    checkVisible = checkVisible,
    getColor = getColor,
    getKillCount = getKillCount,
    getCurrentQuests = getCurrentQuests,
    getCurrentQuestHint = getCurrentQuestHint,
    getItems = getItems,
}