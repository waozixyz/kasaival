import raylib, screens, std/math

type
  Particle* = object
    position*: Vector2 = Vector2(x: 0, y: 0)
    lifetime: float
    velocity: Vector2
    size: float
    color: Color
  Player* = ref object of RootObj
    position* = Vector2()
    xp*: float = 0.0
    speed: float = 0.5
    frozen = false
    scale*: float = 1
    initScale: float = 2
    particles*: seq[Particle]

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
  self.position = Vector2(x: cx + screenWidth * 0.5, y: screenHeight * 0.8)

method getRadius*(self: Player):float {.base.} =
  return 32

proc getZ*(self: Player): float = 
  return self.position.y + self.getRadius()

method addParticle*(self: Player, velocity: Vector2, color: Color) {.base.} =
  var p = Particle(
    size: 32,
    lifetime: 30,
    position: self.position,
    velocity: velocity,
    color: color,
  )
  self.particles.add(p)


method update*(self: Player, dt: float) {.base.} =
  var burn = 8.0
  let radius = self.getRadius()
  let x = self.position.x
  let y = self.position.y
  var dir = Vector2()
  if not self.frozen:
    dir = getDirection(x, y)
    burn += burn * (abs(dir.x) + abs(dir.y)) * self.speed
  # get velocity of player
  var dx = dir.x * self.speed * radius
  var dy = dir.y * self.speed * radius

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
  

  var red = uint8(min(1.0, playerFuel / 1000.0))  # increase red from 0 to 1 as playerFuel goes up to 1000
  var blue = uint8(max(0.0, (playerFuel - 1000.0) / 1000.0))  # increase blue from 0 to 1 as playerFuel goes from 1000 to 2000
  var green = uint8(max(0.0, (playerFuel - 500.0) / 1500.0))  # increase green from 0 to 1 as playerFuel goes from 500 to 2000

  if self.particles.len < 50:
    self.addParticle(Vector2(x: dx, y: dy), Color(r: red, g: green, b: blue))

  # change player scale depending on y postion
  self.scale = getYScale(self.position.y) * self.initScale * min(1.5, max(1, playerFuel / 1000))
  # update flame

  # update hp
  playerFuel -= burn * dt

method draw*(self: Player, i: int) {.base.}  =
  #self.sprite.draw(i)
  for p in self.particles:
    drawCircle(p.position, p.size, p.color)
