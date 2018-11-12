local lg=love.graphics

local Ground = require 'lib/Ground'
local Ocean = require 'lib/Ocean'
local Player = require 'lib/Player'
local Joystick = require 'lib/Joystick'
local Portal = {
  x = 2000
}

-- Planet Miu
local Miu = {}
Miu.__index=Miu
function Miu:add(ao)
  table.insert(self, ao)
end
function Miu:addMao(mao)
  for i,ao in ipairs(mao) do
    self:add(ao)
  end
end

-- Joysticks
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
  local W,H = lg.getDimensions()
  

  do -- Player
    local img = lg.newImage('assets/flame_1.png')
    local w,h = 128,256
    local x,y = W*.5,H*.5
    local sx,sy = 1,1
    Player = Player(img, w, h, x, y, sx, sy)
  end

  -- add ao to Miu
  Miu:addMao({
    Ground,
    Ocean,
    Player
  })

  do -- joysticks
    local x,y,r=W*0.85,H*0.75,64
    local c1={.2,.1,.8,.5}
    local c2={.8,.1,.2,.5}
    
    movePad=Joystick(W-x, y, r, c1)
    attackPad=Joystick(x, y, r, c2)
  end

  -- load ao
  for i,v in ipairs(Miu) do
    if v.load then
      v:load()
    end
     
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

function regulateSpeed(dx, dy, speed)
  local miu = speed
  if dx ~= 0 and dy ~= 0 then
   miu = speed / (math.abs(dx) + math.abs(dy))
  end
  return dx * miu, dy * miu
end

-- update love
function love.update(dt)
  local W,H = lg.getDimensions()
  -- update ao
  for i,v in ipairs(Miu) do
    if v.update then
      v:update(dt)
    end
    if v.hp and v.hp <= 0 then
      table.remove(Miu, i)
    end
    if v.y and v.sx then
      v.sx = v.sx - H / (H + v.y)
      v.sy = v.sx
    end
  end

  movePad:update(dt)
  do -- move Camera and Player
    local dx,dy = movePad.dx, movePad.dy
    dx,dy = regulateSpeed(dx, dy, Player.speed)
 
    if (Player.x < Portal.x or dx < 0) then
      Player.x = Player.x + dx
    end

    if moveInArea(Player.y, dy, H*.5 + 3, H) then
      Player.y = Player.y + dy
    end

    if moveInArea(-Camera.x, dx, Ocean.x, Portal.x - W*.5) and moveInArea(Player.x, -dx, W*.8 - Camera.x, W*.2 - Camera.x)
 then
     Camera.x = Camera.x - dx
    end
  end


 
  do -- collisions

    local p = Player:getHitbox()

    if collision(p, Ocean:getHitbox()) then
      Player:defend(Ocean:attack(Player))
    end

  end



  attackPad:update(dt)

  if love.keyboard.isDown('escape') then
    love.event.quit()
  end
end

-- draw love
function love.draw()
  lg.translate(Camera.x, Camera.y)
  lg.scale(Camera.scale) 
  -- draw ao
  for i,v in ipairs(Miu) do
    if v.draw then
      v:draw(1)
    end
  end
  lg.reset()
  
   
  movePad:draw()
  attackPad:draw()
  lg.print(movePad.dx)

  lg.print(regulateSpeed(movePad.dx, movePad.dy, Player.speed), 50)
  lg.print(Camera.x, 0,50)
end
