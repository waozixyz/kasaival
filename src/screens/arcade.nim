import raylib, ../screens, ../player, ../gaia/ground, ../levels, ../gaia/sky, ../ui/hud, ../utils

type
  Arcade* = ref object of Screen
    player: Player
    ground*: Ground
    level: Level
    sky: Sky
    music: Music
    hud: Hud

method init*(self: Arcade) =
  # init level
  self.level = initDaisy()
  self.id = ArcadeScreen
  # init music
  #when not defined(emscripten):
  #  self.music = loadMusicStream(ASSET_FOLDER & "/music/" & self.level.music)
  #  playMusicStream(self.music);

  # init ui
  self.hud = Hud()
  self.hud.init()
  # Init gaia
  self.sky = Sky()
  self.sky.init()
  self.ground = Ground()
  self.ground.init(self.level)
  # Init entities  
  self.player = Player()
  self.player.init()
  # The width and height of the ground plane
  camera = Camera3D()
  camera.fovy = 45
  camera.projection = CameraProjection.Perspective
  camera.up = Vector3(x: 0.0, y: 1.0, z: 0.0)


proc checkTileCollision(self: Arcade, dt: float) =
  # check tile collision with player
  var player = self.player
  # Iterate through visible tiles and check for collision with the player
  for i, tile in self.ground.tiles:
    if not tile.isTileVisible(): continue
    if checkCollisionBoxes(getBoundingBox(player.position, player.radius), getBoundingBox(tile.position, tile.size)):
      # Set burn timer for tile if player collides with it
      self.ground.tiles[i].burnTimer = 200
      playerFuel += (tile.fertility / 100) * 0.1
      var bf = 1.0
      if tile.color[2] > 120:
        bf *= 2.0
      if tile.color[2] > 140:
        bf *= 4.0
      if tile.color[2] > 180:
        bf *= 8.0
      playerFuel -= (tile.color[2] / 255) * 0.1 * bf
      #self.ground.tiles[i].plant.burnTimer = 2

method restartGame(self: Arcade): void {.base} =
  # reset game state
  playerFuel = startFuel
  self.init()
  gameOver = false



method update*(self: Arcade, dt: float) =
  # update camera
  camera.position.x = self.player.position.x  
  camera.position.y = screenHeight * 0.5 + self.player.position.y
  camera.position.z = groundLength * 2

  camera.target = self.player.position
  
  camera.target.z = 0.0
  if isKeyPressed(M):
    isMute = not isMute

  if not isMute:
    updateMusicStream(self.music)

  # change screen on escape button
  if isKeyPressed(Escape):
    currentScreen = TitleScreen

  
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


method draw*(self: Arcade) =
  # draw background
  self.sky.draw()
  beginMode3D(camera)
  # draw entities
  self.ground.draw()
  self.player.draw()
  endMode3D();
  
  # draw ui
  self.hud.draw(self.player)

method unload*(self: Arcade) =
  discard
