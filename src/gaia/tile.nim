import raylib, plant, perlin, ../utils

type
  PerlinColor* = object
    value*: float
    color*: array[0..2, int]
    y*: int
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
    dead*: bool = false

proc generatePerlinNoise(noise: Noise, x: int, y: int, z: int, offset: float): float =
  result = clamp(noise.perlin(float(x), float(y), float(z)) + offset, 0, 1)

#proc getPlant*(self: Ground, tile: Tile, randRow: bool): Plant =
#  var plant = Plant()
#  let x = tile.position.x - tile.size
#  let y = 0.0
#  let z = rand(tile.position.z - tile.size..tile.position.z + tile.size)
#  plant.init(Vector3(x: x, y: y, z: z), randRow)
#  return plant


proc interpolateColors(lowerColor, upperColor: array[0..2, int], ratio: float): array[0..2, float] =
  for i in 0..2:
    result[i] = float(lowerColor[i]) * (1 - ratio) + float(upperColor[i]) * ratio

proc init*(self: var Tile, x: int, y: int, z: int, tileSize: float, noise: Noise, tilePerlinColors: seq[PerlinColor]) =
  let noiseValue = generatePerlinNoise(noise, x, y, z, float(x) / 200.0 - 0.5) 
  var lowerIndex = 0
  var upperIndex = 0
  for i in 0..<tilePerlinColors.len - 1:
      if noiseValue >= tilePerlinColors[i].value and noiseValue < tilePerlinColors[i + 1].value:
          lowerIndex = i
          upperIndex = i + 1
          break
  let ratio = (noiseValue - tilePerlinColors[lowerIndex].value) / (tilePerlinColors[upperIndex].value - tilePerlinColors[lowerIndex].value)
  self.color = interpolateColors(tilePerlinColors[lowerIndex].color, tilePerlinColors[upperIndex].color, ratio)
  self.position = Vector3(x: float(x) * tileSize, y: float(y) * tileSize, z: float(z) * tileSize)
  self.size = tileSize
  self.orgColor = self.color
  self.fertility = self.color[1] * 1.5 - self.color[0] * 0.5
  if self.color[2] < 50:
      self.fertility += self.color[2]
  else:
      self.fertility -= self.color[2] * 0.5
  self.fertility = max(20, self.fertility)

proc update*(self: var Tile, dt: float) =
  if self.burnTimer > 0:
    if self.fertility > 0:
      self.fertility -= 2 * dt * 60
    self.fertility = clamp(self.fertility, 0, 100)

    self.color[0] += (self.fertility / 100) * 50
    self.color[0] = min(self.color[0], 255.0)

    self.color[1] -= 10
    self.color[1] = max(self.color[1], self.orgColor[1] - 80)

    self.color[2] -= 10
    self.color[2] = max(self.color[2], self.orgColor[2] - 80)

    self.burnTimer -= dt * 60 * 10
    self.hp -= dt * 60
    if self.hp <= 0:
      self.dead = true
  
  let
    diffR = self.color[0] - self.orgColor[0]
    diffG = self.color[1] - self.orgColor[1]
    diffB = self.color[2] - self.orgColor[2]
  
  if diffR > 0:
    self.color[0] = max(self.orgColor[0], self.color[0] - 120 * dt)
  elif diffR < 0:
    self.color[0] = min(self.orgColor[0], self.color[0] + 120 * dt)

  if diffG > 0:
    self.color[1] = max(self.orgColor[1], self.color[1] - 60 * dt)
  elif diffG < 0:
    self.color[1] = min(self.orgColor[1], self.color[1] + 60 * dt)

  if diffB > 0:
    self.color[2] = max(self.orgColor[2], self.color[2] - 40 * dt)
  elif diffB < 0:
    self.color[2] = min(self.orgColor[2], self.color[2] + 40 * dt)

proc draw*(self: Tile) =
  let decayFactor = 1.0 - self.hp / 100.0
  
  # Compute the decayed color for drawing, without modifying the actual tile color
  var decayedColor: array[0..2, float]
  decayedColor[0] = self.color[0] * (1.0 - decayFactor)
  decayedColor[1] = self.color[1] * (1.0 - decayFactor)
  decayedColor[2] = self.color[2] * (1.0 - decayFactor)
  
  # Use the decayedColor for drawing
  var drawColor = uint8ToColor(decayedColor, self.alpha)
  drawCube(self.position, fillVector(self.size), drawColor)
  
  # Draw plants if any
  if self.plants.len > 0:
    for plant in self.plants:
      plant.draw()
