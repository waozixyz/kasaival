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
    fertility: float
    growProbability: float
    alpha*: float = 255.0
    plant*: Plant
    dead: bool = false

  Ground* = ref object of RootObj
    grow*: seq[PlantNames]
    tiles*: seq[Tile]


method addPlant(self: Ground, i: int, randRow: bool) {.base.} =
  var plant = Plant()
  let tile = self.tiles[i]
  let x = tile.position.x - tile.size
  let y = 0.0
  let z = rand(tile.position.z - tile.size..tile.position.z + tile.size)

  plant.init(Vector3(x: x, y: y, z: z), randRow)
  self.tiles[i].plant = plant

method init*(self: Ground, level: Level) {.base.} =
  randomize()
  var z = 0.0
  let
    colors = @[
      [0, 0, 60],   # dark gray
      [55, 50, 120],   # dark blue
      [6, 9, 85],   # Deep dark blue
      [25, 50, 150],   # dark blue
      [58, 120, 200],  # Lighter blue
      [252, 212, 94],  # Yellow
      [97, 155, 65],   # Green-yellow
      [45, 74, 32],    # Jungle green
      [96, 92, 61],    # Swampy brown-green
      [126, 100, 79],  # Green-brown
      [128, 128, 128],  # gray
      [80, 80, 80],  # dark gray
      [30, 30, 39],   # black

    ]
    numColors = float(colors.len) - 1.0
    ratioDenom = groundWidth / numColors
    randomTileColorFactor = 0.2
    randomHeightFactor = 0.2
  while z < groundLength:
    let size = level.tileSize
    var y = float(screenHeight)
    while y > -groundHeight:
      var x = 0.0
      while x < groundWidth:
        var yThreshold = 0.0
  
        # Gradual part at the 
        let caveX = groundWidth - screenWidth * 0.5

        # Gradual part at the end
        if x > caveX:
            var ratio = (x - caveX) / (groundWidth - caveX) + rand(0.0..randomHeightFactor)
            if ratio > 1: ratio = 1
            if ratio < 0: ratio = 0
            yThreshold = lerp(0.0, float(screenHeight), ratio)

        if y > yThreshold: 
          x += size
          continue

        var tile = Tile()
        let
          gradientIndex = int(x / groundWidth * numColors)
          color1 = colors[gradientIndex]
          color2 = colors[gradientIndex + 1]
        var ratio = (x mod ratioDenom) / ratioDenom + rand(-randomTileColorFactor..randomTileColorFactor)
        if ratio > 1: ratio = 1
        if ratio < 0: ratio = 0
        for i in 0..2:
          tile.color[i] = lerp(float(color1[i]), float(color2[i]), ratio) 

        tile.position = Vector3(x: x, y: y, z: z)
        tile.size = size
        tile.orgColor = tile.color 
        self.tiles.add(tile)
        x += size
      y -= size
    z += size



method update*(self: Ground, dt: float) {.base.} =
  # loop through tiles
  for i, tile in self.tiles:
    # tile color logic
    var currentColor = tile.color
    var originalColor = tile.orgColor
    var burnTimer = tile.burnTimer

    if burnTimer > 0:
      # darken the colors while burning
      currentColor[0] = min(255 - originalColor[0], currentColor[0] + 320 * dt)
      currentColor[1] = max(originalColor[1] * 0.8, currentColor[1] - 120 * dt)
      currentColor[2] = max(originalColor[2] * 0.6, currentColor[2] - 200 * dt)
      originalColor[1] = originalColor[1] * (tile.hp / 100)
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
    self.tiles[i].orgColor = originalColor
    self.tiles[i].burnTimer = burnTimer
    # loop through PlantStates
    #for j, plant in tile.plants:
    #  self.tiles[i].plants[j].update(dt)
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
   

proc isTileVisible*(tile: Tile): bool =
  result = (tile.position.x > cameraX - screenWidth * 0.5 and tile.position.x < cameraX + screenWidth * 0.5 and tile.position.y < cameraY + screenHeight)

method draw*(self: Ground) {.base.} =
  for tile in self.tiles:
    if tile.isTileVisible(): 
      #drawCylinder(tile.position, tile.radius, tile.radius, tile.radius, 9, uint8ToColor(tile.color, 255))
      #if tile.alpha >= 200:
      drawCube(tile.position, fillVector3(tile.size), uint8ToColor(tile.color, 255))

      #for plant in tile.plants:
      #  plant.draw()