local copy = require "lib.copy"
local lyra = require "lib.lyra"
local pinkel = require "lib.ps.Pinkel"
local Animation = require "lib.utils.Animation"

local gr = love.graphics
local ma = love.math

local function init(self, pos)
    self.element = "earth"
    self.w, self.h = 46, 27
    self.x, self.y = pos.x, pos.y
    self.scale = 2
    self.direction = -1
    self.pinkelpause = false
    self.anime = Animation:init(gr.newImage("assets/mobs/dog_sprite.png"), self.w, self.h, 1)
    self.zeito = ma.random(0, 8)
    -- add random color to dogs
    self.color = lyra.getColor({.4, 1, .4, 1, .4, 1})

    --pinkelsystem initiieren
    self.ps = pinkel()

    return copy(self)
end

local function getHitbox(self)
    local w = self.w * self.scale
    local h = self.h * self.scale
    return self.x - w * 0.5, self.x + w * 0.5, self.y - h * .2, self.y
end

local function collided(self, obj)
--  print(obj.element)
    if obj.element == "fire" then
        local r, g, b = self.color[1],self.color[2], self.color[3]
        r = r + .1
        g = g - .1
        b = b - .1
        self.color = {r, g, b}
    end
end

local function draw(self)
    local sx, sy = self.scale, self.scale

    if self.direction > 0 then sx = sx * -1 end
    
    gr.setColor(self.color)
    local add = 1
    if self.pinkelpause then add = add + 3 end
    gr.draw(self.anime.spriteSheet, self.anime.quads[self.anime:spritenumber(add)], self.x, self.y, 0, sx, sy, self.w * .5, self.h)

    if self.pinkelpause then
        gr.setColor(1, 1, 1)
        gr.draw(self.ps, self.x + 26 * self.direction * -1, self.y + 12, 0, self.direction * -1, 1, self.w * .5, self.h)
    end
end

local function update(self, dt)
    self.ps:update(dt)

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
        self.zeito = 0
    end
    if not self.pinkelpause then
        self.x = self.x + 200 * dt * self.direction
    end
    if self.x < lyra.startx then
        self.direction = 1
    elseif self.x > lyra:getWidth() + lyra.startx then
        self.direction = -1
    end
end

return {kinetic = true, init = init, draw = draw, update = update, getHitbox = getHitbox, collided = collided}
