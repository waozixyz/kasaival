(local suit (require :lib.suit))

(local gr love.graphics)
(local ma love.math)
(local ev love.event)

(var bckg nil)

(var show_message false)

{:init (fn init [] 
         (set bckg (gr.newImage :assets/menu.jpg)))
 :draw (fn draw [message]
         (var (W H) (gr.getDimensions))
         (var (w h) (bckg:getDimensions))

         
         (var ws (/ (/ W w) (+ 1 (math.floor (/ W w)))))
         (set w (* w ws))
         
         (var hs (/ (/ H h) (+ 1 (math.floor (/ H h)))))
         (set h (* h hs))
         
         (for [ww 0 W (* w 2) ]
           (for [hh 0 H (* h 2) ]
             (gr.draw bckg ww hh 0 ws hs))
           (for [hh 0 H (* h 2) ]
             (gr.draw bckg ww hh 0 ws (- hs))))

         (for [ww 0 W (* w 2) ]
           (for [hh 0 H (* h 2) ]
             (gr.draw bckg ww hh 0 (- ws) hs))
           (for [hh 0 H (* h 2) ]
             (gr.draw bckg ww hh 0 (- ws) (- hs)))))

         

 :update (fn update [dt set-mode]
           (var (w h) (gr.getDimensions))
           (var start (suit.Button "Start Burning" (- (/ w 2) 100) (/ h 3) 200 30))
           (if (= start.hit true)
             (set-mode :src.Game))
           (var exit (suit.Button "Extinguish" (- (/ w 2) 100) (- h (/ h 3)) 200 30))
           (if (= exit.hit true)
             (ev.quit)))

 :keypressed (fn keypressed [key set-mode]
               (if (= key :escape)
                 (ev.quit))
               (if (= key :return)
                 (set-mode :src.Game)))}
