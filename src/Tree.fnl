(local gr love.graphics)
(local ma love.math)
(local ke love.keyboard)
(var deg_to_rad (/ math.pi 180))

(fn rnc [l r]
  ( * (ma.random l r) .01))

;; generate random colors in a range
(fn getColor [cs]
  [(rnc (. cs 1) (. cs 2)) (rnc (. cs 3) (. cs 4)) (rnc (. cs 5) (. cs 6))])

;; each line represents a branch of the tree
;; the parameters x1 y1 angle w h are used from the previous line of branch
(fn getLine [px py angle w h cs]
  ;; decrease line size
  ;; generate x and y coord usingn the angle
  (var x2  (+ px (* (math.cos (* angle deg_to_rad)) h)))
  (var y2  (+ py (* (math.sin (* angle deg_to_rad)) h)))
  {:deg angle :x1 px :y1 py :x2 x2 :y2 y2 :w w :h h :color (getColor cs)})

(fn grow [self]
  ;; get the last set of self.branches, basically one stage of growth
  (var prev (. self.branches (length self.branches)))
  ;; create new table of self.branches
  (var new [])
  
  ;; for each previous branch add new self.branches
  (each [i v (ipairs prev)]
    ;; decide if the branch splits into two self.branches
    (var (w h) (values (* v.w .9) (* v.h .9)))
    (let [split (ma.random 0 1)]
      (when (= split 1)
        (table.insert new (getLine v.x2 v.y2 (- v.deg (ma.random 20 30)) w h self.colorScheme))
        (table.insert new (getLine v.x2 v.y2 (+ v.deg (ma.random 20 30)) w h self.colorScheme)))
      (when (= split 0)
        (table.insert new (getLine v.x2 v.y2 (+ v.deg (ma.random -10 10)) w h self.colorScheme)))))
  ;; add the table of new self.branches to the entire self.branches table
  (table.insert self.branches new))

{:x 0 :y 0 :scale 1 :stages 10 :branches [] :elapsed 0 :growTime 1 :colorScheme [ .1 .3 .1 .3 .1 .3 ] 
 :init (fn init [self t]
         (set self.colorScheme (or t.colorScheme self.colorScheme))
         (set self.stages (or t.stages self.stages))
         (set self.growTime (or t.growTime self.growTime))
         (set self.x (or t.x self.x))
         (set self.y (or t.y self.y))
         (set self.scale (or t.scale self.scale))
         (var currentStage (or t.currentStage 0))
         (var w (or t.w 12))
         (var h (or t.h 32))
         (var branch {:deg -90 :x1 self.x :y1 self.y :x2 self.x :y2 (- self.y 20) :w w :h h :color (getColor self.colorScheme)})
         (if (and t.branches (> (length t.branches) 0))
           (set self.branches t.branches)
           (table.insert self.branches [branch]))
         (for [i (length self.branches) currentStage]
           (grow self)))

 :draw (fn draw [self]
         (each [i val (ipairs self.branches)]
           (each [j val (ipairs val)]
             (var (x1 y1) (values val.x1 val.y1))
             (var (x2 y2) (values val.x2 val.y2))
             (when (= i (length self.branches))
               (set x2 (+ x1 (/ (- x2 x1) (/ self.growTime self.elapsed))))
               (set y2 (+ y1 (/ (- y2 y1) (/ self.growTime self.elapsed)))))
             (gr.setColor val.color)
             (gr.setLineWidth (* val.w self.scale))
             (gr.line x1 y1 x2 y2))))

 :update (fn update [self dt]
           (when (< (length self.branches) self.stages)
             (set self.elapsed (+ self.elapsed dt))
             (when (> self.elapsed self.growTime)
               (grow self)
               (set self.elapsed 0))))}
