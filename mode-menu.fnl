(local suit (require :lib.suit))

(local gr love.graphics)
(local ev love.event)

(var bckg nil)

(var show_message false)

{:init (fn init [] 
         (set bckg (gr.newImage :assets/menu.jpg)))
 :draw (fn draw [message]
         (gr.draw bckg))
 :update (fn update [dt set-mode]
           (var (w h) (gr.getDimensions))
           (var start (suit.Button "Start Burning" (- (/ w 2) 100) 140 200 30))
           (if (= start.hit true)
             (set-mode :mode-game))
           (var exit (suit.Button "Extinguish" (- (/ w 2) 100) 305 200 30))
           (if (= exit.hit true)
             (ev.quit)))

 :keypressed (fn keypressed [key set-mode]
               (if (= key :escape)
                 (ev.quit))
               (if (= key :return)
                 (set-mode :mode-game)))}
