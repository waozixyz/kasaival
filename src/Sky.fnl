(local gr love.graphics)

{:init (fn init [self]
        (set self.bckg (gr.newImage "/assets/sky/bckg-2.jpg"))
        (set self.nebula (gr.newImage "/assets/sky/nebula.png")))
 :draw (fn draw [self cx]
         (gr.setColor 1 1 1)
         (gr.draw self.bckg 0 0)
         (gr.draw self.nebula 0 0))
 :update (fn update [self dt set-mode])
 :keypressed (fn keypressed [self key set-mode])}
