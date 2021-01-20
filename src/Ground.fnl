(local push (require :lib.push))

(local gr love.graphics)
(local ma love.math)

(fn rndColor []
  (var r (ma.random 0 300))
  (var g (ma.random 300 500))
  (var b (ma.random 100 400))
  [r g b])

(fn healTile [tile]
  (var c tile.color)
  (var co tile.orgColor)
  (var (r g b) (values (. c 1) (. c 2) (. c 3)))
  (var (ro go bo) (values (. co 1) (. co 2) (. co 3)))
  (when (~= r ro)
    (set r (+ r (math.floor (* (- ro r) .004))))) 
  (when (~= g go)
    (set g (+ g (math.ceil (* (- go g) .002))))) 
  (when (~= b bo)
    (set b (+ b (math.ceil (* (- bo b) .001))))) 
  [r g b])

(fn burnTile [tile]
  (var c tile.color)
  (var (r g b) (values (. c 1) (. c 2) (. c 3)))
  (if (< r 300)
    (set r (+ r 100))
    (< r 600) 
    (set r (+ r 80))
    (< r 700) 
    (set r (+ r 30))
    (< r 800) 
    (set r (+ r 20)))
  (when (> g 50)
    (set g (- g 14))) 
  (when (> b 200)
    (set b (- b 4))) 
  [r g b])

(local rows 30)

{:tiles [] 
 :collide (fn collide [self obj]
            (local (l r u d) (obj:getHitbox))
            (each [i v (ipairs self.tiles)]
              (when (and (<= v.x r) (>= (+ v.x v.w) l) (<= (- v.y v.h) d) (>= v.y u))
                (obj:collided (lume.getColor v.color .001))
                (set v.color (burnTile v)))))


 :init (fn init [self g t]
         (local (W H) (push:getDimensions))
         (var y (/ H 3))
         (set self.height (- H y))
         ;; start value, gets bigger at each row
         (var w (/ self.height rows))
         (var h w)

         (var i 0)
         (set self.tiles (or t.tiles []))
         (when (= (length self.tiles) 0)
           (while (< y (+ H h))
             (set (w h) (values (+ w 1) (+ h 1)))
             (for [x (- (* g.width .5)) (- g.width (* g.width .5)) w]
               (var c (rndColor))
               (table.insert self.tiles {:x x :y y :w w :h h :color c :orgColor c})
               (var c (rndColor))
               (table.insert self.tiles {:x x :y y :w w :h h :color c :orgColor c})
               (set i (+ i 2)))
             (set y (+ y h)))))
 :draw (fn draw [self]
         (each [i val (ipairs self.tiles)]
           (set val.color (healTile val))
           (gr.setColor (lume.getColor val.color .001))
           (if (= (% i 2) 0)
             (gr.polygon "fill" (- val.x (* val.w .5)) val.y val.x (- val.y val.h) (+ val.x (* val.w .5)) val.y)
           (= (% i 2) 1)
             (gr.polygon "fill" val.x (- val.y val.h) (+ val.x (* val.w .5)) val.y (+ val.x val.w) (- val.y val.h)))))
 :update (fn update [self dt])}
