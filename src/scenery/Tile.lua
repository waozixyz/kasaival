local copy = require "copy"

local gfx = love.graphics

local function init(self, props)
    for k, v in pairs(props) do
        self[k] = v
    end
    return copy(self)
end

local function balanceColor(c, co, m)
    local d = co - c
    if d > m then
        return m
    elseif d < -m then
        return -m
    else return 0 end
end

local function findElement(c)
    local r, g, b = c[1], c[2], c[3]
    if r > g and r > b then
        return "sand"
    elseif g > r and g > b then
        return "grass"
    elseif b > r and b > g then
        return "water"
    end
end

local function burn(self, obj)
    local c = self.color
    local r, g, b = c[1], c[2], c[3]
    local oc = self.orgColor
    local element = findElement(oc)
    if element == "grass" then
        if r < .3 then
            r = r + .17
        elseif r < .5 then
            r = r + .12
        elseif r < .6 then
            r = r + .08
        elseif r < .7 then
            r = r + .05
        elseif r < .8 then
            r = r + .03
        end
    elseif element == "sand" then
        if g > oc[2] - .13 then
            r = r - .005
            g = g - .02
            b = b - .007
        end
    end
    local f = self.fuel - obj.bp
    if f < 0 then f = 0 end
    local burnedFuel = self.fuel - f
    self.fuel = f
    self.color = {r, g, b}
    return burnedFuel
end

local function getTile(i, v)
    if i % 2 == 0 then
        return v.x - v.w * 0.5, v.y, v.x, v.y - v.h, v.x + v.w * 0.5, v.y
    elseif i % 2 == 1 then
        return v.x, v.y - v.h, v.x + v.w * 0.5, v.y, v.x + v.w, v.y - v.h
    end
end

local function draw(self, i)
    gfx.setColor(self.color)
    gfx.polygon("fill", getTile(i, self))
end

local function heal(self)
    local c = self.color
    local oc = self.orgColor
    local r, g, b = c[1], c[2], c[3]
    local element = findElement(oc)
    if element == "grass" then
        if r > .6 then
            r = r - .01
            g = g - .007
            b = b - .002
        elseif r > .5 then
            r = r - .005
            g = g - .005
            b = b - .002
        end
    elseif element == "sand" then

    end
    r = r + balanceColor(r, oc[1], .0009)
    g = g + balanceColor(g, oc[2], .0003)
    b = b + balanceColor(b, oc[3], .0001)
    
    if g < .07 then g = .07 end
    if b < .07 then b = .07 end
    if math.floor(self.fuel * 10) ~= math.floor(self.orgFuel *10) then
      self.fuel = self.fuel + (self.orgFuel - self.fuel) * .1
    end
    self.color = {r, g, b}
end

local function update(self, dt)
    if not self.hit then
        heal(self)
    end
    self.hit = false
end

return {init = init, draw = draw, update = update, burn = burn}