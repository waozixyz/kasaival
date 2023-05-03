import raylib, ../screens, ../player, ../gaia/ground, ../levels, ../gaia/sky, ../gaia/plant, std/math, ../ui/hud

type
  Arcade* = ref object of Screen
    camera: Camera3D
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
  when not defined(emscripten):
    self.music = loadMusicStream(ASSET_FOLDER & "/music/" & self.level.music)
    playMusicStream(self.music);

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

  self.camera = Camera3D()
  self.camera.target = Vector3(x: cameraX, y: 0, z: 300)
  self.camera.position = Vector3(x: cameraX, y: screenHeight - 200, z: 900)
  self.camera.up = Vector3(x: 0.0, y: 1.0, z: 1.0)
  self.camera.fovy = 45.0
  self.camera.projection = CameraProjection.Perspective

proc checkTileCollision(self: Arcade, dt: float) =
  # check tile collision with player
  var playerPosition = self.player.position
  var playerRadius = self.player.getRadius() 

  # Iterate through visible tiles and check for collision with the player
  for i, tile in self.ground.tiles:
    let
      tileMinX = tile.center.x - tile.radius
      tileMaxX = tile.center.x + tile.radius
      tileMinZ = tile.center.z - tile.radius
      tileMaxZ = tile.center.z - tile.radius
      playerMinX = playerPosition.x - playerRadius
      playerMaxX = playerPosition.x + playerRadius
      playerMinZ = playerPosition.z - playerRadius
      playerMaxZ = playerPosition.z + playerRadius

    if playerMinX < tileMaxX and playerMaxX > tileMinX and playerMinZ < tileMaxZ and playerMaxZ > tileMinZ:
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


method restartGame(self: Arcade): void {.base} =
  # reset game state
  playerFuel = startFuel
  cameraX = 4500.0
  self.init()
  gameOver = false

method update*(self: Arcade, dt: float) =
  windPower += dt
  self.camera.position.x = cameraX
  self.camera.target.x = cameraX
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
  beginMode3D(self.camera)
  # draw entities
  self.ground.draw()
  self.player.draw()

  drawGrid(200, 100.0)
  endMode3D();
  
  # draw ui
  self.hud.draw(self.player)

method unload*(self: Arcade) =
  discard
