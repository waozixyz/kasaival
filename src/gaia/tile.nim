import raylib, plant, perlin, ../utils

type
  ColorArray = array[0..2, float]
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
    color*: ColorArray
    orgColor*: ColorArray
    fertility*: float = 100.0
    growProbability: float
    alpha*: float = 255.0
    plants*: seq[Plant]
    dead*: bool = false

const
  DECAY_RATE = 120
  GROWTH_RATE = 60

#proc getPlant*(self: Ground, tile: Tile, randRow: bool): Plant =
#  var plant = Plant()
#  let x = tile.position.x - tile.size
#  let y = 0.0
#  let z = rand(tile.position.z - tile.size..tile.position.z + tile.size)
#  plant.init(Vector3(x: x, y: y, z: z), randRow)
#  return plant


proc interpolateColors(lowerColor, upperColor: array[0..2, int], ratio: float): ColorArray =
  for i in 0..2:
    result[i] = float(lowerColor[i]) * (1 - ratio) + float(upperColor[i]) * ratio

proc init*(self: var Tile, x: int, y: int, z: int, tileSize: float, noise: Noise, tilePerlinColors: seq[PerlinColor]) =
  let noiseValue = clamp(noise.perlin(float(x), float(y), float(z)) + float(x) / 200.0 - 0.5, 0, 1) 
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

proc updateColorComponent(currentColor, orgColor: float, rate: float, dt: float): float =
  let diff = currentColor - orgColor
  if diff > 0:
    return max(orgColor, currentColor - rate * dt)
  elif diff < 0:
    return min(orgColor, currentColor + rate * dt)
  return currentColor

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
    #self.hp -= dt * 60
    #if self.hp <= 0:
    # self.dead = true
  
  self.color[0] = updateColorComponent(self.color[0], self.orgColor[0], DECAY_RATE, dt)
  self.color[1] = updateColorComponent(self.color[1], self.orgColor[1], GROWTH_RATE, dt)
  self.color[2] = updateColorComponent(self.color[2], self.orgColor[2], GROWTH_RATE, dt)

proc draw*(self: Tile) =
  let decayFactor = 1.0 - self.hp / 100.0
  
  var decayedColor: ColorArray
  decayedColor[0] = self.color[0] * (1.0 - decayFactor)
  decayedColor[1] = self.color[1] * (1.0 - decayFactor)
  decayedColor[2] = self.color[2] * (1.0 - decayFactor)
  
  var drawColor = uint8ToColor(decayedColor, self.alpha)
  
  # Get the half size for calculating triangle vertices
  let halfSize = self.size / 2.0
  
  # Define vertices for the triangles
  let topLeftFront = Vector3(x: self.position.x - halfSize, y: self.position.y + halfSize, z: self.position.z + halfSize)
  let topRightFront = Vector3(x: self.position.x + halfSize, y: self.position.y + halfSize, z: self.position.z + halfSize)
  let topLeftBack = Vector3(x: self.position.x - halfSize, y: self.position.y + halfSize, z: self.position.z - halfSize)
  let topRightBack = Vector3(x: self.position.x + halfSize, y: self.position.y + halfSize, z: self.position.z - halfSize)
  let bottomLeftFront = Vector3(x: self.position.x - halfSize, y: self.position.y - halfSize, z: self.position.z + halfSize)
  let bottomRightFront = Vector3(x: self.position.x + halfSize, y: self.position.y - halfSize, z: self.position.z + halfSize)
  let bottomLeftBack = Vector3(x: self.position.x - halfSize, y: self.position.y - halfSize, z: self.position.z - halfSize)
  let bottomRightBack = Vector3(x: self.position.x + halfSize, y: self.position.y - halfSize, z: self.position.z - halfSize)
  
  # Draw the triangles for the sliced cube
  # Front face
  drawTriangle3D(topLeftFront, bottomLeftFront, bottomRightFront, drawColor)
  drawTriangle3D(bottomRightFront, topRightFront, topLeftFront, drawColor)

  # Top face
  drawTriangle3D(topRightBack, topLeftBack, topLeftFront, drawColor)
  drawTriangle3D(topLeftFront, topRightFront, topRightBack, drawColor)

  # Left side face
  #drawTriangle3D(topLeftFront, bottomLeftFront, topLeftBack, drawColor)
  #drawTriangle3D(topLeftBack, bottomLeftBack, bottomLeftFront, drawColor)

  # Right side face
  #drawTriangle3D(topRightFront, bottomRightFront, topRightBack, drawColor)
  #drawTriangle3D(topRightBack, bottomRightBack, bottomRightFront, drawColor)

  # Bottom face
  #drawTriangle3D(bottomLeftFront, bottomLeftBack, bottomRightBack, drawColor)
  #drawTriangle3D(bottomLeftFront, bottomRightBack, bottomRightFront, drawColor)

  # Back face
  #drawTriangle3D(topLeftBack, bottomLeftBack, topRightBack, drawColor)
  #drawTriangle3D(bottomLeftBack, bottomRightBack, topRightBack, drawColor)

  if self.plants.len > 0:
    for plant in self.plants:
      plant.draw()
