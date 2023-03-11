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



proc checkTileCollision(self: Gameplay) =
  # check tile collision with player
  for i, tile in self.ground.tiles:
    if (tile.pos.x + tile.size.x > cx and tile.pos.x - tile.size.x < cx + screenWidth):
      # find collision with player
      var px = self.player.position.x
      var py = self.player.position.y
      var pr = self.player.getRadius()
      var prx = pr * 0.2
      var pry = pr * 0.6
      if (tile.pos.y - tile.size.y < py + pry and tile.pos.y > py - pry):
        if (tile.pos.x - tile.size.x < px + prx and tile.pos.x + tile.size.x > px - prx):
          self.ground.tiles[i].burnTimer = 2


method update*(self: Gameplay, dt: float) =
  if isKeyPressed(Escape):
    currentScreen = TitleScreen

  # Update the camera target and zoom
  self.camera.target.x = cx
  self.camera.zoom = zoom  

  # Update gaia
  self.ground.update(dt)
  self.checkTileCollision()

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

