(local push (require :lib.push))
(local suit (require :lib.suit))

(local ev love.event)
(local fi love.filesystem)
(local gr love.graphics)
(local ke love.keyboard)
(local mo love.mouse)
(local to love.touch)
(local wi love.window)

(local (gameWidth gameHeight) (values 1920 1080))
(local (windowWidth windowHeight) (gr.getDimensions))

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
  (push:setupScreen gameWidth gameHeight windowWidth windowHeight {:fullscreen true :resizable true :highdpi true})
  ;; set the theme color for the ui libray suit
  (set suit.theme.color uiTheme)
  (mode:init))

(fn love.resize [w h]
  (when mode.resize
    (mode:resize))
  (push:resize w h))


(fn love.draw []
  (push:start)
  (gr.setColor 1 1 1)
  (mode:draw)
  (gr.setColor 1 1 1)
  (suit.draw)
  (push:finish))

(fn love.update [dt]
  ;; update mouse coordinates for suit ui library
  (var (x y) (push:toGame (mo.getPosition)))
  (set x (or x 0))
  (set y (or y 0))
  (suit.updateMouse x y)
  
  ;; capture mouse and touch and pass in unified mode:touch function with x and y param
  (when mode.touch
    (local touches (to.getTouches))
    (when (> (length touches) 0)
      (each [i v (ipairs touches)]
        (local (x y) (push:toGame (mo.getPosition v)))
        (when (and x y)
          (mode:touch x y))))
    (when (mo.isDown 1)
      (local (x y) (push:toGame (mo.getPosition)))
      (when (and x y)
        (mode:touch x y))))

  ;; update mode
  (mode:update dt set-mode))

(fn love.keypressed [key]
  (if (ke.isDown "f")
    (push:switchFullscreen)
    (and (ke.isDown "lctrl" "rctrl" "capslock") (= key "q"))
    (ev.quit)
    ;; add what each keypress should do in each mode
    (mode:keypressed key set-mode)))
