(local push (require :lib.push))
(local SpriteSheet (require :lib.SpriteSheet))

(local gr love.graphics)
(local ke love.keyboard)

(var sprite nil)
(var ow 31)
(var oh 175)

{:scale 1 :usingJoystick false :element "fire"
 :getHitbox (fn getHitbox [self]
              (var w (* ow self.scale))
              (var h (* oh self.scale))
              [(- self.x (* w .5)) (+ self.x (* w .5)) (- self.y (* h .2)) self.y])
 :collided (fn collided [self oc f]
             (when (= (type oc) :table)
               (set self.hp (+ self.hp (* (- (. oc 2) (. oc 3)) .3))))
             (when (= oc :plant)
               (set self.hp (+ self.hp .5))))
 :init (fn init [self t]
         (local (W H) (push:getDimensions)) 
         (set self.x (or t.x (* W .5)))
         (set self.y (or t.y (* H .7)))
         (set self.xp (or t.xp 0))
         (set self.hp (or t.hp 1000))
         (set self.lvl (or t.lvl 0))
         (set self.speed (or t.speed 10))
         (var S (SpriteSheet :assets/flame/spr_2.png ow oh))
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
 :move (fn move [self dx dy gh]
         (local (W H) (push:getDimensions)) 
         (local s (* self.speed self.scale))
         (var w (* ow self.scale))
         (var (dx dy) (values (* dx s) (* dy s)))
         (var (x y) (values (+ self.x dx) (+ self.y dy)))
         (if (< x (* w .5))
           (set x (* w .5))
           (> x (- W (* w .5)))
           (set x (- W (* w .5))))
         (if (> y H)
           (set y H)
           (< y (- H gh))
           (set y (- H gh)))
         (set (self.x self.y) (values x y)))
 :update (fn update [self dt gh]
           (set self.hp (- self.hp .3))
           (when (not self.usingJoystick)
             (var (dx dy) (values 0 0))
             (when (ke.isScancodeDown :d :right :kp6)
               (set dx 1))
             (when (ke.isScancodeDown :a :left :kp4)
               (set dx -1))
             (when (ke.isScancodeDown :s :down :kp2)
               (set dy 1))
             (when (ke.isScancodeDown :w :up :kp8)
               (set dy -1))

             (self:move dx dy gh))


           (sprite:update dt))}
