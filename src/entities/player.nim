import raylib, std/random, ../utils, std/math, ../state

type
  ParticleState = enum
    Flame, Smoke

  Particle = object
    position: Vector2
    velocity: Vector2
    size: float
    color: Color
    lifetime: float
    maxLifetime: float
    state: ParticleState

  PlayerState* = enum
    Grounded, Jumping, Falling, Frozen

  Player* = ref object of RootObj
    position*: Vector3
    velocity*: Vector3
    rotation: float
    xp*: float
    speed: float
    radius*: float
    jumpHeight: float
    state*: PlayerState
    particles: seq[Particle]
    particleTexture: Texture2D

const
  MAX_PARTICLES = 200
  PARTICLE_SPAWN_RATE = 50 # particles per second
  PARTICLE_SIZE_RANGE = (2.0, 6.0)
  PARTICLE_LIFETIME_RANGE = (0.5, 1.5)
  FLAME_TO_SMOKE_RATIO = 0.6
  KEY_RIGHT = [KeyboardKey.Right, KeyboardKey.D]
  KEY_LEFT = [KeyboardKey.Left, KeyboardKey.A]
  KEY_UP = [KeyboardKey.Up, KeyboardKey.W]
  KEY_DOWN = [KeyboardKey.Down, KeyboardKey.S]

proc initParticleSystem(self: Player) =
  var flameImage = genImageColor(16, 16, BLANK)
  imageDrawCircle(flameImage, 8, 8, 7, WHITE)
  self.particleTexture = loadTextureFromImage(flameImage)

proc newPlayer*(): Player =
  result = Player(
    position: Vector3(x: gGroundSize.x * 0.4, y: gGroundSize.y + 40, z: gGroundSize.z * 0.5),
    velocity: Vector3(),
    rotation: 0.0,
    xp: 0.0,
    speed: 30.0,
    radius: 20.0,
    jumpHeight: 200.0,
    state: Grounded,
    particles: @[]
  )
  result.initParticleSystem()

method init*(self: Player) {.base.} =
  self.position = Vector3(x: gGroundSize.x * 0.4, y: gGroundSize.y + 40, z: gGroundSize.z * 0.5)
  self.velocity = Vector3()
  self.rotation = 0.0
  self.xp = 0.0
  self.speed = 30.0
  self.radius = 20.0
  self.jumpHeight = 200.0
  self.state = Grounded
  self.particles = @[]
  self.initParticleSystem()


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
  
  if result.z == 0 and result.x == 0 and isMouseButtonDown(MouseButton.Left):
    let mouseRay = getScreenToWorldRay(getMousePosition(), gCamera)
    let collision = getRayCollisionBox(mouseRay, getBoundingBox(self.position, self.radius))
    result.x = collision.normal.x
    result.z = -(collision.normal.y + 0.5) + (collision.normal.z + 0.5)

proc updateVelocity*(self: Player, dt: float) =
  let dir = self.getDirection()
  self.velocity.x = dir.x * self.speed * dt
  self.velocity.z = dir.z * self.speed * dt
  
  if self.state != Grounded:
    self.velocity.y -= gravity * dt
  elif isKeyDown(KeyboardKey.Space):
    self.velocity.y = self.jumpHeight * dt
    self.state = Jumping

proc spawnParticle(self: Player) =
  if self.particles.len < MAX_PARTICLES:
    let angle = rand(0.0 .. 2*PI)
    let distance = rand(self.radius .. self.radius * 1.2)
    let isFlame = rand(1.0) < FLAME_TO_SMOKE_RATIO
    let particle = Particle(
      position: Vector2(
        x: self.position.x + cos(angle) * distance,
        y: self.position.z + sin(angle) * distance
      ),
      velocity: Vector2(x: rand(-10.0 .. 10.0), y: rand(-60.0 .. -40.0)),
      size: rand(PARTICLE_SIZE_RANGE[0] .. PARTICLE_SIZE_RANGE[1]),
      color: if isFlame: Color(r: 255, g: uint8(rand(100 .. 255)), b: 0, a: 255)
             else: Color(r: 200, g: 200, b: 200, a: 200),
      lifetime: 0,
      maxLifetime: rand(PARTICLE_LIFETIME_RANGE[0] .. PARTICLE_LIFETIME_RANGE[1]),
      state: if isFlame: Flame else: Smoke
    )
    self.particles.add(particle)

method draw*(self: Player) {.base.} =
  drawSphere(self.position, self.radius, WHITE)

  beginBlendMode(BlendMode.Additive)
  for particle in self.particles:
    drawTexture(
      self.particleTexture,
      Vector2(x: particle.position.x - particle.size/2, y: particle.position.y - particle.size/2),
      0,
      particle.size / self.particleTexture.width.float,
      particle.color
    )
  endBlendMode()

proc updateParticles(self: Player, dt: float) =
  for i in countdown(self.particles.high, 0):
    var particle = self.particles[i]
    particle.lifetime += dt
    if particle.lifetime >= particle.maxLifetime:
      self.particles.del(i)
    else:
      particle.position.x += particle.velocity.x * dt
      particle.position.y += particle.velocity.y * dt
      let lifeRatio = particle.lifetime / particle.maxLifetime
      
      if particle.state == Flame and lifeRatio > 0.5:
        particle.state = Smoke
        particle.color = Color(r: 200, g: 200, b: 200, a: 200)
      
      particle.color.a = uint8((1 - lifeRatio) * 255)
      particle.velocity.y *= 0.98  # Slow down vertical movement
      self.particles[i] = particle

  let particlesToSpawn = int(PARTICLE_SPAWN_RATE * dt)
  for _ in 0..<particlesToSpawn:
    self.spawnParticle()

method update*(self: Player, dt: float) {.base.} =
  if self.state != Frozen:
    self.updateVelocity(dt)

    let newPos = Vector3(
      x: self.position.x + self.velocity.x,
      y: self.position.y + self.velocity.y,
      z: self.position.z + self.velocity.z
    )
    let diameter = self.radius * 2
    
    if newPos.x - diameter > 0 and newPos.x + diameter < gGroundSize.x:
      self.position.x = newPos.x
    if newPos.z - diameter > 0 and newPos.z + diameter < gGroundSize.z - tileSize * 0.5:
      self.position.z = newPos.z
    self.position.y = newPos.y

  self.updateParticles(dt)
