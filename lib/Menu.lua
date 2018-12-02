local state = require 'state'
local Button = require 'lib/Button'
local lume = require 'lume'
local Menu = {}

local lg=love.graphics
local lk=love.keyboard
local lt=love.touch
local ls=love.system
local lm=love.math

function Menu:load()
  self.elapsed=0
  self.alef=1
  self.title=lg.newImage('assets/title.png')
  self.flames=lg.newImage('assets/menu.jpg')
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

  local img=lg.newImage('ao.png')
  local sc,r=.1,8
  local W,H=lg.getDimensions()
  local w,h=img:getDimensions()
  w,h=w*sc,h*sc
  local x,y=W-w-r,H-h-r
  self.aruga={img=img,sc=sc,r=r,x=x,y=y,w=w,h=h}
end

function Menu:update(dt)
  self.elapsed=self.elapsed+dt

  if math.floor(self.elapsed)%8>3 then
    self.alef=self.alef+.01
  else
    self.alef=self.alef-.01
  end
  self.alef=lume.clamp(self.alef,0,1)
  self.aruga.yshift=(self.alef-.5)*100

  local W,H=lg.getDimensions()
  for k,v in pairs(self.ui) do
    v:update(dt,W)
    if v.hit then
      state.new=k 
    end
  end
  if lk.isDown('escape')  then
    state.new=1
  end
 
  local touches = lt.getTouches()
  for i, id in ipairs(touches) do
    local tx, ty = lt.getPosition(id)
    local aru=self.aruga
    local x,y=aru.x,aru.y+aru.yshift
    local w,h,r=aru.w,aru.h+aru.yshift,aru.r   
    if x-r<tx and x+w+r>tx and y-r<ty and y+h+r>ty then
      ls.openURL('https://alpega.space')
    end
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
  lg.setColor(1,1,1,self.alef)
  lg.draw(self.title,20,20,0,.3)

  lg.setColor(self.alef+.5,self.alef+lm.random(.7,.8),(self.alef%7))
  lg.setFont(self.font)
  lg.printf('Kasaival',0,20,self.w,'center')

  
  lg.setFont(self.versionFont)
  lg.printf('v.1',0,40,self.w,'center')

 
  lg.setFont(self.font)
  for k ,v in pairs(self.ui) do
     v:draw()
  end

  do -- aruga
    local aru=self.aruga
    local img=aru.img
    local yshift=aru.yshift
    local x,y=aru.x,aru.y+yshift
    local w,h=aru.w,aru.h+yshift
    local sc,r=aru.sc,aru.r
    lg.setColor(1,1,1,.8)
    lg.draw(img,x,y,0,sc)

    x,y=x-r,y-r
    w,h=w+r*2,h+r*2
    lg.setColor(1,0,0,.1)     
    lg.rectangle('fill',x,y,w,h,20)
  end


end

return Menu
