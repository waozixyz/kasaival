import raylib, ../screens

type
  Sky* = object
    nebula: Texture2D
    planets: Texture2D
    
method init*(self: var Sky) {.base.} =
  self.nebula = loadTexture(ASSET_FOLDER & "/images/nebula.png")
  self.planets = loadTexture(ASSET_FOLDER & "/images/planets.png")

method update*(self: var Sky, dt: float) {.base.} =
  discard

method draw*(self: Sky) {.base.} =
  var x = -10.0
  var scale = 2.9
  drawTexture(self.planets, Vector2(x: x, y: 0), 0, scale, WHITE)
  drawTexture(self.nebula, Vector2(x: x, y: 0), 0, scale, WHITE)
