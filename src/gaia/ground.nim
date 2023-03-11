import raylib, ../screens, ../levels, std/random, ../utils

type
  Tile* = object
    pos*: Vector2
    size*: Vector2
    vertices*: array[0..2, Vector2]
    burnTimer*: float = 0.0
    color: Color
    orgColor: Color
    fertility: float
    capacity: float = 1
    plants*: seq[PlantNames]

  Ground* = ref object of RootObj
    tiles* = @[Tile()]



proc getTerrainColor(cs: array[0..5, uint8]): array[0..2, uint8] =
  for i in 0..2:
    var a = min(float(cs[i * 2]), float(cs[i * 2 + 1]))
    var b = max(float(cs[i * 2]), float(cs[i * 2 + 1]))
    result[i] = uint8(rand(a..b))
  return result

proc getColorDifference(c1: uint8, c2: uint8, s: float): uint8 =
  return uint8(float(c2) * s + float(c1) * (1 - s))

proc getColor(s: float, t1: Terrain, t2: Terrain): Color =
  var c1 = getTerrainColor(t1.cs)
  var c2 = getTerrainColor(t2.cs)
  return Color(
    r: getColorDifference(c1[0], c2[0], s),
    g: getColorDifference(c1[1], c2[1], s),
    b: getColorDifference(c1[2], c2[2], s),
    a: 255,
  )
proc getColorFromColor(c: Color, f: int): Color =
  return Color(
    r: uint8(int(c.r) + rand(-f..f)),
    g: uint8(int(c.g) + rand(-f..f)),
    b: uint8(int(c.b) + rand(-f..f)),
    a: 255,
  )
    
method init*(self: Ground, level: Level) {.base.} =
  randomize()
  for ti, terrain in level.terrains:
    var
      terrainWidth = float(terrain.tiles) * level.tile.x
      w = level.tile.x
      h = level.tile.y
      y = float(endY)
    while y > startY:
      var x = endX
      while x < (endX + terrainWidth):
        var i = x / (endX + terrainWidth)
        var tile = Tile()
        tile.color = getColor(clamp(i, 0, 1), terrain, level.terrains[ti + 1])
        if (terrain.plants.len > 0):
          tile.fertility = float(rand(0..1000))
        tile.vertices = [
          Vector2(x: x - w, y: y),
          Vector2(x: x, y: y),
          Vector2(x: x, y: y - h)
        ]
        tile.plants = terrain.plants
        tile.orgColor = tile.color 
        self.tiles.add(tile)
        tile.color = getColorFromColor(tile.color, 5)

        tile.vertices = [
          Vector2(x: x, y: y),
          Vector2(x: x + w, y: y - h),
          Vector2(x: x, y: y - h)
        ]     
        self.tiles.add(tile)
        x += w      
      y -= h
      h *= yScaling
      w *= yScaling
    endX += terrainWidth
    startY = y
 

method update*(self: Ground, dt: float) {.base.}=
  for i, tile in self.tiles:
    # plant logic
    discard
      
    # tile color logic
    var t = tile.color
    var burnTimer = tile.burnTimer
    if burnTimer > 0:
      t.r = uint8(min(220, int(t.r) + 10))
      t.g = uint8(max(0, int(t.g) - 5))
      t.b = uint8(max(0, int(t.b) - 2))
      burnTimer -= 5.0 * dt
    else:
      if t.r > tile.orgColor.r:
        t.r = uint8(max(int(tile.orgColor.r), int(t.r) - 2))
      elif t.g < tile.orgColor.g:
        t.g += 1
      elif t.b < tile.orgColor.b:
        t.b += 1
        
    self.tiles[i].color = t
    self.tiles[i].burnTimer = burnTimer

proc isTileVisible*(tile: Tile): bool =
  let (minX, maxX) = getMinMax(tile.vertices, 0)
  return maxX >= cx - 100 and minX <= cx + screenWidth + 100

method draw*(self: Ground) {.base.} =
  for tile in self.tiles:
    if isTileVisible(tile):
      let v = tile.vertices
      drawTriangle(v[0], v[1], v[2], tile.color)
  
method unload*(self: Ground) {.base.}=
  discard