(local push (require :lib.push))

(local gr love.graphics)
(local ma love.math)

(fn getColor []
  (var r (* (ma.random 0 30) .01))
  (var g (* (ma.random 30 50) .01))
  (var b (* (ma.random 10 40) .01))
  [r g b])

(local rows 20)

{:height 320
 :tiles {} 
 :init (fn init [self t]
         (local (W H) (push:getDimensions))
         (set self.height (- H (/ H 3)))
         ;; start value, gets bigger at each row
         (var w (/ self.height rows))
         (var h w)

         (var i 0)
         (var y (- H self.height))
         (if (and t.tiles (> (length t.tiles) 0))
           (set self.tiles t.tiles)
           (while (< y H)
             (set (w h) (values (+ w 1) (+ h 1)))
             (for [x 0 (+ W w) w]
               (tset self.tiles i {:x x :y y :w w :h h :color (getColor)})
               (tset self.tiles (+ i 1) {:x x :y y :w w :h h :color (getColor)})
               (set i (+ i 2)))
             (set y (+ y h)))))
 :draw (fn draw [self]
         (each [key val (pairs self.tiles)]
           (gr.setColor val.color)
           (if (= (% key 2) 0)
             (gr.polygon "fill" (- val.x (* val.w .5)) val.y val.x (- val.y val.h) (+ val.x (* val.w .5)) val.y)
           (= (% key 2) 1)
             (gr.polygon "fill" val.x (- val.y val.h) (+ val.x (* val.w .5)) val.y (+ val.x val.w) (- val.y val.h)))))
 :update (fn update [self dt])}
