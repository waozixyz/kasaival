import raylib

type
  PlantNames* = enum
    UnknownPlant = -1, Oak = 0, Sakura


  Level* = object
    music*: string
    tileSize*: float
    tiles*: Vector3
    grow*: seq[PlantNames]

proc initDaisy*(): Level =
  result.music = "StrangerThings.ogg"
  result.tileSize = 18.0
  result.tiles = Vector3(x: 200, y: 3, z: 20)
  result.grow = @[Oak]