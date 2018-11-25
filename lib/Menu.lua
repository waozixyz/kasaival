local state = require 'state'
local Button = require 'lib/Button'

local Menu = {}

local lg=love.graphics
local lk=love.keyboard

function Menu:load()
  self.flames=lg.newImage('assets/menu.png')
 -- self.sun=lg.newImage('assets/sun_5.png')
  
  self.font=lg.newFont('assets/KasaivalGB.ttf',13)
  self.titleFont=lg.newFont('assets/KasaivalGB.ttf',17)
  self.versionFont=lg.newFont('assets/KasaivalGB.ttf',7)


  self.w, self.h = lg.getDimensions()
  self.ui = {}

  local w,h = 128,28
  local color={0,.6,.7}
  local bckgColor = {.3,.1,.7}
  local margin = 4

  do -- start button
    local x,y = self.w*.5-w,100
    local text = 'Start , Journey'
    table.insert(self.ui, Button(x, y, w, 42, text, color, bckgColor, margin))
  end

  do -- portal button
    local x,y = self.w*.5-w,100+64
    local text = 'Portal'
    table.insert(self.ui, Button(x, y, w, h, text, color, bckgColor, margin))
  end


  do -- exit button
    local x,y = self.w*.5-w,self.h*.8
    local text = 'Evaporate'
    self.ui[-1] = Button(x, y, w, h, text, color, bckgColor, margin)
  end
end

function Menu:update(dt)
  local W,H=lg.getDimensions()
  for k,v in pairs(self.ui) do
    v:update(dt,W)
    if v.hit then
      state.newState=k 
    end
  end
  if lk.isDown('escape')  then
    state.newState=1
  end
end

function Menu:go(d)
  if d then
    local imgW=d:getWidth()
    local x=0
    while x<self.w do
      lg.draw(d,x,0)
      x=x+imgW
    end
  end
end

function Menu:draw()
  local W,H=lg.getDimensions()
  lg.setColor(1,1,1)
  self:go(self.flames)

  lg.setFont(self.titleFont)
  lg.printf('Kasaival',0,20,self.w,'center')

  lg.setFont(self.versionFont)
  lg.printf('v.1',0,40,self.w,'center')

  lg.setFont(self.font)
  for k ,v in pairs(self.ui) do
     v:draw()
  end
end

return Menu
