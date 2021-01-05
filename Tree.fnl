(local gr love.graphics)
(local ma love.math)
(local ke love.keyboard)

;; generate random colors in a range
(fn getColor []
  (var r (* (ma.random 0 3) .1))
  (var g (* (ma.random 4 6) .1))
  (var b (* (ma.random 9 10) .1))
  [r g b])

(var deg_to_rad (/ math.pi 180))

;; each line represents a branch of the tree
;; the parameters x1 y1 angle w h are used from the previous line of branch
(fn getLine [px py angle w h]
  ;; decrease line size
  ;; generate x and y coord usingn the angle
  (var x2  (+ px (* (math.cos (* angle deg_to_rad)) h)))
  (var y2  (+ py (* (math.sin (* angle deg_to_rad)) h)))
  {:deg angle :x1 px :y1 py :x2 x2 :y2 y2 :w w :h h :color (getColor)})

(fn grow [self]
  ;; get the last set of self.branches, basically one stage of growth
  (var prev (. self.branches (length self.branches)))
  ;; create new table of self.branches
  (var new [])
  
  ;; for each previous branch add new self.branches
  (each [i v (ipairs prev)]
    ;; decide if the branch splits into two self.branches
    (var split (ma.random 0 1))
    (var (w h) (values (* v.w .9) (* v.h .9)))
    (when (= split 1)
      (table.insert new (getLine v.x2 v.y2 (- v.deg (ma.random 20 30)) w h))
      (table.insert new (getLine v.x2 v.y2 (+ v.deg (ma.random 20 30)) w h)))
    (when (= split 0)
      (table.insert new (getLine v.x2 v.y2 (+ v.deg (ma.random -10 10)) w h))))
  ;; add the table of new self.branches to the entire self.branches table
  (table.insert self.branches new))

{:x 0 :y 0 :scale 1 :stages 10 :branches [] :elapsed 0 :growTime .2
 :init (fn init [self x y w h]
         (set self.stages (ma.random 8 10))
         (var x (or x 400))
         (var y (or y 500))
         (var w (or w 12))
         (var h (or h 32))
         (var branch {:deg -90 :x1 x :y1 y :x2 x :y2 (- y 20) :w w :h h :color (getColor)})
         (table.insert self.branches [branch]))

 :draw (fn draw [self]
         (each [i val (ipairs self.branches)]
           (each [j val (ipairs val)]
             (var (x1 y1) (values val.x1 val.y1))
             (var (x2 y2) (values val.x2 val.y2))
             (when (= i (length self.branches))
               (set x2 (+ x1 (/ (- x2 x1) (/ self.growTime self.elapsed))))
               (set y2 (+ y1 (/ (- y2 y1) (/ self.growTime self.elapsed)))))
             (gr.setColor val.color)
             (gr.setLineWidth val.w)
             (gr.line x1 y1 x2 y2))))

 :update (fn update [self dt]
           (when (< (length self.branches) self.stages)
             (set self.elapsed (+ self.elapsed dt))
             (when (> self.elapsed self.growTime)
               (grow self)
               (set self.elapsed 0))))}
