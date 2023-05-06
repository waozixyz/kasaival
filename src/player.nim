import raylib, screens, std/math, std/random, utils


type
  PlayerState* = enum
    Grounded = 0, Frozen
  Particle* = object
    position*: Vector3
    lifetime: float = 20
    radius*: float
    color: Color
    rotation: float
  Player* = ref object of RootObj
    rotation: float = 0.0
    position*: Vector3
    velocity*: Vector3
    xp*: float = 0.0
    speed: float = 90.0
    radius*: float = 9.0
    lifetime: float = 30
    particles*: seq[Particle]
    lastDirection: float = 1.0
    jumpForce: float = 20.0
    state*: PlayerState = Grounded

const
  keyRight: array[0..1, KeyboardKey] = [Right, KeyboardKey(D)]
  keyLeft: array[0..1, KeyboardKey] = [Left, KeyboardKey(A)]
  keyUp: array[0..1, KeyboardKey] = [Up, KeyboardKey(W)]
  keyDown: array[0..1, KeyboardKey] = [Down, KeyboardKey(S)]

proc getAngle(diff: Vector3): Vector3 =
  var angle = arctan2(diff.x, diff.z)
  if (angle < 0):
    angle += PI * 2.0
  return Vector3(x: sin(angle), y: 0, z: cos(angle))

proc getDirection(x: float, z: float): Vector3 =
  var dir = Vector3()
  for key in keyRight:
    if (isKeyDown(key)):
      dir.x = 1;
  for key in keyLeft:
    if (isKeyDown(key)):
      dir.x = -1;
  for key in keyUp:
    if (isKeyDown(key)):
      dir.z = -1;
  for key in keyDown:
    if (isKeyDown(key)):
      dir.z = 1;
  

  if (dir.z == 0 and dir.x == 0):
    # check mouse press
    if (isMouseButtonDown(Left)):
      var diff = Vector3(x: mouse.x - x, y: 0, z: mouse.y - z)
      dir = getAngle(diff)

  return dir

method init*(self: Player) {.base.} =
  randomize()
  self.position = Vector3(x: groundWidth * 0.5, y: 0.0, z: groundLength * 0.5)

proc getRadius*(self: Player):float =
  return self.radius

proc getParticle*(self: Player, color: Color): Particle =
  return Particle(
    radius: self.radius,
    lifetime: self.lifetime,
    position: self.position,
    rotation: self.rotation,
    color: color,
  )

method update*(self: Player, dt: float) {.base.} =
  let radius = self.getRadius()
  let x = self.position.x
  let z = self.position.z

  var dir = Vector3()
  dir = getDirection(x, z)
  var dx = (dir.x * self.speed * radius) * dt
  var dz = (dir.z * self.speed * radius) * dt
  
  if self.state != Frozen:
    playerFuel -= (abs(dir.x) + abs(dir.z)) * self.speed * dt / 1000
    # get velocity of player
    if (self.position.x + dx > 0 or dx > 0) and (self.position.x + dx < groundWidth or dx < 0):
      self.position.x += dx
    if (self.position.z + dz > 0 or dz > 0) and (self.position.z + dz < groundLength or dz < 0):
      self.position.z += dz
    echo self.position.x
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
  var color = Color(r: red, g: green, b: blue, a: 255)

  if self.particles.len < 100:
    var p = self.getParticle(color)
    self.particles.add(p)

  for i, p in self.particles:
    var p = self.particles[i]

    p.position.x += rand(-4.0..4.0)
    p.position.y += 2 + self.velocity.y * dt

    p.position.z += rand(-4.0..4.0)

    p.radius *= 0.94
    p.color.a = uint8(float32(p.color.a) * 0.9)
    p.lifetime -= dt * 50
    p.rotation += 20
    if p.lifetime <= 0:
      p = self.getParticle(color)
    self.particles[i] = p
  if dir.x != 0:
    self.lastDirection = dir.x
  var rotX = dx
  if rotX == 0:
    rotX = 5 * self.lastDirection
  self.rotation -= rotx
  # update flame

proc draw(self: Particle, pos: Vector3, color: Color) =
  # draw rectangle
  drawCylinder(pos, self.radius, self.radius, self.radius,  6, color)

proc jitterColor(color: Color, jitter: float): Color =
  result.r = float2uint8(float32(color.r) + rand(-jitter..jitter))
  result.g = float2uint8(float32(color.g) + rand(-jitter..jitter))
  result.b = float2uint8(float32(color.b) + rand(-jitter..jitter))
  result.a = color.a

method draw*(self: Player) {.base.} =
  for p in self.particles:
    p.draw(p.position, jitterColor(p.color, 5.0))
