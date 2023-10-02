local lume = require "utils.lume"
local push = require "utils.push"
local state = require "state"

local Plant = require "plants.plant"

local ems = {}

ems.items = {}
ems.visible_items = {}

function ems:createAndAddItem(itemData, defaultPgw)
    assert(type(itemData) == "table", "itemData must be a table")
    assert(type(defaultPgw) == "number" or defaultPgw == nil, "defaultPgw must be a number or nil")

    local props = itemData.props or {}
    for key, value in pairs(spawner(itemData.pgw or defaultPgw)) do
        props[key] = value
    end

    local item
    if itemData.type == "plant" then
        item = Plant:init(itemData.name, props)
    elseif itemData.type == "mob" then
        item = require("mobs." .. itemData.name):init(props)
    else
        error("Invalid itemData.type: " .. tostring(itemData.type))
    end

    self:addEntity(item)
end

function ems:addEntity(entity)
    table.insert(self.items, entity)
    if entity.type == "player" then
        self.player = entity
    end
end

function ems:removeEntity(entity)
    for i, v in ipairs(self.items) do
        if v == entity then
            table.remove(self.items, i)
            break
        end
    end
end

function ems:checkCollision(o1, o2)
    if o1.getHitbox and o2.getHitbox and o1.collided and o2.collided then
        local l1, r1, u1, d1 = o1:getHitbox()
        local l2, r2, u2, d2 = o2:getHitbox()
        if l1 <= r2 and r1 >= l2 and u1 <= d2 and d1 >= u2 then
            o1:collided(o2, o2:collided(o1))
        end
    end
end

function ems:update(dt)
    for i, entity in ipairs(self.items) do
        if entity.update then
            entity:update(dt)
        end
        if entity.dying or entity.dead then
            if not entity.recordedDeath then
                addDeathCount(self, v)
                entity.recordedDeath = true

                self.player.XP = self.player.XP + 1
            end
        end
        if entity.dead then
            table.remove(self.items, i)
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
end

function ems:checkVisible(entity)
    local W = push:getWidth()
    local extraSpace = 200
    return entity.x + state.cx < W + entity.w + extraSpace and entity.x + state.cx > -entity.w - extraSpace
end

function ems:sort_for_draw()
    local visible = {}
    for _, entity in ipairs(self.items) do
        if self:checkVisible(entity) then
            table.insert(visible, entity)
        end
    end
    return lume.sort(visible, "y")
end

function ems:draw(...)
    self.visible_items = self:sort_for_draw()
    for _, entity in ipairs(self.visible_items) do
        if entity.draw then
            entity:draw(...)
        end
    end
end

return ems
