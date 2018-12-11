;; lyra is your personal assistant
(local state (require :state))
(local Camera (require :lib.camera))
(local Kiu (require :Kiu.Index))

(local lyra [])
(fn lyra.load []
  (set state.w 800)
  (set state.h 600)
  (set state.p Kiu)
  (set state.stage :Splash)
  (set state.eye (Camera state.w state.h {:x 0 :y 0 :resizable true}))
  nil)

(fn getStage [st]
  ((. state.p st)))

(fn lyra.update [dt]
  (: state.eye :update)
  (set state.stage (if (= (type state.stage) :string)
    (getStage state.stage)
    state.stage))
  (when (and state.stage state.stage.update)
    (: state.stage :update dt))
  nil)

(fn lyra.draw []
  (: state.eye :push)
  (when (and state.stage state.stage.draw)
    (: state.stage :draw))
  (: state.eye :pop)
  nil)
lyra