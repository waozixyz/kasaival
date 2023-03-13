import raylib, std/random, ../utils, std/math, ../screens

type
  Branch = object
    deg: int
    v1, v2: Vector2
    w, h: float
    color: Color
    orgColor: Color
  Leaf = object
    row: int
    v1, v2: Vector2
    r: float
    color: Color
    orgColor: Color
  Plant* = object 
    branches: seq[seq[Branch]]
    leaves: seq[Leaf]
    leafChance: float = 0.5
    maxRow: int = 5
    currentRow: int = 0
    splitChance: int = 40
    splitAngle: array[2,int] = [20,30]
    csBranch: array[6,uint8]= [ 125, 178, 122, 160, 76, 90 ]
    csLeaf: array[6,uint8] = [ 150, 204, 190, 230, 159, 178 ]
    leftBound*: float = 9999999
    rightBound*: float = -9999999
    growTimer: float = 0
    growTime: float = 20
    scale: float = 1
    w: float = 10
    h: float = 15
    startY*: float = 0
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
      
method addBranch(self: var Plant, deg: int, b: Branch) {.base.} =
  let bw = b.w * 0.9
  let bh = b.h * 0.95
  let px = b.v2.x
  let py = b.v2.y
  let nx = px + getRotX(deg) * bh;
  let ny = py + getRotY(deg) * bh;
  var c = getColor(self.csBranch)
  let v1 = Vector2(x: px, y: py)
  let v2 = Vector2(x: nx, y: ny)
  self.branches[self.currentRow + 1].add(Branch(deg: deg, v1: v1, v2: v2, w: bw, h: bh, color: c, orgColor: c))
  var chance = clamp((rand(0.0..100.0) / 100.0) * float(self.currentRow) / float(self.maxRow), 0.0, self.leafChance)
                      
  if chance > self.leaf_chance:
    let divX = getRotX(deg * 2) * bw;
    let divY = getRotY(deg * 2) * bw;
    c = getColor(self.csLeaf)
    self.leaves.add(Leaf(row: self.currentRow, r: bw, v1: Vector2(x: nx+divX, y: ny+divY), v2: Vector2( x: nx-divX, y: ny-divY), color: c, orgColor: c))

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
  let c = getColor(self.csBranch)
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
  if self.growTimer > 0.0:
    self.growTimer -= 100.0 * dt
  elif self.currentRow < self.maxRow:
    self.grow()
    self.growTimer = self.growTime


  for i, row in self.branches:
    for j, branch in row:
      var (r, g, b) = (branch.color.r, branch.color.g, branch.color.b)
      if self.burnTimer > 0:
        r = uint8(min(220, int(r) + 5))
        g = uint8(max(0, int(g) - 5))
        b = uint8(max(0, int(b) - 2))
        self.burnTimer -= 5.0 * dt
      else:
        if r > branch.orgColor.r:
          r = max(branch.orgColor.r, r - 2)
      self.branches[i][j].color = Color(r: r, g: g, b: b, a:255)
method draw*(self: Plant) {.base.} =
  for i, row in self.branches:
    for b in row:
      var v2 = b.v2
      if i == self.currentRow and self.growTimer > 0.0:
        v2 = Vector2(x: self.getNextPos(b.v1.x, v2.x), y: self.getNextPos(b.v1.y, v2.y))
      drawLine(b.v1, v2, b.w, b.color)

    for l in self.leaves:
      if l.row < i and not (i == self.currentRow and self.growTimer > 0.0):
        drawCircle(l.v1, l.r, l.color)
        drawCircle(l.v2, l.r, l.color)
