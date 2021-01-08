(local fi love.filesystem)
(var info (fi.getInfo :lib.stdio))
(when info
  (local repl (require :lib.stdio)))
(local suit (require :lib.suit))
(local canvas (let [(w h) (love.window.getMode)]
                (love.graphics.newCanvas w h)))

(var scale 1)

;; set the first mode
(var mode (require :src.Game))

(fn set-mode [mode-name ...]
  (set mode (require mode-name))
  (when mode.init
    (mode.init ...)))

(fn love.load []
  (canvas:setFilter :nearest :nearest)
  (when repl
    (repl.start))
  ;; set the theme color for the ui libray suit
  (set suit.theme.color {:normal {:bg [.3 .1 .14]
                                  :fg [.7 .0 .34]}
                         :hovered {:bg [.4 .1 .14]
                                   :fg [.9 .0 .1]}
                         :active {:bg [.2 .0 .1]
                                  :fg [.5 .1 .2]}})
  (mode.init))

(fn love.draw []
  ;; the canvas allows you to get sharp pixel-art style scaling; if you
  ;; don't want that, just skip that and call mode.draw directly.
  (love.graphics.setCanvas canvas)
  (love.graphics.clear)
  (love.graphics.setColor 1 1 1)
  (mode.draw)
  (suit.draw)
  (love.graphics.setCanvas)
  (love.graphics.setColor 1 1 1)
  (love.graphics.draw canvas 0 0 0 scale scale))

(fn love.update [dt]
  (mode.update dt set-mode))

(fn love.keypressed [key]
  (if (and (love.keyboard.isDown "lctrl" "rctrl" "capslock") (= key "q"))
      (love.event.quit)
      ;; add what each keypress should do in each mode
      (mode.keypressed key set-mode)))
