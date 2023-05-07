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
  startFuel* = 200
  gravity* = 9.81

var
  groundSize* = Vector3(x: 6000, y: 100, z: 300)
  gameOver* = false
  mouse* = Vector2()
  camera* = Camera3D()
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
