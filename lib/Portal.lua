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
  return tostring(d) .. 'D-' .. tostring(h) .. 'H-' .. tostring(m) .. 'M'
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
    x=self.x+10
    y=self.y+self.h-10
    c={0,.8,.9}
    bc={.4,0,.4}
    local firestorm='start firestorm'
    b.firestorm=Button(x, y-h*2.2, w, h, firestorm, c, bc) 
    b.feedback=Button(x, y-h, w, h, 'give feedback', c, bc)

    self.b=b
  end

  if self.img then
    self.img=lg.newImage('assets/Portal-1.png')
 end
end) 

function Portal:getHitbox()
  local x,y=self.x,self.y
  local w=self.w or 0
  local h=self.h or 0
  if self.img then
   w=self.img:getWidth()
   h=self.img:getHeight()
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
    self.b.time.val = timeToString(self.time)
  end
  if state.current==1 then
  self.hit = false
  local touches = lt.getTouches()
  for i, id in ipairs(touches) do
    local tx, ty = lt.getPosition(id)
    local b = self:getHitbox()
    local l,r,u,d=b[1],b[2],b[3],b[4]
    
    if tx>=l and tx<=r and ty>=u and ty<=d then
      state.new=0
    end
  end
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
  if state.current==2 then
  local s=self
  lg.setColor(self.color)
  lg.rectangle('fill',s.x,s.y,s.w,s.h)
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
  if state.current == 1 then
    lg.setColor(red(.1),.8)
    lg.draw(self.img,self.x-7,self.y)
    lg.setColor(green(.1),.8)
lg.draw(self.img,self.x,self.y-7)
    lg.setColor(blue(.1),.8)
    lg.draw(self.img,self.x,self.y)
  end
  end
 
end

return Portal