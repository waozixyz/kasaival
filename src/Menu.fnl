(local push (require :lib.push))
(local suit (require :lib.suit))
(local Bckg (require :src.Bckg))

(local fi love.filesystem)
(local gr love.graphics)
(local ma love.math)
(local mo love.mouse)
(local ev love.event)


(local arrow (mo.getSystemCursor :arrow))
(local hand (mo.getSystemCursor :hand))


{:init (fn init [self]
         (Bckg:init))
 :draw (fn draw [self]
         (Bckg:draw))
         
 :update (fn update [self dt set-mode]
           (var cursor arrow)
           (local (W H) (push:getDimensions))
           (local (w h) (values 320 64))
           (local x (- (* W .5) (* w .5)))

           (gr.setNewFont 42)
           (var start (suit.Button "KASAI" { :id 1 }x 330 w h))
           (when start.hit
             (set-mode :src.Load))

           (var exit (suit.Button "eXtinguish" { :id 2 } x 680 w h))
           (if exit.hit
             (ev.quit))
           (when (or (suit.isHovered 1) (suit.isHovered 2))
             (set cursor hand))
           (mo.setCursor cursor))

 :keypressed (fn keypressed [self key set-mode]
               (if (or (= key :escape) (= key :x))
                 (ev.quit))
               (if (= key :return)
                 (set-mode :src.Load)))}
