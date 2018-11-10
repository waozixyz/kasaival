local lg=love.graphics

local Ground = {}
local Player = require 'lib/Player'

local miu = {}

function love.load()
  local W,H = lg.getDimensions()
  
  -- create objs for miu
  table.insert(miu, Player.new('assets/flame_1.png', 128, 256, W*0.5, H*0.5, 1))


  -- load objs
  for k,v in ipairs(miu) do
    if v.load ~= nil then
      v:load()
    end
  end
end


function love.update(dt)
  -- update objs
  for k,v in ipairs(miu) do
    if v.update ~= nil then
      v:update(dt)
    end
  end
end

function love.draw()

  local W, H = lg.getDimensions()

  lg.setColor(0.4, 0.2, 0.1 ) 
  lg.rectangle('fill', 0, H * 0.4 , W, H * 0.6 )
  lg.setColor(1, 1, 1) 
  
  -- draw objs
  for k,v in ipairs(miu) do
    if v.draw ~= nil then
      v:draw()
    end
  end

end
