(local Bckg (require :src.Bckg))

(local fi love.filesystem)
(local gr love.graphics)

{:saveFile "saves/save0"
 :init (fn init [self set-mode]
         (when (not (fi.getInfo :saves))
           (fi.createDirectory :saves))
         (var files (fi.getDirectoryItems :saves))
         (each [key file (pairs files)]
           (print file)))

 :draw (fn draw [self]
         (Bckg.draw))
 :update (fn update [self dt set-mode]
          (when (= (# (fi.getDirectoryItems :saves)) 0)
            (set-mode :src.Game self.saveFile)))
 :keypressed (fn keypressd [self key set-mode]
               (if (= key :escape)
                 (set-mode :src.Menu))
               (if (= key :return)
                 (set-mode :src.Game self.saveFile)))}

