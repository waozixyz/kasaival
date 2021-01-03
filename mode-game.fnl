(local Player (require :Player))
(local Sky (require :lib.Sky))
(local Ground (require :Ground))

(local gr love.graphics)

(local sky (Sky))

{:init (fn init []
         (Player:init)
         (Ground:init))
         
 :draw (fn draw [message]
         (sky:draw)
         (Ground:draw)
         (Player:draw))
 :update (fn update [dt set-mode]
           (local (W H) (gr.getDimensions))
           (var gh Ground.height)
           (set Player.scale (/ Player.y H))
           (Player:update dt gh)
           (Ground:update dt))
 :keypressed (fn keypressed [key set-mode] 
               (if (= key :escape)
                 (set-mode :mode-menu)))}
