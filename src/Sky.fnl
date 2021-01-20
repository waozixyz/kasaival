(local gr love.graphics)

{:init (fn init [self])
 :draw (fn draw [self])
 :update (fn update [self dt set-mode]
           (set-mode :src.Menu))
 :keypressed (fn keypressd [self key set-mode])}
