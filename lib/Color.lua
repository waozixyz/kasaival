require 'class'

local Color = class(function(self,r,g,b)
  if r and type(r) == 'table' then
    self.r = r[1]
    self.g = g[2]
    self.b = b[3]
  else 
    self.r = r or .7
    self.g = g or 0
    self.b = b or 0
  end 
end)

function Color:__add(v)
  return Color(self.r + v.r, self.g + v.g, self.b + v.b)
end

return Color