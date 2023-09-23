import raylib, screens, std/random, utils, std/math

type
  PlayerState* = enum
    Grounded = 0, Jumping, Falling, Frozen

  Particle* = object
    position*: Vector3
    lifetime: float = 20
    radius*: float
    color: Color
    rotation: float

  Player* = ref object of RootObj
    rotation: float = 0.0
    position*, velocity*: Vector3
    xp*: float = 0.0
    speed: float = 30.0
    radius*: float = 3.0
    lifetime: float = 30
    particles*: seq[Particle]
    lastDirection: float = 1.0
    jumpHeight: float = 200.0
    shader: Shader
    state*: PlayerState = Grounded
    bd*: Vector3 = Vector3()

const
  PARTICLE_DECAY_RATE = 0.94
  PARTICLE_ALPHA_DECAY_RATE = 0.9
  PARTICLE_LIFETIME_DECAY = 3.0
  PARTICLE_MAX_COUNT = 100
  COLOR_JITTER = 2.5
  UPWARD_VELOCITY_MODIFIER = 0.3

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
    let mouseRay = getMouseRay(mouse, camera)
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

proc getFlameColor(self: Player, lifetime: float): Color =
  # Linear interpolation between base color and decay color based on lifetime
  let t = math.clamp(lifetime / self.lifetime, 0.0 .. 1.0)
  let baseColor = Color(r: 255, g: 90, b: 20, a: 255) # Reddish tone
  let decayColor = Color(r: 220, g: 200, b: 200, a: 255) # White-grayish tone
  
  result.r = clampuint8(uint8(float32(baseColor.r) * t + float32(decayColor.r) * (1 - t)))
  result.g = clampuint8(uint8(float32(baseColor.g) * t + float32(decayColor.g) * (1 - t)))
  result.b = clampuint8(uint8(float32(baseColor.b) * t + float32(decayColor.b) * (1 - t)))
  result.a = clampuint8(float2uint8(float32(255) * PARTICLE_ALPHA_DECAY_RATE * t))

proc getParticle*(self: Player, color: Color): Particle =
  return Particle(
    radius: self.radius * (0.5 + rand(0.5..1.5)),
    lifetime: self.lifetime * rand(0.8..1.2),
    position: self.position,
    rotation: self.rotation,
    color: color,
  )

method init*(self: Player) {.base.} =
  randomize()
  self.position = Vector3(x: groundSize.x * 0.4, y: groundSize.y + self.radius * 2, z: groundSize.z * 0.5)

method update*(self: Player, dt: float) {.base.} =
  if self.state != Frozen:
    let
      diameter = self.radius * 2
      vel = self.velocity
      pos = self.position
    
    if (pos.x + vel.x - diameter > 0 or vel.x > 0) and (pos.x + vel.x + diameter < groundSize.x or vel.x < 0):
      self.position.x += vel.x
    if (pos.z + vel.z - diameter > 0 or vel.z > 0) and (pos.z + vel.z + diameter + 6 < groundSize.z or vel.z < 0):
      self.position.z += vel.z
    self.position.y += vel.y

  if self.particles.len < PARTICLE_MAX_COUNT:
    var p = self.getParticle(self.getFlameColor(self.lifetime))
    self.particles.add(p)

  for i, p in self.particles:
    var p = self.particles[i]
    p.position.x += float32(rand(-2.0..2.0))
    p.position.y += self.radius * UPWARD_VELOCITY_MODIFIER + self.velocity.y * dt
    p.position.z += float32(rand(-2.0..2.0))
    p.radius *= PARTICLE_DECAY_RATE
    p.lifetime -= PARTICLE_LIFETIME_DECAY
    if p.lifetime <= 0:
        p = self.getParticle(self.getFlameColor(self.lifetime))
    else:
      p.color = self.getFlameColor(p.lifetime)

    self.particles[i] = p


method draw*(self: Player) {.base.} =
  for p in self.particles:
    drawSphere(p.position, p.radius, p.color)

