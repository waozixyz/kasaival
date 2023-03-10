import
  raylib

type
  GameScreen* = enum
    Unknown = -1, Logo = 0, Title, Gameplay

# ----------------------------------------------------------------------------------
# Global Variables Definition (shared by several modules)
# ----------------------------------------------------------------------------------

const
  screenWidth* = 800
  screenHeight* = 600

var
  zoom* = 1.0
  cx* = 0.0
  mouse* = Vector2()
  currentScreen*: GameScreen = Gameplay
  
