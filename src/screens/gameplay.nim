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
  var pw = self.player.getRadius() * 0.5
  var ph = self.player.getRadius() * 0.2
  for i, tile in self.ground.tiles:
    if not isTileVisible(tile):
      continue
    var collided = false
    let vertices = tile.vertices
    for j in 0 ..< vertices.len:
      let vertex = vertices[j]
      let nextVertex = vertices[(j + 1) mod vertices.len]
      if doLineSegmentsIntersect(
          vertex.x, vertex.y, nextVertex.x, nextVertex.y,
          pos.x - pw, pos.y - ph, pos.x + pw, pos.y + ph):
        collided = true
        break
    if collided:
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

