local function init(self)
    --zeithilfsvariable
    self.zeito = 0
    --windvariablen
    self.spawnx = 0.5
    self.windx = 1
    self.windy = 1
    self.windstark = 1
    self.spawnmodifikator = 0
    self.test = 1

    return self
end

local function draw(self)
    --windpfeil darstellung, nur die richtung
    love.graphics.setColor(0, 0, 0)
    love.graphics.line(200, 200, 200 + self.windx, 200 + self.windy)
    love.graphics.setColor(1, 1, 1)
end

-- ich weiß, eher umständlich, aber einmal gemacht ist einmal gemacht ^^
local function update(self, dt)
    self.zeito = self.zeito + dt
    if self.spawnx < 1 then
        self.spawnmodifikator = self.spawnmodifikator + 2 * dt
        --spawnmodifikatoer größe checken
        if self.spawnmodifikator > 50 then
            self.spawnx = 1.5
        end
    end
    --bei größer 50 wandert er wieder zurück auf start
    if self.spawnx > 1 then
        self.spawnmodifikator = self.spawnmodifikator - 2 * dt
        --bei startangekommen steigt er wie zuvor
        if self.spawnmodifikator < 5 then
            self.spawnx = 0.5
        end
    end
    --wind soll sich nur seltener verändern
    if self.zeito > 3 then
        self.test = love.math.random(1, 10)
        if 5 < (self.spawnmodifikator / (self.test + (self.spawnmodifikator / 10))) then
            --zufall windrichtung
            self.windx = math.sin(math.pi * (self.spawnmodifikator / 75))
            self.windy = math.sin(math.pi * (self.spawnmodifikator / 200))
            self.zeit0 = 0
        end
    end

    --windstaärke ist immer da, ist smoothlaufend
    self.windstark = (self.spawnmodifikator / (self.test + (self.spawnmodifikator / 10))) * 10
end

local function getWind(self)
    local windx = self.windx * self.windstark
    local windy = self.windy * self.windstark

    return windx, windy
end

return {init = init, draw = draw, update = update, getWind = getWind}
