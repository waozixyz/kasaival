require 'class'
local Vector=require 'lib/Vector'
local Particle=require 'lib/Particle'
local lg,lm=love.graphics,love.math

local W=class(function(self,x,y)
  self.Position=Vector(x, y)
  self.Particles={}
  self.numParticles=lm.random(150, 450)
  self.elapsed=0
end)

function W:addParticle(x, y)
  self.R=lm.random(0,6)*.1
  self.G=lm.random(0,6)*.1
  self.B=lm.random(0,6)*.1
  table.insert(self.Particles, Particle(x, y, self.R, self.G, self.B))
end

function W:load()
  local posi=self.Position
 
  for dt=1,20 do
    for i=1,10 do
      self:addParticle(posi.x, posi.y)
    end

    for k=#self.Particles,1,-1 do
      local p=self.Particles[k]
      if p:isDead() then
        table.remove(self.Particles, k) 
      else
        p:update(dt/100, posi)
      end
    end
  end
end

function W:update(dt)
  local posi=self.Position
  self.elapsed=self.elapsed+dt
 
  self:addParticle(posi.x, posi.y)
  
  for k=#self.Particles,1,-1 do
   local p=self.Particles[k]
   if p:isDead() then
     table.remove(self.Particles, k) 
   else
     p:update(dt,posi)
   end
  end
  self.x,self.y=posi.x,posi.y
end

function W:draw()
  for k,v in ipairs(self.Particles) do
    v:draw()
  end
end

return W