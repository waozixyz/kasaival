
(local gr love.graphics)
(local ma love.math)

(var tiles {})
(fn getTileColor []
  (var r (* (ma.random 0 3) .1))
  (var g (* (ma.random 4 6) .1))
  (var b (* (ma.random 1 4) .1))
  {:r r :g g :b b})
{:height 290
 :init (fn init [self]
         (local (W H) (gr.getDimensions))
         (var (w h) (values 8 8)) ;start value, gets bigger at each row
         (var i 0)
         (var y (- H self.height))
         (while (< y H)
           (set (w h) (values (+ w 1) (+ h 1)))
           (for [x 0 W w]
             (tset tiles i {:x x :y y :w w :h h :color (getTileColor)})
             (tset tiles (+ i 1) {:x x :y y :w w :h h :color (getTileColor)})
             (set i (+ i 2)))
           (set y (+ y h))))
 :draw (fn draw [self]
         (each [key val (pairs tiles)]
           (gr.setColor val.color.r val.color.g val.color.b)
           (if (= (% key 2) 0)
             (gr.polygon "fill" (- val.x (* val.w .5)) val.y val.x (- val.y val.h) (+ val.x (* val.w .5)) val.y)
           (= (% key 2) 1)
             (gr.polygon "fill" val.x (- val.y val.h) (+ val.x (* val.w .5)) val.y (+ val.x val.w) (- val.y val.h)))))
 :update (fn update [self dt])}
