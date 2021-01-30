local function init(self)
    self.dampf=1
    self.spawnmodifikator=0

    return self
end









local function draw(self)
    --verschiedene herumwandernde Etwas
    love.graphics.draw(dog, 1000+self.spawnmodifikator*70-self.dampf^2, 600+math.sin(self.spawnmodifikator)*self.spawnmodifikator*self.spawnmodifikator/self.dampf)
    
    love.graphics.draw(dog, 1050+math.sin(self.spawnmodifikator)*70-self.spawnmodifikator, 650+math.sin(self.spawnmodifikator)*self.spawnmodifikator*self.spawnmodifikator/self.dampf+self.spawnmodifikator)
    love.graphics.draw(dog, 1100+(math.cos(self.spawnmodifikator)+1)*self.dampf*self.dampf, 500+math.sin(self.spawnmodifikator)*self.spawnmodifikator)
   
    love.graphics.draw(dog, 1150+(math.sin(self.spawnmodifikator)+1)*self.dampf*self.dampf-10*self.dampf, 500+10*self.spawnmodifikator+math.sin(self.spawnmodifikator)*self.spawnmodifikator)
    
    love.graphics.draw(dog, 1400+self.spawnmodifikator*70-self.dampf^2, 680+math.sin(self.spawnmodifikator+self.spawnmodifikator)*self.spawnmodifikator*self.spawnmodifikator/self.dampf)
   
    love.graphics.draw(dog, 800+self.spawnmodifikator*90-self.dampf^2, 800+math.sin(self.dampf)*self.spawnmodifikator*self.spawnmodifikator/self.dampf)
end



local function update(self, dt)
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
    
    





    
    
    end 
    
    return {init = init, draw = draw, update = update}