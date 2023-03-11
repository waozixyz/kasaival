import raylib, screens, particles/fire, std/math

type
  Player* = ref object of RootObj
    position = Vector2()
    sprite = Fire()
    hp: float = 100.0
    xp: float = 0.0
    speed: float = 0.5
    frozen = false

const
  key_right: array[0..1, KeyboardKey] = [Right, KeyboardKey(D)]
  key_left: array[0..1, KeyboardKey] = [Left, KeyboardKey(A)]
  key_up: array[0..1, KeyboardKey] = [Up, KeyboardKey(W)]
  key_down: array[0..1, KeyboardKey] = [Down, KeyboardKey(S)]


proc getAngle(diff: Vector2): Vector2 =
  var angle = arctan2(diff.x, diff.y)
  if (angle < 0):
    angle += PI * 2.0
  return Vector2(x: sin(angle), y: cos(angle))

proc getDirection(x: float, y: float): Vector2 =
  var dir = Vector2()
  for key in key_right:
    if (isKeyDown(key)):
      dir.x = 1;
  for key in key_left:
    if (isKeyDown(key)):
      dir.x = -1;
  for key in key_up:
    if (isKeyDown(key)):
      dir.y = -1;
  for key in key_down:
    if (isKeyDown(key)):
      dir.y = 1;
  
  if (dir.y == 0 and dir.x == 0):
    # check mouse press
    if (isGestureDetected(Tap)):
      var diff = Vector2(x: mouse.x - x + cx, y: mouse.y - y)
      const offset = 5
      if (diff.x > offset or diff.y > offset):
        dir = getAngle(diff)

  return dir

method init*(self: Player) {.base.} =
  self.position = Vector2(x: cx + screenWidth * 0.5, y: screenHeight * 0.8)
  self.sprite.init()

method update*(self: Player) {.base.} =
  let radius = self.sprite.getRadius()
  let x = self.position.x
  let y = self.position.y
  var dir = Vector2()
  if (not self.frozen):
    dir = getDirection(x, y)
  
  # get velocity of player
  var dx = dir.x * self.speed * radius
  var dy = dir.y * self.speed * radius
  
  # x limit, move screen at edges
  var eyeBound = screenWidth / 5;
  if ((x + dx < cx + eyeBound and cx > 0) or (x + dx > cx + screenWidth - eyeBound and cx < float(endX) - screenWidth)):
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
  if (y + dy > maxY and dy > 0):
    self.position.y = maxY
  elif (y + dy < minY and dy < 0):
    self.position.y = minY
  else:
    self.position.y += dy
  

  self.sprite.update(self.position)

method draw*(self: Player) {.base.}  =
  self.sprite.draw()

method unload*(self: Player) {.base.} =
  self.sprite.unload()
