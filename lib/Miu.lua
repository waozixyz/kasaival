require 'class'

local World=require 'lib/World'

local Miu=class(function(self)
  self.id=1
  self.mao={World()}
end)

return Miu
