(local suit (require :lib.suit))
(local Bckg (require :src.Bckg))

(local fi love.filesystem)
(local gr love.graphics)
(local ma love.math)
(local ev love.event)

{
 :init (fn init [self])
 :draw (fn draw [self]
         (Bckg.draw))
         

 :update (fn update [self dt set-mode]
           (var (w h) (gr.getDimensions))
           (var start (suit.Button "Burn" (- (/ w 2) 100) (/ h 3) 200 30))
           (when (= start.hit true)
             (set-mode :src.Load))

           (var exit (suit.Button "Extinguish" (- (/ w 2) 100) (- h (/ h 3)) 200 30))
           (if (= exit.hit true)
             (ev.quit)))

 :keypressed (fn keypressed [self key set-mode]
               (if (= key :escape)
                 (ev.quit))
               (if (= key :return)
                 (set-mode :src.Load)))}
