(local Player (require :Player))
(local Sky (require :lib.Sky))
(local Ground (require :Ground))

(local gr love.graphics)

(local sky (Sky))

{:init (fn init []
         (Player.init)
         (Ground.init))
 :draw (fn draw [message]
         (sky:draw)
         (Ground.draw)
         (Player.draw))
 :update (fn update [dt set-mode]
           (Player.update dt)
           (Ground.update dt))
 :keypressed (fn keypressed [key set-mode] 
               (if (= key :escape)
                 (set-mode :mode-menu)))}
