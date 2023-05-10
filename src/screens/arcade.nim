import raylib, ../screens, ../player, ../gaia/ground, ../gaia/sky, ../ui/hud, ../utils

type
  Arcade* = ref object of Screen
    player: Player
    ground*: Ground
    sky: Sky
    music: Music
    hud: Hud

method init*(self: Arcade) =
  # init level
  self.id = ArcadeScreen
  # init music
  when not defined(emscripten):
    self.music = loadMusicStream(ASSET_FOLDER & "/music/StrangerThings.ogg")
    playMusicStream(self.music);

  # init ui
  self.hud = Hud()
  self.hud.init()
  # Init gaia
  self.sky = Sky()
  self.sky.init()
  self.ground = Ground()
  self.ground.init()
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
        let tileHitbox = getBoundingBox(tile.position, tile.size)
        
        if checkCollisionBoxes(playerHitbox, tileHitbox):
          grounded = true
          # Set burn timer for tile if player collides with it
          tile.burnTimer = 200
          playerFuel += (tile.fertility / 100) * 0.1
          var bf = 1.0
          if tile.color[2] > 120:
            bf *= 2.0
          if tile.color[2] > 140:
            bf *= 4.0
          if tile.color[2] > 180:
            bf *= 8.0
          #self.ground.map[x][y][z] = tile
          # playerFuel -= (tile.color[2] / 255) * 0.1 * bf
          #self.ground.tiles[i].plant.burnTimer = 2
        if checkCollisionBoxes(playerVelocityHitbox, tileHitbox):
          # Check x-axis collision
          if playerVelocity.x != 0:
            if tileHitbox.min.x < playerHitbox.max.x:
              playerVelocity.x = 0
            elif tileHitbox.max.x > playerHitbox.min.x:
              playerVelocity.x = 0
    
          # Check z-axis collision
          if playerVelocity.z != 0:
            if tileHitbox.min.z < playerHitbox.max.z:
              playerVelocity.z = 0
            if tileHitbox.max.z > playerHitbox.min.z:
              playerVelocity.z = 0

        if checkCollisionBoxes(playerVelocityHeightHitbox, tileHitbox):
          # Check y-axis collision
          if playerVelocity.y != 0:
            if tileHitbox.min.y < playerHitbox.max.y:
              playerVelocity.y = 0
              grounded = true
            elif tileHitbox.max.y > playerHitbox.min.y:
              playerVelocity.y = 0
              
    
      
  self.player.velocity = playerVelocity
  self.player.state = if grounded: Grounded else: Falling

method restartGame(self: Arcade): void {.base} =
  # reset game state
  playerFuel = startFuel
  self.init()
  gameOver = false

method update*(self: Arcade, dt: float) =
  # update camera
  camera.position.x = self.player.position.x  
  camera.position.y = screenHeight * 0.5 + self.player.position.y
  camera.position.z = groundSize.z * 2

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
