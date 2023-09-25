import raylib, std/math, std/random

proc deg2rad*(degrees: float): float =
  result = degrees * PI / 180.0

proc getCustomColorSchema*(cs: array[0..5, float]): array[0..2, float] =
  result = [rand(min(cs[0], cs[1])..max(cs[0], cs[1])),
            rand(min(cs[2], cs[3])..max(cs[2], cs[3])),
            rand(min(cs[4], cs[5])..max(cs[4], cs[5]))]

proc clampuint8*(value: uint8, minVal: uint8 = 0, maxVal: uint8 = 255): uint8 =
  if value < minVal: return minVal
  elif value > maxVal: return maxVal
  else: return value


proc float2uint8*(num: float32): uint8 =
  if num > 255:
    result = 255
  elif num < 0:
    result = 0
  else:
    result = uint8(num)

proc uint8ToColor*(color: array[0..2, float], alpha: float): Color =
  result =  Color(
    r: uint8(float2uint8(color[0])),
    g: uint8(float2uint8(color[1])),
    b: uint8(float2uint8(color[2])),
    a: uint8(float2uint8(alpha)))


func addVectors*(a: Vector3, b: Vector3): Vector3 =
  result = Vector3(x: a.x + b.x, y: a.y + b.y, z: a.z + b.z)

func subtractVectors*(v1: Vector3, v2: Vector3): Vector3 =
  result = Vector3(x: v1.x - v2.x, y: v1.y - v2.y, z: v1.z - v2.z)

proc fillVector*(a: float): Vector3 =
  result = Vector3(x: a, y: a, z: a)
proc lerp*(a, b, t: float): float =
  result = a + (b - a) * t


proc uniform*(a, b: float): float =
  result = (b - a) * rand(0.0..1.0) + a

proc getBoundingBox*(position: Vector3, radius: float): BoundingBox =
  result = BoundingBox(min: Vector3(
    x: position.x - radius,
    y: position.y - radius,
    z: position.z - radius
  ),
  max: Vector3(
    x: position.x + radius,
    y: position.y + radius,
    z: position.z + radius
  ))

proc getBoundingBox*(position: Vector3, size: Vector3): BoundingBox =
  result = BoundingBox(min: Vector3(
    x: position.x - size.x,
    y: position.y - size.y,
    z: position.z - size.z
  ),
  max: Vector3(
    x: position.x + size.x,
    y: position.y + size.y,
    z: position.z + size.z
  ))

