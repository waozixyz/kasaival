import
  raylib

type
  GameScreen* = enum
    UnknownScreen = -1, LogoScreen = 0, TitleScreen, GameplayScreen

# ----------------------------------------------------------------------------------
# Global Variables Definition (shared by several modules)
# ----------------------------------------------------------------------------------

const
  screenWidth* = 800
  screenHeight* = 600

var
  zoom* = 1.0
  cx* = 0.0
  startY* = 200
  endX* = screenWidth
  mouse* = Vector2()
  currentScreen*: GameScreen = GameplayScreen
  
type
  Screen* = ref object of RootObj
    id*: GameScreen 


method init*(self: Screen) {.base.}  =
  discard

method update*(self: Screen) {.base.} =
  discard
  
method draw*(self: Screen) {.base.}  =
  discard

method unload*(self: Screen) {.base.} =
  discard
