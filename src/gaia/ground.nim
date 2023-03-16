import raylib, ../screens, ../levels, std/random, ../utils, plant

type
  Tile* = object
    pos*: Vector2
    size*: Vector2
    vertices*: array[0..2, Vector2]
    burnTimer*: float = 0.0
    color*: array[0..2, float]
    orgColor*: array[0..2, float]
    fertility: float
    growProbability: float
    capacity: int = 1
    plants*: seq[Plant]

  Ground* = ref object of RootObj
    grow*: seq[PlantNames]
    tiles*: seq[Tile]


proc getColorDifference(c1: float, c2: float, s: float): float =
  return c2 * s + c1 * (1 - s)

proc getColor(s: float, t1: Terrain, t2: Terrain): array[0..2, float] =
  var
    c1 = getCustomColorSchema(t1.cs)
    c2 = getCustomColorSchema(t2.cs)
  return [getColorDifference(c1[0], c2[0], s),
    getColorDifference(c1[1], c2[1], s),
    getColorDifference(c1[2], c2[2], s),
  ]
proc getColorFromColor(c: array[0..2, float], f: float): array[0..2, float] =
  return [c[0] + rand(-f..f),
    c[1] + rand(-f..f),
    c[2] + rand(-f..f)
  ]

method addPlant(self: Ground, i: int, randRow: bool) {.base.} =
  var plant = Plant()
  let tile = self.tiles[i]
  let (minX, _) = getMinMax(tile.vertices, 0)
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
          
        tile.growProbability = (tile.color[1] - (tile.color[0] + tile.color[1] * 0.5 )) / 100.0
        echo tile.growProbability
        if tile.growProbability > 0.5:
          tile.fertility = rand(0.0..1.1)

        tile.vertices = [
          Vector2(x: x - w, y: y),
          Vector2(x: x, y: y),
          Vector2(x: x, y: y - h)
        ]
        self.grow = level.grow
        tile.orgColor = tile.color 
        self.tiles.add(tile)
        tile.color = getColorFromColor(tile.color, 15)

        tile.vertices = [
          Vector2(x: x, y: y),
          Vector2(x: x + w, y: y - h),
          Vector2(x: x, y: y - h)
        ]     
        self.tiles.add(tile)
        if (tile.fertility > 1 ):
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
      currentColor[0] = min(220.0 - originalColor[0] * 0.8, currentColor[0] + 600 * dt)
      currentColor[1] = max(0.0 + originalColor[1] * 0.8, currentColor[1] - 300 * dt)
      currentColor[2] = max(0.0 + originalColor[2] * 0.8, currentColor[2] - 120 * dt)
      # decrement timer
      burnTimer -= 5.0 * dt
    else:
      # bring the color back to original if not burning anymore
      if currentColor[0] > originalColor[0]:
        currentColor[0] = max(originalColor[0], currentColor[0] - 120 * dt)
      elif currentColor[1] < originalColor[1]:
        currentColor[1] += 60 * dt
      elif currentColor[2] < originalColor[2]:
        currentColor[2] += 60 * dt
    
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
    if (self.grow.len == 0 and tile.growProbability < 0.5): continue
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
      drawTriangle(v[0], v[1], v[2], uint8ToColor(tile.color, 255))
  
