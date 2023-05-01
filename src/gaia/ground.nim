import raylib, ../screens, ../levels, std/random, ../utils, plant

type
  Tile* = object
    pos*: Vector2
    radius*: float32
    center*: Vector2
    burnTimer*: float = 0.0
    color*: array[0..2, float]
    orgColor*: array[0..2, float]
    fertility: float
    growProbability: float
    capacity: int = 1
    plants*: seq[Plant]
    rotation: float = 0.0

  Ground* = ref object of RootObj
    grow*: seq[PlantNames]
    tiles*: seq[Tile]


proc getColorDifference(c1: float, c2: float, s: float): float =
  return c1 * (1 - s) + c2 * s

proc getColor(s: float, t1: Terrain, t2: Terrain): array[0..2, float] =
  var c1 = getCustomColorSchema(t1.cs)
  var c2 = getCustomColorSchema(t2.cs)
  result = [getColorDifference(c1[0], c2[0], s),
            getColorDifference(c1[1], c2[1], s),
            getColorDifference(c1[2], c2[2], s)]
            
proc getColorFromColor(c: array[0..2, float], f: float): array[0..2, float] =
  return [c[0] + rand(-f..f),
    c[1] + rand(-f..f),
    c[2] + rand(-f..f)
  ]
method addPlant(self: Ground, i: int, randRow: bool) {.base.} =
  var plant = Plant()
  let tile = self.tiles[i]
  let x = tile.center.x - tile.radius
  let y = rand(tile.center.y - tile.radius..tile.center.y + tile.radius)

  plant.init(x, y, randRow)
  self.tiles[i].plants.add(plant)

method init*(self: Ground, level: Level) {.base.} =
  randomize()
  endX = -level.tileSize
  for ti, terrain in level.terrains:
    var
      terrainWidth = float(terrain.tiles) * level.tileSize
      y = startY
    while y < screenHeight + level.tileSize * 2:
      
      let radius = level.tileSize * getYScale(y)
      var x = endX
      while x < endX + terrainWidth:
        var
          i = clamp((x - endX) / terrainWidth, 0, 1)
          tile = Tile()
        tile.color = getColor(i, terrain, level.terrains[ti + 1])
          
        tile.growProbability = (tile.color[1] - (tile.color[0] + tile.color[1] * 0.5 )) / 100.0
        if tile.growProbability > 0.5:
          tile.fertility = rand(0.0..1.1)

        tile.center = Vector2(x: x, y: y)
        tile.radius = radius
        tile.rotation = 0.0
        self.grow = level.grow
        tile.orgColor = tile.color 
        self.tiles.add(tile)
        tile.center = Vector2(x: x + rand(-radius * 0.5..radius * 0.5), y: y + rand(-radius * 0.5..radius * 0.5))
        tile.color = getColorFromColor(tile.color, 20.0)
        self.tiles.add(tile)

        x += radius * 1.5
      y += radius

    endX += terrainWidth


method update*(self: Ground, dt: float) {.base.} =
  # loop through tiles
  for i, tile in self.tiles:      
    # update rotation based on wind
    self.tiles[i].rotation = rand(0.0.. windPower)
    # tile color logic
    var currentColor = tile.color
    var originalColor = tile.orgColor
    var burnTimer = tile.burnTimer

    if burnTimer > 0:
      # darken the colors while burning
      currentColor[0] = min(220, currentColor[0] + 800 * dt)
      currentColor[1] = max(originalColor[1] * 0.4, currentColor[1] - 400 * dt)
      currentColor[2] = max(originalColor[2] * 0.6, currentColor[2] - 200 * dt)
      # decrement timer
      burnTimer -= 5.0 * dt
    else:
      # bring the color back to original if not burning anymore
      if currentColor[0] > originalColor[0]:
        currentColor[0] = max(originalColor[0], currentColor[0] - 120 * dt)
      elif currentColor[1] < originalColor[1]:
        currentColor[1] += 60 * dt
      elif currentColor[2] < originalColor[2]:
        currentColor[2] += 40 * dt
    
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
  return tile.center.x + tile.radius >= cx - 100 and tile.center.x - tile.radius <= cx + screenWidth + 100

method draw*(self: Ground) {.base.} =
  for tile in self.tiles:
    if isTileVisible(tile):
      
      drawPoly(tile.center, 12, tile.radius, tile.rotation, uint8ToColor(tile.color, 250))
