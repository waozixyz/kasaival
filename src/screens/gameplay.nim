import raylib, ../screens, ../player, ../gaia/ground, ../levels, ../utils

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
  var pos = self.player.position
  var pr = self.player.getRadius() * 2
  for i, tile in self.ground.tiles:
    if not isTileVisible(tile):
      continue
    let vertices = tile.vertices
    
    let (minX, maxX) = getMinMax(vertices, 0)
    let (minY, maxY) = getMinMax(vertices, 1)
    if pos.x - pr < maxX and pos.x + pr * 0.5 > minX and pos.y  < maxY and pos.y + pr + 10 > minY:
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

