import raylib, std/random, perlin, ../state, tile, ../utils

type
  Ground* = ref object of RootObj
    tiles*: seq[Tile]
    tileSize*: float

proc initializePerlinColors(): seq[PerlinColor] = 
  return @[
    PerlinColor(value: 0, color: [21, 71, 108], y: 3),
    PerlinColor(value: 0.1, color: [21, 71, 108], y: 3),
    PerlinColor(value: 0.2, color: [37, 111, 140], y: 4),
    PerlinColor(value: 0.3, color: [252, 212, 94], y: 5),
    PerlinColor(value: 0.4, color: [80, 180, 80], y: 6), 
    PerlinColor(value: 0.5, color: [80, 150, 80], y: 6),
    PerlinColor(value: 0.6, color: [60, 120, 42], y: 7),
    PerlinColor(value: 0.7, color: [50, 83, 30], y: 8),
    PerlinColor(value: 0.9, color: [95, 83, 62], y: 9),
    PerlinColor(value: 1.0, color: [107, 100, 100], y: 20),
  ]

method init*(self: Ground) {.base.} =
  randomize()

  let tilePerlinColors = initializePerlinColors()
  
  let noise = newNoise()
  gGroundSize = Vector3(x: tileSize * tilesDimensions.x, y: tileSize * tilesDimensions.y, z: tileSize * tilesDimensions.z)
  self.tileSize = tileSize

  for coord in grid3D(tilesDimensions):
    var tile = Tile()
    tile.init(coord.x.int, coord.y.int, coord.z.int, tileSize, noise, tilePerlinColors)
    self.tiles.add(tile)

method update*(self: Ground, dt: float) {.base.} =
  var aliveTiles: seq[Tile] = @[]

  for tile in self.tiles.mitems():
    tile.update(dt)
    if not tile.dead:
      aliveTiles.add(tile)

  self.tiles = aliveTiles

method draw*(self: Ground) {.base.} =
  for tile in self.tiles:
    tile.draw()
