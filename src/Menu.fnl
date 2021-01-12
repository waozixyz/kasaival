(local push (require :lib.push))
(local suit (require :lib.suit))
(local Bckg (require :src.Bckg))

(local fi love.filesystem)
(local gr love.graphics)
(local ma love.math)
(local ev love.event)

{:init (fn init [self]
         (Bckg:init))
 :draw (fn draw [self]
         (Bckg:draw))
         

 :update (fn update [self dt set-mode]
           (local (W H) (push:getDimensions))
           (local (w h) (values 320 64))
           (local x (- (* W .5) (* w .5)))

           (gr.setNewFont 42)
           (var start (suit.Button "KASAI" x 330 w h))
           (when (= start.hit true)
             (set-mode :src.Load))

           (var exit (suit.Button "eXtinguish" x 680 w h))
           (if (= exit.hit true)
             (ev.quit)))

 :keypressed (fn keypressed [self key set-mode]
               (if (or (= key :escape) (= key :x))
                 (ev.quit))
               (if (= key :return)
                 (set-mode :src.Load)))}
