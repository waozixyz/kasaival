(local push (require :lib.push))
(local copy (require :lib.copy))
(local serpent (require :lib.serpent))

(local Ground (require :src.Ground))
(local HUD (require :src.HUD))
(local Music (require :src.Music))
(local Player (require :src.Player))
(local Saves (require :src.Saves))
(local Sky (require :lib.Sky))
(local Tree (require :src.Tree))


(local fi love.filesystem)
(local gr love.graphics)
(local ke love.keyboard)
(local ma love.math)
(local sy love.system)

(local sky (Sky))

(var cr [ 500 700 200 400 200 300 ])
(var cg [ 200 300 500 700 200 300 ])
(var cb [ 200 300 300 500 500 600 ])

(fn toggle [val] (if val false true))

(fn addTree [self completeTree]
  (local (W H) (push:getDimensions))
  (var y (ma.random 0 (- H (/ H 3))))
  (var scale (/ (+ y (/ H 3)) H))

  (var x (ma.random 0 W))
  ;; create a projected x value in the fantasy 2.5 d world
  (var vir_x (/ x scale))

  (var rat_x (/ x vir_x))
  (set y (+ (/ H 3) (* y rat_x)))


  (var w (* (ma.random 14 16) scale))
  (var h (* (ma.random 32 52) scale))
  
  ;; copy the table template of Tree
  (table.insert self.trees (copy Tree))
  ;; get the newest tree
  (var tree (. self.trees (length self.trees)))
  (var maxStage (ma.random 8 10))
  (var currentStage (if completeTree maxStage 0))
  (var growTime (ma.random .5 1))
  (var c (. [cr cg cb] (ma.random 1 3)))
  ;; initialize the tree
  (tree:init {:x x :y y :scale scale :w w :h h :maxStage maxStage :currentStage currentStage :growTime growTime :colorScheme c}))

(fn getProp [e]
  (var t {})
  (each [k v (pairs e)]
    (when (and (~= k :move) (~= k :init) (~= k :collided) (~= k :update) (~= k :draw) (~= k :getHitbox) (~= k :collide))
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

  (tset sav :cx self.cx)
  (tset sav :elapsed self.elapsed)
  (tset sav :muted self.muted)
  (tset sav :treeTime self.treeTime)

  (var (s m) (fi.write self.saveFile (serpent.dump sav))))


(fn checkCollision [o1 o2]
  (local (l1 r1 u1 d1) (o1:getHitbox))
  (local (l2 r2 u2 d2) (o2:getHitbox))
  (if (and (<= l1 r2) (>= r1 l2) (<= u1 d2) (>= d1 u2))
             true
             false))

(local radToDeg (/ 180 math.pi))
(local degToRad (/ math.pi 180))



{:elapsed 0 :bgm nil
 :usingTouchMove false
 :muted true :cx 0
 :treeTime 0
 :init (fn init [self saveFile]
         ;; seth the game width
         (local (W H) (push:getDimensions))
         (set self.width (* W 2))

         ;; initialize the head over display
         (HUD:init)


         ;; the game is not over and shouldnt restart, triggering true will restart the game
         (set self.restart false)
         
         ;; get the last saveFile
         (set self.saveFile (or saveFile (Saves:nextSave)))

         ;; these variables are made for pausing exiting and saving the game
         (set (self.paused self.exit self.readyToExit) (values false false false))

         ;; this table is used to store all trees
         (set self.trees [])

         ;; load player ground trees from savefile into here
         (var (p g t) (values {} {} nil))
         (when (fi.getInfo self.saveFile)
           (set t [])
           (var (contents size) (fi.read self.saveFile))
           (var (ok sav) (serpent.load contents))
           ;; set up game
           ;; set elapsed time
           (set self.elapsed (. sav :elapsed))
           ;; get tree time
           (set self.treeTime (. sav :treeTime))
           ;; set the initiale camera x value
           (set self.cx (. save :cx))
           ;; load player
           (set p (. sav :p))
           ;; load ground
           (set g (. sav :g))
           ;; load trees
           (set t (. sav :t))) 

         ;; load ground
         (set self.ground (copy Ground))
         (self.ground:init self g)

         ;; for each tree in table load its content
         ;; if the tree table is empty make a hundred new trees
         (if (and t (> (length t) 0))
           (each [i v (ipairs t)]
             (table.insert self.trees (copy Tree))
             (var tree (. self.trees (length self.trees)))
             (tree:init v))
           (for [i 1 100]
             (addTree self true)))
         ;; load player
         (set self.player (copy Player))
         (self.player:init p))

 :checkVisible (fn checkVisible [self x w]
                 (local (W H) (push:getDimensions))
                 (if (and (< (+ x self.cx) (+ W w)) (> (+ x self.cx) (- w))) true false))
         
 :draw (fn draw [self]
         (local (W H) (push:getDimensions))
         ;; set the sky translation lower then the normal translation
         (var sky_cx (* self.cx .2))
         (gr.translate sky_cx 0)
         (sky:draw)

         ;; translate world using camera x 
         (gr.translate (- self.cx sky_cx) 0)
         (self.ground:draw self)
         (var entities [self.player])
         (each [i tree (ipairs self.trees)]
           (when (self:checkVisible tree.x 200)
             (table.insert entities tree)))
         (set entities (lume.sort entities :y))
         (each [i entity (ipairs entities)]
           (entity:draw))

         ;; reset camera translation to draw HUD
         (gr.translate (- self.cx)  0)
         (HUD:draw self))
 :touch (fn touch [self x y dt]
          (when (<= self.player.hp 0)
            (set self.restart true))
          (when (not self.paused)
            (var (px py) (values self.player.x self.player.y))
            (var x (- x self.cx))
            (var (nx ny) (values (- x px) (- y py)))
            (var w (* self.player.scale self.player.ow .2))
            (var h (* self.player.scale self.player.oh .2))
            (when (and (< nx w) (> nx (- w)) (< ny h) (> ny (- h))) (set nx nil) (set ny nil))
            (when (and (> y 100) nx ny)
              (var angle (* (math.atan2 nx ny) radToDeg))
              (when (< angle 0) (set angle (+ 360 angle)))
              (set angle (* angle degToRad))
              (var (ax ay) (values (math.sin angle) (math.cos angle)))
              (self.player:move ax ay self dt)
              (set self.usingTouchMove true))))

 :update (fn update [self dt set-mode]
           (HUD:update self)
           (local (W H) (push:getDimensions))

           (if self.muted
             (Music:mute)
             (Music:play))

           
           (when self.readyToExit
             (Music.bgm:pause)
             (set-mode :src.Menu))
           (when self.restart
             (set-mode :src.Game))

           
           (when (and self.exit (not self.readyToExit))
             (if _G.testing
               (love.event.quit)
               (do
                 (gr.captureScreenshot (.. self.saveFile ".png"))
                 (save self)
                 (set self.readyToExit true))))
             

           (when (and (not self.paused) (> self.player.hp 0))
             (when (not self.usingTouchMove)
               (var (dx dy) (values 0 0))
               (when (ke.isScancodeDown :d :right :kp6)
                 (set dx 1))
               (when (ke.isScancodeDown :a :left :kp4)
                 (set dx -1))
               (when (ke.isScancodeDown :s :down :kp2)
                 (set dy 1))
               (when (ke.isScancodeDown :w :up :kp8)
                 (set dy -1))
               (self.player:move dx dy self dt))


             ;; add new trees after treeTime goes over 1 second
             (set self.treeTime (+ self.treeTime dt))
             (when (> self.treeTime 1)
               (addTree self)
               (set self.treeTime 0))

             (set self.elapsed (+ self.elapsed dt))
             ;; adjust the player size
             (set self.player.scale (* (/ self.player.y H) (* self.player.hp .001)))
             ;; update functions
             (self.player:update dt self)
             (each [i tree (ipairs self.trees)]
               (when (checkCollision tree self.player)
                 (self.player:collided tree.element)
                 (tree:collided self.player.element))
               (tree:update dt)
               (when (< (length tree.branches) 1)
                 (set self.player.xp (+ self.player.xp 10)) 
                 (set self.player.hp (+ self.player.hp ))
                 (table.remove self.trees i)))
             (self.ground:update dt)
             (self.ground:collide self.player)
             (set self.usingTouchMove false)))
 :keypressed (fn keypressed [self key set-mode] 
               (HUD:keypressed self key)
               (when (<= self.player.hp 0)
                 (set self.restart true)))}
