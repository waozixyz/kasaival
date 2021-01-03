(local Player (require :Player))
(local Sky (require :lib.Sky))
(local Tree (require :Tree))
(local Ground (require :Ground))

(local gr love.graphics)

(local sky (Sky))

{:init (fn init []
         (Player:init)
         (Tree:init)
         (Ground:init))
         
 :draw (fn draw [message]
         (sky:draw)
         (Ground:draw)
         (Tree:draw)
         (Player:draw))
 :update (fn update [dt set-mode]
           (local (W H) (gr.getDimensions))
           ;; get the ground height variable
           (var gh Ground.height)
           ;; adjust the player size
           (set Player.scale (/ Player.y H))
           ;; update functions
           (Player:update dt gh)
           (Tree:update dt)
           (Ground:update dt))
 :keypressed (fn keypressed [key set-mode] 
               (if (= key :escape)
                 ;; return to main menu
                 (set-mode :mode-menu)))}
