import raylib, ../screens, ../player, ../gaia/ground, ../levels, ../utils, ../gaia/sky, ../gaia/plant, std/algorithm, ../ui/hud

type
  Entity = object
    item: string
    index: array[0..1, int]
    z: float
  Arcade* = ref object of Screen
    camera: Camera2D = Camera2D()
    player: Player = Player()
    ground*: Ground = Ground()
    level: Level = initDaisy()
    sky: Sky = Sky()
    music: Music
    hud: Hud = Hud()
    entities: seq[Entity]

method init*(self: Arcade) =
  self.id = ArcadeScreen
  # init music
  when not defined(emscripten):
    self.music = loadMusicStream(ASSET_FOLDER & "/music/" & self.level.music)
    playMusicStream(self.music);
  # init ui
  self.hud.init()
  # Init gaia
  self.sky.init()
  self.ground.init(self.level)
  # Init entities  
  self.player.init()

proc checkTileCollision(self: Arcade, dt: float) =
  # check tile collision with player
  var playerPosition = self.player.position
  var playerRadius = self.player.getRadius() 

  # Iterate through visible tiles and check for collision with the player
  for i, tile in self.ground.tiles:
    if not isTileVisible(tile): continue

    let
      tileMinX = tile.center.x - tile.radius
      tileMaxX = tile.center.x + tile.radius
      tileMinY = tile.center.y - tile.radius
      tileMaxY = tile.center.y - tile.radius
      playerMinX = playerPosition.x - playerRadius
      playerMaxX = playerPosition.x + playerRadius
      playerMinY = playerPosition.y - playerRadius
      playerMaxY = playerPosition.y + playerRadius

    if playerMinX < tileMaxX and playerMaxX > tileMinX and playerMinY < tileMaxY and playerMaxY > tileMinY:
      # Set burn timer for tile if player collides with it
      self.ground.tiles[i].burnTimer = 2
      let c = self.ground.tiles[i].color
      let oc = self.ground.tiles[i].orgColor
      var bf = 4.0
      if oc[2] > 100:
        bf *= 2
      if oc[2] > 150:
        bf *= 10
      playerFuel += (c[1]  - (c[2] + oc[2]) * bf) / 1000 * dt

      if tile.plants.len == 0: continue
      
      for j, p in tile.plants:
        self.ground.tiles[i].plants[j].burnTimer = 2

proc sortEntities(x, y: Entity): int =
  cmp(x.z, y.z)


method restartGame(self: Arcade): void {.base} =
  # reset game state
  playerFuel = startFuel
  cx = 4500.0

  self.init()
  gameOver = false

method update*(self: Arcade, dt: float) =
  windPower += dt
  if isKeyPressed(M):
    isMute = not isMute

  if not isMute:
    updateMusicStream(self.music)

  # change screen on escape button
  if isKeyPressed(Escape):
    currentScreen = TitleScreen

  # Update the camera target and zoom
  self.camera.target.x = cx
  self.camera.zoom = zoom

  # update ui
  self.hud.update(dt)
  if playerFuel <= 0:
    gameOver = true
    if isKeyPressed(Enter) or isMouseButtonDown(Left):
      self.restartGame()
    return

  # Update gaia
  self.sky.update(dt)
  self.ground.update(dt)
  self.checkTileCollision(dt)

  # Update entities
  self.player.update(dt)

  # add entities to sort
  self.entities = @[]
  for i, t in self.ground.tiles:
    for j, p in t.plants:
      if p.dead: break
      if p.rightBound < cx or p.leftBound > cx + screenWidth: continue
      self.entities.add(Entity(index: [i, j], z: p.getZ(), item: "plant"))
    if t.isTileVisible():
      self.entities.add(Entity(index: [i, 0], z: t.center.y - t.radius, item: "ground"))
  
  for i, p in self.player.particles:
    self.entities.add(Entity(index: [i, -1], z: p.position.y, item: "player"))
  self.entities.sort(sortEntities)


method draw*(self: Arcade) =
  # draw background
  self.sky.draw()
  drawRectangle(0, int32(startY - 10), screenWidth, screenHeight, Color(r: 255, g: 255, b: 255, a: 120))
  beginMode2D(self.camera);

  # draw entities
  for entity in self.entities:
    var i = entity.index
    case entity.item:
      of "plant":
        self.ground.tiles[i[0]].plants[i[1]].draw()
      of "player":
        self.player.draw(i[0])
      of "ground":
        self.ground.draw(i[0])
  endMode2D();
  
  # draw ui
  self.hud.draw(self.player)

method unload*(self: Arcade) =
  discard
