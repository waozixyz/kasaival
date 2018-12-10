;; lyra is your personal assistant
(local fennel (require :fennel)) (table.insert (or package.loaders package.searchers) fennel.searcher)
(local view (require :fennelview))
(local state (require :state))
(local Camera (require :lib.camera))
(local Splash (require :Miu.Splash))

(local (le lg lk lw) (values love.event love.graphics love.keyboard love.window))


(fn love.load []
  (set state.w 800)
  (set state.h 600)
  (set state.eye (Camera state.w state.h {"x" 0 "y" 0 "resizable" true}))
  (set state.stage (Splash))
  nil)

(fn love.update [dt]
  (state.eye.update state.eye)
  (state.stage.update state.stage dt)
  nil)
(fn love.draw []
  (state.eye.push state.eye)
  (state.stage.draw state.stage)
  (state.eye.pop state.eye)
  nil)