import raylib, screens, particles/fire, std/math

type
  Player* = ref object of RootObj
    position* = Vector2()
    sprite* = Fire()
    fuel*: float = 300
    xp*: float = 0.0
    speed: float = 0.6
    frozen = false
    scale*: float = 1
    initScale: float = 2
    alpha: float = 255

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
  self.sprite.init()

method getRadius*(self: Player):float {.base.} =
  return self.sprite.getRadius()

proc getZ*(self: Player): float = 
  return self.position.y + self.getRadius()

method addFuel*(self: Player, fuel: float) {.base.} =
  self.fuel += fuel

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
  var eyeBound = screenWidth / (5 * (self.scale * 1.8))

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
  else: self.position.y += dy
  
  # change player scale depending on y postion
  self.scale = (self.position.y / screenHeight) * yScaling * self.initScale
  self.sprite.scale = self.scale
  # update flame
  self.sprite.update(self.position)

  # update hp
  self.fuel -= burn * dt

method draw*(self: Player, i: int) {.base.}  =
  self.sprite.draw(i, self.fuel)
