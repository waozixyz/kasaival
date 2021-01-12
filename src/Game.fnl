(local push (require :lib.push))
(local copy (require :lib.copy))
(local serpent (require :lib.serpent))

(local Player (require :src.Player))
(local Sky (require :lib.Sky))
(local Tree (require :src.Tree))
(local Ground (require :src.Ground))

(local gr love.graphics)
(local ma love.math)
(local fi love.filesystem)

(local sky (Sky))

(var cr [ 50 70 20 40 30 30])
(var cg [ 20 40 50 70 20 30 ])
(var cb [ 50 80 20 30 80 90 ])

(fn toggle [val] (if val false true))

(fn addTree [self randomStage]
  (local (W H) (push:getDimensions))
  (var y (ma.random (/ H 3) H))
  (var scale (/ y H))
  (var x (ma.random 0 W))
  (var w (* (ma.random 10 12) scale))
  (var h (* (ma.random 22 32) scale))
  ;; copy the table template of Tree
  (table.insert self.trees (copy Tree))
  ;; get the newest tree
  (var tree (. self.trees (length self.trees)))
  (var maxStage (ma.random 8 10))
  (var currentStage (if randomStage (ma.random 0 maxStage) 0))
  (var growTime (ma.random .5 1))
  (var c (. [cb cb cb] (ma.random 1 3)))
  ;; initialize the tree
  (tree:init {:x x :y y :scale scale :w w :h h :maxStage maxStage :currentStage currentStage :growTime growTime :colorScheme c}))

(fn getProp [e]
  (var t {})
  (each [k v (pairs e)]
    (when (and (~= k :init) (~= k :update) (~= k :draw) (~= k :getHitbox) (~= k :collide))
      (tset t k v)))
  t)

(fn save [self]
  (var sav {})
  (tset sav :p (getProp self.player))
  (tset sav :g (getProp self.ground))
  (var t [])
  (each [i v (ipairs self.trees)]
    (table.insert t (getProp v)))
  (tset sav :t t)

  (tset sav :elapsed self.elapsed)
  (var (s m) (fi.write self.saveFile (serpent.dump sav))))

{:elapsed 0
 :saveFile "saves/save1"
 :init (fn init [self saveFile]
         (set self.saveFile (or saveFile self.saveFile))
         (set (self.paused self.exit self.readyToExit) (values false false false))
         (set self.trees [])

         (var (p g t) (values {} {} []))
         
         (when (fi.getInfo self.saveFile)
           (var (contents size) (fi.read self.saveFile))
           (var (ok sav) (serpent.load contents))
           (set self.elapsed (. sav :elapsed))
           (set p (. sav :p))
           (set g (. sav :g))
           (set t (. sav :t)))
         

         (set self.ground (copy Ground))
         (self.ground:init g)

         (if (> (length t) 0)
           (each [i v (ipairs t)]
             (table.insert self.trees (copy Tree))
             (var tree (. self.trees (length self.trees)))
             (tree:init v))
           (for [i 1 10]
             (addTree self true)))
         
         (set self.player (copy Player))
         (self.player:init p))
         
 :draw (fn draw [self]
         (sky:draw)
         (self.ground:draw)
         (var entities [self.player])
         (each [i tree (ipairs self.trees)]
           (table.insert entities tree))
         (set entities (lume.sort entities "y"))
         (each [i entity (ipairs entities)]
           (entity:draw)))

 :update (fn update [self dt set-mode]
           (local (W H) (push:getDimensions))

           (when self.readyToExit
             (set-mode :src.Menu))
           (when (and self.paused (not self.readyToExit))
             (gr.captureScreenshot (.. self.saveFile ".png"))
             (save self)
             (when self.exit
               (set self.readyToExit true)))
             
           (when (not self.paused)
             (set self.elapsed (+ self.elapsed dt))
             ;; adjust the player size
             (set self.player.scale (/ self.player.y H))
             ;; update functions
             (self.player:update dt self.ground.height)
             (each [i tree (ipairs self.trees)]
               (tree:update dt))
             (self.ground:update dt)
             (self.ground:collide self.player)))
 :keypressed (fn keypressed [self key set-mode] 
               (when (= key :p)
                 (set self.paused (toggle self.paused)))
               (when (= key :escape)
                 (set self.paused true)
                 (set self.exit true)))}
