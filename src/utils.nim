import raylib

proc getMinMaxX*(vertices: array[0..2,Vector2]): (float, float) =
  var minX = vertices[0].x
  var maxX = vertices[0].x
  for v in vertices:
    if v.x < minX:
      minX = v.x
    elif v.x > maxX:
      maxX = v.x
  return (float(minX), float(maxX))


proc doLineSegmentsIntersect*(x1, y1, x2, y2, x3, y3, x4, y4: float): bool =
  # calculate the direction of the lines
  let dir1x = x2 - x1
  let dir1y = y2 - y1
  let dir2x = x4 - x3
  let dir2y = y4 - y3
  
  # calculate denominator and numerator for t 
  let denom = dir1x * dir2y - dir1y * dir2x
  let numT = (x1 - x3) * dir2y - (y1 - y3) * dir2x
  let numU = (x1 - x3) * dir1y - (y1 - y3) * dir1x
  # check if the line segments intersect
  if denom.abs() > 0.00001:
    let t = numT / denom
    let u = -numU / denom

    if abs(t) < 0.5 and abs(u) < 0.5:
      return true

  return false