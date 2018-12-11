local state = require("state")
local Camera = require("lib.camera")
local Kiu = require("Kiu.Index")
local lyra = {}
lyra.load = function()
  state.w = 800
  state.h = 600
  state.p = Kiu
  state.stage = "Splash"
  state.eye = Camera(state.w, state.h, {resizable = true, x = 0, y = 0})
  return nil
end
local function getStage(st)
  return state.p[st]()
end
lyra.update = function(dt)
  state.eye:update()
  local function _0_()
    if (type(state.stage) == "string") then
      return getStage(state.stage)
    else
      return state.stage
    end
  end
  state.stage = _0_()
  local function _1_()
    if (state.stage and state.stage.update) then
      return state.stage:update(dt)
    end
  end
  _1_()
  return nil
end
lyra.draw = function()
  state.eye:push()
  local function _0_()
    if (state.stage and state.stage.draw) then
      return state.stage:draw()
    end
  end
  _0_()
  state.eye:pop()
  return nil
end
return lyra
