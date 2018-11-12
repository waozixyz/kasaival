-- Kasaival
-- this is a start of a magical journey
local miu = require 'miu'

-- aliases
local lg=love.graphics
local lw=love.window
local li=love.image

-- yin and yang, there is no good and evil, there is a balance we can decide to try and reach, only through this balance can we try to escape certain cycles and achieve higher cycles. nirvana is our goal, yet is not for seeking, it is for being.
-- be the flow, be yourself, be free
local Pink, Cyan

-- Only through the portal can we get an updatte to the game
local Portal = {
  x = 2000
}

-- Joysticks
local Joystick = require 'lib/Joystick'
local movePad, attackPad


-- Camera
local Camera = {
  x = 0,
  y = 0,
  scale = 1,
}

function moveInArea(x, dx, min, max)
  return (x > min or dx > 0) and (x < max or dx < 0)
end


-- load love
function love.load()
  lw.setIcon(li.newImageData('icon.png'))
  local W,H = lg.getDimensions()
   -- miuuuuu
  miu = miu(self)
  Pink = miu.pink
  Cyan = miu.cyan

  do -- joysticks
    local x,y,r=W*0.85,H*0.75,64
    local c1={.2,.1,.8,.5}
    local c2={.8,.1,.2,.5}
    
    movePad=Joystick(W-x, y, r, c1)
    attackPad=Joystick(x, y, r, c2)
  end
end
 
function collision(pink, cyan)
  local flag = false
  if #pink % 2 == 1 then return end
  
  if pink[1] < cyan[2] and pink[2] > cyan[1] then
      flag = true
    else
      flag = false
    end
   
  return flag
end

-- update love
function love.update(dt)
  local W,H = lg.getDimensions()

  movePad:update(dt)
  do -- move Camera and Pink
    local dx,dy = movePad.dx, movePad.dy
    Pink:move(dx,dy)

    if moveInArea(-Camera.x, dx, Cyan.base.x, Portal.x - W*.5) and moveInArea(Pink.x, -dx, W*.8 - Camera.x, W*.2 - Camera.x)
 then
     Camera.x = Camera.x - dx
    end
  end

 
  do -- collisions
    local phb=Pink:getHitbox()
    local ohb=Cyan.base:getHitbox()
    if collision(phb, ohb) then
      Pink:defend(Cyan.base:attack(Pink))
    end
  end

  attackPad:update(dt)
  do -- attack
    local dx,dy = attackPad.dx, attackPad.dy
    if dx ~= 0 or dy ~= 0 then
      Pink:attack(dx, dy)
    end
 end

  if love.keyboard.isDown('escape') then
    love.event.quit()
  end

  miu:update(dt)
end

-- draw love
function love.draw()
  lg.translate(Camera.x, Camera.y)
  lg.scale(Camera.scale) 
  miu:draw()
  lg.reset()
   
  movePad:draw()
  attackPad:draw()
end
