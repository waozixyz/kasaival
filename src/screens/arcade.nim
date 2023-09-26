import raylib, ../screens, ../player, ../gaia/ground, ../gaia/sky, ../ui/hud, ../utils, ../gameState, ../mechanics/collision

type
  Arcade* = ref object of Screen
    player: Player
    ground*: Ground
    sky: Sky
    music: Music
    hud: Hud
  Axis = enum
    X, Y, Z

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

  checkTileCollision(self.player, self.ground, dt)

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
