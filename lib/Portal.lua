require 'class'

local lg=love.graphics

local Camera=require 'lib/Camera'     
local Button=require 'lib/Button'

local Text=class(function(self, val,x,y,w,color,fontSize,ta)
  self.val=val or 'empty text'
  self.x=x or 0
  self.y=y or 0
  self.w=w or 150
  self.color=color or {.8,.2,.7}
  self.fontSize=fontSize or 13
  self.ta=ta or 'center'
end)

function Text:draw()
  lg.setColor(self.color) lg.printf(self.val,self.x,self.y,self.w,self.ta)
end

local Portal = class(function(self,x,y,w,h)
  local W,H=lg.getDimensions()
  self.x=x or 2000
  self.y=y or 0
  self.w=w or 150
  self.h=h or H
  self.color={.2,.2,.2 }
  local t={}
  t.d=99
  t.h=23
  t.m=56
  do --b
    local b,x,y,w,h,c,bc
    local datetime=tostring(t.d) .. 'D-' .. tostring(t.h) .. 'H-' .. tostring(t.m) .. 'M'
    b = {
Text('Kasaival 2.0',self.x,self.y+10,self.w,{.7,.2,.4},17),
Text(datetime,self.x,self.y+47,self.w)
}

    w,h=57,32
  
    local t={'3D','9H','3H','56M', '21M','7M','3M'}

    for i,v in ipairs(t) do
      local xtra=0
      if i==#t and #t%2==1 then
        xtra=(w+10)*.5
      end
      x=self.x+10+(i%2)*(w+10)-xtra
      y=self.y+80+math.floor((i-1)*.5)*(h+10)
      table.insert(b, Button(x, y, w, h, '-' .. v, c, bc))
    end

    w,h=128,48
    x=self.x+10
    y=self.y+self.h-10
    c={0,.8,.9}
    bc={.4,0,.4}
    local firestorm='launch firestorm ($10)'
    local feedback='give feedback'  
    b.firestorm=Button(x, y-h*2.2, w, h, firestorm, c, bc) 
    b.feedback=Button(x, y-h, w, h, feedback, c, bc)

    self.b=b
  end
  self.time=t
end) 

function Portal:update(dt)
  for k,v in pairs(self.b) do
    if v.update then
      v:update(dt, Camera.x)
    end
  end
  if self.b.feedback.hit then
    --open web link to mailto friend cateye
  elseif self.b.firestorm.hit then
    --generate cryptowallet and how to transfer + advanced settings, faircoin?
  end
end

function Portal:draw()
  local s=self
  lg.setColor(self.color)
  lg.rectangle('fill',s.x,s.y,s.w,s.h)
 
  for k,v in pairs(self.b) do
    if v.draw then
      if v.fontSize then
        lg.setNewFont(v.fontSize)
      end
      v:draw()
    end
  end
end

return Portal