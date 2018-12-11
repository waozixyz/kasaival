(require :class)
(local state (require :state))
(local splashy (require :lib.splashy))

(local lg love.graphics)

(fn mission []
  (set state.stage 'Menu'))

(local W (class (fn [self]
  (var duration 2)
  (var aruga (lg.newImage 'ao.png'))
  (splashy.addSplash aruga duration 0 0 .5)
  (splashy.onComplete mission)
  nil)))

(fn W.update [W,dt]
  (splashy.update dt)
  nil)
(fn W.draw [W]
  (splashy.draw)
  nil)

W
