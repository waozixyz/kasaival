(local Player (require :Miu.Player))

(local gr love.graphics)

(local player (Player 1 200 200))

{:init (fn init [])
 :draw (fn draw [message]
         (player:draw))
 :update (fn update [dt set-mode]
           (player:update dt))
 :keypressed (fn keypressd [key set-mode] 
               (if (= key :escape)
                 (set-mode :mode-menu)))}
