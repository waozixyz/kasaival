import raylib, ../screens, ../levels, std/random, std/math, ../utils, plant

type
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
    grow*: seq[PlantNames]
    tiles*: seq[Tile]


proc getPlant(self: Ground, tile: Tile, randRow: bool): Plant =
  var plant = Plant()
  let x = tile.position.x - tile.size
  let y = 0.0
  let z = rand(tile.position.z - tile.size..tile.position.z + tile.size)
  plant.init(Vector3(x: x, y: y, z: z), randRow)
  return plant

method init*(self: Ground, level: Level) {.base.} =
  randomize()
  var z = 0.0
  let
    colors = @[
      [6, 9, 85],   # Deep dark blue
      [25, 50, 150],   # dark blue
      [58, 80, 180],  # Lighter blue
      [58, 120, 200],  # Lighter blue
      [252, 212, 94],  # Yellow
      [97, 155, 65],   # Green-yellow
      [60, 120, 42],   # Green
      [45, 104, 32],    # Jungle green
      [96, 92, 61],    # Swampy brown-green
      [126, 100, 79],  # Green-brown
      [128, 128, 128],  # gray
      [80, 80, 80],  # dark gray

    ]
    numColors = float(colors.len) - 1.0
    ratioDenom = groundWidth / numColors
    randomFactor = 0.2
  while z < groundLength:
    let size = level.tileSize
    var y = 0.0
    while y > -groundHeight:
      var x = 0.0
      while x < groundWidth:

        var tile = Tile()
        let
          gradientIndex = int(x / groundWidth * numColors)
          color1 = colors[gradientIndex]
          color2 = colors[gradientIndex + 1]
        var ratio = (x mod ratioDenom) / ratioDenom + rand(-randomFactor..randomFactor)
        if ratio > 1: ratio = 1
        if ratio < 0: ratio = 0
        for i in 0..2:
          tile.color[i] = lerp(float(color1[i]), float(color2[i]), ratio) 

        tile.position = Vector3(x: x, y: y, z: z)
        tile.size = size
        tile.orgColor = tile.color 
        tile.fertility = tile.color[1] * 1.5 - tile.color[0] * 0.5

        if tile.color[2] < 50:
          tile.fertility += tile.color[2]
        else:
          tile.fertility -= tile.color[2] * 0.5
        
        tile.fertility = max(20, tile.fertility)

        if tile.fertility > 120:
          var p = self.getPlant(tile, true)
          #tile.plants.add(p)
        self.tiles.add(tile)
        x += size
      y -= size
    z += size



method update*(self: Ground, dt: float) {.base.} =
  # loop through tiles
  for i in 0..self.tiles.len - 1:
    var tile = self.tiles[i]
    # tile color logic
    if tile.burnTimer > 0:
      if tile.fertility > 0:
          tile.fertility -= 2 * dt * 60
      tile.fertility = clamp(tile.fertility, 0, 100)
      # darken the colors while burning

      tile.color[0] += (tile.fertility / 100) * 50
      if tile.color[0] > 255:
        tile.color[0] = 255.0

      tile.color[1] -= 10
      if tile.color[1] < max(0, tile.orgColor[1] - 80):
        tile.color[1] = max(0, tile.orgColor[1] - 80)

      tile.color[2] -= 10
      if tile.color[2] < max(0, tile.orgColor[2] - 80):
        tile.color[2] = max(0, tile.orgColor[2] - 80)
      # decrement timer
      tile.burnTimer -= dt * 60 * 10
    # calculate the differences between the current color and the original color
    let
      diffR = tile.color[0] - tile.orgColor[0]
      diffG = tile.color[1] - tile.orgColor[1]
      diffB = tile.color[2] - tile.orgColor[2]

    # update the current color based on the differences
    if diffR > 0:
      tile.color[0] = max(tile.orgColor[0], tile.color[0] - 120 * dt)
    elif diffR < 0:
      tile.color[0] = min(tile.orgColor[0], tile.color[0] + 120 * dt)

    if diffG < 0:
      tile.color[1] = min(tile.orgColor[1], tile.color[1] + 60 * dt)
    elif diffG > 0:
      tile.color[1] = max(tile.orgColor[1], tile.color[1] - 60 * dt)

    if diffB < 0:
        tile.color[2] = min(tile.orgColor[2], tile.color[2] + 40 * dt)
    elif diffB > 0:
        tile.color[2] = max(tile.orgColor[2], tile.color[2] - 40 * dt)

    
    # update tile
    # loop through PlantStates
    if tile.plants.len > 0:
      while i in 0..tile.plants.len:
        var plant = tile.plants[i]
        plant.update(dt)
    #  if plant.state == PlantStates.Dead:
    #    # remove dead plant from list
    #    self.tiles[i].plants.delete(j)

    # tile grow plant logic
    # check if we should add a new plant
    #if (self.grow.len == 0 and tile.growProbability < 0.5): continue
    #self.tiles[i].fertility += dt * 0.001

    
    #if tile.fertility < 1.0 or tile.plants.len >= tile.capacity: continue
    # reset fertility and add new plant
    #self.tiles[i].fertility = 0.0
    #self.addPlant(i, false)
    self.tiles[i] = tile


proc isTileVisible*(tile: Tile): bool =
  result = (tile.position.x > camera.position.x - screenWidth * 0.5 and tile.position.x < camera.position.x + screenWidth * 0.5 and tile.position.y < camera.position.y + screenHeight)

method draw*(self: Ground) {.base.} =
  for tile in self.tiles:
    if tile.isTileVisible(): 
      #drawCylinder(tile.position, tile.radius, tile.radius, tile.radius, 9, uint8ToColor(tile.color, 255))
      #if tile.alpha >= 200:
      var color = uint8ToColor(tile.color, 255)
      var fertility = clamp(tile.fertility, 0, 100)
      color.r = float2uint8(float(color.r) * (clamp(fertility, 30, 50) / 50))
      color.g = float2uint8(float(color.g) * (clamp(fertility, 30, 50) / 50))
      color.b = float2uint8(float(color.b) * (clamp(fertility, 30, 50) / 50))
      drawCube(tile.position, fillVector3(tile.size), color)

    if tile.plants.len > 0:
      for plant in tile.plants:
        plant.draw()
