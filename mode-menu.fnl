(local suit (require :suit))

(local gr love.graphics)
(local ev love.event)

(var bckg nil)

(var show_message false)

(fn test []
  (print :hi))

{:init (fn init [] 
         (set bckg (gr.newImage :assets/menu.jpg)))
 :draw (fn draw [message]
         (gr.draw bckg))
 :update (fn update [dt set-mode]
           (var (w h) (gr.getDimensions))
           (var start (suit.Button "Start Burning" {:id 1} (- (/ w 2) 100) 100 200 30))
           (if (= start.hit true)
             (set-mode :mode-game)))

 :keypressed (fn keypressed [key set-mode]
               (if (= key :escape)
                 (ev.quit))
               (if (= key :return)
                 (set-mode :mode-game)))}
