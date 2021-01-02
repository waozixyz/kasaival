(local Flame (require :lib.Flame))

(local gr love.graphics)
(local ke love.keyboard)

(var sprite nil)
(var x 0)
(var y 0)
(var speed 1)

{:init (fn init []
         (local (W H) (gr.getDimensions)) 
         (set x (* W .5))
         (set y (* H .5))
         (set sprite (Flame 1)))
 :draw (fn draw []
         (sprite:draw))
 :update (fn update [dt]
           (local (W H) (gr.getDimensions)) 
           (if (and (ke.isScancodeDown :d :right) (< x W))
             (set x (+ x speed)))
           (if (and (ke.isScancodeDown :a :left) (> x 0))
             (set x (- x speed)))
           (if (and (ke.isScancodeDown :s :down) (< y H))
             (set y (+ y speed)))
           (if (and (ke.isScancodeDown :w :up) (> y 200))
             (set y (- y speed)))

           (set sprite.x x)
           (set sprite.y y)
           (sprite:update dt))}
