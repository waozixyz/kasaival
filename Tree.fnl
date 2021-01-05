(local gr love.graphics)
(local ma love.math)
(local ke love.keyboard)

(var branches [])
(var elapsed 0)
(var stages 10)

;; generate random colors in a range
(fn getColor []
  (var r (* (ma.random 0 3) .1))
  (var g (* (ma.random 4 6) .1))
  (var b (* (ma.random 9 10) .1))
  [r g b])


;; each line represents a branch of the tree
(fn getLine [prev_x prev_y add_x add_y prev_w]
  (var width (* prev_w .8))
  {:x1 prev_x :y1 prev_y :x2 (+ prev_x add_x) :y2 (+ prev_y add_y) :w width :color (getColor)})

(fn grow []
  ;; get the last set of branches, basically one stage of growth
  (var prev (. branches (length branches)))
  ;; create new table of branches
  (var new [])
  
  ;; for each previous branch add new branches
  (each [i v (ipairs prev)]
    ;; decide if the branch splits into two branches
    (var split (ma.random 0 1))
    (when (= split 1)
      (table.insert new (getLine v.x2 v.y2 (ma.random -15 -5) -20 v.w))
      (table.insert new (getLine v.x2 v.y2 (ma.random 5 15) -20 v.w)))
    (when (= split 0)
      (table.insert new (getLine v.x2 v.y2 (ma.random -4 4) -20 v.w))))
  ;; add the table of new branches to the entire branches table
  (table.insert branches new))

{:x 0 :y 0 :scale 1
 :init (fn init [self x y w]
         (var x (or x 500))
         (var y (or y 400))
         (var w (or w 12))
         (var branch {:x1 x :y1 y :x2 x :y2 (- y 20) :w w :color (getColor)})
         (table.insert branches [branch]))
 :draw (fn draw [self]
         (each [i val (ipairs branches)]
           (each [i val (ipairs val)]
             (gr.setColor val.color)
             (gr.setLineWidth val.w)
             (gr.line val.x1 val.y1 val.x2 val.y2))))
 :update (fn update [self dt]
           (when (< (length branches) stages)
             (set elapsed (+ elapsed dt))
             (when (> elapsed 1)
               (grow)
               (set elapsed 0))))}
