import raylib, ../screens

var
  framesCounter: int32 = 0
  finishScreen: int32 = 0


proc initGameplayScreen* =
  # Gameplay Screen Initialization logic
  # TODO: Initialize GAMEPLAY screen variables here!
  framesCounter = 0
  finishScreen = 0

proc updateGameplayScreen* =
  if isKeyPressed(Escape):
    currentScreen = Title

proc drawGameplayScreen* =
  # Gameplay Screen Draw logic
  # TODO: Draw GAMEPLAY screen here!
  drawRectangle(0, 0, getScreenWidth(), getScreenHeight(), Purple)
  drawText("PRESS ENTER or TAP to JUMP to ENDING SCREEN", 130, 220, 20, Maroon)

proc unloadGameplayScreen* =
  # Gameplay Screen Unload logic
  # TODO: Unload GAMEPLAY screen variables here!
  discard

proc finishGameplayScreen*: int32 =
  # Gameplay Screen should finish?
  return finishScreen
