import raylib, screens, std/math, std/random, utils

type
  Particle* = object
    position*: Vector2 = Vector2(x: 0, y: 0)
    lifetime: float = 20
    velocity: Vector2 = Vector2(x: 0, y: 0)
    radius: float
    color: Color
    rotation: float
  Player* = ref object of RootObj
    rotation: float = 0.0
    position* = Vector2()
    xp*: float = 0.0
    speed: float = 30
    frozen = false
    radius*: float = 22.0
    scale*: float = 1
    lifetime: float = 30
    particles*: seq[Particle]
    lastDirection: float = 1.0

const
  keyRight: array[0..1, KeyboardKey] = [Right, KeyboardKey(D)]
  keyLeft: array[0..1, KeyboardKey] = [Left, KeyboardKey(A)]
  keyUp: array[0..1, KeyboardKey] = [Up, KeyboardKey(W)]
  keyDown: array[0..1, KeyboardKey] = [Down, KeyboardKey(S)]

proc getAngle(diff: Vector2): Vector2 =
  var angle = arctan2(diff.x, diff.y)
  if (angle < 0):
    angle += PI * 2.0
  return Vector2(x: sin(angle), y: cos(angle))

proc getDirection(x: float, y: float): Vector2 =
  var dir = Vector2()
  for key in keyRight:
    if (isKeyDown(key)):
      dir.x = 1;
  for key in keyLeft:
    if (isKeyDown(key)):
      dir.x = -1;
  for key in keyUp:
    if (isKeyDown(key)):
      dir.y = -1;
  for key in keyDown:
    if (isKeyDown(key)):
      dir.y = 1;
  
  if (dir.y == 0 and dir.x == 0):
    # check mouse press
    if (isMouseButtonDown(Left)):
      var diff = Vector2(x: mouse.x - x + cx, y: mouse.y - y)
      dir = getAngle(diff)

  return dir

method init*(self: Player) {.base.} =
  randomize()
  self.position = Vector2(x: cx + screenWidth * 0.5, y: screenHeight * 0.8)

proc getRadius*(self: Player):float =
  return self.radius * self.scale

proc getZ*(self: Player): float = 
  return self.position.y + self.getRadius()

proc getParticle*(self: Player, velocity: Vector2, color: Color): Particle =
  return Particle(
    radius: self.radius * self.scale,
    lifetime: self.lifetime,
    position: self.position,
    velocity: velocity,
    rotation: self.rotation,
    color: color,
  )

method update*(self: Player, dt: float) {.base.} =
  let radius = self.getRadius()
  let x = self.position.x
  let y = self.position.y
  var dir = Vector2()
  if not self.frozen:
    dir = getDirection(x, y)
    #playerFuel -= (abs(dir.x) + abs(dir.y)) * self.speed * dt / 1000
  # get velocity of player
  var dx = (dir.x * self.speed * radius) * dt
  var dy = (dir.y * self.speed * radius) * dt

  # x limit, move screen at edges
  var eyeBound = 200 + screenWidth / (radius * self.scale * 2)

  if (x + dx < cx + eyeBound and cx > 0 and dx < 0) or (x + dx > cx + screenWidth - eyeBound and cx < float(endX) - screenWidth and dx > 0):
    cx += dx;

  if (x + dx < cx + radius and dx < 0):
    self.position.x = cx + radius
  elif (x + dx > cx + screenWidth - radius):
    self.position.x = cx + screenWidth - radius
  else:
    self.position.x += dx
  # y limits
  var minY = float(startY) - radius * 0.5;
  var maxY = screenHeight - radius;
  if y + dy > maxY and dy > 0: self.position.y = maxY
  elif y + dy < minY and dy < 0: self.position.y = minY
  else:
    self.position.y += dy

  var 
    red: uint8
    green: uint8
    blue: uint8

  if playerFuel < 1000:
    red = uint8(150 + 100 * (playerFuel / 1000.0))
    green = uint8(40 + 50 * (playerFuel / 1000.0))
    blue = 5
  elif playerFuel < 2000:
    red = uint8(240 - 100 * ((playerFuel - 1000) / 1000.0))
    green = uint8(90 - 70 * ((playerFuel - 1000) / 1000.0))
    blue = uint8(20 + 80 * ((playerFuel - 1000) / 1000.0))
  else:
    red = uint8(10 + 110 * ((playerFuel - 2000) / 1000.0))
    green = 20
    blue = uint8(100 + 110 * ((playerFuel - 2000) / 1000.0))
  var color = Color(r: red, g: green, b: blue, a: 200)

  var vel = Vector2(x: dx, y: dy)
  if self.particles.len < 50:
    var p = self.getParticle(vel, color)
    self.particles.add(p)

  for i, p in self.particles:
    var p = self.particles[i]

    p.position.x += rand(-4.0..4.0)
    p.position.y += -5 * (1 - abs(dir.x))

    p.radius *= 0.94
    p.color.a = uint8(float32(p.color.a) * 0.9)
    p.lifetime -= dt * 50
    p.rotation += 20
    if p.lifetime <= 0:
      p = self.getParticle(vel, color)
    self.particles[i] = p
  if dir.x != 0:
    self.lastDirection = dir.x
  var rotX = dx / self.scale
  if rotX == 0:
    rotX = 5 * self.lastDirection
  self.rotation -= rotx
  # change player scale depending on y postion
  self.scale = getYScale(self.position.y) * min(1.5, max(1, playerFuel / 1000))
  # update flame

proc draw(self: Particle, pos: Vector2, color: Color) =
  # draw rectangle
  drawPoly(pos, 5, self.radius, self.rotation, color)

proc jitterColor(color: Color, jitter: float): Color =
  result.r = float2uint8(float32(color.r) + rand(-jitter..jitter))
  result.g = float2uint8(float32(color.g) + rand(-jitter..jitter))
  result.b = float2uint8(float32(color.b) + rand(-jitter..jitter))
  result.a = color.a

method draw*(self: Player, i: int) {.base.} =
  var p = self.particles[i]
  p.draw(p.position, jitterColor(p.color, 5.0))
