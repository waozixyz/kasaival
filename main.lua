local lg=love.graphics

local Ground = require 'lib/Ground'
local Mothership = require 'lib/Mothership'
local Ocean = require 'lib/Ocean'
local Player = require 'lib/Player'
local Joystick = require 'lib/Joystick'

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

-- ao's
local P

-- Camera
local Camera = {
  x = 0,
  y = 0,
}

-- load love
function love.load()
  local W,H = lg.getDimensions()
  

  P=Player.new({
    img='assets/flame_1.png',
    w=128,
    h=256,
    x=W*0.5,
    y=H*0.5,
    sx=1,
    st=1
  })

  -- add ao to Miu
  Miu:addMao({
    Ground,
    Mothership,
    Ocean,
    P 
  })

  do -- joysticks
    local x,y,r=W*0.85,H*0.75,64
    local c1={.2,.1,.8,.5}
    local c2={.8,.1,.2,.5}
    
    movePad=Joystick(W-x, y, r, c1)
    attackPad=Joystick(x, y, r, c2)
  end

  -- load ao
  for k,v in ipairs(Miu) do
    if v.load ~= nil then
      v:load()
    end
  end
end

-- update love
function love.update(dt)
  -- update ao
  for k,v in ipairs(Miu) do
    if v.update ~= nil then
      v:update(dt)
    end
  end
  

  movePad:update(dt)
  do -- move Camera and Player
    local dx = movePad.dx
    local dy = movePad.dy
    P.x = P.x + dx
    P.y = P.y + dy
    Camera.x = Camera.x - dx
    Camera.y = Camera.y - dy
  end

  attackPad:update(dt)
 
end

-- draw love
function love.draw()
  lg.translate(Camera.x, Camera.y)

  -- draw ao
  for k,v in ipairs(Miu) do
    if v.draw ~= nil then
      v:draw(1)
    end
  end
  
  lg.translate(-Camera.x, -Camera.y)
  movePad:draw()
  attackPad:draw()


end
