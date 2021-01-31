

local copy = require "lib.copy"

function newe( image , width, height, duration )
    local animation = {}
    animation.spriteSheet = image;

 animation.quads = {};

for y = 0, image:getHeight() - height, height do
   for x = 0, image:getWidth() - width, width do
       table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
   end
end

animation.duration=duration
animation.currentTime=0

return animation
end



local function init(self,pos)
    self.dampf=1
    self.spawnmodifikator=0
     self.dog= love.graphics.newImage( "assets/dog/solodog.png" )
    self.x=pos.x
    self.y=pos.y
     self.spawnx = 0
     self.dogdirection = 1
     
     self.animation = newe(love.graphics.newImage("assets/dog/dog_sprite.png"), 46, 28, 1)


    return copy(self)
end


local function draw(self)


    
    
    --spriteSheet
    local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * 3) + 1
      --  love.graphics.draw( self.animation.spriteSheet, self.animation.quads[spriteNum],200 ,200)
    
    
    
    
    
    
        --verschiedene herumwandernde Etwas

        love.graphics.draw(self.animation.spriteSheet, self.animation.quads[spriteNum], self.x+self.spawnmodifikator*30-self.spawnmodifikator, self.y+math.sin(self.spawnmodifikator*13)*6, 0, self.dogdirection*(-1), 1)

        love.graphics.draw(self.animation.spriteSheet, self.animation.quads[spriteNum], 1400-self.spawnmodifikator*70,464+math.sin(self.spawnmodifikator*10)*6, 0, self.dogdirection, 1)
       
        love.graphics.draw(self.animation.spriteSheet, self.animation.quads[spriteNum], 800+self.spawnmodifikator*40,464+math.sin(self.spawnmodifikator*12)*6, 0, self.dogdirection*(-1), 1)
        love.graphics.draw(self.animation.spriteSheet, self.animation.quads[spriteNum], 1000-(self.spawnmodifikator+self.dampf)*30, 464+math.sin(self.spawnmodifikator*15)*6, 0, self.dogdirection, 1)
        
        love.graphics.draw(self.animation.spriteSheet, self.animation.quads[spriteNum], 750-(self.spawnmodifikator+self.dampf)*54, 464+math.sin(self.spawnmodifikator*7)*6,0, self.dogdirection,1)
        
        love.graphics.draw(self.animation.spriteSheet, self.animation.quads[spriteNum], 1100+(self.spawnmodifikator+self.dampf)*37, 464+math.sin(self.spawnmodifikator*17)*6, 0, self.dogdirection*(-1),1)
    
        love.graphics.draw(self.animation.spriteSheet, self.animation.quads[spriteNum], 1150-self.spawnmodifikator*100-self.spawnmodifikator, 464+math.sin(self.spawnmodifikator*13)*6, 0, self.dogdirection, 1)
        

        
        
    end
    
    





local function update(self, dt, animation )


    self.animation.currentTime = self.animation.currentTime + dt
    if self.animation.currentTime >= self.animation.duration then
        self.animation.currentTime = self.animation.currentTime -self.animation.duration
    end

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
        self.dogdirection=-1
        --bei startangekommen steigt er wie zuvor
               
               
        if self.spawnmodifikator <5 then
            self.spawnx=0.5
        self.dogdirection=1
            
        end
    
    end



    
    end 

    
   

    
    


        

        
    return {init = init, draw = draw, update = update}