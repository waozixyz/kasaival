import raylib, ../screens, ../levels, std/random

type
  Tile = object
    pos: Vector2
    size: Vector2
    vertices: array[0..2, Vector2]
    burnTimer: float = 0
    color: Color
    org_color: Color
    fertility: float
    capacity: float = 1
    plants: seq[PlantNames]

  Ground* = ref object of RootObj
    tiles = @[Tile()]



proc getTerrainColor(cs: array[0..5, uint8]): array[0..2, uint8] =
  var result: array[0..2, uint8]
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
  echo c1
  return Color(
    r: getColorDifference(c1[0], c2[0], s),
    g: getColorDifference(c1[1], c2[1], s),
    b: getColorDifference(c1[2], c2[2], s),
    a: 255,
  )
    
method init*(self: Ground, level: Level) {.base.} =
  randomize()
  var w = level.tile.x
  var h = level.tile.y
  
  for ti in 0..level.terrains.len - 2:
    var terrain = level.terrains[ti]
    var y = startY + h

    while (y < float(endY) + h):
      var x = endX
      for i in 0..terrain.tiles:
        var tile = Tile()
        tile.color = getColor(clamp(i / terrain.tiles, 0, 1), terrain, level.terrains[ti + 1])
        if (terrain.plants.len > 0):
          tile.fertility = float(rand(0..1000))
        tile.vertices = [
          Vector2(x: x - w, y: y),
          Vector2(x: x + w, y: y),
          Vector2(x: x, y: y - h)
        ]
        tile.plants = terrain.plants
        tile.pos = Vector2(x: x, y: y)
        tile.size = Vector2(x: w, y: h)
        tile.org_color = tile.color 
        self.tiles.add(tile)
        tile.vertices = [
          Vector2(x: x, y: y),
          Vector2(x: x + w, y: y - h),
          Vector2(x: x - w, y: y - h)
        ]     
        self.tiles.add(tile)
     
        x += w
      y += h
    endX += float(terrain.tiles) * float(w) - float(w)

  
    
method update*(self: Ground) {.base.} =
  discard

method draw*(self: Ground) {.base.} =
  for tile in self.tiles:
    let v = tile.vertices
    drawTriangle(v[0], v[1], v[2], tile.color)
    
method unload*(self: Ground) {.base.}=
  discard