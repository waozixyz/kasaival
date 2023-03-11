import raylib, ../screens, ../player

type
  Gameplay* = ref object of Screen
    camera: Camera2D = Camera2D()
    player: Player = Player()

method init*(self: Gameplay) =
  self.id = GameplayScreen
  self.player.init()

method update*(self: Gameplay) =
  if isKeyPressed(Escape):
    currentScreen = TitleScreen

  # Update the camera target and zoom
  self.camera.target.x = cx
  self.camera.zoom = zoom  

  # Update entities
  self.player.update()

method draw*(self: Gameplay) =
  beginMode2D(self.camera);
  self.player.draw()
  endMode2D();

method unload*(self: Gameplay) =
  self.player.unload()

