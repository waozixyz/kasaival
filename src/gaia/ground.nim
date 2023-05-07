import raylib, ../screens, ../levels, std/random, std/math, ../utils, plant, perlin

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
    map*: seq[seq[seq[Tile]]]
    tileSize*: float

  PerlinColor = object
    value: float
    color: array[0..2, int]


proc getPlant(self: Ground, tile: Tile, randRow: bool): Plant =
  var plant = Plant()
  let x = tile.position.x - tile.size
  let y = 0.0
  let z = rand(tile.position.z - tile.size..tile.position.z + tile.size)
  plant.init(Vector3(x: x, y: y, z: z), randRow)
  return plant

proc calculateGroundSize(tileSize: float, tiles: Vector3): Vector3 =
  result = Vector3(x: tileSize * tiles.x, y: tileSize * tiles.y, z: tileSize * tiles.z)

proc generatePerlinNoise(noise: Noise, x: int, y: int, z: int, offset: float): float =
  result = clamp(noise.perlin(float(x), float(y), float(z)) + offset, 0, 0.99)

method init*(self: Ground, level: Level) {.base.} =
  randomize()
  # set ground size
  let noise = newNoise()
  groundSize = calculateGroundSize(level.tileSize, level.tiles)
  self.tileSize = level.tileSize
  let
    color_gradient = [
      PerlinColor(value: 0.0, color: [21, 71, 108]),    # Deep water
      PerlinColor(value: 0.2, color: [37, 111, 163]),   # Shallow water
      PerlinColor(value: 0.3, color: [252, 212, 94]),   # Sand
      PerlinColor(value: 0.4, color: [200, 180, 84]),   # Darker sand
      PerlinColor(value: 0.5, color: [80, 150, 60]),   # Light Grass
      PerlinColor(value: 0.6, color: [60, 120, 42]),    # Grass
      PerlinColor(value: 0.7, color: [50, 83, 30]),    # Jungle
      PerlinColor(value: 0.9, color: [107, 83, 62]),  # Rock
      PerlinColor(value: 1.0, color: [120, 120, 120]),  # Snow
    ]

  self.map = newSeq[newSeq[newSeq[Tile](int(level.tiles.z))](int(level.tiles.y))](int(level.tiles.x))
  for x in 0..self.map.len - 1:
    self.map[x] = newSeq[newSeq[Tile](int(level.tiles.z))](int(level.tiles.y))
    for y in 0..self.map[x].len - 1:
      self.map[x][y] = newSeq[Tile](int(level.tiles.z))
  for x in 0..int(level.tiles.x) - 1:
    var perlinOffset = (float(x) / float(level.tiles.x)) - 0.5
    for y in 0..int(level.tiles.y) - 1:
      for z in 0..int(level.tiles.z) - 1:
        var tile = Tile()
        let noiseValue = generatePerlinNoise(noise, x, y, z, perlinOffset)
          
        var
          ratio = 0.5
          lower_color = [120, 120, 120]
          upper_color = [120, 120, 120]
        for i in 0..color_gradient.len - 2:
          if noiseValue >= color_gradient[i].value and noiseValue < color_gradient[i + 1].value:
            lower_color = color_gradient[i].color
            upper_color = color_gradient[i + 1].color
            # Calculate the ratio to use for interpolation 
            
            ratio = (noiseValue - color_gradient[i].value) / (color_gradient[i + 1].value - color_gradient[i].value)
            break
        if noiseValue == 1:
          echo lower_color, " ", upper_color, " ", ratio
        for i in 0..2:
          # Interpolate thes based on the noise value
          tile.color[i] = float(lower_color[i]) * (1 - ratio) + float(upper_color[i]) * ratio
         
        
        tile.position = Vector3(x: float(x) * level.tileSize, y: float(y) * level.tileSize, z: float(z) * level.tileSize)
        tile.size = level.tileSize
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
        self.map[x][y][z] = tile


method update*(self: Ground, dt: float) {.base.} =
  # loop through tiles
  for x in 0..self.map.len - 1:
    for y in 0..self.map[x].len - 1:
      for z in 0..self.map[x][y].len - 1:
        break
        var tile = self.map[x][y][z]
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
          for i in 0..tile.plants.len:
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

        # Set the tile
        self.map[x][y][z] = tile

proc isTileVisible*(self: Ground, x: int): bool =
  result = float(x) * self.tileSize > camera.position.x - screenWidth * 0.6 and float(x) * self.tileSize < camera.position.x + screenWidth * 0.6
    

method draw*(self: Ground) {.base.} =
  for x in 0..self.map.len - 1:
    if not self.isTileVisible(x): continue
    
    for y in 0..self.map[x].len - 1:
    
      for z in 0..self.map[x][y].len - 1:
        let tile = self.map[x][y][z]
        #if tile.isTileVisible(): 
        #drawCylinder(tile.position, tile.radius, tile.radius, tile.radius, 9, uint8ToColor(tile.color, 255))
        #if tile.alpha >= 200:
        var color = uint8ToColor(tile.color, 255)
        #var fertility = clamp(tile.fertility, 0, 100)
        #if tile.orgColor[1] - (tile.orgColor[0] + tile.orgColor[2]) * 0.5 > 0:
        #  color.g = float2uint8(float(color.g) * (clamp(fertility, 30, 50) / 50))
        #  color.b = float2uint8(float(color.b) * (clamp(fertility, 0, 40) / 50))
        drawCube(tile.position, fillVector3(tile.size), color)

        if tile.plants.len > 0:
          for plant in tile.plants:
            plant.draw()
