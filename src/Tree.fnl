(local gr love.graphics)
(local ma love.math)
(local ke love.keyboard)
(var deg_to_rad (/ math.pi 180))

(fn rnc [l r]
  (math.floor (ma.random l r)))

;; generate random colors in a range
(fn rndColor [cs]
  [(rnc (. cs 1) (. cs 2)) (rnc (. cs 3) (. cs 4)) (rnc (. cs 5) (. cs 6))])

(fn getColor [c]
  [(* (. c 1) .001) (* (. c 2) .001) (* (. c 3) .001)])

;; each line represents a branch of the tree
;; the parameters x1 y1 angle w h are used from the previous line of branch
(fn getLine [px py angle w h cs]
  ;; decrease line size
  ;; generate x and y coord usingn the angle
  (var x2 (math.floor (+ px (* (math.cos (* angle deg_to_rad)) h))))
  (var y2 (math.floor (+ py (* (math.sin (* angle deg_to_rad)) h))))
  {:deg angle :x1 px :y1 py :x2 x2 :y2 y2 :w w :h h :color (rndColor cs)})

(fn grow [self]
  ;; get the last set of self.branches, basically one stage of growth
  (var prev (. self.branches (length self.branches)))
  ;; create new table of self.branches
  (var new [])
  
  ;; for each previous branch add new self.branches
  (each [i v (ipairs prev)]
    ;; decide if the branch splits into two self.branches
    (var (w h) (values (* v.w .9) (* v.h .9) 2))
    (let [split (ma.random 0 1)]
      (when (= split 1)
        (table.insert new (getLine v.x2 v.y2 (- v.deg (ma.random 20 30)) w h self.colorScheme))
        (table.insert new (getLine v.x2 v.y2 (+ v.deg (ma.random 20 30)) w h self.colorScheme)))
      (when (= split 0)
        (table.insert new (getLine v.x2 v.y2 (+ v.deg (ma.random -10 10)) w h self.colorScheme)))))
  ;; add the table of new self.branches to the entire self.branches table
  (table.insert self.branches new))

(fn shrink [self]
  (set self.elapsed 0)
  (table.remove self.branches (length self.branches)))



{:x 0 :y 0 :scale 1 :element "plant" :stages 10 :branches [] :elapsed 0 :growTime 1
 :colorScheme [ 100 300 100 300 100 300 ] :hp 100 :collapseTime 0

 :getHitbox (fn getHitbox [self] 
              (var first (. (. self.branches 1) 1))
              (var w (* first.w self.scale 2))
              (var h (* first.h self.scale 2))
              [(- self.x w) (+ self.x w) (- self.y h) (+ self.y h)])

 :collided (fn collided [self element]
             (when (= element :fire)
               (each [i val (ipairs self.branches)]
                 (each [j val (ipairs val)]
                   (var c val.color)
                   (var (r g b) (values (. c 1) (. c 2) (. c 3)))
                   (when (< r 900) (set r (+ r 60)))
                   (when (> g 300) (set g (- g 20)))
                   (when (> b 100) (set b (- b 10)))
                   (set val.color [r g b])
                   (set self.hp (- self.hp .1))))))

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
         (var branch {:deg -90 :x1 self.x :y1 self.y :x2 self.x :y2 (- self.y 20) :w w :h h :color (rndColor self.colorScheme)})
         (if (and t.branches (> (length t.branches) 0))
           (set self.branches t.branches)
           (table.insert self.branches [branch]))
         (for [i (length self.branches) currentStage]
           (grow self)))

 :draw (fn draw [self]
         (local l (length self.branches))
         (when (> l 0)
           (each [i val (ipairs self.branches)]
             (each [j val (ipairs val)]
               (var (x1 y1) (values val.x1 val.y1))
               (var (x2 y2) (values val.x2 val.y2))
               (when (= i l)
                 (set x2 (+ x1 (/ (- x2 x1) (/ self.growTime self.elapsed))))
                 (set y2 (+ y1 (/ (- y2 y1) (/ self.growTime self.elapsed)))))
               (gr.setColor (getColor val.color))
               (gr.setLineWidth (* val.w self.scale))
               (gr.line x1 y1 x2 y2)))))

 :update (fn update [self dt]
           (local l (length self.branches))
           (if (> self.hp 80)
             (when (< l self.stages)
               (set self.elapsed (+ self.elapsed dt))
               (when (> self.elapsed self.growTime)
                 (grow self)
                 (set self.elapsed 0)))
             (> l 0)
             (do
               (if (> l (/ self.hp l))
                 (shrink self)
                 (when (< l 5)
                   (set self.collapseTime (+ self.collapseTime dt))
                   (when (> self.collapseTime (* self.growTime 10))
                     (shrink self)
                     (set self.collapseTime 0))))
               (each [i val (ipairs self.branches)]
                 (each [j val (ipairs val)]
                   (var c val.color)
                   (var (r g b) (values (. c 1) (. c 2) (. c 3)))
                   (when (> r 300) (set r (- r 8)))
                   (when (< g 200) (set g (+ g 4)))
                   (when (< b 120) (set b (+ b 4)))
                   (set val.color [r g b]))))))}
