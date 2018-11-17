local state = require 'state'
local Button = require 'lib/Button'

local Menu = {}

local lg=love.graphics

function Menu:load()
  self.flames=lg.newImage('assets/menu.png')
  self.sun=lg.newImage('assets/sun_5.png')

  self.w, self.h = lg.getDimensions()
  self.ui = {}
  do -- start button
    local w,h = 128,32
    local x,y = self.w*.5-w,100
    local text = 'Start Journey'
    local color = {0,.3,.7}
    local bckgColor = {.5,.7,.7}
    local margin = 4
    table.insert(self.ui, Button(x, y, w, h, text, color, bckgColor, margin))
  end
end

function Menu:update(dt, miu, w, h)
  self.w,self.h = w,h
  for i,v in ipairs(self.ui) do
    v:update(dt)
    if v.hit then
      if i == 1 then 
        state.newState = 1
      end
    end
  end
end

function Menu:go(d)
  if d then
    lg.draw(d, 0,0, 0, d:getWidth()/self.w, d:getWidth()/self.w)
  end
end

function Menu:draw()
  lg.setColor(1,1,1)
  self:go(self.flames)
  lg.setColor(1,1,1,.3)
  self:go(self.sun)

  for i,v in ipairs(self.ui) do
     v:draw()
  end
end

return Menu
