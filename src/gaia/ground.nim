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
    var
      a = min(float(cs[i * 2]), float(cs[i * 2 + 1]))
      b = max(float(cs[i * 2]), float(cs[i * 2 + 1]))
    result[i] = uint8(rand(a..b))
  return result

proc getColorDifference(c1: uint8, c2: uint8, s: float): uint8 =
  return uint8(float(c2) * s + float(c1) * (1 - s))

proc getColor(s: float, t1: Terrain, t2: Terrain): Color =
  var
    c1 = getTerrainColor(t1.cs)
    c2 = getTerrainColor(t2.cs)
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
  endX = -level.tile.x
  for ti, terrain in level.terrains:
    var
      terrainWidth = float(terrain.tiles) * level.tile.x
      (w, h) = (level.tile.x, level.tile.y)
      y = float(endY)
    while y > startY:
      var x = endX
      while x < endX + terrainWidth:
        var
          i = clamp((x - endX) / terrainWidth, 0, 1)
          tile = Tile()
        tile.color = getColor(i, terrain, level.terrains[ti + 1])
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
        tile.color = getColorFromColor(tile.color, 15)

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
  endX -= level.tile.x
method update*(self: Ground, dt: float) {.base.}=
  for i, tile in self.tiles:
    # plant logic
      
    # tile color logic
    var t = tile.color
    var to = tile.orgColor
    var burnTimer = tile.burnTimer
    if burnTimer > 0:
      t.r = uint8(min(int(220.0 - float(to.r) * 0.8), int(t.r) + 10))
      t.g = uint8(max(int(0.0 + float(to.g) * 0.8), int(t.g) - 5))
      t.b = uint8(max(int(0.0 + float(to.b) * 0.8), int(t.b) - 2))
      burnTimer -= 5.0 * dt
    else:
      if t.r > to.r:
        t.r = uint8(max(int(to.r), int(t.r) - 2))
      elif t.g < to.g:
        t.g += 1
      elif t.b < to.b:
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