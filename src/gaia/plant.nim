import raylib, std/random, ../utils, std/math, ../screens

type
  Branch = object
    deg: int
    v1, v2: Vector2
    w, h: float
    color: Color
    orgColor: Color
    leaves: seq[Leaf]
  Leaf = object
    v1, v2: Vector2
    r: float
    color: Color
    orgColor: Color
  Plant* = object 
    branches: seq[seq[Branch]]
    leafChance: float = 0.5
    maxRow: int = 5
    currentRow: int = 0
    splitChance: int = 40
    splitAngle: array[0..1, int] = [20,30]
    csLeaf: array[6,uint8] = [ 150, 244, 150, 250, 99, 128 ]
    leftBound*: float = 9999999
    rightBound*: float = -9999999
    growTimer: float = 0
    growTime: float = 20
    scale: float = 1
    w: float = 10
    h: float = 15
    startY*: float = 0
    growing: bool = true
    burnTimer*: float = 0.0


proc getColor(cs: array[0..5, uint8]): Color =
  var c = getCustomColorSchema(cs)

  return Color(r: c[0], g: c[1], b: c[2], a: 255)

proc getRotX(deg: int): float = 
  return cos(deg2rad(float(deg)))

proc getRotY(deg: int): float = 
  return sin(deg2rad(float(deg)))

method getAngle(self: Plant): int {.base.} =
  return rand( self.splitAngle[0]..self.splitAngle[1] )

proc getRandomUint8(baseUint8: uint8, randRange: int): uint8 =
  ## Returns a random uint8 within range of `randRange` added to base `uint8`
  result = uint8(min(255, max(0, int(baseUint8) + rand(-randRange..randRange))))
  
method addBranch(self: var Plant, deg: int, b: Branch) {.base.} =
  let bw = b.w * 0.9
  let bh = b.h * 0.95
  let px = b.v2.x
  let py = b.v2.y
  let nx = px + getRotX(deg) * bh;
  let ny = py + getRotY(deg) * bh;
  
  var c = Color(
    r: getRandomUint8(b.color.r, rand(0..15)),
    g: getRandomUint8(b.color.g, rand(0..20)),
    b: getRandomUint8(b.color.b, rand(0..15)),
    a: 255
  )

  let v1 = Vector2(x: px, y: py)
  let v2 = Vector2(x: nx, y: ny)
  self.branches[self.currentRow + 1].add(Branch(deg: deg, v1: v1, v2: v2, w: bw, h: bh, color: c, orgColor: c))
  var chance = clamp(rand(0.0..1.0) * float(self.currentRow) / float(self.maxRow), 0.0, self.leafChance)
  if chance == self.leafChance:
    let divX = getRotX(deg * 2) * bw;
    let divY = getRotY(deg * 2) * bw;
    c = getColor(self.csLeaf)
    var currentBranch = self.branches[self.currentRow + 1].len - 1
    self.branches[self.currentRow + 1][currentBranch].leaves.add(Leaf( r: bw * 0.8, v1: Vector2(x: nx+divX, y: ny+divY), v2: Vector2( x: nx-divX, y: ny-divY), color: c, orgColor: c))

  if nx < self.leftBound:
    self.leftBound = nx
  elif nx > self.rightBound:
    self.rightBound = nx + bw
      
proc getZ*(self: Plant): float = 
  return float(self.branches[0][0].v1.y)
  
proc getNextPos(self: Plant, a: float, b: float): float = 
  return b + (a - b) * float(self.growTimer) / float(self.growTime)
    
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

method init*(self: var Plant, x: float, y: float, randomRow: bool) {.base.} =
  self.startY = y
  var scale = y / screenHeight
  self.w = 20 * scale
  self.h = 32 * scale
  var angle = -90


  # add the first branch at angle 90
  let vertices = (Vector2(x: x, y: y), Vector2(x: x, y: y - self.h))
  let c = Color(r: uint8(rand(125..178)),g: uint8(rand(122..160)),b: uint8(rand(76..90)))
  let branch = Branch(deg: angle, v1: vertices[0], v2: vertices[1], w: self.w, h: self.h, color: c, orgColor: c)
  self.leftBound = x
  self.rightBound = x + self.w
  self.branches.add(@[branch])
  # set up grow time
  self.growTimer = rand(0.0..self.growTime)

  # grow tree to random row if necessary
  if randomRow:
    var growToRow = rand(0..self.maxRow)
    while self.currentRow < growToRow:
      self.grow()

method update*(self: var Plant, dt: float) {.base.} =
  for i, row in self.branches:
    for j, branch in row:
      var (r, g, b) = (branch.color.r, branch.color.g, branch.color.b)
      for k, leaf in branch.leaves:
        var (r, g, b) = (leaf.color.r, leaf.color.g, leaf.color.b)
        if self.burnTimer > 0:
          r = uint8(min(220, int(r) + 5))
          g = uint8(max(0, int(g) - 5))
          b = uint8(max(0, int(b) - 2))
        else:
          if r > leaf.orgColor.r:
            r = max(leaf.orgColor.r, r - 2)
        self.branches[i][j].leaves[k].color = Color(r: r, g: g, b: b, a:255)

      if self.burnTimer > 0:
        self.growing = false
        r = uint8(min(220, int(r) + 5))
        g = uint8(max(0, int(g) - 5))
        b = uint8(max(0, int(b) - 2))
        self.burnTimer -= 5.0 * dt
      else:
        if r < 50:
          self.growing = true
        if r > branch.orgColor.r:
          r = max(branch.orgColor.r, r - 2)
      self.branches[i][j].color = Color(r: r, g: g, b: b, a:255)

  if self.growing:
    if self.growTimer > 0.0:
      self.growTimer -= 100.0 * dt
    elif self.currentRow < self.maxRow:
      self.grow()
      self.growTimer = self.growTime
method draw*(self: Plant) {.base.} =
  for i, row in self.branches:
    for b in row:
      var v2 = b.v2
      if i == self.currentRow and self.growTimer > 0.0:
        v2 = Vector2(x: self.getNextPos(b.v1.x, v2.x), y: self.getNextPos(b.v1.y, v2.y))
      drawLine(b.v1, v2, b.w, b.color)

      for l in b.leaves:
        var radius = l.r
        if i == self.currentRow and self.growTimer > 0.0:
          radius = self.getNextPos(0.0, l.r)
        drawCircle(l.v1, radius, l.color)
  