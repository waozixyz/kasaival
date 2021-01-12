(local push (require :lib.push))

(local gr love.graphics)

{:init (fn init [self img]
         (set self.img (or img (gr.newImage :assets/menu.jpg)))
         (set self.items [])
         (var (W H) (push:getDimensions))
         (var (w h) (self.img:getDimensions))
          
         (var ws (/ (/ W w) (+ 1 (math.floor (/ W w)))))
         (set w (* w ws))
          
         (var hs (/ (/ H h) (+ 1 (math.floor (/ H h)))))
         (set h (math.floor (* h hs)))
          
         (for [ww 0 W (* w 2) ]
           (for [hh 0 H (* h 2) ]
             (table.insert self.items { :x ww :y hh :sx ws :sy hs }))
           (for [hh 0 H (* h 2) ]
             (table.insert self.items { :x ww :y hh :sx ws :sy (- hs) })))          
         (for [ww 0 W (* w 2) ]
           (for [hh 0 H (* h 2) ]
             (table.insert self.items { :x ww :y hh :sx (- ws) :sy hs }))
           (for [hh 0 H (* h 2) ]
             (table.insert self.items { :x ww :y hh :sx (- ws) :sy (- hs) }))))
 :draw (fn draw [self]
         (each [i v (ipairs self.items)]
           (gr.draw self.img v.x v.y 0 v.sx v.sy)))}
