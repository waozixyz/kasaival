(local suit (require :lib.suit))
(local Bckg (require :src.Bckg))

(local fi love.filesystem)
(local gr love.graphics)
(local mo love.mouse)


{:init (fn init [self]
         (set self.saves [])
         (set self.hand (mo.getSystemCursor :hand))
         (set self.arrow (mo.getSystemCursor :arrow))
         (when (not (fi.getInfo :saves))
           (fi.createDirectory :saves))
         (var files (fi.getDirectoryItems :saves))
         (each [i file (ipairs files)]
           (var id (file:gsub "save" ""))
           (set id (id:gsub ".png" ""))
           (set id (tonumber id))
           (when (= (type id) "number")
             (when (= (. self.saves id) nil)
               (tset self.saves id {}))
             (var s (. self.saves id))
             (if (string.find file :.png)
               (tset s :img (gr.newImage (.. "saves/" file)))
               (tset s :file file))))
         (when (< (length self.saves) 4)
           (var id (+ (length self.saves) 1))
           (tset self.saves id {:img (gr.newImage "assets/newGame.jpg") :file (.. "save" id)})))

 :draw (fn draw [self]
         (Bckg.draw))
 :update (fn update [self dt set-mode]
           (var cursor self.arrow)
           (local (W H) (gr.getDimensions))
           (when (< (length self.saves) 2)
             (set-mode :src.Game "saves/save1"))
          
           (each [id val (pairs self.saves)]
             (local (w h) (val.img:getDimensions))
             (var scale (* (/ W w) .2))
             (var y (- (* H .5) (* h scale .5)))
             (var x (+ (* (- id 1) (+ w (* W .1)) scale) (* W .05)))
             (var s (suit.ImageButton val.img {:id id :scale scale} x y))
             (when (suit.isHovered id)
               (set cursor self.hand))
             (when (= s.hit true)
               (mo.setCursor self.arrow)
               (set-mode :src.Game (.. "saves/" val.file))))
           (mo.setCursor cursor))
 :keypressed (fn keypressd [self key set-mode]
               (if (= key :escape)
                 (set-mode :src.Menu))
               (if (= key :return)
                 (set-mode :src.Game self.saveFile)))}

