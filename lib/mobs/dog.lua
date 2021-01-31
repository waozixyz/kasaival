local function init(self)
    self.dampf=1
    self.spawnmodifikator=0
     dog= love.graphics.newImage( "solodog.png" )
     self.spawnx=0
     dogdirection=1
    return self
    
end









local function draw(self)
    --verschiedene herumwandernde Etwas
    love.graphics.draw(dog, 1000-(self.spawnmodifikator+self.dampf)*30, 464+math.sin(self.spawnmodifikator)*6, 0, dogdirection, 1)
    love.graphics.setColor(1,0,0)
    love.graphics.draw(dog, 750-math.sin(self.spawnmodifikator)*30+(self.spawnmodifikator*self.dampf)/(self.spawnmodifikator+self.dampf+40), 464+math.sin(self.spawnmodifikator)*6,0, dogdirection,1)
    love.graphics.setColor(0,1,0)
    love.graphics.draw(dog, 1100+(self.spawnmodifikator*self.dampf)/(self.spawnmodifikator+self.dampf), 464+math.sin(self.spawnmodifikator)*self.spawnmodifikator, 0, dogdirection*(-1),1)
    love.graphics.setColor(0,0,1)
    love.graphics.draw(dog, 1150-self.spawnmodifikator*100-self.spawnmodifikator, 464+math.sin(self.spawnmodifikator)*5, 0, dogdirection, 1)
    
    love.graphics.draw(dog, 1400-self.spawnmodifikator*70,464+math.sin(self.spawnmodifikator)*6, 0, dogdirection, 1)
   
    love.graphics.draw(dog, 800+self.spawnmodifikator*40,464+math.sin(self.spawnmodifikator)*6, 0, dogdirection*(-1), 1)
end



local function update(self, dt)


    if self.spawnx<1 then
        
        self.spawnmodifikator=self.spawnmodifikator+2*dt
    
       if  660+math.sin(self.spawnmodifikator)*self.spawnmodifikator*self.spawnmodifikator > 800 then
       self.dampf=self.dampf+dt
       end 

       --unvisiblesidechange
       
    --spawnmodifikatoer größe checken
       if self.spawnmodifikator> 50 then
        self.spawnx=1.5
        
       end
    
    end
    --bei größer 50 wandert er wieder zurück auf start
    if self.spawnx>1 then 
        self.spawnmodifikator=self.spawnmodifikator-2*dt
        self.dampf=self.dampf-2*dt
        --dogrichtung
        dogdirection=-1
        --bei startangekommen steigt er wie zuvor
               
               
        if self.spawnmodifikator <5 then
            self.spawnx=0.5
        dogdirection=1
            
        end
    
    end
    






    
    
    end 
    
    return {init = init, draw = draw, update = update}