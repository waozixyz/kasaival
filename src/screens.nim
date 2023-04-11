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
  startFuel* = 300

var
  gameOver* = false
  zoom* = 1.0
  cx* = 4500.0
  startY* = 150.0
  endX* = 0.0
  endY* = screenHeight
  mouse* = Vector2()
  currentScreen*: GameScreen = ArcadeScreen
  yScaling* =  0.98
  mouseCursor* = 0
  isMute* = false
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
