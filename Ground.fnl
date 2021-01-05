
(local gr love.graphics)
(local ma love.math)

(var tiles {})
(fn getColor []
  (var r (* (ma.random 0 3) .1))
  (var g (* (ma.random 3 5) .1))
  (var b (* (ma.random 1 4) .1))
  [r g b])
(var height 0)
{:init (fn init [gh]
         (set height gh)
         (local (W H) (gr.getDimensions))
         (var (w h) (values 8 8)) ;start value, gets bigger at each row
         (var i 0)
         (var y (- H height))
         (while (< y H)
           (set (w h) (values (+ w 1) (+ h 1)))
           (for [x 0 W w]
             (tset tiles i {:x x :y y :w w :h h :color (getColor)})
             (tset tiles (+ i 1) {:x x :y y :w w :h h :color (getColor)})
             (set i (+ i 2)))
           (set y (+ y h))))
 :draw (fn draw []
         (each [key val (pairs tiles)]
           (gr.setColor val.color)
           (if (= (% key 2) 0)
             (gr.polygon "fill" (- val.x (* val.w .5)) val.y val.x (- val.y val.h) (+ val.x (* val.w .5)) val.y)
           (= (% key 2) 1)
             (gr.polygon "fill" val.x (- val.y val.h) (+ val.x (* val.w .5)) val.y (+ val.x val.w) (- val.y val.h)))))
 :update (fn update [dt])}
