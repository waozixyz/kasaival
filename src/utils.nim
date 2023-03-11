import raylib

proc getMinMax*(vertices: array[0..2, Vector2]; dir: int): (float, float) =
  var minVal = if dir == 0: vertices[0].x else: vertices[0].y
  var maxVal = if dir == 0: vertices[0].x else: vertices[0].y

  for v in vertices:
    let val = if dir == 0: v.x else: v.y
    if val < minVal:
      minVal = val
    elif val > maxVal:
      maxVal = val
    return (float(minVal), float(maxVal))

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
  let tolerance = 0.6

  # check if the line segments intersect
  if denom.abs() > 0.00001:
    let t = numT / denom
    let u = -numU / denom
    if abs(t) < tolerance and abs(u) < tolerance:
      return true

  return false
  
proc isCollided*(minX, minY, maxX, maxY, objX, objY, objW, objH: float): bool =
  let pw = (maxX - minX) / 2.0
  let ph = (maxY - minY) / 2.0
  let cx = minX + pw
  let cy = minY + ph

  # check if the two AABBs overlap
  if abs(cx - objX) > (pw + objW) or abs(cy - objY) > (ph + objH):
    return false

  # check if the two OBBs overlap
  return doLineSegmentsIntersect(
      minX, minY, maxX, minY,
      objX - objW / 2.0, objY + objH / 2.0, objX + objW / 2.0, objY + objH / 2.0) or
      doLineSegmentsIntersect(
      maxX, minY, maxX, maxY,
      objX + objW / 2.0, objY + objH / 2.0, objX + objW / 2.0, objY - objH / 2.0) or
      doLineSegmentsIntersect(
      maxX, maxY, minX, maxY,
      objX + objW / 2.0, objY - objH / 2.0, objX - objW / 2.0, objY - objH / 2.0) or
      doLineSegmentsIntersect(
      minX, maxY, minX, minY,
      objX - objW / 2.0, objY - objH / 2.0, objX - objW / 2.0, objY + objH / 2.0)
