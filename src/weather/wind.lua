local copy = require "copy"

local gfx = love.graphics

local function init(self)
  self.rest = 0.5
  self.windx = 1
  self.windstark = 1
  self.spawnmodifikator = 0
  self.zeito = 1
  self.mod=1
  return copy(self)
end

local function draw(self)
  --windpfeil darstellung, nur die richtung
  gfx.setColor(0, 0, 0)
  gfx.line(200, 200, 200 + self.windx*self.windstark,200 )
  gfx.setColor(1, 1, 1,1 )
end

local function update(self, dt)
  self.zeito = self.zeito + dt

  if self.rest < 1 then
    self.spawnmodifikator = self.spawnmodifikator + 2 * dt
    --spawnmodifikatoer größe checken
    if self.spawnmodifikator > 20 then
      self.rest = 1.5
    end
  end
  --bei größer 50 wandert er wieder zurück auf start
  if self.rest > 1 then
    self.spawnmodifikator = self.spawnmodifikator - 2 * dt

    --bei startangekommen steigt er wie zuvor
    if self.spawnmodifikator < 5 then
      self.rest = 0.5
    end
  end

  self.windx = math.sin(self.zeito) + self.spawnmodifikator / 30
  if self.zeito >= math.pi * 2 then
    self.zeito = 0
  end

  --windstaärke ist immer da, ist smoothlaufend
  self.windstark = self.mod*3 * self.spawnmodifikator / 10
end

local function setWind(self, mod)
self.mod = mod 
end


local function getWind(self)
  local windx = self.windx * self.windstark

  return windx
end
return {init = init, draw = draw, update = update, getWind = getWind, setWind = setWind}
