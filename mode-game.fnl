(local copy (require :lib.copy))
(local serpent (require :lib.serpent))

(local Player (require :Player))
(local Sky (require :lib.Sky))
(local Tree (require :Tree))
(local Ground (require :Ground))

(local gr love.graphics)
(local ma love.math)
(local fi love.filesystem)

(local sky (Sky))

(var trees [])
(var gh 290)

(var cr [ 5 7 2 4 3 3])
(var cg [ 2 4 5 7 2 3 ])
(var cb [ 5 8 2 3 8 9 ])

(var saveFile :save0)

(fn addTree [randomStage]
  (local (W H) (gr.getDimensions))
  (var y (ma.random (- H gh) H))
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

(fn save []
  (var sav {})
  (tset sav :g (getProp Ground))
  (tset sav :p (getProp Player))
  (var t [])
  (each [i v (ipairs trees)]
    (table.insert t (getProp v)))
  (tset sav :t t)

  (var (s m) (fi.write saveFile (serpent.dump sav))))

(fn clear []
  (set trees []))

(fn load []
  (var p {})
  (var g {})
  (var t [])

  (when (fi.getInfo saveFile)
    (var (contents size) (fi.read saveFile ))
    (var (ok copy) (serpent.load contents))
    (set p (. copy :p))
    (set g (. copy :g))
    (set t (. copy :t)))

  (if (> (length t) 0)
    (each [i v (ipairs t)]
      (table.insert trees (copy Tree))
      (var tree (. trees (length trees)))
      (tree:init v))
    (for [i 0 10]
      (addTree true)))
  (Ground:init gh g)
  (Player:init p))

{:init (fn init []
         (load))
         
 :draw (fn draw [message]
         (sky:draw)
         (Ground:draw)
         (var entities [Player])
         (each [i tree (ipairs trees)]
           (table.insert entities tree))
         (set entities (lume.sort entities "y"))
         (each [i entity (ipairs entities)]
           (entity:draw)))

 :update (fn update [dt set-mode]
           (local (W H) (gr.getDimensions))
           ;; adjust the player size
           (set Player.scale (/ Player.y H))
           ;; update functions
           (Player:update dt gh)
           (each [i tree (ipairs trees)]
             (tree:update dt))
           (Ground:update dt))
 :keypressed (fn keypressed [key set-mode] 
               (when (= key :escape)
                 (save)
                 (clear)
                 ;; return to main menu
                 (set-mode :mode-menu)))}
