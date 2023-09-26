import raylib, std/random, ../utils, plant, perlin, ../state, tile

type
  Ground* = ref object of RootObj
    tiles*: seq[Tile]
    tileSize*: float

proc initializePerlinColors(): seq[PerlinColor] = 
  return @[
    PerlinColor(value: 0, color: [21, 71, 108], y: 3),    # Deep water
    PerlinColor(value: 0.1, color: [21, 71, 108], y: 3),    # Deep water
    PerlinColor(value: 0.2, color: [37, 111, 140], y: 4),   # Shallow water
    PerlinColor(value: 0.3, color: [252, 212, 94], y: 5),   # Sand
    PerlinColor(value: 0.4, color: [80, 180, 80], y: 6),   # Lighter Grass 
    PerlinColor(value: 0.5, color: [80, 150, 80], y: 6),   # Light Grass
    PerlinColor(value: 0.6, color: [60, 120, 42], y: 7),    # Grass
    PerlinColor(value: 0.7, color: [50, 83, 30], y: 8),    # Jungle
    PerlinColor(value: 0.9, color: [95, 83, 62], y: 9),  # Rock
    PerlinColor(value: 1.0, color: [107, 100, 100], y: 20),  # Rock
  ]

method init*(self: Ground) {.base.} =
  randomize()

  let tilesDimensions = Vector3(x: 200, y: 6, z: 5)
  let tilePerlinColors = initializePerlinColors()
  
  let noise = newNoise()
  gGroundSize = Vector3(x: tileSize * tilesDimensions.x, y: tileSize * tilesDimensions.y, z: tileSize * tilesDimensions.z)
  self.tileSize = tileSize

  for x in 0..<tilesDimensions.x.int:
    for y in 0..<tilesDimensions.y.int:
      for z in 0..<tilesDimensions.z.int:
        var tile = Tile()
        tile.init(x, y, z, tileSize, noise, tilePerlinColors)
        echo(tile)
        self.tiles.add(tile)
                
proc isTileVisible*(self: Ground, x: int): bool =
  result = float(x) * self.tileSize > gCamera.position.x - screenWidth * 0.6 and float(x) * self.tileSize < gCamera.position.x + screenWidth * 0.6

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