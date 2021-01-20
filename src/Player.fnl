(local push (require :lib.push))
(local SpriteSheet (require :lib.SpriteSheet))

(local gr love.graphics)
(local ke love.keyboard)

(var sprite nil)

{:scale 1 :element "fire"
 :ow 31 :oh 175
 :getHitbox (fn getHitbox [self]
              (var w (* self.ow self.scale))
              (var h (* self.oh self.scale))
              (values (- self.x (* w .5)) (+ self.x (* w .5)) (- self.y (* h .2)) self.y))
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
         (set self.speed (or t.speed 600))
         (var S (SpriteSheet :assets/flame/spr_2.png self.ow self.oh))
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
         (var sc (* self.scale 1.4))
         (sprite:draw self.x self.y 0 sc sc (* self.ow .5) self.oh))
 :move (fn move [self dx dy g dt]
        (local (W H) (push:getDimensions)) 
        (local s (* self.speed self.scale dt))
        (var w (* self.ow self.scale))
        (var (dx dy) (values (* dx s) (* dy s)))
        (var (x y) (values (+ self.x dx) (+ self.y dy)))
        (if (< (+ x g.cx) (/ W 4))
          (set g.cx (- g.cx dx))
          (> (+ x g.cx) (- W (/ W 4)))
          (set g.cx (- g.cx dx)))
        (if (> y H)
          (set y H)
          (< y (- H g.ground.height))
          (set y (- H g.ground.height)))
        (set (self.x self.y) (values x y)))
 :update (fn update [self dt g]
           (if (> self.hp 3000)
             (set self.hp (- self.hp 3))
             (> self.hp 2000)
             (set self.hp (- self.hp 1))
             (> self.hp 1000)
             (set self.hp (- self.hp .6))
             (> self.hp 400)
             (set self.hp (- self.hp .3))
             (> self.hp 300)
             (set self.hp (- self.hp .6))
             (> self.hp 200)
             (set self.hp (- self.hp 1))
             (set self.hp (- self.hp 3)))
           (sprite:update dt))}
