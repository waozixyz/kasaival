import raylib, std/math, std/random

proc deg2rad*(degrees: float): float =
  result = degrees * PI / 180.0

proc getCustomColorSchema*(cs: array[0..5, float]): array[0..2, float] =
  result = [rand(min(cs[0], cs[1])..max(cs[0], cs[1])),
            rand(min(cs[2], cs[3])..max(cs[2], cs[3])),
            rand(min(cs[4], cs[5])..max(cs[4], cs[5]))]

proc uint8ToColor*(color: array[0..2, float], alpha: float): Color =
  result =  Color(
    r: uint8(color[0]),
    g: uint8(color[1]),
    b: uint8(color[2]),
    a: uint8(alpha))