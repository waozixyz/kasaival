import raylib, ../entities/player, ../state

type
  Hud* = ref object of RootObj
    discard

method init*(self: Hud) {.base.} =
  discard

method update*(self: Hud, dt: float) {.base.} =
  discard
  
method draw*(self: Hud, player: Player) {.base.} =
  let displayFuel = "Fuel: " & $int32(gPlayerFuel)
  drawText(displayFuel.cstring, 20, 20, 30, Maroon)
  if gGameOver:
    drawRectangle(0, 0, screenWidth, screenHeight, Color(r: 0, g: 0, b: 0, a:  200))
    drawText("Game Over", int32(float(screenWidth)/2.0 - float(measureText("Game Over", 48))/2.0), int32(float(screenHeight)/2 - 24), 48, WHITE)
    drawText("Touch anywhere to restart", int32(float(screenWidth) / 2.0 - float(measureText("Touch anywhere to restart", 20)) / 2.0), int32(float(screenHeight) / 2 + 50), 20, Maroon)
