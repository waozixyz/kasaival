local copy = require "lib.copy"
local lyra = require "lib.lyra"
local pinkel = require "lib.ps.pinkelx"
local Animation = require "lib.utils.Animation"

local gr = love.graphics
local ma = love.math



local function init(self, pos)
    self.x = pos.x
    self.y = pos.y
    self.direction = -1
    self.pinkelpause = false
    self.anime = Animation:init(gr.newImage("assets/mobs/dog_sprite.png"), 46, 27, 1)
    self.zeito = ma.random(0, 11)
    -- add random color to dogs
    self.color = lyra.getColor({.4, 1, .4, 1, .4, 1})


    --pinkelsystem initiieren
    self.ps = pinkel()



    return copy(self)
end



local function get_sprite_num(self)
    local add, mult = 1, 3
    if self.pinkelpause then
        add = add + 3
    end
    return math.floor(self.anime.currentTime / self.anime.duration * mult) + add
end

local function draw(self)
    local sx, sy = 2, 2

    if self.direction > 0 then
        sx = sx * -1
    end
    

    if self.pinkelpause then
        gr.setColor(1, 1, 1, 1)
        self.ps:setPosition(self.x-70*self.direction, self.y+18)
        self.ps:setSizes(0.06)
        --pinkel direction
        if self.direction <1 then
        self.ps:setDirection(2.2236430644989)
        else
        self.ps:setDirection(1)
        end
        gr.setColor(1,1,1)
        gr.draw(self.ps)
       end

    gr.setColor(self.color)
    gr.draw(self.anime.spriteSheet, self.anime.quads[get_sprite_num(self)], self.x, self.y, 0, sx, sy)

    


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

return {init = init, draw = draw, update = update}
