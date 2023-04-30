import raylib, std/random

type
  Particle* = object
    startY*: float
    position: Vector2
    lifetime: float
    velStart: Vector2
    velEnd: Vector2
    shrinkFactor: float
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
    velocity*: Vector2
    position*: Vector2
    colorStart*: array[0..3, uint8] = [200, 60, 50, 200]
    colorEnd*: array[0..3, uint8] = [120, 0, 100, 20]
    particles* = @[Particle()]


method init*(self: Fire) {.base.} =
  randomize()

proc getColorEnd(self: Fire): array[0..3, uint8] =
  var rtn = self.colorEnd
  for i in 0..3:
    rtn[i] -= uint8(rand(0..20))
  rtn[0] -= uint8(rand(0..20))
  return rtn

  
method getRadius*(self: Fire): float {.base.} =
  return self.radius * self.scale

method getParticle(self: Fire): Particle {.base.} =
  let velX = rand(-3.0..3.0) * self.scale
  let velXEnd = velX * -1 + rand(-3.0..3.0) * self.scale
  let shrinkFactor = rand(92.0..95.0) * 0.0105
  let size = self.radius * self.scale;
  let velY = (-4 * self.scale) + abs(self.velocity.x) * 0.7
  let velYEnd = -(rand(3.0..5.0) * self.scale)
  var p = Particle(
    size: size,
    lifetime: self.lifetime,
    startY: self.position.y,
    position: self.position,
    velStart: Vector2( x: velX, y: velY),
    velEnd: Vector2( x: velXEnd, y: velYEnd),
    color: Color(),
    colorStart: self.colorStart,
    colorEnd: getColorEnd(self),
    shrinkFactor: shrinkFactor,
  )
  return p

proc updateColors(p: Particle, pp: float): Color =
  var colors: array[0..3, uint8]
  for i in 0 ..< p.colorStart.len:
    colors[i] = uint8(float(p.colorStart[i]) * pp + float(p.colorEnd[i]) * (1 - pp))
  
  return Color(r: colors[0], g: colors[1], b: colors[2], a: colors[3])

# Updates the state of the `Fire` emitter given a new position
method update*(self: Fire) {.base.} =
  # Create new particle if the maximum capacity has not been reached yet
  if self.currentAmount < self.amount:
    var p = self.getParticle()
    self.particles.add(p)
    self.currentAmount += 1

  # Update each particle
  for i in 0..(self.currentAmount - 1):   # Updated the loop limits since the index starts from 0
    var p = self.particles[i]
    
    # Regenerate particle if its lifetime has ended
    if p.lifetime <= 0:
      p = self.getParticle()

    var pp = p.lifetime.float / self.lifetime.float   # Convert to float before dividing for proper division 
    if pp > 0:
      # Update particle attributes based on its remaining lifetime
      p.position = Vector2(
        x: p.position.x + (p.velStart.x * pp) + (p.velEnd.x * (1.0 - pp)),
        y: p.position.y + (p.velStart.y * pp) + (p.velEnd.y * (1.0 - pp))
      )
      p.color = updateColors(p, pp)
      p.size *= p.shrinkFactor
     
    p.lifetime -= 1
    self.particles[i] = p  # Assign back the updated particle

  
method draw*(self: Fire, i: int) {.base.} =
  let p = self.particles[i]
  drawCircle(p.position, p.size, p.color)
 

