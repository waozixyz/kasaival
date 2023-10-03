local copy = require "utils.copy"
local state = require "state"
local utils = require "utils"

local Animation = require "utils.animation"
local Pinkel = require "ps.Pinkel"
local Plant = require "plants.Plant"

local gfx = love.graphics
local ma = love.math

local function init(self, pos)
    self.element = "earth"
    self.type = "dog"
    self.ability = "Saguaro"
    self.w, self.h = 46, 27
    self.x, self.y = pos.x, pos.y
    self.scale = 2
    self.direction = -1
    self.fuel = 5
    self.pinkelpause = false
    self.anime = Animation:init(gfx.newImage("assets/mobs/dog_sprite.png"), self.w, self.h, 1)
    self.zeito = ma.random(0, 8)
    -- add color variation to dogs
    self.color = utils.getColor({.4, 1, .4, 1, .3, 1})

    --pinkelsystem initiieren
    self.ps = Pinkel()

    return copy(self)
end

local function getHitbox(self)
    local w = self.w * self.scale
    local h = self.h * self.scale
    return self.x - w * 0.5, self.x + w * 0.5, self.y - h * .2, self.y
end

local function collided(self, obj)
    if obj.element == "fire" then
        local r, g, b = self.color[1],self.color[2], self.color[3]
        r, g, b = r + .1, g - .1, b - .1
        self.color = {r, g, b}
        self.fading = true
        if self.zeito < 7.8 or self.zeito > 8.2 then
            self.zeito = 7.8
        end
    end
end

local function draw(self)
    local sx, sy = self.scale, self.scale
    if self.direction > 0 then sx = sx * -1 end
    
    gfx.setColor(self.color)
    local add = 1
    if self.fading then add = add + 6 end
    if self.pinkelpause then add = add + 3 end
    gfx.draw(self.anime.spriteSheet, self.anime.quads[self.anime:spritenumber(add)], self.x, self.y, 0, sx, sy, self.w * .5, self.h)

    if self.pinkelpause and not self.fading then
        gfx.setColor(1, 1, 1)
        gfx.draw(self.ps, self.x + 26 * self.direction * -1, self.y + 12, 0, self.direction * -1, 1, self.w * .5, self.h)
    end
end
local function use_ability(self)
    table.insert(ems.items, Plant:init(self.ability, {x = self.x, y = self.y }))
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
        use_ability(self)
        self.zeito = 0
    end
    if self.zeito > 8.2 and self.fading then
        self.dead = true
    end
    if not self.pinkelpause and not self.fading then
        self.x = self.x + 200 * dt * self.direction
    end
    if self.x < 0 then
        self.direction = 1
    elseif self.x > state.gw then
        self.direction = -1
    end
end

return {init = init, draw = draw, update = update, getHitbox = getHitbox, collided = collided}