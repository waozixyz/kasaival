require 'class'
local Vector=require 'lib/Vector'
local Particle=require 'lib/Particle'
local lg,lm=love.graphics,love.math

local W=class(function(self,x,y,size)
  self.Position=Vector(x, y)
  self.Particles={}
  self.elapsed=0
  self.size=size or 3
end)

function W:addParticle(x, y)
  local r=lm.random(9,10)*.1
  local g=lm.random(0,3)*.1
  local b=lm.random(0,6)*.1
  table.insert(self.Particles, Particle(x, y, self.size, r, g, b))
end

function W:update(dt)
  local posi=self.Position
  self.elapsed=self.elapsed+dt
  if math.floor(dt*100)%3== 0 then
    self:addParticle(posi.x, posi.y)
  end

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