import raylib, std/random, ../utils, std/math, ../state

type
  PlantStates* = enum
    Growing = 0, Mature, Burning, Reviving, Dead
  Branch = object
    deg: int
    position: Vector3
    size: Vector3
    color: array[0..2, float]
    orgColor: array[0..2, float]

  Plant* = object 
    init* = false
    state* = Growing
    position: Vector3
    size: Vector3 = Vector3(x: 10, y: 16, z: 10)
    branches: seq[seq[Branch]]
    maxRow: int = 5
    currentRow: int = 0
    splitChance: int = 40
    splitAngle: array[0..1, int] = [20,30]
    leftBound*: float
    rightBound*: float
    growTimer: float = 0
    growSpeed: float = 2
    burnSpeed: float = 20
    branchFuel: float = 2
    burnTimer*: float = 0.0
    decayTimer: float = 0.0
    alpha: float = 255.0

proc getRotX(deg: int): float = 
  return cos(deg2rad(float(deg)))

proc getRotY(deg: int): float = 
  return sin(deg2rad(float(deg)))

method getAngle(self: Plant): int {.base.} =
  return rand( self.splitAngle[0]..self.splitAngle[1] )

proc getRandomColor(color: float, randRange: float): float =
  ## Returns a random uint8 within range of `randRange` added to base `uint8`
  result = min(255.0, max(0.0, color + rand(-randRange..randRange)))
  
method addBranch(self: var Plant, deg: int, b: Branch) {.base.} =
  let size = Vector3(x: b.size.x * 0.9, y: b.size.y * 0.95, z: b.size.z * 0.9)
  var pos = b.position
  pos.y += b.size.y
  var new_pos = pos
  new_pos.x += getRotX(deg) * size.y;
  new_pos.y += getRotY(deg) * size.y;

  var c = [
    getRandomColor(b.color[0], rand(0.0..15.0)),
    getRandomColor(b.color[1], rand(0.0..20.0)),
    getRandomColor(b.color[2], rand(0.0..15.0))]

  self.branches[self.currentRow + 1].add(Branch(deg: deg, position: pos, size: size, color: c, orgColor: c))
  
  if new_pos.x < self.leftBound:
    self.leftBound = new_pos.x
  elif new_pos.x > self.rightBound:
    self.rightBound = new_pos.x + size.x

proc increaseColor(channel: float, amount: float): float =
    result = min(255.0, max(0.0, channel + amount))

method grow*(self: var Plant) {.base.} =
  doAssert self.currentRow < self.max_row, "Plant cannot grow anymore"
    
  let prevRow = self.branches[self.currentRow]
  for i in 0..prevRow.len - 1:
    self.branches.add(@[])
    var branch = prevRow[i]
    let split = rand(0..100)
    if self.splitChance > split:
      self.addBranch(branch.deg - self.getAngle(), branch)
      self.addBranch(branch.deg + self.getAngle(), branch)
    else:
      self.addBranch(branch.deg, branch)
  
  inc(self.currentRow)


  for i, row in self.branches:
    for j, b in row:
      self.branches[i][j].color[1] = increaseColor(b.orgColor[1], +2.0)
      self.branches[i][j].orgColor[1] = increaseColor(b.orgColor[1], -8.0)
      self.branches[i][j].orgColor[0] = increaseColor(b.orgColor[0], +5.0)
      self.branches[i][j].color[0] = increaseColor(b.color[0], +5.0)

method init*(self: var Plant, position: Vector3, randomRow: bool) {.base.} =
  self.position = position

  var angle = -90

  # add the first branch at angle 90
  let c = [rand(125.0..178.0), rand(142.0..230.0), rand(76.0..120.0)]
  let branch = Branch(deg: angle, position: position, size: self.size, color: c, orgColor: c)
  self.leftBound = self.position.x
  self.rightBound = self.position.x + self.size.x
  self.branches.add(@[branch])

  # grow tree to random row if necessary
  if randomRow:
    var growToRow = rand(0..self.maxRow)
    while self.currentRow < growToRow:
      self.grow()
  self.init = true
method shrink*(self: var Plant) {.base.} =
  if self.currentRow == 0:
    self.state = Dead
  for i, b in self.branches[self.currentRow]:
    self.branches[self.currentRow].delete(i)
    gPlayerFuel += self.branchFuel

  dec(self.currentRow)


proc burnColor(self: var Plant, dt: float, branchColor: array[0..2, float], org: array[0..2, float]): array[0..2, float] =
  var c = branchColor
  if self.burnTimer > 0.0:
    c[0] = min(220.0, c[0] + 600.0 * dt)
    c[1] = max(0.0, c[1] - 40.0 * dt)
    c[2] = max(0.0, c[2] - 180.0 * dt)
  elif self.state != Growing:
    if c[0] > org[0] - 30: 
      c[0] = max(0, c[0] - 30.0 * dt)
    if c[1] < org[1] - 150:
      c[1] = min(2.0, c[1] - 120 * dt)
  if self.state == Reviving:
    if c[1] < org[1]:
      c[1] += 120 * dt

  return c

method update*(self: var Plant, dt: float)  {.base.}  =  
  if self.alpha < 1:
    self.state = Dead

  if self.state == Dead: 
    return
    
  # If the plant is burning, reduce its size and stop growth
  if self.burnTimer > 0:
    self.state = Burning
    self.burnTimer -= 5.0 * dt

    if self.growTimer > 1:
      self.shrink()
      self.growTimer = 0
    else:
      self.growTimer += self.burnSpeed * dt

  if self.state == Burning:
    self.decayTimer += dt

  # Loop through all branches and leaves, updating their colors based on burn timer
  for i, row in self.branches:
    for j, branch in row:
      let color = branch.color
      let orgColor = branch.orgColor
      
      # Update branch color
      if self.decayTimer > 50:
        var c = color
        c[0] = max(0, c[0] - 20 * dt)
        c[1] = max(0, c[1] - 20 * dt)
        c[2] = max(0, c[2] - 20 * dt)
        if self.alpha > 200:
          self.alpha = max(0, self.alpha - 2 * dt)
        else:
          self.alpha = max(0, self.alpha - 20 * dt)

        self.branches[i][j].color = c
        continue
      else:
        self.branches[i][j].color = self.burnColor(dt, color, orgColor)
      
     
      # Check if the plant should start growing again if it was previously burnt
      if self.burnTimer <= 0 and color[0] < 100 and color[1] > 100:
        self.state = Reviving
        self.decayTimer = 0
        if color[2] > 200:
          self.state = Growing
          

  # If the plant is able to grow, increase its size and update the timer
  if self.state == Growing:
    if self.growTimer > 0.0:
      self.growTimer -= self.growSpeed * dt
    elif self.currentRow < self.maxRow:
      self.grow()
      self.growTimer = 1

method draw*(self: Plant) {.base.} =
  if self.state == Dead: return
  for i, row in self.branches:
    for b in row:
      drawCube(b.position, b.size, uint8ToColor(b.color, self.alpha))
   