import raylib, screens, std/lenientops

# ----------------------------------------------------------------------------------------
# Module Variables Definition (local)
# ----------------------------------------------------------------------------------------

var
  framesCounter: int32 = 0
  finishScreen: int32 = 0

proc initEndingScreen* =
  # Ending Screen Initialization logic
  # TODO: Initialize ENDING screen variables here!
  framesCounter = 0
  finishScreen = 0

proc updateEndingScreen* =
  # Ending Screen Update logic
  # TODO: Update ENDING screen variables here!
  # Press enter or tap to return to TITLE screen
  if isKeyPressed(Enter) or isGestureDetected(Tap):
    finishScreen = 1
    playSound(fxCoin)

proc drawEndingScreen* =
  # Ending Screen Draw logic
  # TODO: Draw ENDING screen here!
  drawRectangle(0, 0, getScreenWidth(), getScreenHeight(), Blue)
  drawText(font, "ENDING SCREEN", Vector2(x: 20, y: 10), font.baseSize*3'f32, 4, DarkBlue)
  drawText("PRESS ENTER or TAP to RETURN to TITLE SCREEN", 120, 220, 20, DarkBlue)

proc unloadEndingScreen* =
  # Ending Screen Unload logic
  # TODO: Unload ENDING screen variables here!
  discard

proc finishEndingScreen*: int32 =
  # Ending Screen should finish?
  return finishScreen
