import raylib, screens

const
  ASSET_FOLDER* = "resources"

when defined(GraphicsApiOpenGl33):
  const
    glslVersion* = 330
else:
  const
    glslVersion* = 100

const
  screenWidth* = 800
  screenHeight* = 600
  startFuel* = 200
  gravity* = 9.81
  tileSize* = 22

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
