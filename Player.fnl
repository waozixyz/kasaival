(local SpriteSheet (require :lib.SpriteSheet))

(local gr love.graphics)
(local ke love.keyboard)

(var sprite nil)
(var speed 2)
(var ow 31)
(var oh 184)

{:x 0 :y 0 :scale 1
 :init (fn init [self]
         (local (W H) (gr.getDimensions)) 
         (set self.x (* W .5))
         (set self.y (* H .5))
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
 :draw (fn draw [self]
         (gr.setColor 1 1 1)
         (sprite:draw self.x self.y 0 self.scale self.scale (* ow .5) oh))
 :update (fn update [self dt gh]
           (local (W H) (gr.getDimensions)) 
           (var w (* ow self.scale))
           (var s (* speed self.scale))
           (if (and (ke.isScancodeDown :d :right) (< self.x (- W (* w .5))))
             (set self.x (+ self.x s)))
           (if (ke.isScancodeDown :a :left)
             (set self.x (- self.x s)))
           (if (and (ke.isScancodeDown :s :down) (< self.y H))
             (set self.y (+ self.y s)))
           (if (and (ke.isScancodeDown :w :up) (> self.y (- H gh)))
             (set self.y (- self.y s)))

           (if (< self.x (* w .5))
             (set self.x (* w .5)))
           (if (> self.x (- W (* w .5)))
             (set self.x (- W (* w .5))))



           (sprite:update dt))}
