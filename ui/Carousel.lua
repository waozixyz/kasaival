require 'class'

local lg=love.graphics
local lt=love.touch

local state=require 'state'

local Cart=require 'ui/Cart'

local Ca=class(function(self,x,y,no)
  local H=lg.getHeight()
  self.x=x or 0
  self.y=y or 400
  self.carts={}
  local noOfCarts=no or 11
  local m=16
  for i=1,noOfCarts do
    local xoff=30
    local w=92
    local x=w*(i-1)+xoff+m*i
    local y=self.y+m
    local h=H-y*state.phi-m

    table.insert(self.carts,Cart(x,y,w,h))
  end
  self.al=lg.newImage('assets/arrow-left.png')
  self.ar=lg.newImage('assets/arrow-right.png')
end)

function Ca:update(dt)
  local carts=self.carts
  local touches=lt.getTouches()
  for i,id in ipairs(touches) do
    local tx,ty=lt.getPosition(id)
    for _,v in carts do
     local x,y,w,h=v.x,v.y,v.w,v.h
     if tx>=x and tx<=x+w and ty>=y and ty<=y+h then
       v.active=true
     end
    end
  end
end

function Ca:draw(phi)
  local W,H=lg.getDimensions()
  local x,y=self.x*phi,self.y*phi

  -- bottom HUD
  local m=12
  lg.setColor(.4,.1,.2,.5)
  lg.rectangle('fill',0,y,W,H-y)

  -- boxes for sprites
  for _,v in ipairs(self.carts) do
    v:draw(phi)
  end

  lg.setColor(.7,.2,.2,.8)
  m=16
  lg.draw(self.al,m,y)
  x=W-self.ar:getWidth()-m
  lg.draw(self.ar,x,y)
end

return Ca
