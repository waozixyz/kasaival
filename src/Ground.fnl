(local push (require :lib.push))

(local gr love.graphics)
(local ma love.math)

(fn getColor []
  (var r (* (ma.random 0 30) .01))
  (var g (* (ma.random 30 50) .01))
  (var b (* (ma.random 10 40) .01))
  [r g b])

(fn burnTile [tile]
  (var c tile.color)
  (var r (. c 1))
  (var g (. c 2))
  (var b (. c 3))
  (when (< r .7)
    (set r (+ r .04))) 
  (when (> g .1)
    (set g (- g .02))) 
  (when (> b .2)
    (set b (- b .01))) 
  [r g b])

(local rows 50)

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
               (var c (getColor))
               (table.insert self.tiles {:x x :y y :w w :h h :color c :orgColor c})
               (var c (getColor))
               (table.insert self.tiles {:x x :y y :w w :h h :color c :orgColor c})
               (set i (+ i 2)))
             (set y (+ y h)))))
 :draw (fn draw [self]
         (each [i val (ipairs self.tiles)]
           (gr.setColor val.color)
           (if (= (% i 2) 0)
             (gr.polygon "fill" (- val.x (* val.w .5)) val.y val.x (- val.y val.h) (+ val.x (* val.w .5)) val.y)
           (= (% i 2) 1)
             (gr.polygon "fill" val.x (- val.y val.h) (+ val.x (* val.w .5)) val.y (+ val.x val.w) (- val.y val.h)))))
 :update (fn update [self dt])}
