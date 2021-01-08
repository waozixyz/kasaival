(local gr love.graphics)

{:init (fn init [])
 :draw (fn draw [message])
 :update (fn update [dt set-mode]
           (set-mode :src.Menu))
 :keypressed (fn keypressd [key set-mode])}
