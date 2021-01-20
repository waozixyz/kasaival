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

(fn getTile [i v]
  (if (= (% i 2) 0)
    (values (- v.x (* v.w .5)) v.y v.x (- v.y v.h) (+ v.x (* v.w .5)) v.y)
    (= (% i 2) 1)
    (values v.x (- v.y v.h) (+ v.x (* v.w .5)) v.y (+ v.x v.w) (- v.y v.h))))


(local rows 30)

{:grid [] 
 :collide (fn collide [self obj]
            (local (l r u d) (obj:getHitbox))
            (each [i row (ipairs self.grid)]
              (each [i v (ipairs row)]
                (when (and (<= v.x r) (>= (+ v.x v.w) l) (<= (- v.y v.h) d) (>= v.y u))
                  (obj:collided (lume.getColor v.color .001))
                  (set v.color (burnTile v))))))
 :init (fn init [self g t]
         (local (W H) (push:getDimensions))
         (var y (/ H 3))
         (set self.height (- H y))
         ;; start value, gets bigger at each row
         (var w (/ self.height rows))
         (var h w)

         (var i 0)
         (set self.grid (or t.grid []))
         (when (= (length self.grid) 0)
           (while (< y (+ H h))
             (var row [])
             (set (w h) (values (+ w 1) (+ h 1)))
             (for [x (* g.width -.5) (- g.width (* g.width .5)) w]
               (var c (rndColor))
               (table.insert row {:x x :y y :w w :h h :color c :orgColor c})
               (var c (rndColor))
               (table.insert row {:x x :y y :w w :h h :color c :orgColor c})
               (set i (+ i 2)))
             (table.insert self.grid row)
             (set y (+ y h)))))
 :draw (fn draw [self g]
         (each [i row (ipairs self.grid)]
           (each [i tile (ipairs row)]
             (set tile.color (healTile tile))
             (when (g:checkVisible tile.x tile.w) 
               (gr.setColor (lume.getColor tile.color .001))
               (gr.polygon "fill" (getTile i tile))))))
 :update (fn update [self dt])}
