(local ev love.event)
(local fi love.filesystem)
(local gr love.graphics)
(local ke love.keyboard)
(local wi love.window)

(local suit (require :lib.suit))
(var canvas (let [(w h) (wi.getMode)]
                (gr.newCanvas w h)))

(var scale 1)

;; set the first mode
(var mode (require :src.Game))

(fn set-mode [mode-name ...]
  (set mode (require mode-name))
  (when mode.init
    (mode:init ...)))

(var uiTheme {
  :normal {:bg [.3 .1 .14] :fg [.7 .0 .34]} 
  :hovered {:bg [.4 .1 .14] :fg [.9 .0 .1]}
  :active {:bg [.2 .0 .1] :fg [.5 .1 .2]}})

(fn love.load []
  (canvas:setFilter :nearest :nearest)
  ;; set the theme color for the ui libray suit
  (set suit.theme.color uiTheme)
  (mode:init))

(fn love.resize [w h]
  (set canvas (let [(w h) (wi.getMode)] (gr.newCanvas w h)))
  (when mode.resize
    (mode:resize)))

(fn love.draw []
  ;; the canvas allows you to get sharp pixel-art style scaling; if you
  ;; don't want that, just skip that and call mode.draw directly.
  (gr.setCanvas canvas)
  (gr.clear)
  (gr.setColor 1 1 1)
  (mode:draw)
  (suit.draw)
  (gr.setCanvas)
  (gr.setColor 1 1 1)
  (gr.draw canvas 0 0 0 scale scale))

(fn love.update [dt]
  (mode:update dt set-mode))

(fn toggle [b]
  (if (= b true)
    false
    true))

(fn love.keypressed [key]
  (if (ke.isDown "f")
    (wi.setFullscreen (toggle (wi.getFullscreen)))
    (and (ke.isDown "lctrl" "rctrl" "capslock") (= key "q"))
    (ev.quit)
    ;; add what each keypress should do in each mode
    (mode:keypressed key set-mode)))
