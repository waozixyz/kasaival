local Menu = {}

local lg=love.graphics

function Menu:load(miu)
  self.miu = miu
  self.flames=lg.newImage('assets/menu.png')
  self.sun=lg.newImage('assets/sun_5.png')


end

function Menu:update(dt, miu, w, h)
  self.w,self.h = w,h
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
end

return Menu
