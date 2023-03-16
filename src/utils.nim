import raylib, std/math, std/random

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

proc deg2rad*(degrees: float): float =
  result = degrees * PI / 180.0


proc getCustomColorSchema*(cs: array[0..5, float]): array[0..2, float] =
  for i in 0..2:
    var
      a = min(cs[i * 2], cs[i * 2 + 1])
      b = max(cs[i * 2], cs[i * 2 + 1])
    result[i] = rand(a..b)
  return result



proc uint8ToColor*(color: array[0..2, float], alpha: float): Color =
  result =  Color(
    r: uint8(color[0]),
    g: uint8(color[1]),
    b: uint8(color[2]),
    a: uint8(alpha))