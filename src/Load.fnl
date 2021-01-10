(local Bckg (require :src.Bckg))

(local gr love.graphics)

{:saveFile :save0
 :init (fn init [self])
 :draw (fn draw [self]
         (Bckg.draw))
 :update (fn update [self dt set-mode])
 :keypressed (fn keypressd [self key set-mode]
               (if (= key :escape)
                 (set-mode :src.Menu))
               (if (= key :return)
                 (set-mode :src.Game self.saveFile)))}

