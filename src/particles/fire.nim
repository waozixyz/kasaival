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
    color: array[0..3, uint8]
    color_start: array[0..3, uint8]
    color_end: array[0..3, uint8]

  Fire* = ref object of RootObj
    currentAmount: int = 0
    amount: int = 70
    lifetime: float = 40
    scale: float = 1
    radius: float = 14
    color_start: array[0..3, uint8] = [200, 50, 80, 200]
    color_end: array[0..3, uint8] = [120, 30, 60, 20]
    particles = @[Particle()]


method init*(self: Fire) {.base.} =
  randomize()

proc getColorEnd(self: Fire): array[0..3, uint8] =
  var rtn = self.color_end;
  rtn[0] -= uint8(rand(0..40))
  rtn[1] -= uint8(rand(0..20))
  rtn[2] -= uint8(rand(0..20))
  rtn[3] -= uint8(rand(0..20))
  return rtn;
  
method getRadius*(self: Fire): float {.base.} =
  return self.radius * self.scale;

method getParticle(self: Fire, position: Vector2): Particle {.base.} =
  let vel_x = rand(-3.0..3.0) * self.scale
  let vel_x_end = (rand(-2.0..2.0) - vel_x) * self.scale
  let shrink_factor = rand(90.0..95.0) * 0.01
  let size = self.radius * self.scale;
  let vel_y = -4 * self.scale;
  var p = Particle(
    size: size,
    lifetime: self.lifetime,
    start_y: int(position.y),
    position: position,
    vel_start: Vector2( x: vel_x, y: vel_y),
    vel_end: Vector2( x: vel_x_end, y: vel_y),
    color: self.color_start,
    color_start: self.color_start,
    color_end: get_color_end(self),
    shrink_factor: shrink_factor,
  )
  return p

method updateColors(self: Fire, p: var Particle, pp: float) {.base.} =
  p.color[0] = uint8(float(self.color_start[0]) * pp + float(self.color_end[0]) * (1 - pp));
  p.color[1] = uint8(float(self.color_start[1]) * pp + float(self.color_end[1]) * (1 - pp));
  p.color[2] = uint8(float(self.color_start[2]) * pp + float(self.color_end[2]) * (1 - pp));
  p.color[3] = uint8(float(self.color_start[3]) * pp + float(self.color_end[3]) * (1 - pp));

        
method update*(self: Fire, position: Vector2) {.base.} =
  if (self.currentAmount < self.amount):
    var p = self.getParticle(position)
    self.particles.add(p)
    self.currentAmount += 1

  for i in 0..self.currentAmount:
    var p = self.particles[i]
    if (p.lifetime <= 0):
      p = self.getParticle(position)
    
    var pp = p.lifetime / self.lifetime
    if (pp > 0):
      p.position.x += p.vel_start.x * pp + p.vel_end.x * (1 - pp)
      p.position.y += p.vel_start.y * pp + p.vel_end.y * (1 - pp)
      self.updateColors( p, pp)

      p.size *= p.shrink_factor
    p.lifetime -= 1
    self.particles[i] = p
  
proc u8ToColor(color: array[0..3, uint8]): Color =
  return Color(r: color[0], g: color[1], b: color[2], a: color[3])

method draw*(self: Fire) {.base.} =
  for p in self.particles:
    drawCircle(p.position, p.size, u8ToColor(p.color))
 

method unload*(self: Fire) {.base.} =
  discard
