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
(fn getLine [p angle w h cs]
  ;; decrease line size
  ;; generate x and y coord usingn the angle
  (var nx (math.floor (+ (. p 1) (* (math.cos (* angle deg_to_rad)) h))))
  (var ny (math.floor (+ (. p 2) (* (math.sin (* angle deg_to_rad)) h))))
  {:deg angle :p p :n [nx ny]  :w w :h h :color (rndColor cs)})

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
        (table.insert new (getLine v.n (- v.deg (ma.random 20 30)) w h self.colorScheme))
        (table.insert new (getLine v.n (+ v.deg (ma.random 20 30)) w h self.colorScheme)))
      (when (= split 0)
        (table.insert new (getLine v.n (+ v.deg (ma.random -10 10)) w h self.colorScheme)))))
  ;; add the table of new self.branches to the entire self.branches table
  (table.insert self.branches new))

(fn shrink [self]
  (set self.elapsed 0)
  (table.remove self.branches (length self.branches)))



{:x 0 :y 0 :element "plant" :colorScheme [ 100 300 100 300 100 300 ] :collapseTime 0

 :getHitbox (fn getHitbox [self] 
              (var first (. (. self.branches 1) 1))
              (var w (* first.w self.scale 2))
              (var h (* first.h self.scale 2))
              (values (- self.x w) (+ self.x w) (- self.y h) (+ self.y h)))

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
                   (set self.hp (- self.hp .5))))))

 :init (fn init [self t]
         (set self.colorScheme (or t.colorScheme self.colorScheme))
         (set self.elapsed (or t.elapsed 0))
         (set self.stages (or t.stages 10))
         (set self.growTime (or t.growTime 1))
         (set self.x (or t.x self.x))
         (set self.y (or t.y self.y))
         (set self.hp (or t.hp 100))
         (set self.scale (or t.scale 1))
         (set self.branches (or t.branches []))
         (var currentStage (or t.currentStage 0))
         (var w (or t.w 12))
         (var h (or t.h 32))
         (var p [0  self.y]) ;; prev coord
         (var n [0 (- self.y h)]) ;; next coori
         (var branch {:deg -90 :p p :n n :w w :h h :color (rndColor self.colorScheme)})
         (if (and t.branches (> (length t.branches) 0))
           (set self.branches t.branches)
           (table.insert self.branches [branch]))
         (for [i (length self.branches) currentStage]
           (grow self)))

 :draw (fn draw [self]
         (local x self.x)
         (local l (length self.branches))
         (when (> l 0)
           (each [i val (ipairs self.branches)]
             (each [j val (ipairs val)]
               (var (px py) (values (. val.p 1) (. val.p 2)))
               (var (nx ny) (values (. val.n 1) (. val.n 2)))
               (when (= i l)
                 (set nx (+ px (/ (- nx px) (/ self.growTime self.elapsed))))
                 (set ny (+ py (/ (- ny py) (/ self.growTime self.elapsed)))))
               (set (px nx) (values (+ x px) (+ x nx)))
               (gr.setColor (getColor val.color))
               (gr.setLineWidth (* val.w self.scale))
               (gr.line px py nx ny)))))

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
