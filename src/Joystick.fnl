(local push (require :lib.push))

(local gr love.graphics)
(local mo love.mouse)
(local to love.touch)

{:dx 0 :dy 0
 :init (fn init [self]
         (local (W H) (push:getDimensions))
         (set self.color [.5 .2 .5 .6])
         (set self.r (* W .05))
         (set self.d (* self.r 2))
         (set self.x self.d) 
         (set self.y (- H self.d)))
 :draw (fn draw [self]
         (gr.setColor self.color)
         (gr.circle :fill self.dx self.dy self.r)
         (set self.dx self.x)
         (set self.dy self.y))
 :touch (fn touch [self x y]
          (when (and (>= x (- self.x self.d)) (<= x (+ self.x self.d)) (>= y (- self.y self.d)) (<= y (+ self.y self.d)))
            (set (self.dx self.dy) (values x y))))}
