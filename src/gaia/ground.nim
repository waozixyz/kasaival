import raylib, ../screens, ../levels, std/random, ../utils, plant

type
  Tile* = object
    pos*: Vector2
    size*: Vector2
    vertices*: array[0..2, Vector2]
    burnTimer*: float = 0.0
    color: Color
    orgColor: Color
    fertility: float
    capacity: int = 1
    grow*: seq[PlantNames]
    plants*: seq[Plant]

  Ground* = ref object of RootObj
    tiles* = @[Tile()]


proc getColorDifference(c1: uint8, c2: uint8, s: float): uint8 =
  return uint8(float(c2) * s + float(c1) * (1 - s))

proc getColor(s: float, t1: Terrain, t2: Terrain): Color =
  var
    c1 = getCustomColorSchema(t1.cs)
    c2 = getCustomColorSchema(t2.cs)
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

method addPlant(self: Ground, i: int, randRow: bool) {.base.} =
  var plant = Plant()
  let tile = self.tiles[i]
  let (minX, maxX) = getMinMax(tile.vertices, 0)
  let (minY, maxY) = getMinMax(tile.vertices, 1)
  let scale = minY / screenHeight

  let padding = 15.0  * scale

  let x = minX
  let y = rand((minY + padding)..(maxY-padding))

  plant.init(x, y, randRow)
  self.tiles[i].plants.add(plant)
 
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
        if (terrain.grow.len > 0):
          tile.fertility = rand(0.0..1.1)
  

        tile.vertices = [
          Vector2(x: x - w, y: y),
          Vector2(x: x, y: y),
          Vector2(x: x, y: y - h)
        ]
        tile.grow = terrain.grow
        tile.orgColor = tile.color 
        self.tiles.add(tile)
        tile.color = getColorFromColor(tile.color, 15)

        tile.vertices = [
          Vector2(x: x, y: y),
          Vector2(x: x + w, y: y - h),
          Vector2(x: x, y: y - h)
        ]     
        self.tiles.add(tile)
        if (tile.fertility > 1):
          self.addPlant(self.tiles.len - 1, true)
        x += w      
      y -= h
      h *= yScaling
      w *= yScaling
    endX += terrainWidth
    startY = y
  endX -= level.tile.x
method update*(self: Ground, dt: float) {.base.} =
  # loop through tiles
  for i, tile in self.tiles:      
    # tile color logic
    var currentColor = tile.color
    var originalColor = tile.orgColor
    var burnTimer = tile.burnTimer

    if burnTimer > 0:
      # darken the colors while burning
      currentColor.r = uint8(min(int(220.0 - float(originalColor.r) * 0.8), int(currentColor.r) + 10))
      currentColor.g = uint8(max(int(0.0 + float(originalColor.g) * 0.8), int(currentColor.g) - 5))
      currentColor.b = uint8(max(int(0.0 + float(originalColor.b) * 0.8), int(currentColor.b) - 2))
      # decrement timer
      burnTimer -= 5.0 * dt
    else:
      # bring the color back to original if not burning anymore
      if currentColor.r > originalColor.r:
        currentColor.r = max(originalColor.r, currentColor.r - 2)
      elif currentColor.g < originalColor.g:
        currentColor.g += 1
      elif currentColor.b < originalColor.b:
        currentColor.b += 1
    
    # update tile color and timer
    self.tiles[i].color = currentColor
    self.tiles[i].burnTimer = burnTimer

    # loop through plants
    for j, plant in tile.plants:
      self.tiles[i].plants[j].update(dt)
      if plant.dead:
        # remove dead plant from list
        self.tiles[i].plants.delete(j)

    # tile grow plant logic
    # check if we should add a new plant
    if (tile.grow.len == 0): continue
    self.tiles[i].fertility += dt * 0.001

    
    if tile.fertility < 1.0 or tile.plants.len >= tile.capacity: continue
    # reset fertility and add new plant
    self.tiles[i].fertility = 0.0
    self.addPlant(i, false)
   

proc isTileVisible*(tile: Tile): bool =
  let (minX, maxX) = getMinMax(tile.vertices, 0)
  return maxX >= cx - 100 and minX <= cx + screenWidth + 100

method draw*(self: Ground) {.base.} =
  for tile in self.tiles:
    if isTileVisible(tile):
      let v = tile.vertices
      drawTriangle(v[0], v[1], v[2], tile.color)
  
