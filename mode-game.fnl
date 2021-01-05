(local copy (require :lib.copy))

(local Player (require :Player))
(local Sky (require :lib.Sky))
(local Tree (require :Tree))
(local Ground (require :Ground))

(local gr love.graphics)
(local ma love.math)

(local trees [])
(local sky (Sky))

(var gh 290)

(fn addTree []
  (local (W H) (gr.getDimensions))
  (var x (ma.random 0 W))
  (var y (ma.random (- H gh) H))
  (table.insert trees (copy Tree))
  (var tree (. trees (length trees)))
  (tree:init x y))

{:init (fn init []
         (addTree)
         (addTree)
         (Player:init)
         (Ground.init gh))
         
 :draw (fn draw [message]
         (sky:draw)
         (Ground.draw)
         (each [i tree (ipairs trees)]
           (tree:draw))
         (Player:draw))
 :update (fn update [dt set-mode]
           (local (W H) (gr.getDimensions))
           ;; adjust the player size
           (set Player.scale (/ Player.y H))
           ;; update functions
           (Player:update dt gh)
           (each [i tree (ipairs trees)]
             (tree:update dt))
           (Ground.update dt))
 :keypressed (fn keypressed [key set-mode] 
               (if (= key :escape)
                 ;; return to main menu
                 (set-mode :mode-menu)))}
