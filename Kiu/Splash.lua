require("class")
local state = require("state")
local splashy = require("lib.splashy")
local lg = love.graphics
local function mission()
  state.stage = "Menu"
  return nil
end
local function _0_(self)
  local duration = 2
  local aruga = lg.newImage("ao.png")
  splashy.addSplash(aruga, duration, 0, 0, 0.5)
  splashy.onComplete(mission)
  return nil
end
local W = class(_0_)
W.update = function(W, dt)
  splashy.update(dt)
  return nil
end
W.draw = function(W)
  splashy.draw()
  return nil
end
return W
