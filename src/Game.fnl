(local push (require :lib.push))
(local copy (require :lib.copy))
(local serpent (require :lib.serpent))

(local Ground (require :src.Ground))
(local HUD (require :src.HUD))
(local Player (require :src.Player))
(local Saves (require :src.Saves))
(local Sky (require :lib.Sky))
(local Tree (require :src.Tree))
(local Joystick (require :src.Joystick))

(local au love.audio)
(local fi love.filesystem)
(local gr love.graphics)
(local ma love.math)
(local sy love.system)

(local sky (Sky))

(var cr [ 500 700 200 400 200 300 ])
(var cg [ 200 300 500 700 200 300 ])
(var cb [ 200 300 300 500 500 600 ])

(fn toggle [val] (if val false true))

(fn addTree [self completeTree]
  (local (W H) (push:getDimensions))
  (var y (ma.random (/ H 3) H))
  (set y (+ y (ma.random 0 1)))
  (var scale (/ y H))
  (var x (ma.random 0 W))
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

  (tset sav :elapsed self.elapsed)
  (var (s m) (fi.write self.saveFile (serpent.dump sav))))

(fn drawText [text font size xpad ypad]
  (local (W H) (push:getDimensions))
  (local xpad (or xpad 0))
  (local ypad (or ypad 0))
  (local w (font:getWidth text))
  (gr.setFont font)
  (gr.print text (+ (- (* W .5) (* w .5)) xpad) (+ (* H .5) ypad)))

(fn checkCollision [o1 o2]
  (local (h1 h2) (values (o1:getHitbox) (o2:getHitbox)))
  (if (and (<= (. h1 1) (. h2 2)) (>= (. h1 2) (. h2 1)) (<= (. h1 3) (. h2 4)) (>= (. h1 4) (. h2 3)))
             true
             false))

(fn playSong [self]
  (set self.songAuthor :TeknoAXE)
  (local dir :assets/music/)
  (local list [:Running_On_Air :Robot_Disco_Dance :Supersonic :Dystopian_Paradise :Caught_in_the_Drift])
  (local ext :.mp3)
  (var title self.songTitle)
  (while (= title self.songTitle)
    (set self.songTitle (. list (ma.random (length list)))))
  (set self.bgm (au.newSource (.. dir self.songTitle ext) :stream))
  (au.play self.bgm))

{:elapsed 0 :bgm nil
 :virtualJoystick false
 :treeTime 0
 :muted true
 :init (fn init [self saveFile]
         (HUD:init)
         (set self.restart false)
         (set self.fontSize 48)
         (set self.bigFont (gr.newFont :assets/fonts/hintedSymbola.ttf self.fontSize))
         (set self.font (gr.newFont :assets/fonts/hintedSymbola.ttf 20))

         (when (or (= (sy.getOS) "Android") (= (sy.getOS) "iOS"))
           (set self.virtualJoystick true))

         (set self.saveFile (or saveFile (Saves:nextSave)))
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
         
         (if (not self.bgm)
           (playSong self)
           (not (self.bgm:isPlaying))
           (self.bgm:play))
         (when self.muted
           (self.bgm:pause))

         (set self.ground (copy Ground))
         (self.ground:init g)

         (if (> (length t) 0)
           (each [i v (ipairs t)]
             (table.insert self.trees (copy Tree))
             (var tree (. self.trees (length self.trees)))
             (tree:init v))
           (for [i 1 100]
             (addTree self true)))
         
         (set self.player (copy Player))
         (self.player:init p)
         (set self.moveStick (copy Joystick))
         (self.moveStick:init))
         
 :draw (fn draw [self]
         (local (W H) (push:getDimensions))
         (sky:draw)
         (self.ground:draw)
         (var entities [self.player])
         (each [i tree (ipairs self.trees)]
           (table.insert entities tree))
         (set entities (lume.sort entities :y))
         (each [i entity (ipairs entities)]
           (entity:draw))
         (when self.virtualJoystick
           (self.moveStick:draw))
         (when (<= self.player.hp 0)
           (gr.setFont self.bigFont)
           (gr.setColor 0 0 0 .5)
           (gr.rectangle "fill" 0 0 W H)
           (gr.setColor .6 0 .3)
           (drawText "GameOver" self.bigFont self.fontSize 0 0)
           (drawText "touch anywhere or press any key to try again" self.bigFont self.fontSize 0 self.fontSize))
         (do
           (gr.setFont self.font)
           (gr.setColor [1 1 1])
           (local title (.. "🎶 " self.songAuthor " - " self.songTitle " 🎶"))
           (local w (self.font:getWidth title))
           (gr.print title (- W w 20) (- H 40))))

 :touch (fn touch [self ...]
          (if (<= self.player.hp 0)
            (set self.restart true)
            (when (and self.virtualJoystick (not self.pause))
              (var (mx my) (self.moveStick:touch ...))
              (when (or (~= mx 0) (~= my 0))
                (self.player:move mx my self.ground.height)
                (set self.player.usingJoystick true)))))

 :update (fn update [self dt set-mode]
           (HUD:update self)
           (local (W H) (push:getDimensions))
           (when (and (not (self.bgm:isPlaying)) (not self.muted))
             (playSong self))
           
           (when self.readyToExit
             (self.bgm:pause)
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

             ;; add new trees after treeTime goes over 1 second
             (set self.treeTime (+ self.treeTime dt))
             (when (> self.treeTime 1)
               (addTree self)
               (set self.treeTime 0))

             (set self.elapsed (+ self.elapsed dt))
             ;; adjust the player size
             (set self.player.scale (* (/ self.player.y H) (* self.player.hp .001)))
             ;; update functions
             (self.player:update dt self.ground.height)
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
             (set self.player.usingJoystick false)))
 :keypressed (fn keypressed [self key set-mode] 
               (HUD:keypressed self key)
               (when (<= self.player.hp 0)
                 (set self.restart true))
               (when (= key :n)
                 (self.bgm:stop))
               (when (= key :m)
                 (if self.muted
                   (do
                     (set self.muted false)
                     (self.bgm:play))
                   (do
                     (set self.muted true)
                     (self.bgm:pause)))))}
