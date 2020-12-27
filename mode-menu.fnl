(var counter 0)
(var time 0)

{:draw (fn draw [message]
         (love.graphics.print (: "This window should close in %0.2f seconds"
                                 :format (- 3 time)) 32 16))
 :update (fn update [dt set-mode]
           
           )
 :keypressed (fn keypressed [key set-mode]
                 (love.event.quit))}
