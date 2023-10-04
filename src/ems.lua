local lume = require "utils.lume"
local push = require "utils.push"
local state = require "state"
local spawner = require "utils.spawner"
local json = require "dkjson"

local Plant = require "plants.plant"

local ems = {}

ems.items = {}
ems.visibleItems = {}

function ems:createAndAddItem(itemData, defaultPgw)
    assert(type(itemData) == "table", "itemData must be a table")
    assert(type(defaultPgw) == "number" or defaultPgw == nil, "defaultPgw must be a number or nil")

    local item
    local props = itemData.props or {}
    if defaultPgw or itemData.pgw then
        for key, value in pairs(spawner(itemData.pgw or defaultPgw)) do
            props[key] = value
        end
    end
    -- Load the JSON data for the specific plant
    if itemData.entityType == "plant" then
        local jsonData = love.filesystem.read("data/" .. itemData.entityType .. "s/" .. itemData.entityName .. ".json")
        local data, _, err = json.decode(jsonData)
        if not data then
            error("Error loading " .. itemData.entityType .. " data: " .. err)
        end

        -- Merge the loaded JSON data into props
        for key, value in pairs(data) do
            props[key] = value
        end
        item = Plant:init(props)
    elseif itemData.entityType == "mob" then
        item = require("mobs." .. itemData.entityName):init(props)
    else
        error("Invalid itemData.type: " .. tostring(itemData.entityType))
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
    if o1 and o2 and o1.getHitbox and o2.getHitbox and o1.collided and o2.collided then
        local l1, r1, u1, d1 = o1:getHitbox()
        local l2, r2, u2, d2 = o2:getHitbox()
        if l1 <= r2 and r1 >= l2 and u1 <= d2 and d1 >= u2 then
            o1:collided(o2, o2:collided(o1))
        end
    end
end

function ems:addDeathCount(entity)
    if not state.killCount[entity.type] then
        state.killCount[entity.type] = 0
    end
    state.killCount[entity.type] = state.killCount[entity.type] + 1
end

function ems:countItemsByTypeAndName(itemType, itemName)
    local count = 0
    for _, item in ipairs(self.items) do
        if item.type == itemType and item.name == itemName then
            count = count + 1
        end
    end
    return count
end

function ems:update(dt)
    for i, entity in ipairs(self.items) do
        if entity.update then
            entity:update(dt)
        end
        if entity.fading or entity.dead then
            if not entity.recordedDeath then
                self:addDeathCount(entity)
                entity.recordedDeath = true
                self.player.XP = self.player.XP + 1
            end
        end
        if entity.dead then
            table.remove(self.items, i)
        end
        if self.player then
            local o1 = self.player
            for _, o2 in ipairs(self.visibleItems) do
                if o1 ~= o2 then
                    self:checkCollision(o1, o2)
                end
            end
        end
    end
end


function ems:checkVisible(entity)
    local W = push:getWidth()
    local w = entity.w + 200
    if entity.x + state.cx < W + w and entity.x + state.cx > -w then return true else return false end
end

function ems:sortForDraw()
    local rtn = {}
    for _, entity in ipairs(self.items) do
        if ems:checkVisible(entity) then
            table.insert(rtn, entity)
        end
    end
    
    return lume.sort(rtn, "y")
end

function ems:draw(...)
    self.visibleItems = self:sortForDraw()
    for _, entity in ipairs(self.visibleItems) do
        if entity.draw then
            entity:draw(...)
        end
    end
end

return ems
