import raylib

const 
	deg_to_rad = math.pi / 180.0 

type
  Branch = object
    deg: int
    v1, v2: Vector2
    w, h: float
    color: Color
  Leaf = object
    row: usize
    v1, v2: Vector2
    r: float
    color: Color
  Plant = object 
    branches: seq[Branch]
    leaves: seq[Leaf]
    leafChance: float = 0.5
    maxRow: int = 5
    currentRow: int = 0
    splitChance: int = 40
    splitAngle: array[2,int] = [20,30]
    csBranch: array[6,uint8]= [ 125, 178, 122, 160, 76, 90 ]
    csLeaf: array[6,uint8] = [ 150, 204, 190, 230, 159, 178 ]
    leftX: float = 9999999
    rightX: float = -9999999
    growTimer: int = 0
    growTime: int = 20
    scale: float = 1
    w: float = 10
    h: float = 15
    startY: float = 0

proc getColor(cs: array[0..5, uint8]): Color =
	var r = cast[uint8](rand(cs[0]..cs[1]))
	var b = cast[uint8](rand(cs[2]..cs[3]))
	var g = cast[uint8](rand(cs[4]..cs[5]))
	return(Color(r, g, b, 255))

proc getRotX(deg: int): float = 
	return math.cos(deg.toFloat() * deg_to_rad)

proc getRotY(deg: int): float = 
	return math.sin(deg.toFloat() * deg_to_rad)

method getAngle(self: Plant): int =
  return random( self.splitAngle[0]..self.splitAngle[1] )
      
method addBranch(self: var Plant, deg: int, b: var Branch) =
  let bw = b.w * 0.9
  let bh = b.h * 0.95
  let px = b.v2.x
  let py = b.v2.y
  let nx = px + getRotX(deg) * bh;
  let ny = py + getRotY(deg) * bh;
  var c = getColor(self.csBranch)

  self.branches.add(Branch(deg,n1,n2,bw,bh,c))
  var chance = clamp(((rand(100) as float) / 100.0) * (self.currentRow as float) / (self.maxRow as float), 0.0, self.leafChance)
                      
  if chance > self.leaf_chance:
    let divX = getRotX(deg * 2) * bw;
    let divY = getRotY(deg * 2) * bw;
    self.leaves.add(Leaf(row: self.currentRow, r: bw, v1: Vector2(nx+divX, ny+divY), v2: Vector2(nx-divX, ny-divY),color:getColor(self.cs_leaf)))

  if nx < self.left_x:
    self.left_x = nx
  elif nx > self.right_x:
    self.right_x = nx + bw
      
proc getZ(p: Plant): float32 = 
    p.branches[0][0].v1.y
  
proc getNextPos(p: Plant, a: float32, b: float32): float32 = 
    b + (a - b) * float32(p.grow_timer) / float32(p.grow_time)
    
proc grow(p: Plant, allocator: Allocator) =
  doAssert p.currentRow < p.max_row, "Plants cannot grow anymore"
    
  let prewRow = p.branches[p.currentRow]
  for prewRow, i in 0 ..< len(prevRow):
    let mut branch = prewRow[i]
    let split = rl.GetRandomValue(0, 100)
    if p.split_chance > split:
      p.addBranch(branch.deg - p.getAngle(), branch)
      p.addBranch(branch.deg + p.getAngle(), branch)
    else:
      p.addBranch(branch.deg, branch)
  
  inc(p.currentRow)

  