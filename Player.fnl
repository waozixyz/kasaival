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
           (if (ke.isScancodeDown :d :right)
             (set x (+ x speed)))
           (if (ke.isScancodeDown :a :left)
             (set x (- x speed)))
           (if (ke.isScancodeDown :s :down)
             (set y (+ y speed)))
           (if (ke.isScancodeDown :w :up)
             (set y (- y speed)))

           (set sprite.x x)
           (set sprite.y y)
           (sprite:update dt))}
