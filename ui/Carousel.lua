require 'class'

local lg=love.graphics
local lt=love.touch

local state=require 'state'
local Cart=require 'ui/Cart'

local Ca=class(function(self,x,y,no)
  self.x=x or -state.eye.w*.5
  self.y=y or 200
  self.h=state.h-self.y
  self.carts={}
  local noOfCarts=no or 11
  local m=16
  for i=1,noOfCarts do
    local xoff=30
    local w=92
    local x=self.x+w*(i-1)+xoff+m*i
    local y=self.y-m
    local h=state.eye.h*.5-y-m
 table.insert(self.carts,Cart(x,y,w,h))
  end
  self.al=lg.newImage('assets/arrow-left.png')
  self.ar=lg.newImage('assets/arrow-right.png')
end)
function count(st,en)
  local c={}
  for s=st,en do 
    table.insert(c,s)
  end
  return c
end

function Ca:update(dt)
  local touches=lt.getTouches()
  local carts=count(1,#self.carts)

  local tx,ty=state.eye:getMouseWorldCoordinates()
  for i,_ in pairs(carts) do
   local v=self.carts[i]   
   local x,y=v.x,v.y
   local w,h=v.w,v.h
   if tx>=x and tx<=x+w and ty>=y and ty<=y+h then
     v.touch=true
     table.remove(carts,i)
   else
     v.touch=false
   end
  end
end

function Ca:draw()
  local x,y=state.eye.x,state.eye.y
  local w,h=state.eye.w,state.eye.h
  -- bottom HUD
  local m=12
  lg.setColor(.4,.1,.2,.5)
  lg.rectangle('fill',x,y,w,h-y)

  -- boxes for sprites
  for _,v in ipairs(self.carts) do
    v:draw()
  end

  lg.setColor(.7,.2,.2,.8)
  m=16
  lg.draw(self.al,x+m,y)
  x=state.w*.5-self.ar:getWidth()-m
  lg.draw(self.ar,x,y)
end

return Ca
