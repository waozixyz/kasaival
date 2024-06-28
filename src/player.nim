import raylib, std/random, utils, std/math, state

const
  FIREBALL_SHADER_PATH = "resources/shaders/glsl330/fireball.fs"
  FLAME_SHADER_PATH = "resources/shaders/glsl330/flame.fs"

type
  PlayerState* = enum
    Grounded = 0, Jumping, Falling, Frozen

  Player* = ref object of RootObj
    rotation: float = 0.0
    position*, velocity*: Vector3
    xp*: float = 0.0
    speed: float = 30.0
    radius*: float = 20.0
    lifetime: float = 30
    lastDirection: float = 1.0
    jumpHeight: float = 200.0
    state*: PlayerState = Grounded
    bd*: Vector3 = Vector3()
    fireball_shader: Shader
    flame_shader: Shader
    seconds: float = 0.0
    bufferAShader: Shader
    framebuffer: RenderTexture2D



const
  KEY_RIGHT = [Right, KeyboardKey(D)]
  KEY_LEFT = [Left, KeyboardKey(A)]
  KEY_UP = [Up, KeyboardKey(W)]
  KEY_DOWN = [Down, KeyboardKey(S)]

proc getDirection(self: Player): Vector3 =
  result = Vector3()
  for key in KEY_RIGHT:
    if isKeyDown(key): result.x = 1
  for key in KEY_LEFT:
    if isKeyDown(key): result.x = -1
  for key in KEY_UP:
    if isKeyDown(key): result.z = -1
  for key in KEY_DOWN:
    if isKeyDown(key): result.z = 1
  
  if result.z == 0 and result.x == 0 and isMouseButtonDown(Left):
    let mouseRay = getScreenToWorldRay(gMousePosition, gCamera)
    let collision = getRayCollisionBox(mouseRay, getBoundingBox(self.position, self.radius))
    result.x = collision.normal.x
    result.z = -(collision.normal.y + 0.5) + (collision.normal.z + 0.5)

proc getVelocity*(self: Player, dt: float): Vector3 =
    var vel = self.velocity
    let dir = self.getDirection()
    vel.x = (dir.x * self.speed * self.radius) * dt
    vel.z = (dir.z * self.speed * self.radius) * dt
    if self.state != Grounded:
      vel.y -= gravity * dt
    if self.state == Grounded and isKeyDown(Space):
      vel.y = self.jumpHeight * dt
      self.state = Jumping
  
    result = vel
  
method init*(self: Player) {.base.} =
  randomize()
  self.position = Vector3(x: gGroundSize.x * 0.4, y: gGroundSize.y + self.radius * 2, z: gGroundSize.z * 0.5)
  # Load the flame effect shader
  self.fireball_shader = loadShader("", FIREBALL_SHADER_PATH)
  self.flame_shader = loadShader("", FLAME_SHADER_PATH)
  
  if self.fireball_shader.id == 0:
    echo "Error: Failed to load flame effect shader!"

  
method update*(self: Player, dt: float) {.base.} =
  self.seconds += dt

  if self.state != Frozen:
    let
      diameter = self.radius * 2
      vel = self.velocity
      pos = self.position
    
    if (pos.x + vel.x - diameter > 0 or vel.x > 0) and (pos.x + vel.x + diameter < gGroundSize.x or vel.x < 0):
      self.position.x += vel.x
    if (pos.z + vel.z - diameter > 0 or vel.z > 0) and (pos.z + vel.z + diameter < gGroundSize.z - tileSize * 0.5 or vel.z < 0):
      self.position.z += vel.z
    self.position.y += vel.y

  let iTimeLoc = getShaderLocation(self.fireball_shader, "iTime")
  let iResolutionLoc = getShaderLocation(self.fireball_shader, "iResolution")
  let iMouseLoc = getShaderLocation(self.fireball_shader, "iMouse")
  setShaderValue(self.fireball_shader, iTimeLoc, self.seconds.float32)
  setShaderValue(self.fireball_shader, iResolutionLoc, [screenWidth.float32, screenHeight.float32])
  let mousePos = getMousePosition()
  let mouseState = Vector4(
      x: mousePos.x.float32,
      y: mousePos.y.float32,
      z: if isMouseButtonDown(MouseButton.LEFT): 1.0 else: 0.0,
      w: if isMouseButtonDown(MouseButton.RIGHT): 1.0 else: 0.0
  )
  setShaderValue(self.fireball_shader, iMouseLoc, mouseState)

method draw*(self: Player) {.base.} =
  beginBlendMode(BlendMode.Alpha);
  beginShaderMode(self.fireball_shader)

  drawSphere(self.position, self.radius * 2, RAYWHITE)

  #drawCylinder(bottomPosition, self.radius, self.radius, capsuleHeight, 16, RAYWHITE)

  endShaderMode()
  endBlendMode()
