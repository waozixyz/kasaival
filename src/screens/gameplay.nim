import raylib, ../screens, ../player, ../gaia/ground, ../levels

type
  Gameplay* = ref object of Screen
    camera: Camera2D = Camera2D()
    player: Player = Player()
    ground: Ground = Ground()
    level: Level = initDaisy()

method init*(self: Gameplay) =
  self.id = GameplayScreen
  # Init gaia
  self.ground.init(self.level)

  # Init entities  
  self.player.init()

method update*(self: Gameplay) =
  if isKeyPressed(Escape):
    currentScreen = TitleScreen

  # Update the camera target and zoom
  self.camera.target.x = cx
  self.camera.zoom = zoom  

  # Update gaia
  self.ground.update()

  # Update entities
  self.player.update()

method draw*(self: Gameplay) =
  beginMode2D(self.camera);
  # draw gaia
  self.ground.draw()
  # draw entities
  self.player.draw()
  endMode2D();

method unload*(self: Gameplay) =
  # unload gaia
  self.ground.unload()
  # unload entities
  self.player.unload()

