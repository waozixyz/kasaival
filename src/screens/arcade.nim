import raylib, ../screens, ../player, ../gaia/ground, ../gaia/sky, ../ui/hud, ../state, ../mechanics/collision

type
  Arcade* = ref object of Screen
    player: Player
    ground*: Ground
    sky: Sky
    music: Music
    hud: Hud

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
  gCamera.fovy = 45
  gCamera.projection = CameraProjection.Perspective
  gCamera.up = Vector3(x: 0.0, y: 1.0, z: 0.0)

method restartGame(self: Arcade): void {.base} =
  gPlayerFuel = startFuel
  self.init()
  gGameOver = false

method update*(self: Arcade, dt: float) =
  gCamera.position.x = self.player.position.x
  gCamera.position.y = 200
  gCamera.position.z = 200
  gCamera.target.x = self.player.position.x
  gCamera.target.z = 0.0
  gCamera.target.y = 50

  if isKeyPressed(M):
    gIsMute = not gIsMute

  if not gIsMute:
    updateMusicStream(self.music)

  if isKeyPressed(Escape):
    gCurrentScreen = TitleScreen

  self.hud.update(dt)
  if gPlayerFuel <= 0:
    gGameOver = true
    if isKeyPressed(Enter) or isMouseButtonDown(Left):
      self.restartGame()
    return

  self.sky.update(dt)
  self.ground.update(dt)

  checkTileCollision(self.player, self.ground, dt)

  self.player.update(dt)


method draw*(self: Arcade) =
  self.sky.draw()

  beginMode3D(gCamera)
  self.ground.draw()
  self.player.draw()
  endMode3D();
  
  self.hud.draw(self.player)

method unload*(self: Arcade) =
  discard
