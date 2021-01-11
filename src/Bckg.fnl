(local gr love.graphics)
(local bckg (gr.newImage :assets/menu.jpg))

{:draw (fn draw [img]
         (var img (or img bckg))
         (var (W H) (gr.getDimensions))
         (var (w h) (img:getDimensions))
          
         (var ws (/ (/ W w) (+ 1 (math.floor (/ W w)))))
         (set w (* w ws))
          
         (var hs (/ (/ H h) (+ 1 (math.floor (/ H h)))))
         (set h (math.floor (* h hs)))
          
         (for [ww 0 W (* w 2) ]
           (for [hh 0 H (* h 2) ]
             (gr.draw img ww hh 0 ws hs))
           (for [hh 0 H (* h 2) ]
             (gr.draw img ww hh 0 ws (- hs))))
          
         (for [ww 0 W (* w 2) ]
           (for [hh 0 H (* h 2) ]
             (gr.draw img ww hh 0 (- ws) hs))
           (for [hh 0 H (* h 2) ]
             (gr.draw img ww hh 0 (- ws) (- hs)))))}
