(local suit (require :lib.suit))
(local Bckg (require :src.Bckg))

(local fi love.filesystem)
(local gr love.graphics)
(local mo love.mouse)


{:saves []
 :init (fn init [self]
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
               (tset s :file file)))))

 :draw (fn draw [self]
         (Bckg.draw))
 :update (fn update [self dt set-mode]
           (local (W H) (gr.getDimensions))
           (when (= (length self.saves) 0)
             (set-mode :src.Game "saves/save1"))
          
           (each [id val (pairs self.saves)]
             (var s (suit.ImageButton val.img {:id 1 :scale .2} 100 20))
             (if (suit.isHovered 1)
               (mo.setCursor self.hand)
               (mo.setCursor self.arrow))
             (when (= s.hit true)
               (mo.setCursor self.arrow)
               (set-mode :src.Game (.. "saves/" val.file)))))
 :keypressed (fn keypressd [self key set-mode]
               (if (= key :escape)
                 (set-mode :src.Menu))
               (if (= key :return)
                 (set-mode :src.Game self.saveFile)))}

