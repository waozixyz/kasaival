local fennel = require("fennel")
table.insert((package.loaders or package.searchers), fennel.searcher)
local view = require("fennelview")
local state = require("state")
local Camera = require("lib.camera")
local Splash = require("Miu.Splash")
local le, lg, lk, lw = love.event, love.graphics, love.keyboard, love.window
love.load = function()
  state.w = 800
  state.h = 600
  state.eye = Camera(state.w, state.h, {resizable = true, x = 0, y = 0})
  state.stage = Splash()
  return nil
end
love.update = function(dt)
  state.eye.update(state.eye)
  state.stage.update(state.stage, dt)
  return nil
end
love.draw = function()
  state.eye.push(state.eye)
  state.stage.draw(state.stage)
  state.eye.pop(state.eye)
  return nil
end
return love.draw
