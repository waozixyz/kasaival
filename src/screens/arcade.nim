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
  self.camera.fovy = 45
  self.camera.projection = CameraProjection.Perspective
  self.camera.position = Vector3(x: cameraX, y: cameraY + screenHeight * 0.5, z: groundLength * 2)
  self.camera.target = Vector3(x: cameraX, y: cameraY, z: 100)
  self.camera.up = Vector3(x: 0.0, y: 1.0, z: 0.0)

proc playerIsColliding(playerPos: Vector3, playerSize: float, objPos: Vector3, objSize: float): bool =
  let
    objRadius = objSize / 2.0
    playerRadius = playerSize / 2.0

  result = (
    playerPos.x - playerRadius < objPos.x + objRadius and 
    playerPos.x + playerRadius > objPos.x - objRadius and 
    playerPos.z - playerRadius < objPos.z + objRadius and 
    playerPos.z + playerRadius > objPos.z - objRadius and
    playerPos.y - playerRadius < objPos.y + objRadius and 
    playerPos.y + playerRadius > objPos.y 
  )


proc checkTileCollision(self: Arcade, dt: float) =
  # check tile collision with player
  var player = self.player
  var grounded = false
  # Iterate through visible tiles and check for collision with the player
  for i, tile in self.ground.tiles:
    if tile.hp <= 0: continue
    if playerIsColliding(player.position, player.radius, tile.position, tile.orgSize):
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
      grounded = true
      if tile.plants.len == 0: continue
      
      for j, p in tile.plants:
        self.ground.tiles[i].plants[j].burnTimer = 2

  if grounded:
    player.state = PlayerState.Grounded
    player.velocity.y = 0.0

  else:
    player.state = PlayerState.Falling
method restartGame(self: Arcade): void {.base} =
  # reset game state
  playerFuel = startFuel
  cameraX = startCameraX
  self.init()
  gameOver = false

method update*(self: Arcade, dt: float) =
  windPower += dt
  self.camera.position.x = cameraX
  self.camera.position.y = cameraY + screenHeight * 0.5
  self.camera.target.x = cameraX
  self.camera.target.y = cameraY
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
  endMode3D();
  
  # draw ui
  self.hud.draw(self.player)

method unload*(self: Arcade) =
  discard
