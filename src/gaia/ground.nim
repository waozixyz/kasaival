import raylib, ../screens, ../levels, std/random, ../utils, plant

type
  Tile* = object
    hp*: float = 100
    size*: float
    orgSize*: float
    position*: Vector3
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
  result = c1 * (1 - s) + c2 * s

proc getColor(s: float, t1: Terrain, t2: Terrain): array[0..2, float] =
  var c1 = getCustomColorSchema(t1.cs)
  var c2 = getCustomColorSchema(t2.cs)
  result = [getColorDifference(c1[0], c2[0], s),
            getColorDifference(c1[1], c2[1], s),
            getColorDifference(c1[2], c2[2], s)]

method addPlant(self: Ground, i: int, randRow: bool) {.base.} =
  var plant = Plant()
  let tile = self.tiles[i]
  let x = tile.position.x - tile.size
  let y = 0.0
  let z = rand(tile.position.z - tile.size..tile.position.z + tile.size)

  plant.init(Vector3(x: x, y: y, z: z), randRow)
  self.tiles[i].plants.add(plant)

method init*(self: Ground, level: Level) {.base.} =
  randomize()


  endX = -level.tileSize
  for ti, terrain in level.terrains:
    var
      terrainWidth = float(terrain.tiles) * level.tileSize
      z = 0.0
    while z < groundLength:
      let size = level.tileSize
      var y = 0.0
      while y > -groundHeight:
        var x = endX
        while x < endX + terrainWidth:
          var
            i = clamp((x - endX) / terrainWidth, 0, 1)
            tile = Tile()
          tile.color = getColor(i, terrain, level.terrains[ti + 1])
            
          tile.growProbability = (tile.color[1] - (tile.color[0] + tile.color[1] * 0.5 )) / 100.0
          if tile.growProbability > 0.5:
            tile.fertility = rand(0.0..1.1)

          tile.position = Vector3(x: x, y: y, z: z)
          tile.size = size
          tile.orgSize = size
          tile.rotation = rand(0.0..360.0)
          self.grow = level.grow
          tile.orgColor = tile.color 
          self.tiles.add(tile)

          x += size
        y -= size
      z += size

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
      self.tiles[i].hp -= dt * 60
      # darken the colors while burning
      currentColor[0] = min(255 - originalColor[0], currentColor[0] + 320 * dt)
      currentColor[1] = max(originalColor[1] * 0.8, currentColor[1] - 120 * dt)
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
    if tile.hp != 100:
      echo tile.hp, " ", self.tiles[i].size 

    self.tiles[i].size = tile.orgSize * (tile.hp / 100)
    # loop through plants
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
  result = tile.position.x < cameraX + screenWidth * 0.6 and tile.position.x > cameraX - screenWidth * 0.6 and tile.position.y < cameraY + screenHeight * 0.5 and tile.position.y > cameraY - screenHeight * 0.2

method draw*(self: Ground) {.base.} =
  for tile in self.tiles:
    if tile.isTileVisible:
      #drawCylinder(tile.position, tile.radius, tile.radius, tile.radius, 9, uint8ToColor(tile.color, 255))
      drawCube(tile.position, Vector3(x: tile.size, y: tile.size, z: tile.size), uint8ToColor(tile.color, 255))
    #for plant in tile.plants:
    #  plant.draw()