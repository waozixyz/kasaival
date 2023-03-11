import raylib, std/random

type
  Particle* = object
    start_y: int
    position: Vector2
    lifetime: float
    vel_start: Vector2
    vel_end: Vector2
    shrink_factor: float
    size: float
    color: Color
    colorStart: array[0..3, uint8]
    colorEnd: array[0..3, uint8]

  Fire* = ref object of RootObj
    currentAmount: int = 0
    amount: int = 70
    lifetime: float = 40
    scale*: float = 1
    radius: float = 14
    colorStart: array[0..3, uint8] = [200, 60, 50, 200]
    colorEnd: array[0..3, uint8] = [120, 0, 100, 20]
    particles = @[Particle()]


method init*(self: Fire) {.base.} =
  randomize()

proc getColorEnd(self: Fire): array[0..3, uint8] =
  var rtn = self.colorEnd;
  rtn[0] -= uint8(rand(0..40))
  rtn[1] -= uint8(rand(0..20))
  rtn[2] -= uint8(rand(0..20))
  rtn[3] -= uint8(rand(0..20))
  return rtn;
  
method getRadius*(self: Fire): float {.base.} =
  return self.radius * self.scale;

method getParticle(self: Fire, position: Vector2): Particle {.base.} =
  let vel_x = rand(-3.0..3.0) * self.scale
  let vel_x_end = vel_x * -1 + rand(-3.0..3.0) * self.scale
  let shrink_factor = rand(92.0..95.0) * 0.01
  let size = self.radius * self.scale;
  let vel_y = -4 * self.scale;
  let vel_y_end = vel_y + (rand(3.0..5.0) * self.scale)
  var p = Particle(
    size: size,
    lifetime: self.lifetime,
    start_y: int(position.y),
    position: position,
    vel_start: Vector2( x: vel_x, y: vel_y),
    vel_end: Vector2( x: vel_x_end, y: vel_y_end),
    color: Color(),
    colorStart: self.colorStart,
    colorEnd: getColorEnd(self),
    shrink_factor: shrink_factor,
  )
  return p

proc updateColors(p: Particle, pp: float): Color =
  var colors: array[0..3, uint8]
  for i in 0 ..< p.colorStart.len:
    colors[i] = uint8(float(p.colorStart[i]) * pp + float(p.colorEnd[i]) * (1 - pp))
  
  return Color(r: colors[0], g: colors[1], b: colors[2], a: colors[3])

# Updates the state of the `Fire` emitter given a new position
method update*(self: Fire, position: Vector2) {.base.} =
  # Create new particle if the maximum capacity has not been reached yet
  if self.currentAmount < self.amount:
    var p = self.getParticle(position)
    self.particles.add(p)
    self.currentAmount += 1

  # Update each particle
  for i in 0..(self.currentAmount - 1):   # Updated the loop limits since the index starts from 0
    var p = self.particles[i]
    
    # Regenerate particle if its lifetime has ended
    if p.lifetime <= 0:
      p = self.getParticle(position)

    var pp = p.lifetime.float / self.lifetime.float   # Convert to float before dividing for proper division 
    if pp > 0:
      # Update particle attributes based on its remaining lifetime
      p.position = Vector2(
        x: p.position.x + (p.vel_start.x * pp) + (p.vel_end.x * (1.0 - pp)),
        y: p.position.y + (p.vel_start.y * pp) + (p.vel_end.y * (1.0 - pp))
      )
      p.color = updateColors(p, pp)
      p.size *= p.shrink_factor
     
    p.lifetime -= 1
    self.particles[i] = p  # Assign back the updated particle

  
method draw*(self: Fire) {.base.} =
  for p in self.particles:
    drawCircle(p.position, p.size, p.color)
 

method unload*(self: Fire) {.base.} =
  discard
