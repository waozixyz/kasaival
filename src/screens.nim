import
  raylib

type
  GameScreen* = enum
    UnknownScreen = -1, LogoScreen = 0, TitleScreen, ArcadeScreen

# ----------------------------------------------------------------------------------
# Global Variables Definition (shared by several modules)
# ----------------------------------------------------------------------------------

const ASSET_FOLDER* = "resources"

const
  screenWidth* = 800
  screenHeight* = 600
  groundLength* = 400
  groundHeight* = 500
  startFuel* = 200
  gravity* = 9.81
  startCameraX* = 1000

var
  gameOver* = false
  cameraX* = 2000.0
  cameraY* = 0.0
  endX* = 0.0
  mouse* = Vector2()
  currentScreen*: GameScreen = ArcadeScreen
  mouseCursor* = 0
  isMute* = true
  windPower* = 0.0
  playerFuel*: float = startFuel

type
  Screen* = ref object of RootObj
    id*: GameScreen 

method init*(self: Screen) {.base.}  =
  discard

method update*(self: Screen, dt: float) {.base.} =
  discard
  
method draw*(self: Screen) {.base.}  =
  discard

method unload*(self: Screen) {.base.} =
  discard
