require 'class'

local lg=love.graphics
local lk=love.keyboard
local lt=love.touch
local ls=love.system
local lm=love.math

local state = require 'state'
local lume = require 'lume'
local Button = require 'lib/Button'

local Menu=class(function(self)
  local W,H=lg.getDimensions()
  self.w,self.h=W,H
  self.animated=false
 
  self.elapsed=0
  self.title=lg.newImage('assets/title.png')
  self.bckg=lg.newImage('assets/menu.jpg')
  self.ui = {}

  local color={0,.6,.7}
  local bckgColor = {.3,.1,.7}
  local margin = 10
  local x,y,w,h,text

  -- start journey
  w,h=128,42
  x,y = self.w*.5-w,H*.35
  text = 'Start Journey'
  table.insert(self.ui, Button(x, y, w, h, text, color, bckgColor, margin))
  
  -- portal button
  y = y+h+margin
  h=24
  text = 'Portal'
  table.insert(self.ui, Button(x, y, w, h, text, color, bckgColor, margin))

  -- exit button
  local addToY=H-(y+h+margin)
  if addToY>0 then
    addToY=addToY*.8
  else addToY=0 end
  
  y = y+h+margin+addToY 
  local text = 'Evaporate'
  self.ui[-1] = Button(x, y, w, h, text, color, bckgColor, margin)
  
  self.font=lg.newFont('assets/KasaivalGB.ttf',13)
  self.titleFont=lg.newFont('assets/KasaivalGB.ttf',17)
  self.versionFont=lg.newFont('assets/KasaivalGB.ttf',7)
  self.alef=1
  local a={}
  a.img=lg.newImage('ao.png')
  a.sc,a.r=.1,8
  local w,h=a.img:getDimensions()
  a.w,a.h=w*a.sc,h*a.sc
  a.x=W-a.w-a.r
  a.y=H-a.h-a.r
  self.aruga=a
end)

function Menu:update(dt)
  local W,H=lg.getDimensions()
  if W ~= self.w or H ~= self.h then
    self.w,self.h=W,H
 
    local a=self.aruga
    local w,h=a.img:getDimensions()
    a.w,a.h=w*a.sc,h*a.sc
    a.x=W-a.w-a.r
    a.y=H-a.h-a.r
    self.aruga=a
  end

  if self.animated then
    self.elapsed=self.elapsed+dt  
  else
    self.alef=1
  end

  if math.floor(self.elapsed)%8>3 then
    self.alef=self.alef+.01
  else
    self.alef=self.alef-.01
  end

  self.alef=lume.clamp(self.alef,0,1)
  self.aruga.yshift=self.alef

  for k,v in pairs(self.ui) do
    v:update(dt,W)
    if v.hit then
      state.n=k
    end
  end
  if lk.isDown('escape')  then
    state.n=-1
  end
 
  local touches = lt.getTouches()
  for i, id in ipairs(touches) do
    local tx, ty = lt.getPosition(id)
    local aru=self.aruga
    local ysh=aru.yshift
    local x,y=aru.x,aru.y+ysh
    local w,h,r=aru.w,aru.h,aru.r   
    if x-r<tx and x+w+r>tx and y-r-10<ty and y+h+r>ty then
      state.openLink('ao')
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
  local w,h=self.w,self.h
  local alef=self.alef or .4
  local font=self.font

  do --bckg
    local bckg=self.bckg
    local w,h=bckg:getDimensions()
    lg.setColor(1,1,1)
    lg.draw(bckg,0,0,0,W/w,H/h)
  end
 
  lg.setColor(alef+.5,alef+lm.random(.7,.8),(alef%7))
  lg.setFont(font)
  lg.printf('Kasaival',0,20,w,'center')

  
  lg.setFont(self.versionFont)
  lg.printf('v.1',0,40,w,'center')

  lg.setFont(font)
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

    local ma=lm.random(9,10)*.1
    local na=lm.random(9,10)*.1
    lg.setColor(1,1,ma,na)
    lg.draw(img,x,y,0,sc)
  end
end

return Menu

