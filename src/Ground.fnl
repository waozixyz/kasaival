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
    (set r (+ r (* (- ro r) .007)))) 
  (when (~= g go)
    (set g (+ g (* (- go g) .005)))) 
  (when (~= b bo)
    (set b (+ b (* (- bo b) .001)))) 
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
    (set r (+ r 12)))
  (when (> g 100)
    (set g (- g 8))) 
  (when (> b 200)
    (set b (- b 4))) 
  [r g b])

(local rows 40)

{:tiles [] 
 :collide (fn collide [self obj]
            (local o (obj:getHitbox))
            (each [i v (ipairs self.tiles)]
              (when (and (<= v.x (. o 2)) (>= (+ v.x v.w) (. o 1)) (<= (- v.y v.h) (. o 4)) (>= v.y (. o 3)))
                (set v.color (burnTile v)))))


 :init (fn init [self t]
         (local (W H) (push:getDimensions))
         (var y (/ H 3))
         (set self.height (- H y))
         ;; start value, gets bigger at each row
         (var w (/ self.height rows))
         (var h w)

         (var i 0)
         (if (and t t.tiles (> (length t.tiles) 0))
           (set self.tiles t.tiles)
           (while (< y (+ H h))
             (set (w h) (values (+ w 1) (+ h 1)))
             (for [x 0 (+ W w) w]
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
