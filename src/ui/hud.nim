import raylib, std/random, ../screens

type
  Hud* = ref object of RootObj
    discard

method init*(self: Hud) {.base.} =
  discard

method update*(self: Hud, dt: float) {.base.} =
  discard
  
method draw*(self: Hud) {.base.} =
  drawText("Fuel", 20, 20, 30, Maroon);
  drawText("Day", screenWidth - 100, 20, 30, BEIGE);

