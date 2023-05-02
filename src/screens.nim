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

var
  gameOver* = false
  zoom* = 1.0
  cx* = 4500.0
  startY* = 150.0
  endX* = 0.0
  mouse* = Vector2()
  currentScreen*: GameScreen = ArcadeScreen
  mouseCursor* = 0
  isMute* = true
  windPower* = 0.0
  playerFuel*: float = startFuel


proc getYScale*(y: float): float =
  result = (y - 100.0) / 150.0 * 0.4 + 0.6



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
