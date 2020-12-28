(local gr love.graphics)

{:init (fn init [])
 :draw (fn draw [message])
 :update (fn update [dt set-mode])
 :keypressed (fn keypressd [key set-mode] 
               (if (= key :escape)
                 (set-mode :mode-menu)))}
