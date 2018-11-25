require 'class'

local lg=love.graphics
local lt=love.touch

local Button=class(function(self, x, y, w, h, text, color, bckgColor, margin,val)
  self.x = x or 200
  self.y = y or 100
  self.w = w or 128
  self.h = h or 32
  self.text = text or 'Start Journey'
  self.val=val or nil
  self.color = color or {0,.3,.7}
  self.bckgColor = bckgColor or {.5,.7,.7}
  self.margin = 4
  self.hit = false 
end)

function therapy(x)
  local t = {}
  if #x == 2 then
    t.li,t.ri = x[1], x[1]
    t.top,t.bot = x[2], x[2]
    return t
  elseif #x == 4 then
    t.li,t.ri = x[1], x[3]
    t.top,t.bot = x[2], x[4]
    return t
  else return -1 end
end

function coly(p, cy)
  if p then
    if not cy then
      local cy = p[2]
      p = p[1]
    end
    p = therapy(p)
    cy = therapy(cy)
    if p.ri > cy.li and p.li < cy.ri and p.top < cy.bot and p.bot > cy.top then
      return true
    end
  else
    return -1
  end
end

function Button:update(dt,width)
  if width then
    self.x=width*.5-self.w*.5
  end
 
  self.hit = false
  local touches = lt.getTouches()
  for i, id in ipairs(touches) do
    local tx, ty = lt.getPosition(id)
    local x = self.x
    local y =  self.y
    local w, h = self.w,self.h
    if coly({x,y,x+w,y+h}, {tx,ty}) then
      self.hit = true
    end
  end
end

function Button:lum(color, lum)
  if self.hit then lum=lum*-1 end
  return color[1]+lum, color[2]+lum, color[3]+lum
end

function Button:draw()
  local s=self
  local m = self.margin
  -- top, bottom margin
  lg.setColor(s:lum(self.bckgColor, .1))
  lg.rectangle('fill', self.x, self.y, self.w, m, 2)
  lg.setColor(s:lum(self.bckgColor, -.1))
  lg.rectangle('fill', self.x, self.y+self.h, self.w, -m, 2)

  -- left, right margin
  lg.setColor(s:lum(self.bckgColor, .1))
  lg.rectangle('fill', self.x, self.y, m, self.h, 2)
  lg.setColor(s:lum(self.bckgColor, -.1))
  lg.rectangle('fill', self.x + self.w, self.y, -m, self.h, 2)

  -- inner button
  lg.setColor(self.bckgColor)
  lg.rectangle('fill', self.x+m, self.y+m, self.w-m*2, self.h-m*2, 2)
  lg.setColor(self.color)
  lg.printf(self.text, self.x, self.y+m*2, self.w, 'center')
end

return Button
