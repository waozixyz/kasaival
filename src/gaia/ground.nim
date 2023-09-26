import raylib, std/random, ../utils, plant, perlin, ../gameState

type
  PerlinColor = object
    value*: float
    color*: array[0..2, int]
    y: int
  Tile* = object
    hp*: float = 100
    difficulty: float = 1
    size*: float
    position*: Vector3
    burnTimer*: float = 0.0
    color*: array[0..2, float]
    orgColor*: array[0..2, float]
    fertility*: float = 100.0
    growProbability: float
    alpha*: float = 255.0
    plants*: seq[Plant]
    dead: bool = false

  Ground* = ref object of RootObj
    map*: seq[seq[seq[Tile]]]
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

proc newSeqWith[T](len: int, value: T): seq[T] =
  result = newSeq[T](len)
  for i in 0..<len:
    result[i] = value

proc interpolateColors(lowerColor, upperColor: array[0..2, int], ratio: float): array[0..2, float] =
  for i in 0..2:
    result[i] = float(lowerColor[i]) * (1 - ratio) + float(upperColor[i]) * ratio

proc getPlant(self: Ground, tile: Tile, randRow: bool): Plant =
  var plant = Plant()
  let x = tile.position.x - tile.size
  let y = 0.0
  let z = rand(tile.position.z - tile.size..tile.position.z + tile.size)
  plant.init(Vector3(x: x, y: y, z: z), randRow)
  return plant

proc calculateGroundSize(tileSize: float, tiles: Vector3): Vector3 =
  result = Vector3(x: tileSize * tiles.x, y: tileSize * tiles.y, z: tileSize * tiles.z)

proc generatePerlinNoise(noise: Noise, x: int, y: int, z: int, offset: float): float =
  result = clamp(noise.perlin(float(x), float(y), float(z)) + offset, 0, 1)

proc updateTile(tile: var Tile, dt: float) =
  if tile.burnTimer > 0:
    if tile.fertility > 0:
      tile.fertility -= 2 * dt * 60
    tile.fertility = clamp(tile.fertility, 0, 100)

    tile.color[0] += (tile.fertility / 100) * 50
    tile.color[0] = min(tile.color[0], 255.0)

    tile.color[1] -= 10
    tile.color[1] = max(tile.color[1], tile.orgColor[1] - 80)

    tile.color[2] -= 10
    tile.color[2] = max(tile.color[2], tile.orgColor[2] - 80)

    tile.burnTimer -= dt * 60 * 10
  
  let
    diffR = tile.color[0] - tile.orgColor[0]
    diffG = tile.color[1] - tile.orgColor[1]
    diffB = tile.color[2] - tile.orgColor[2]
  
  if diffR > 0:
    tile.color[0] = max(tile.orgColor[0], tile.color[0] - 120 * dt)
  elif diffR < 0:
    tile.color[0] = min(tile.orgColor[0], tile.color[0] + 120 * dt)

  if diffG > 0:
    tile.color[1] = max(tile.orgColor[1], tile.color[1] - 60 * dt)
  elif diffG < 0:
    tile.color[1] = min(tile.orgColor[1], tile.color[1] + 60 * dt)

  if diffB > 0:
    tile.color[2] = max(tile.orgColor[2], tile.color[2] - 40 * dt)
  elif diffB < 0:
    tile.color[2] = min(tile.orgColor[2], tile.color[2] + 40 * dt)

method init*(self: Ground) {.base.} =
  randomize()

  let tiles = Vector3(x: 200, y: 3, z: 5)
  let tilePerlinColors = initializePerlinColors()
  
  let noise = newNoise()
  gGroundSize = calculateGroundSize(tileSize, tiles)
  self.tileSize = tileSize

  self.map = newSeqWith(tiles.x.int, newSeqWith(tiles.y.int, newSeq[Tile](tiles.z.int)))
  for x in 0..int(tiles.x) - 1:
    var perlinOffset = float(x) / float(tiles.x) - 0.5

    for y in 0..int(tiles.y) - 1:
      for z in 0..int(tiles.z) - 1:
        var tile = Tile()
        let noiseValue = generatePerlinNoise(noise, x, y, z, perlinOffset) 

        # Find the two Perlin colors that the noise value lies between
        var lowerIndex = 0
        var upperIndex = 0
        for i in 0..<tilePerlinColors.len - 1:
          if noiseValue >= tilePerlinColors[i].value and noiseValue < tilePerlinColors[i + 1].value:
            lowerIndex = i
            upperIndex = i + 1
            break

        let ratio = (noiseValue - tilePerlinColors[lowerIndex].value) / (tilePerlinColors[upperIndex].value - tilePerlinColors[lowerIndex].value)
        
        tile.color = interpolateColors(tilePerlinColors[lowerIndex].color, tilePerlinColors[upperIndex].color, ratio)
        
        tile.position = Vector3(x: float(x) * tileSize, y: float(y) * tileSize, z: float(z) * tileSize)
        tile.size = tileSize
        tile.orgColor = tile.color
        tile.fertility = tile.color[1] * 1.5 - tile.color[0] * 0.5

        if tile.color[2] < 50:
          tile.fertility += tile.color[2]
        else:
          tile.fertility -= tile.color[2] * 0.5
        
        tile.fertility = max(20, tile.fertility)

        #if tile.fertility > 120:
          #var p = self.getPlant(tile, true)
          #tile.plants.add(p)
        self.map[x][y][z] = tile

proc isTileVisible*(self: Ground, x: int): bool =
  result = float(x) * self.tileSize > gCamera.position.x - screenWidth * 0.6 and float(x) * self.tileSize < gCamera.position.x + screenWidth * 0.6
    

method update*(self: Ground, dt: float) {.base.} =
  for x in 0..self.map.len - 1:
    for y in 0..self.map[x].len - 1:
      for z in 0..self.map[x][y].len - 1:
        updateTile(self.map[x][y][z], dt)

method draw*(self: Ground) {.base.} =
  for x in 0..<self.map.len:
    if not self.isTileVisible(x): continue
    for y in 0..<self.map[x].len:
      for z in 0..<self.map[x][y].len:
        let tile = self.map[x][y][z]
        var color = uint8ToColor(tile.color, 255)
        drawCube(tile.position, fillVector(tile.size), color)
        if tile.plants.len > 0:
          for plant in tile.plants:
            plant.draw()