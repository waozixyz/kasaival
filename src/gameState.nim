import raylib, screens, gameConfig

var
  gGroundSize* = Vector3(x: 6000, y: 100, z: 300)
  gGameOver* = false
  gMousePosition* = Vector2()
  gCamera* = Camera3D()
  gCurrentScreen*: GameScreen = ArcadeScreen
  gMouseCursor* = 0
  gIsMute* = true
  gWindPower* = 0.0
  gPlayerFuel*: float = startFuel
