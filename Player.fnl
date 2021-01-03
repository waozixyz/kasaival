(local SpriteSheet (require :lib.SpriteSheet))

(local gr love.graphics)
(local ke love.keyboard)

(var sprite nil)
(var x 0)
(var y 0)
(var speed 1)
(var ow 31)
(var oh 184)

{:scale 1
 :init (fn init []
         (local (W H) (gr.getDimensions)) 
         (set x (* W .5))
         (set y (* H .5))
         (var S (SpriteSheet :assets/flame/spr_1.png ow oh))
         (var a (S:createAnimation))
         (for [row 1 4]
           (var limit 43)
           (if (= row 4)
            (set limit 41))
           (for [col 1 limit]
             (a:addFrame col row)))
         (a:setDelay 0.04)
         (set sprite a))
 :draw (fn draw []
         (gr.setColor 1 1 1)
         (sprite:draw x y 0 1 1 (* ow .5) oh))
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

           (sprite:update dt))}
