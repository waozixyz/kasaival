
local copy = require "lib.copy"
local ma = love.math
local gr = love.graphics



local function init(self)
    self.rest = 0.5
    self.windx = 1
    self.windstark = 1
    self.spawnmodifikator = 0
    self.zeito = 1
    return copy(self)
end



local function draw(self)
    --windpfeil darstellung, nur die richtung
    gr.setColor(0, 0, 0)
    gr.line(200, 200, 200 + self.windx*self.windstark,200 )
    gr.setColor(1, 1, 1,1 )
end


local function update(self, dt)
        
        self.zeito = self.zeito + 1/3*dt
        if self.rest < 1 then
            self.spawnmodifikator = self.spawnmodifikator + 2 * dt
            --spawnmodifikatoer größe checken
            if self.spawnmodifikator > 50 then
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
    
                self.windx = math.sin(self.zeito)*5
               
        
        
    
        --windstaärke ist immer da, ist smoothlaufend
        self.windstark = (self.spawnmodifikator / 10 + (self.spawnmodifikator / 10))
    end 


    local function getWind(self)
        local windx = self.windx * self.windstark
    
        return windx
    end
return {init = init, draw = draw, update = update, getWind = getWind}