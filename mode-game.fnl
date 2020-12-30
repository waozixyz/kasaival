(local Player (require :Player))
(local Sky (require :lib.Sky))
(local Ground (require :lib.Ground))

(local gr love.graphics)

(local ground (Ground))
(local sky (Sky))

{:init (fn init []
         (Player.init))
 :draw (fn draw [message]
         (sky:draw)
         (ground:draw)
         (Player.draw))
 :update (fn update [dt set-mode]
           (Player.update dt))
 :keypressed (fn keypressed [key set-mode] 
               (if (= key :escape)
                 (set-mode :mode-menu)))}
