local function init(self)
    --spwanervariablen, bewegunsmodifakatoren
    self.spawnmodifikator=0
    self.spawnx=0.5
    self.dampf=1
    --zeithilfsvariable
    self.zeito=0
    --windvariablen
    
    self.windx=1
    self.windy=1
    self.windstark=1
    dog = love.graphics.newImage( "runningdog.png")
    
    self.test=0
    return self
end

local function draw(self)
    --verschiedene herumwandernde Etwas
    
    love.graphics.draw(dog, 1000+self.spawnmodifikator*70-self.dampf^2, 600+math.sin(self.spawnmodifikator)*self.spawnmodifikator*self.spawnmodifikator/self.dampf, 50)
    love.graphics.setColor(0.160*self.spawnmodifikator, 0.82*self.dampf/self.spawnmodifikator, 0.45+self.dampf^2)
    love.graphics.circle("fill", 1050+math.sin(self.spawnmodifikator)*70-self.spawnmodifikator, 650+math.sin(self.spawnmodifikator)*self.spawnmodifikator*self.spawnmodifikator/self.dampf+self.spawnmodifikator, 40)
    love.graphics.draw(dog, 1100+(math.cos(self.spawnmodifikator)+1)*self.dampf*self.dampf, 500+math.sin(self.spawnmodifikator)*self.spawnmodifikator, 20)
    love.graphics.setColor(0.160, 0.82, 0.45)
    love.graphics.circle("fill", 1150+(math.sin(self.spawnmodifikator)+1)*self.dampf*self.dampf-10*self.dampf, 500+10*self.spawnmodifikator+math.sin(self.spawnmodifikator)*self.spawnmodifikator, 20)
    love.graphics.setColor(0.160, 0.82, 0.45)
    love.graphics.circle("fill", 1400+self.spawnmodifikator*70-self.dampf^2, 680+math.sin(self.spawnmodifikator+self.spawnmodifikator)*self.spawnmodifikator*self.spawnmodifikator/self.dampf, 50-self.spawnmodifikator)
    love.graphics.setColor(1, 0.82, 0.45)
    love.graphics.circle("fill", 800+self.spawnmodifikator*90-self.dampf^2, 800+math.sin(self.dampf)*self.spawnmodifikator*self.spawnmodifikator/self.dampf, 50)
    --windpfeil darstellung
    love.graphics.line( 50, 50, self.windmode*self.windx*self.windstark, self.windmode*self.windy*self.windstark,)
    --windergriffener ball
    love.graphics.setColor(0.160*self.spawnmodifikator, 1, 0.45+self.dampf^2)
    love.graphics.circle("fill", 900+self.spawnmodifikator+*self.windx*self.windstark, 700+self.spawnmodifikator+*self.windy*self.windstark, 30)
end



local function update(self, dt)
self.zeito=self.zeito+dt
if self.spawnx<1 then

    self.spawnmodifikator=self.spawnmodifikator+2*dt

   if  660+math.sin(self.spawnmodifikator)*self.spawnmodifikator*self.spawnmodifikator > 800 then
   self.dampf=self.dampf+dt
   end 
--spawnmodifikatoer größe checken
   if self.spawnmodifikator> 50 then
    self.spawnx=1.5
   end

end
--bei größer 50 wandert er wieder zurück auf start
if self.spawnx>1 then 
    self.spawnmodifikator=self.spawnmodifikator-2*dt
    self.dampf=self.dampf-2*dt
    --bei startangekommen steigt er wie zuvor
    if self.spawnmodifikator <5 then
        self.spawnx=0.5
        
    end

end


if self.zeito >3 then 
self.test =love.math.random(1, 10)
if 5 < (self.spawnmodifikator/(self.test+(self.spawnmodifikator/10))) then 


--zufall windrichtung
self.windx= math.sin (math.pi*(self.spawnmodifikator/75))
self.windy= math.sin (math.pi*(self.spawnmodifikator/200))
self.zeit0=0
end
end 
print(self.spawnmodifikator)
print(self.test)
print(self.windmode)
--windstaärke ist immer da, ist smoothlaufend
self.windstark=self.spawnmodifikator

end 

return {init = init, draw = draw, update = update}