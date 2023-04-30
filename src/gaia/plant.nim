import raylib, std/random, ../utils, std/math, ../screens

type
  Branch = object
    deg: int
    v1, v2: Vector2
    w, h: float
    color: array[0..2, float]
    orgColor: array[0..2, float]
    leaves: seq[Leaf]
  Leaf = object
    v1, v2: Vector2
    r: float
    color: array[0..2, float]
    orgColor: array[0..2, float]
  Plant* = object 
    branches: seq[seq[Branch]]
    leafChance: float = 0.5
    maxRow: int = 5
    currentRow: int = 0
    splitChance: int = 40
    splitAngle: array[0..1, int] = [20,30]
    csLeaf: array[0..5, float] = [ 150, 244, 150, 250, 99, 128 ]
    leftBound*: float = 9999999
    rightBound*: float = -9999999
    growTimer: float = 0
    growSpeed: float = 2
    burnSpeed: float = 4
    scale: float = 1.0
    branchFuel: float = 2
    w: float = 10
    h: float = 15
    startY*: float = 0
    growing: bool = true
    burnTimer*: float = 0.0
    dead*: bool = false
    reviving: bool = false
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
  let bw = b.w * 0.9
  let bh = b.h * 0.95
  let px = b.v2.x
  let py = b.v2.y
  let nx = px + getRotX(deg) * bh;
  let ny = py + getRotY(deg) * bh;
  var c = [
    getRandomColor(b.color[0], rand(0.0..15.0)),
    getRandomColor(b.color[1], rand(0.0..20.0)),
    getRandomColor(b.color[2], rand(0.0..15.0))]

  let v1 = Vector2(x: px, y: py)
  let v2 = Vector2(x: nx, y: ny)
  self.branches[self.currentRow + 1].add(Branch(deg: deg, v1: v1, v2: v2, w: bw, h: bh, color: c, orgColor: c))
  let chance = clamp(rand(0.0..1.0) * float(self.currentRow) / float(self.maxRow), 0.0, self.leafChance)
  if chance == self.leafChance:
    let divX = getRotX(deg * 2) * bw;
    let divY = getRotY(deg * 2) * bw;
    let leafColor = getCustomColorSchema(self.csLeaf)
    c = [
      float(leafColor[0]),
      float(leafColor[1]),
      float(leafColor[2]),
    ]
    let currentBranch = self.branches[self.currentRow + 1].len - 1
    self.branches[self.currentRow + 1][currentBranch].leaves.add(Leaf( r: bw * 0.8, v1: Vector2(x: nx+divX, y: ny+divY), v2: Vector2( x: nx-divX, y: ny-divY), color: c, orgColor: c))

  if nx < self.leftBound:
    self.leftBound = nx
  elif nx > self.rightBound:
    self.rightBound = nx + bw
      
proc getZ*(self: Plant): float = 
  return self.startY

proc getNextPos(self: Plant, a: float, b: float): float = 
  return b + (a - b) * float(self.growTimer) / 1.0

proc increaseColor(channel: float, amount: float): float =
    result = min(255.0, max(0.0, channel + amount))

method grow*(self: var Plant) {.base.} =
  doAssert self.currentRow < self.max_row, "Plants cannot grow anymore"
    
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

method init*(self: var Plant, x: float, y: float, randomRow: bool) {.base.} =
  self.startY = y
  var scale = getYScale(y)
  self.w = 20 * scale
  self.h = 32 * scale
  var angle = -90

  # add the first branch at angle 90
  let vertices = (Vector2(x: x, y: y), Vector2(x: x, y: y - self.h))
  let c = [rand(125.0..178.0), rand(162.0..230.0), rand(76.0..90.0)]
  let branch = Branch(deg: angle, v1: vertices[0], v2: vertices[1], w: self.w, h: self.h, color: c, orgColor: c)
  self.leftBound = x
  self.rightBound = x + self.w
  self.branches.add(@[branch])

  # grow tree to random row if necessary
  if randomRow:
    var growToRow = rand(0..self.maxRow)
    while self.currentRow < growToRow:
      self.grow()

method shrink*(self: var Plant) {.base.} =
  if self.currentRow == 0:
    self.dead = true
  for i, b in self.branches[self.currentRow]:
    self.branches[self.currentRow].delete(i)
    playerFuel += self.branchFuel

  dec(self.currentRow)


proc burnColor(self: var Plant, dt: float, branchColor: array[0..2, float], org: array[0..2, float]): array[0..2, float] =
  var c = branchColor
  if self.burnTimer > 0.0:
    c[0] = min(220.0, c[0] + 600.0 * dt)
    c[1] = max(0.0, c[1] - 40.0 * dt)
    c[2] = max(0.0, c[2] - 180.0 * dt)
  elif not self.growing:
    if c[0] > org[0] - 30: 
      c[0] = max(0, c[0] - 30.0 * dt)
    if c[1] < org[1] - 150:
      c[1] = min(2.0, c[1] - 120 * dt)
  if self.reviving:
    if c[1] < org[1]:
      c[1] += 120 * dt

  return c

method update*(self: var Plant, dt: float)  {.base.}  =  
  if self.alpha < 1:
    self.dead = true

  if self.dead: 
    return
    


  # If the plant is burning, reduce its size and stop growth
  if self.burnTimer > 0:
    self.growing = false
    self.burnTimer -= 5.0 * dt

    if self.growTimer > 1:
      self.shrink()
      self.growTimer = 0
    else:
      self.growTimer += self.burnSpeed * dt

  if not self.growing and not self.reviving:
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
      
      # Loop through all leafs to update leaf color
      for k, leaf in branch.leaves:
        let leafColor = leaf.color
        let leafOrgCol = leaf.orgColor
        self.branches[i][j].leaves[k].color = self.burnColor(dt, leafColor, leafOrgCol)
        
      # Check if the plant should start growing again if it was previously burnt
      if self.burnTimer <= 0 and color[0] < 100 and color[1] > 100:
        self.reviving = true
        self.decayTimer = 0
        if color[2] > 200:
          self.growing = true
          self.reviving = false
          

  # If the plant is able to grow, increase its size and update the timer
  if self.growing:
    if self.growTimer > 0.0:
      self.growTimer -= self.growSpeed * dt
    elif self.currentRow < self.maxRow:
      self.grow()
      self.growTimer = 1

method draw*(self: Plant) {.base.} =
  if self.dead: return
  for i, row in self.branches:
    for b in row:
      var v2 = b.v2
      if i == self.currentRow and self.growTimer > 0.0:
        v2 = Vector2(x: self.getNextPos(b.v1.x, v2.x), y: self.getNextPos(b.v1.y, v2.y))
      drawLine(b.v1, v2, b.w, uint8ToColor(b.color, self.alpha))

      for l in b.leaves:
        var radius = l.r
        if i == self.currentRow and self.growTimer > 0.0:
          radius = self.getNextPos(0.0, l.r)
        drawCircle(l.v1, radius, uint8ToColor(l.color, self.alpha))
  