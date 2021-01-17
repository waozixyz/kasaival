(local suit (require :lib.suit))

(local mo love.mouse)

{:init (fn init [self]
         (set self.hand (mo.getSystemCursor :hand))
         (set self.arrow (mo.getSystemCursor :arrow)))
 :update (fn update [self]
           (var cursor self.arrow)
           (when (suit.anyHovered)
             (set cursor self.hand))
           (when (suit.anyHit)
             (set cursor self.arrow))
           (mo.setCursor cursor))}

         


