require 'class'

local World=require 'lib/World'

local Miu=class(function(self)
  
  self.mao={World()}
end)

return Miu
