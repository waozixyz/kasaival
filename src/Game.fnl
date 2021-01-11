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

(var trees [])

(var cr [ 50 70 20 40 30 30])
(var cg [ 20 40 50 70 20 30 ])
(var cb [ 50 80 20 30 80 90 ])

(fn addTree [randomStage]
  (local (W H) (gr.getDimensions))
  (var y (ma.random (- H Ground.height) H))
  (var scale (/ y H))
  (var x (ma.random 0 W))
  (var w (* (ma.random 10 12) scale))
  (var h (* (ma.random 22 32) scale))
  ;; copy the table template of Tree
  (table.insert trees (copy Tree))
  ;; get the newest tree
  (var tree (. trees (length trees)))
  (var maxStage (ma.random 8 10))
  (var currentStage (if randomStage (ma.random 0 maxStage) 0))
  (var growTime (ma.random .5 1))
  (var c (. [cb cb cb] (ma.random 1 3)))
  ;; initialize the tree
  (tree:init {:x x :y y :scale scale :w w :h h :maxStage maxStage :currentStage currentStage :growTime growTime :colorScheme c}))

(fn getProp [e]
  (var t {})
  (each [k v (pairs e)]
    (when (and (~= k :init) (~= k :update) (~= k :draw))
      (tset t k v)))
  t)

(fn save [self]
  (var sav {})
  (tset sav :g (getProp self.ground))
  (tset sav :p (getProp self.player))
  (var t [])
  (each [i v (ipairs trees)]
    (table.insert t (getProp v)))
  (tset sav :t t)

  (var (s m) (fi.write self.saveFile (serpent.dump sav))))

(fn clear []
  (set trees []))


(var elapsed 0)
{:saveFile "saves/save0"
 :init (fn init [self saveFile]
         (set self.saveFile (or saveFile self.saveFile))
         (var p {})
         (var g {})
         (var t [])
         
         (when (fi.getInfo self.saveFile)
           (var (contents size) (fi.read self.saveFile))
           (var (ok copy) (serpent.load contents))
           (set p (. copy :p))
           (set g (. copy :g))
           (set t (. copy :t)))
         
         (if (> (length t) 0)
           (each [i v (ipairs t)]
             (table.insert trees (copy Tree))
             (var tree (. trees (length trees)))
             (tree:init v))
           (for [i 1 10]
             (addTree true)))
         (set self.ground (copy Ground))
         (self.ground:init g)
         (set self.player (copy Player))
         (self.player:init p))
         
 :draw (fn draw [self]
         (sky:draw)
         (self.ground:draw)
         (var entities [self.player])
         (each [i tree (ipairs trees)]
           (table.insert entities tree))
         (set entities (lume.sort entities "y"))
         (each [i entity (ipairs entities)]
           (entity:draw)))

 :update (fn update [self dt set-mode]
           (local (W H) (gr.getDimensions))
           ;; adjust the player size
           (set self.player.scale (/ self.player.y H))
           ;; update functions
           (self.player:update dt self.ground.height)
           (each [i tree (ipairs trees)]
             (tree:update dt))
           (self.ground:update dt))
 :keypressed (fn keypressed [self key set-mode] 
               (when (= key :escape)
                 (save self)
                 (clear)
                 ;; return to main menu
                 (set-mode :src.Menu)))}
