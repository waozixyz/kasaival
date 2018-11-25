require 'class'

local lg=love.graphics

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

local Portal = class(function(self,x,y,w,h)
  local W,H=lg.getDimensions()
  self.x=x or 0
  self.y=y or 0
  self.w=w or 150
  self.h=h or H
  self.color={.2,.2,.2 }
  
  self.time=8639760

 self.font=lg.newFont('assets/KasaivalGB.ttf',13)
  self.titleFont=lg.newFont('assets/KasaivalGB.ttf',17)
  self.timeFont=lg.newFont('assets/KasaivalGB.ttf',11)

  do --b
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
end) 

function Portal:update(dt)
  for k,v in pairs(self.b) do
    if v.update then
      v:update(dt)
      if v.hit then
        if v.val then
          self.time = self.time + v.val
        end
      end
    end
  end
  if self.b.feedback.hit then
    --open web link to mailto friend cateye
  elseif self.b.firestorm.hit then
    --generate cryptowallet and how to transfer + advanced settings, faircoin?
  end

  self.b.time.val = timeToString(self.time)
end

function Portal:draw()
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

return Portal