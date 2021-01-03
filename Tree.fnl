(local gr love.graphics)
(local ma love.math)
(local ke love.keyboard)

(var lines [])
(var elapsed 0)
(var finalLine 100)

;; generate random colors in a range
(fn getColor []
  (var r (* (ma.random 0 3) .1))
  (var g (* (ma.random 4 6) .1))
  (var b (* (ma.random 9 10) .1))

  {:r r :g g :b b})

;; each line basically represents a branch of the tree
(fn addLine [add_x add_y]
  (var (old_x old_y) (if (= (# lines) 0)
    (values add_x add_y)
    (values (. (. lines (# lines) :x2))
            (. (. lines (# lines) :y2)))))
  (var (new_x new_y) (if (= (# lines) 0)
                       (values add_x add_y)
                       (values (+ old_x add_x) (+ old_y add_y))))
  (tset lines (+ (# lines) 1) {:x1 old_x :y1 old_y :x2 new_x :y2 new_y :w 10 :color (getColor)}))

{:x 0 :y 0 :scale 1
 :init (fn init [self x y]
         (var x (or x 500))
         (var y (or y 400))
         (addLine x y))
 :draw (fn draw [self]
         (each [key val (pairs lines)]
           (gr.setColor val.color.r val.color.g val.color.b)
           (gr.setLineWidth val.w)
           (gr.line val.x1 val.y1 val.x2 val.y2)))
 :update (fn update [self dt]
           (when (< (# lines) finalLine)
             (set elapsed (+ elapsed dt))
             (when (> elapsed 1)
               (addLine 0 -20)
               (set elapsed 0))))}
