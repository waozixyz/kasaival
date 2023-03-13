import raylib, std/random

type
  Hud* = ref object of RootObj
    discard

method init*(self: Hud) {.base.} =
  discard

method update*(self: Hud, dt: float) {.base.} =
  discard
  
method draw*(self: Hud) {.base.} =
  discard
