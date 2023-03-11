import raylib, screens, particles/fire

type
  Player* = ref object of RootObj
    position = Vector2()
    sprite = Fire()


method init*(self: Player) {.base.}  =
  self.position = Vector2(x: cx + screenWidth * 0.5, y: screenHeight * 0.8)
  self.sprite.init()

method update*(self: Player) {.base.} =
  self.sprite.update(self.position)
  
method draw*(self: Player) {.base.}  =
  self.sprite.draw()

method unload*(self: Player) {.base.} =
  self.sprite.unload()
