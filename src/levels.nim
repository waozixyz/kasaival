type
  PlantNames* = enum
    UnknownPlant = -1, Oak = 0, Sakura


 
  Level* = object
    music*: string
    tileSize*: float = 0.0
    grow*: seq[PlantNames]

proc initDaisy*(): Level =
  result.music = "StrangerThings.ogg"
  result.tileSize = 18.0
  result.grow = @[Oak]