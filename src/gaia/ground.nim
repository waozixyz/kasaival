import raylib, ../screens, ../levels, std/random

type
  Tile = object
    pos*: Vector2
    size*: Vector2
    vertices: array[0..2, Vector2]
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
        tile.pos = Vector2(x: x, y: y)
        tile.size = Vector2(x: w, y: h)
        tile.orgColor = tile.color 
        self.tiles.add(tile)
        tile.color = getColor(clamp(i, 0, 1), terrain, level.terrains[ti + 1])

        tile.vertices = [
          Vector2(x: x, y: y),
          Vector2(x: x + w, y: y - h),
          Vector2(x: x, y: y - h)
        ]     
        self.tiles.add(tile)
        x += w      
      y -= h
      h *= 0.94
      w *= 0.94
    endX += terrainWidth
 

    
method update*(self: Ground, dt: float) {.base.} =

   for i, tile in self.tiles:
    if tile.plants.len > 0:
      # tile.fertility += dt;
      # if (t.fertility > 1000 and tile.plants.items.len < tile.capacity):
      #   tile.fertility = 0
      #   var p = Plant()
      #   var x = rand(t.pos.x..t.pos.x + t.size.x)
      #   var y = rand(t.pos.y..t.pos.y + t.size.y)
      #   tile.plants.add(p)
      discard
    var r = int(tile.color.r)
    var g = int(tile.color.g)
    var b = int(tile.color.b)
    var colorChange = false

    if tile.burnTimer > 0:
        if r < 200:
          r += 20
        if g > 100:
          g -= 10
        if b > 4:
          b -= 4 
        colorChange = true
        self.tiles[i].burnTimer -= (20.0 * dt)
    else:
      var heal = rand(0..10)
      if heal > 7:
        if r > int(tile.orgColor.r):
          r -= 2
        elif g < int(tile.orgColor.g):
          g += 1
        elif b < int(tile.orgColor.b):
          b += 1
        colorChange = true
    if colorChange:
      self.tiles[i].color = Color(
        r: uint8(r),
        g: uint8(g),
        b: uint8(b),
        a: 255
      )    

method draw*(self: Ground) {.base.} =
  for tile in self.tiles:
    let v = tile.vertices
    drawTriangle(v[0], v[1], v[2], tile.color)
    
method unload*(self: Ground) {.base.}=
  discard