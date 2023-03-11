import raylib, ../screens, ../levels, std/random

type
  Tile = object
    pos: Vector2
    size: Vector2
    v1: Vector2
    v2: Vector2
    v3: Vector2
    burnTimer: float = 0
    color: Color
    org_color: Color
    fertility: float
    capacity: float = 1
    plants: seq[PlantNames]

  Ground* = ref object of RootObj
    tiles = @[Tile()]



proc getTerrainColor(cs: array[0..5, uint8]): array[0..4, uint8] =
  var result: array[0..4, uint8]
  for i in 0..4:
    var a = min(float(cs[i]), float(cs[i + 1]))
    var b = max(float(cs[i]), float(cs[i + 1]))
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
    a: getColorDifference(c1[3], c2[3], s),
  )
    
method init*(self: Ground, level: Level) {.base.} =
  randomize()
  var w = level.tile.x
  var h = level.tile.y
  var y = startY + h
  
  for ti, terrain in level.terrains:
    var startX = endX
    endX += float(terrain.tiles) * float(w) - float(w)
    while (y < float(endY) + h):
      var x = 0.0
      for i in 0..terrain.tiles:
        var color = getColor(clamp(i / ti, 0, 1), terrain, level.terrains[ti + 1])
        var pos = Vector2(x: x, y: y)
        var size = Vector2(x: w, y:  h)
        var fertility = 0.0;
        if (terrain.plants.len > 0):
          fertility = float(rand(0..1000))
        var v1 = Vector2(x: x - w, y: y)
        var v2 = Vector2(x: x + w, y: y)
        var v3 = Vector2(x: x, y: y - h)
        var t = Tile(
          plants: terrain.plants,
          fertility: fertility,
          pos: pos,
          size: size,
          v1: v1,
          v2: v2,
          v3: v3,
          color: color,
          org_color: color 
        )
        self.tiles.add(t)
        x += w
      y += h
  
    
method update*(self: Ground) {.base.} =
  discard

method draw*(self: Ground) {.base.} =
  for tile in self.tiles:
    drawTriangle(tile.v1, tile.v2, tile.v3, tile.color)
    
method unload*(self: Ground) {.base.}=
  discard