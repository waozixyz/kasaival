require 'class'

local lt=love.touch
local lg=love.graphics
local lm=love.math

local state=require 'state'
local Camera=require 'lib/Camera'     
local Button=require 'lib/Button'

local Text=class(function(self, val,x,y,w,font,color,ta)
  self.val=val or 'empty text'
  self.x=x or 0
  self.y=y or 0
  self.w=w or 150
  self.color=color or {.8,.2,.7}
  self.ta=ta or 'center'

  self.font=font
end)

function Text:draw()
  lg.setColor(self.color) lg.printf(self.val,self.x,self.y,self.w,self.ta)
end

function timeToString(x)
  local d = math.ceil(x / 86400)
  local h = math.ceil((x % 86400) / 3600)
  local m = math.ceil((x % 86400 % 3600) / 60)
  
  if d < 10 then
    d='00' .. tostring(d)
  elseif d < 100 then
    d='0' .. tostring(d)
  else d=tostring(d) end
  
  if h < 10 then
    h='0' .. tostring(h)
  else h=tostring(h) end

  if m < 10 then
    m='0' .. tostring(m)
  else m=tostring(m) end

  return  d .. 'D-' .. h .. 'H-' .. m .. 'M'
end

local Portal = class(function(self,t,h,c,w,h)
  local W,H=lg.getDimensions()
  self.x,self.y=32,32

  if type(t) == 'table' then
    for i,v in ipairs(t) do
      self[v]=1
    end
  elseif type(t) == 'number' then
    self.x=t
  end
  
  if type(h) == 'number' then
    if self.x then
     self.y=h
    else
     self.x=h
    end
  end
 
  if type(c) == 'number' then
    if not self.y then
      self.y=c
    end
  end
  
  if state.current == 2 then
    self.w=w or 150
    self.h=h or H
    self.color={.2,.2,.2 } 
    self.time=8639760
    self.font=lg.newFont('assets/KasaivalGB.ttf',13)
    self.titleFont=lg.newFont('assets/KasaivalGB.ttf',17)
   self.timeFont=lg.newFont('assets/KasaivalGB.ttf',11)

    local b,x,y,w,h,c,bc
    b = {
Text('Kasaival 2.0',self.x,self.y+10,self.w,self.font,{.7,.2,.4}),
}
b.time = Text(timeToString(self.time),self.x,self.y+47,self.w,self.timeFont)

    w,h=57,32
  
    local t={
  [-259200] = '-3D', 
  [-32400] = '-9H',
  [-10800] = '3H',
  [-3360] = '-56M',
  [-1260] = '-21M',
  [-420] = '-7M',
  [-180] = '-3M',

}
  local i = 1
  for k,v in pairs(t) do
    local xtra=0
    if i==#t and #t%2==1 then
      xtra=(w+10)*.5
    end
    x=self.x+10+(i%2)*(w+10)-xtra
    y=self.y+80+math.floor((i-1)*.5)*(h+10)
    table.insert(b, Button(x, y, w, h, v, c, bc,0,k))
    i = i + 1
  end

    w,h=128,48
    x=W-w-16
    y=self.y
    c={0,.8,.9}
    bc={.4,0,.4}
    local firestorm='start firestorm'
    b.firestorm=Button(x, y, w, h, firestorm, c, bc) 
    b.feedback=Button(x, y+h, w, h, 'give feedback', c, bc)

    self.b=b
  end


  self.img=lg.newImage('assets/Portal-1.png')
  self.scale=4
end) 

function Portal:getHitbox()
  local x,y=self.x,self.y
  local w=self.w or 0
  local h=self.h or 0
  if self.img then
   w,h=self.img:getDimensions()
  end
    
  return {x, x+w, y, y+h}
end

function Portal.bb(c,time)
 for k,v in pairs(c) do
    if v.update then
      v:update(dt)
      if v.hit then
        if v.val then
          time = time + v.val
        end
      end
    end
  end
  if c.feedback.hit then
    --open web link to mailto friend cateye
  elseif c.firestorm.hit then
    --generate cryptowallet and how to transfer + advanced settings, faircoin?
  end

  return time
end

function Portal:update(dt)
  if self.b then
  self.time=self.bb(self.b,self.time)
  if self.time > 0 then
    self.b.time.val = timeToString(self.time)
  else
    local str='Updating'
    if not self.dots then self.dots=0 end
    self.dots=self.dots+dt
    if self.dots>3 then self.dots=0 end
    local dots=''
    for i=1,math.floor(self.dots) do
      dots=dots .. '.'
    end
    self.b.time.val = str .. dots
  end
  end
  if true then
   local sc=self.scale
   local w,h=self.img:getDimensions()
   w,h=w*sc,h*sc
   local x,y=-w*.5,-h*.5

   self.hit = false
   local touches = lt.getTouches()
   for i, id in ipairs(touches) do
     local tx, ty = lt.getPosition(id)
 
     if tx>=x and tx<=x+w and ty>=y and ty<=y+h then
       state.new=0
     end
    end
    self.x,self.y=x,y
  end
end

function red(m)
  return {lm.random(6,8)*m,lm.random(3,4)*m,lm.random(6,8)*m}
end
function green(m)
  return {lm.random(6,8)*m,lm.random(6,8)*m,lm.random(3,4)*m}
end
function blue(m)
  return {lm.random(3,4)*m,lm.random(6,8)*m,lm.random(6,8)*m}
end



function Portal:draw()
  local W,H=lg.getDimensions() 
  if state.current==2 then
  local s=self
 -- lg.setColor(self.color)
  --lg.rectangle('fill',s.x,s.y,s.w,s.h)
 -- lg.setColor(1,1,1)
 -- lg.print(self.test,200,47)
  for k,v in pairs(self.b) do
    if v.draw then
      if v.font then
        lg.setFont(v.font)
      end
      v:draw()
    end
  end
  end
  if self.img then
   lg.setColor(green(.1),.8)
   local img,scale=self.img,self.scale
   local x,y=self.x,self.y
   lg.draw(img,x,y,0,scale)
  end
end

return Portal