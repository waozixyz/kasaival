(local push (require :lib.push))
(local suit (require :lib.suit))
(local Bckg (require :src.Bckg))
(local Cursor (require :src.Cursor))
(local Saves (require :src.Saves))

(local fi love.filesystem)
(local gr love.graphics)

{:init (fn init [self]
         (Bckg:init)
         (Cursor:init)
         (set self.saves (Saves:getFiles))
         (when (< (length self.saves) 4)
           (var id (+ (length self.saves) 1))
           (tset self.saves id {:img (gr.newImage "assets/newGame.jpg") :file (.. "save" id)})))

 :draw (fn draw [self]
         (Bckg:draw))
 :update (fn update [self dt set-mode]
           (local (W H) (push:getDimensions))
           (when self.saves
             (when (< (length self.saves) 2)
               (set-mode :src.Game "saves/save1"))
          
             (each [id val (pairs self.saves)]
               (local (w h) (val.img:getDimensions))
               (var scale (* (/ W w) .2))
               (var y (- (* H .5) (* h scale .5)))
               (var x (+ (* (- id 1) (+ w (* W .1)) scale) (* W .05)))
               (var s (suit.ImageButton val.img {:scale scale} x y))
               (when (= s.hit true)
                 (if val.file
                   (set-mode :src.Game (.. "saves/" val.file))
                   (set-mode :src.Game))))
             (Cursor:update)))
 :keypressed (fn keypressd [self key set-mode]
               (when (= key :escape)
                 (set-mode :src.Menu))
               (when (= key :1)
                 (set-mode :src.Game (.. Saves.saveName :1)))
               (when (= key :2)
                 (set-mode :src.Game (.. Saves.saveName :2)))
               (when (= key :3)
                 (set-mode :src.Game (.. Saves.saveName :3)))
               (when (= key :4)
                 (set-mode :src.Game (.. Saves.saveName :4)))
               (when (= key :return)
                 (set-mode :src.Game (.. Saves.saveName :1))))}

