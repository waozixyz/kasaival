local copy = require "utils.copy"
local state = require "state"
local utils = require "utils"
local ems = require "ems"
local Animation = require "utils.animation"
local Pinkel = require "ps.pinkel"
local Plant = require "plants.plant"

-- Constants
local DOG_WIDTH = 106
local DOG_HEIGHT = 64
local DOG_SPEED = 200

-- Aliases
local gfx = love.graphics
local ma = love.math

-- Initialize the dog entity
local function init(self, pos)
    -- Basic properties
    self.element = "earth"
    self.type = "dog"
    self.ability = "growTree"
    self.plantToGrow = "saguaro"
    self.w, self.h = DOG_WIDTH, DOG_HEIGHT
    self.x, self.y = pos.x, pos.y
    self.scale = 1
    self.direction = -1

    -- State properties
    self.fuel = 5
    self.rounds = 0
    self.maxRounds = ma.random(1, 3)
    self.pinkelpause = false
    self.zeito = ma.random(0, 8)
    self.color = utils.getColor({.4, 1, .4, 1, .3, 1})
    self.fading = false
    self.dead = false
    
    -- Animation and particle system
    self.anime = Animation:init(gfx.newImage("assets/mobs/dog.png"), self.w, self.h, 1)
    self.ps = Pinkel()
    
    return copy(self)
end

-- Get the hitbox of the dog
local function getHitbox(self)
    local w = self.w * self.scale
    local h = self.h * self.scale
    return self.x - w * 0.5, self.x + w * 0.5, self.y - h, self.y
end

-- Handle collision
local function collided(self, obj)
    if obj.element == "fire" then
        local r, g, b = self.color[1], self.color[2], self.color[3]
        self.color = {r + .1, g - .1, b - .1}
        self.fading = true
        if not (7.8 <= self.zeito and self.zeito <= 8.2) then
            self.zeito = 7.8
        end
    end
end
-- Draw the dog
local function draw(self)
    local sx, sy = self.scale, self.scale
    sx = (self.direction > 0) and -sx or sx
    gfx.setColor(self.color)
    
    local spriteIndex = 1
    spriteIndex = self.fading and spriteIndex + 6 or spriteIndex
    spriteIndex = self.pinkelpause and spriteIndex + 3 or spriteIndex
    gfx.draw(self.anime.spriteSheet, self.anime.quads[self.anime:spritenumber(spriteIndex)], self.x, self.y, 0, sx, sy, self.w * .5, self.h)

    if self.pinkelpause and not self.fading then
        gfx.setColor(1, 1, 1)
        gfx.draw(self.ps, self.x, self.y - self.h * 0.3, 0, self.scale * -self.direction, self.scale)
    end
end

-- Use the dog's ability
local function useAbility(self)
    if self.ability == "growTree" then
        local itemData = {
            entityType = "plant", 
            entityName = self.plantToGrow, 
            props = {
                x = self.x, 
                y = self.y 
            }
        }
        ems:createAndAddItem(itemData)
    end
end

local function update(self, dt)
    if self.pinkelpause and not self.fading then
        self.ps:update(dt)
    end

    self.anime.currentTime = self.anime.currentTime + dt
    if self.anime.currentTime >= self.anime.duration then
        self.anime.currentTime = 0
    end

    self.zeito = self.zeito + dt
    if self.zeito > 8 then
        self.pinkelpause = true
    end
    if self.zeito > 11 then
        self.pinkelpause = false
        useAbility(self)
        self.zeito = 0
    end
    if self.zeito > 8.2 and self.fading then
        self.dead = true
    end

    if not self.pinkelpause and not self.fading then
        self.x = self.x + DOG_SPEED * dt * self.direction
    end

    if self.x < 0 or self.x > state.gw then
        self.rounds = self.rounds + 1
        if self.rounds < self.maxRounds then
            self.direction = self.direction * -1
        end
    end

    if self.x < - self.w or self.x > state.gw + self.w then
        self.dead = true
    end
end

return {init = init, draw = draw, update = update, getHitbox = getHitbox, collided = collided}
