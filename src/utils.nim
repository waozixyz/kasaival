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


