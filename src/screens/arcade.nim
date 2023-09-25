import raylib, ../screens, ../player, ../gaia/ground, ../gaia/sky, ../ui/hud, ../utils, ../gameConfig, ../gameState

type
  Arcade* = ref object of Screen
    player: Player
    ground*: Ground
    sky: Sky
    music: Music
    hud: Hud

const
  BURN_TIMER_VALUE = 200
  COLOR_THRESHOLD_1 = 120
  COLOR_THRESHOLD_2 = 140
  COLOR_THRESHOLD_3 = 180

proc checkXAxisCollision(playerVelocity: Vector3, playerHitbox: BoundingBox, tileHitbox: BoundingBox): float =
  if playerVelocity.x != 0:
    if tileHitbox.min.x < playerHitbox.max.x or tileHitbox.max.x > playerHitbox.min.x:
      return 0
  return playerVelocity.x

proc checkZAxisCollision(playerVelocity: Vector3, playerHitbox: BoundingBox, tileHitbox: BoundingBox): float =
  if playerVelocity.z != 0:
    if tileHitbox.min.z < playerHitbox.max.z or tileHitbox.max.z > playerHitbox.min.z:
      return 0
  return playerVelocity.z

proc checkYAxisCollision(playerVelocity: Vector3, playerHitbox: BoundingBox, tileHitbox: BoundingBox, grounded: var bool): float =
  if playerVelocity.y != 0:
    if tileHitbox.min.y < playerHitbox.max.y:
      grounded = true
      return 0
    elif tileHitbox.max.y > playerHitbox.min.y:
      return 0
  return playerVelocity.y

method init*(self: Arcade) =
  self.id = ArcadeScreen

  when not defined(emscripten):
    self.music = loadMusicStream(ASSET_FOLDER & "/music/StrangerThings.ogg")
    playMusicStream(self.music);

  self.hud = Hud()
  self.hud.init()

  self.sky = Sky()
  self.sky.init()

  self.ground = Ground()
  self.ground.init()

  self.player = Player()
  self.player.init()

  gCamera = Camera3D()
  gCamera.fovy = 60
  gCamera.projection = CameraProjection.Perspective
  gCamera.up = Vector3(x: 0.0, y: 1.0, z: 0.0)

proc checkTileCollision(self: Arcade, dt: float) =
  var playerVelocity = self.player.getVelocity(dt)
  var tmpVel = playerVelocity
  tmpVel.y = 0
  let
    playerHitbox = getBoundingBox(self.player.position, self.player.radius)
    playerVelocityHitbox = getBoundingBox(addVectors(self.player.position, tmpVel), self.player.radius)
    playerVelocityHeightHitbox = getBoundingBox(addVectors(self.player.position, playerVelocity), self.player.radius)
  var grounded = false
  for x in 0..self.ground.map.len - 1:
    if not self.ground.isTileVisible(x): continue
    for y in 0..self.ground.map[x].len - 1:
      for z in 0..self.ground.map[x][y].len - 1:
        var tile = self.ground.map[x][y][z]
        let tileHitbox = getBoundingBox(tile.position, tile.size * 0.5)
        
        if checkCollisionBoxes(playerHitbox, tileHitbox):
          grounded = true
          tile.burnTimer = 200
          gPlayerFuel += (tile.fertility / 100) * 0.1
          var bf = 1.0
          if tile.color[2] > 120:
            bf *= 2.0
          if tile.color[2] > 140:
            bf *= 4.0
          if tile.color[2] > 180:
            bf *= 8.0
          #self.ground.map[x][y][z] = tile
          # gPlayerFuel -= (tile.color[2] / 255) * 0.1 * bf
          #self.ground.tiles[i].plant.burnTimer = 2
        if checkCollisionBoxes(playerVelocityHitbox, tileHitbox):
          tile.burnTimer = BURN_TIMER_VALUE
          playerVelocity.x = checkXAxisCollision(playerVelocity, playerHitbox, tileHitbox)
          playerVelocity.z = checkZAxisCollision(playerVelocity, playerHitbox, tileHitbox)
        if checkCollisionBoxes(playerVelocityHeightHitbox, tileHitbox):
          tile.burnTimer = BURN_TIMER_VALUE
          playerVelocity.y = checkYAxisCollision(playerVelocity, playerHitbox, tileHitbox, grounded)

      
  self.player.velocity = playerVelocity
  self.player.state = if grounded: Grounded else: Falling

method restartGame(self: Arcade): void {.base} =
  # reset game state
  gPlayerFuel = startFuel
  self.init()
  gGameOver = false

method update*(self: Arcade, dt: float) =
  # update camera
  gCamera.position.x = self.player.position.x - 20
  gCamera.position.y = self.player.position.y + 2
  gCamera.position.z = 200
  gCamera.target = self.player.position
  
  gCamera.target.z = 0.0

  if isKeyPressed(M):
    gIsMute = not gIsMute

  if not gIsMute:
    updateMusicStream(self.music)

  # change screen on escape button
  if isKeyPressed(Escape):
    gCurrentScreen = TitleScreen

  
  # update ui
  self.hud.update(dt)
  if gPlayerFuel <= 0:
    gGameOver = true
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
  beginMode3D(gCamera)
  # draw entities
  self.ground.draw()
  self.player.draw()
  endMode3D();
  
  # draw ui
  self.hud.draw(self.player)

method unload*(self: Arcade) =
  discard
