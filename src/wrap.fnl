(local push (require :lib.push))
(local suit (require :lib.suit))

(local ev love.event)
(local fi love.filesystem)
(local gr love.graphics)
(local ke love.keyboard)
(local mo love.mouse)
(local wi love.window)

(local (gameWidth gameHeight) (values 1920 1080))
(local (windowWidth windowHeight) (wi.getDesktopDimensions))

;; set the first mode
(var mode (require :src.Load))

(fn set-mode [mode-name ...]
  (set mode (require mode-name))
  (when mode.init
    (mode:init ...)))

(var uiTheme {
  :normal {:bg [.3 .1 .14] :fg [.7 .0 .34]} 
  :hovered {:bg [.4 .1 .14] :fg [.9 .0 .1]}
  :active {:bg [.2 .0 .1] :fg [.5 .1 .2]}})

(fn love.load []
  (push:setupScreen gameWidth gameHeight windowWidth windowHeight {:resizable true :highdpi true})
  ;; set the theme color for the ui libray suit
  (set suit.theme.color uiTheme)
  (mode:init))

(fn love.resize [w h]
  (push:resize w h)
  (when mode.resize
    (mode:resize)))


(fn love.draw []
  (push:start)
  (gr.setColor 1 1 1)
  (mode:draw)
  (gr.setColor 1 1 1)
  (suit.draw)
  (push:finish))

(fn love.update [dt]
    (var (x y) (push:toGame (mo.getPosition)))
    (set x (or x 0))
    (set y (or y 0))
    (suit.updateMouse x y)
  (mode:update dt set-mode))

(fn toggle [b]
  (if (= b true)
    false
    true))

(fn love.keypressed [key]
  (if (ke.isDown "f")
    (push:switchFullscreen)
    (and (ke.isDown "lctrl" "rctrl" "capslock") (= key "q"))
    (ev.quit)
    ;; add what each keypress should do in each mode
    (mode:keypressed key set-mode)))
