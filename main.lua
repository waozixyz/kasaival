local lg=love.graphics

local Ground = {}
local Player = require 'lib/Player'

local miu = {}

function love.load()
  W,H = lg.getDimensions()

  -- create objs for miu
  P = Player.new('/assets/flame.png', W*0.5, H*0.5, 128, 256)
  table.insert(miu, P)


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
  -- draw objs
  for k,v in ipairs(miu) do
    if v.draw ~= nil then
      v:draw()
    end
  end

  W, H = lg.getDimensions()

  lg.setColor(0.4, 0.2, 0.1 ) 
  lg.rectangle('fill', 0, H * 0.4 , W, H * 0.6 )


end
