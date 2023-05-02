import raylib, ../screens, ../player, std/math

type
  Hud* = ref object of RootObj
    discard

method init*(self: Hud) {.base.} =
  discard

method update*(self: Hud, dt: float) {.base.} =
  discard
  
method draw*(self: Hud, player: Player) {.base.} =
  drawText("Fuel: " & $int32(playerFuel), 20, 20, 30, Maroon);
  drawText("Day", screenWidth - 100, 20, 30, BEIGE);
  if gameOver:
    # draw semi-transparent overlay
    drawRectangle(0, 0, screenWidth, screenHeight, Color(r: 0, g: 0, b: 0, a:  200))
    # draw Game Over text
    drawText("Game Over", int32(float(screenWidth)/2.0 - float(measureText("Game Over", 48))/2.0), int32(float(screenHeight)/2 - 24), 48, WHITE)
    drawText("Touch anywhere to restart", int32(float(screenWidth) / 2.0 - float(measureText("Touch anywhere to restart", 20)) / 2.0), int32(float(screenHeight) / 2 + 50), 20, Maroon)
